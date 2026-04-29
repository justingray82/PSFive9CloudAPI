function Connect-Five9Cloud {
    [CmdletBinding(DefaultParameterSetName = 'CloudAuth')]
    param(
        [ValidateSet('us','uk','eu','ca')][string]$Region = 'us',
        [ValidateSet('prod','alpha')][string]$Environment = 'prod',

        [Parameter(ParameterSetName = 'CloudAuth')][string]$Username,
        [Parameter(ParameterSetName = 'CloudAuth')][string]$Password,

        [Parameter(ParameterSetName = 'OAuth', Mandatory)][string]$ClientId,
        [Parameter(ParameterSetName = 'OAuth', Mandatory)][string]$ClientSecret,
        [string]$DomainId,

        [switch]$SkipUpdateCheck
    )

    # ── Auto-update check ──────────────────────────────────────────────────────
    if (-not $SkipUpdateCheck) {
        try {
            Write-Verbose "Checking for PSFive9CloudAPI updates..."
            $psdUrl    = 'https://raw.githubusercontent.com/justingray82/PSFive9CloudAPI/main/PSFive9CloudAPI.psd1'
            $rawPsd1   = (Invoke-WebRequest -Uri $psdUrl -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop).Content
            $remoteVer = [regex]::Match($rawPsd1, "ModuleVersion\s*=\s*'([^']+)'").Groups[1].Value
            $localVer  = (Get-Module PSFive9CloudAPI -ErrorAction SilentlyContinue).Version.ToString()

            if ($remoteVer -and $localVer -and ([version]$remoteVer -gt [version]$localVer)) {
                Write-Verbose "Update available: v$localVer -> v$remoteVer. Downloading..."

                $modulePath = (Get-Module PSFive9CloudAPI -ErrorAction SilentlyContinue).ModuleBase
                if ($modulePath) {
                    $zipUrl  = 'https://github.com/justingray82/PSFive9CloudAPI/archive/refs/heads/main.zip'
                    $tempZip = "$env:TEMP\PSFive9CloudAPI_update.zip"
                    $tempDir = "$env:TEMP\PSFive9CloudAPI_update"

                    Invoke-WebRequest -Uri $zipUrl -OutFile $tempZip -UseBasicParsing -ErrorAction Stop
                    if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force }
                    Expand-Archive -Path $tempZip -DestinationPath $tempDir -Force
                    Remove-Item $tempZip -Force

                    Get-ChildItem "$tempDir\PSFive9CloudAPI-main" -Include '*.ps1','*.psm1','*.psd1' -Recurse |
                        ForEach-Object { Copy-Item $_.FullName -Destination $modulePath -Force }

                    Remove-Item $tempDir -Recurse -Force
                    $script:_Five9NeedsReimport = $true
                    $script:_Five9RemoteVer     = $remoteVer
                    Write-Verbose "Files updated. Will reimport after connecting."
                }
            } else {
                Write-Verbose "PSFive9CloudAPI is current (v$localVer)."
            }
        } catch {
            Write-Verbose "Update check skipped: $_"
        }
    }
    # ──────────────────────────────────────────────────────────────────────────

    # ── Initialise global state ────────────────────────────────────────────────
    $global:Five9 = @{ AccessToken = $null; ExpiresAt = $null; DomainId = $null; ApiBaseUrl = $null; AuthType = $null; AuthParams = @{} }

    $base = "https://api.$Environment.$Region.five9.net"
    $global:Five9.ApiBaseUrl = $base
    $global:Five9.AuthType   = $PSCmdlet.ParameterSetName
    # ──────────────────────────────────────────────────────────────────────────

    # ── Authenticate ───────────────────────────────────────────────────────────
    if ($PSCmdlet.ParameterSetName -eq 'OAuth') {
        $global:Five9.AuthParams = @{ ClientId = $ClientId; ClientSecret = $ClientSecret; Base = $base }
        $ok = Invoke-Five9OAuth $base $ClientId $ClientSecret
    } else {
        if (-not $Username) { $Username = Read-Host 'Username' }
        if (-not $Password) { $Password = Read-Host 'Password' }
        $global:Five9.AuthParams = @{ Username = $Username; Password = $Password; Base = $base }
        $ok = Invoke-Five9CloudAuth $base $Username $Password
    }
    if ($ok -eq $false) { $global:Five9 = @{}; return }
    # ──────────────────────────────────────────────────────────────────────────

    # ── Resolve DomainId via whoami ────────────────────────────────────────────
    try {
        Write-Verbose "Resolving domain ID via whoami..."
        $whoami = Invoke-RestMethod -Uri "$base/users/v1/users/whoami" `
                                    -Headers (Get-Five9CloudAuthHeader) `
                                    -ErrorAction Stop
        $global:Five9.DomainId = $whoami.domainId
        Write-Verbose "Connected as '$($whoami.username)' to domain $($whoami.domainId)."
    } catch {
        Write-Host "Authentication succeeded but failed to resolve domain ID" -ForegroundColor Red
        $global:Five9 = @{}
        return
    }
    # ──────────────────────────────────────────────────────────────────────────

    # ── Reimport if updated ────────────────────────────────────────────────────
    if ($script:_Five9NeedsReimport) {
        $script:_Five9NeedsReimport = $false
        Write-Verbose "Reimporting updated module..."
        Import-Module PSFive9CloudAPI -Force -Global
        Write-Verbose "PSFive9CloudAPI updated to v$($script:_Five9RemoteVer) and active."
    }
    # ──────────────────────────────────────────────────────────────────────────
}