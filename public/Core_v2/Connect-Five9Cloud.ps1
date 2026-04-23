function Connect-Five9Cloud {
    [CmdletBinding(DefaultParameterSetName = 'CloudAuth')]
    param(
        [ValidateSet('us','uk','eu','ca')][string]$Region = 'us',
        [ValidateSet('prod','alpha')][string]$Environment = 'prod',
        [string]$DomainId,

        [Parameter(ParameterSetName = 'CloudAuth')][string]$Username,
        [Parameter(ParameterSetName = 'CloudAuth')][string]$Password,

        [Parameter(ParameterSetName = 'OAuth', Mandatory)][string]$ClientId,
        [Parameter(ParameterSetName = 'OAuth', Mandatory)][string]$ClientSecret,

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
                Write-Verbose "Update available: v$localVer -> v$remoteVer. Starting background install..."
                Start-Job -Name 'PSFive9Update' -ScriptBlock {
                    Invoke-Expression (Invoke-RestMethod 'https://raw.githubusercontent.com/justingray82/PSFive9CloudAPI/main/Install-PSFive9CloudAPI.ps1')
                } | Out-Null
                Write-Warning "PSFive9CloudAPI v$remoteVer installed in background. Run 'Import-Module PSFive9CloudAPI -Force' to activate."
            } else {
                Write-Verbose "PSFive9CloudAPI is current (v$localVer)."
            }
        } catch {
            Write-Verbose "Update check skipped: $_"
        }
    }
    # ──────────────────────────────────────────────────────────────────────────

    $global:Five9 = @{ AccessToken = $null; ExpiresAt = $null; DomainId = $null; ApiBaseUrl = $null; AuthType = $null; AuthParams = @{} }

    $base = "https://api.$Environment.$Region.five9.net"
    $global:Five9.ApiBaseUrl = $base
    $global:Five9.AuthType   = $PSCmdlet.ParameterSetName

    # ── Authenticate ──────────────────────────────────────────────────────────
    if ($PSCmdlet.ParameterSetName -eq 'OAuth') {
        $global:Five9.AuthParams = @{ ClientId = $ClientId; ClientSecret = $ClientSecret; Base = $base }
        $ok = Invoke-Five9OAuth $base $ClientId $ClientSecret
    } else {
        if (-not $Username) { $Username = Read-Host 'Username' }
        if (-not $Password) { $Password = Read-Host 'Password' }
        $global:Five9.AuthParams = @{ Username = $Username; Password = $Password; Base = $base }
        $ok = Invoke-Five9CloudAuth $base $Username $Password
    }
    if ($ok -eq $false) { return }
    # ──────────────────────────────────────────────────────────────────────────

    # ── Discover DomainId via whoami ──────────────────────────────────────────
    try {
        Write-Verbose "Resolving domain ID via whoami..."
        $whoami = Invoke-RestMethod -Uri "$base/users/v1/users/whoami" `
                                    -Headers (Get-Five9CloudAuthHeader) `
                                    -ErrorAction Stop
        $global:Five9.DomainId = $whoami.domainId
        Write-Verbose "Connected as '$($whoami.username)' to domain $($whoami.domainId)."
    } catch {
        Write-Error "Authentication succeeded but failed to resolve domain ID: $_"
        $global:Five9 = @{}
        return
    }
    # ──────────────────────────────────────────────────────────────────────────
}