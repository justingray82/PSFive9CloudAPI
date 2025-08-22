function Connect-Five9Cloud {
    [CmdletBinding()]
    param (
        [bool]$ExistingAuthorization,
        [Parameter(Mandatory = $true)][string]$DomainId,
        [string]$CustomerKey,
        [string]$SecretId,
        [ValidateSet("us", "ca", "eu", "in", "uk")]
        [string]$Region = "us"
    )

    if (-not $ExistingAuthorization -and (-not $CustomerKey -or -not $SecretId)) {
        throw "CustomerKey and SecretId are required when not using ExistingAuthorization."
    }

    $credsPath = "$env:USERPROFILE\.five9cloud\$DomainId.cred"
    $authString = "${CustomerKey}:${SecretId}"
    $encoded = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($authString))

    if ($ExistingAuthorization) {
        if (-not (Test-Path $credsPath)) {
            throw "No stored credentials found for domain ID '$DomainId'. Please run without -ExistingAuthorization to provide credentials."
        }
        $encoded = Get-Content $credsPath -Raw
    } else {
        $save = Read-Host "Do you want to save these credentials for future use? (y/n)"
        if ($save -match '^(y|yes)$') {
            if (-not (Test-Path (Split-Path $credsPath))) {
                New-Item -ItemType Directory -Path (Split-Path $credsPath) -Force | Out-Null
            }
            Set-Content -Path $credsPath -Value $encoded -Force
            Write-Host "Credentials saved to $credsPath"
        }
    }

    $apiBaseUrl = "https://api.prod.$Region.five9.net"
    $authUrl = "$apiBaseUrl/oauth2/v1/token"

    try {
        $response = Invoke-RestMethod -Uri $authUrl -Method Post -Headers @{
            Authorization = "Basic $encoded"
        } -ContentType "application/x-www-form-urlencoded" -Body "grant_type=client_credentials"

        $global:Five9CloudToken = @{
            AccessToken = $response.access_token
            TokenType = $response.token_type
            ExpiresIn = $response.expires_in
	    ExpiresAt   = (Get-Date).AddSeconds($response.expires_in)
            DomainId = $DomainId
            Region = $Region
            ApiBaseUrl = $apiBaseUrl
        }

        Write-Host "Connected to domain $DomainId in region $Region"
        Write-Host "API Base URL: $apiBaseUrl"
        Write-Host "Access Token Acquired"
    } catch {
        Write-Error "Failed to authenticate with Five9 API: $_"
    }
}
