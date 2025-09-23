function Test-Five9CloudConnection {
    <#
    .SYNOPSIS
    Validates the Five9 Cloud connection and ensures the access token is still valid.
    Automatically reconnects using saved credentials if the token has expired.

    .DESCRIPTION
    This function checks that $global:Five9CloudToken exists and that the token has not expired
    based on the ExpiresIn value returned at authentication. If the token has expired and saved
    credentials exist for the domain, it will automatically attempt to reconnect.

    .PARAMETER Silent
    If specified, suppresses informational messages during auto-reconnection.

    .OUTPUTS
    [bool] True if valid or successfully reconnected, False if unable to connect.

    .EXAMPLE
    Test-Five9CloudConnection
    # Returns true if the connection is valid or was successfully renewed
    # Returns false if unable to establish connection

    .EXAMPLE
    Test-Five9CloudConnection -Silent
    # Same as above but without informational messages
    #>
    
    [CmdletBinding()]
    param (
        [switch]$Silent
    )
    
    # Check if token exists
    if (-not $global:Five9CloudToken) {
        if (-not $Silent) {
            Write-Host "No active Five9 Cloud connection found."
        }
        
        # Try to find and use saved credentials
        $credsFound = $false
        $credsPath = "$env:USERPROFILE\.five9cloud"
        
        if (Test-Path $credsPath) {
            $credFiles = Get-ChildItem -Path $credsPath -Filter "*.cred" | Select-Object -First 1
            if ($credFiles) {
                $domainId = [System.IO.Path]::GetFileNameWithoutExtension($credFiles.Name)
                if (-not $Silent) {
                    Write-Host "Found saved credentials for domain: $domainId. Attempting to connect..."
                }
                
                try {
                    # Attempt to connect with saved credentials
                    Connect-Five9Cloud -ExistingAuthorization $true -DomainId $domainId
                    return $true
                } catch {
                    if (-not $Silent) {
                        Write-Host "Failed to connect with saved credentials. Please run Connect-Five9Cloud manually." -ForegroundColor Yellow
                    }
                    return $false
                }
            }
        }
        
        if (-not $credsFound -and -not $Silent) {
            Write-Host "You must connect first using Connect-Five9Cloud." -ForegroundColor Yellow
        }
        return $false
    }

    # Ensure the token has required properties
    if (-not $global:Five9CloudToken.ExpiresAt -or -not $global:Five9CloudToken.DomainId) {
        if (-not $Silent) {
            Write-Host "Your session token is missing required properties. Please reconnect using Connect-Five9Cloud." -ForegroundColor Yellow
        }
        return $false
    }

    # Check if the token is expired
    $now = Get-Date
    $expiryTime = $global:Five9CloudToken.ExpiresAt
    
    # Add a small buffer (30 seconds) to renew slightly before actual expiry
    $expiryWithBuffer = $expiryTime.AddSeconds(-30)
    
    if ($now -ge $expiryWithBuffer) {
        if (-not $Silent) {
            Write-Host "Five9 Cloud session token has expired or is about to expire. Attempting to reconnect..." -ForegroundColor Yellow
        }
        
        # Attempt to reconnect using saved credentials
        $domainId = $global:Five9CloudToken.DomainId
        $region = $global:Five9CloudToken.Region
        $credsPath = "$env:USERPROFILE\.five9cloud\$domainId.cred"
        
        if (Test-Path $credsPath) {
            try {
                # Store the current connection info
                $previousConnection = @{
                    DomainId = $domainId
                    Region = $region
                }
                
                if (-not $Silent) {
                    Write-Host "Reconnecting to domain $domainId in region $region..."
                }
                
                # Attempt to reconnect with saved credentials
                # We need to modify this to not prompt for saving again
                $originalPreference = $global:ConfirmPreference
                $global:ConfirmPreference = 'None'
                
                # Read the saved credentials to determine auth type
                $credData = Get-Content $credsPath -Raw | ConvertFrom-Json
                
                # Determine which auth method was used
                $authMethod = $null
                if ($credData.ApiControl) { 
                    $authMethod = "ApiControl" 
                } elseif ($credData.CloudAuth) { 
                    $authMethod = "CloudAuth" 
                }
                
                if ($authMethod) {
                    # Call the internal reconnect function
                    $reconnectParams = @{
                        DomainId = $domainId
                        Region = $region
                        CredsPath = $credsPath
                        AuthMethod = $authMethod
                        Silent = $Silent
                    }
                    
                    if (Invoke-AutoReconnect @reconnectParams) {
                        if (-not $Silent) {
                            Write-Host "Successfully reconnected to Five9 Cloud." -ForegroundColor Green
                        }
                        $global:ConfirmPreference = $originalPreference
                        return $true
                    }
                }
                
                $global:ConfirmPreference = $originalPreference
                
                if (-not $Silent) {
                    Write-Host "Failed to reconnect automatically. Please run Connect-Five9Cloud manually." -ForegroundColor Red
                }
                return $false
                
            } catch {
                if (-not $Silent) {
                    Write-Host "Error during auto-reconnection: $_" -ForegroundColor Red
                    Write-Host "Please run Connect-Five9Cloud manually." -ForegroundColor Yellow
                }
                return $false
            }
        } else {
            if (-not $Silent) {
                Write-Host "No saved credentials found for domain $domainId." -ForegroundColor Yellow
                Write-Host "Please run Connect-Five9Cloud to authenticate." -ForegroundColor Yellow
            }
            return $false
        }
    }

    # Token is still valid
    if (-not $Silent) {
        $remainingTime = $expiryTime - $now
        $remainingMinutes = [Math]::Round($remainingTime.TotalMinutes, 1)
        Write-Verbose "Token valid for $remainingMinutes more minutes"
    }
    
    return $true
}

function Invoke-AutoReconnect {
    <#
    .SYNOPSIS
    Internal function to handle automatic reconnection using saved credentials.
    
    .DESCRIPTION
    This internal function performs the actual reconnection using saved credentials
    without prompting for user input.
    
    .PARAMETER DomainId
    The Five9 domain ID to connect to.
    
    .PARAMETER Region
    The Five9 region (us, ca, eu, in, uk).
    
    .PARAMETER CredsPath
    Path to the saved credentials file.
    
    .PARAMETER AuthMethod
    The authentication method to use (ApiControl or CloudAuth).
    
    .PARAMETER Silent
    If specified, suppresses informational messages.
    
    .OUTPUTS
    [bool] True if reconnection successful, False otherwise.
    #>
    
    [CmdletBinding()]
    param (
        [string]$DomainId,
        [string]$Region,
        [string]$CredsPath,
        [string]$AuthMethod,
        [switch]$Silent
    )
    
    try {
        $credData = Get-Content $CredsPath -Raw | ConvertFrom-Json
        $apiBaseUrl = "https://api.prod.$Region.five9.net"
        
        # Perform authentication based on method
        if ($AuthMethod -eq "ApiControl" -and $credData.ApiControl) {
            $authUrl = "$apiBaseUrl/oauth2/v1/token"
            
            $response = Invoke-RestMethod -Uri $authUrl -Method Post -Headers @{
                Authorization = "Basic $($credData.ApiControl)"
            } -ContentType "application/x-www-form-urlencoded" -Body "grant_type=client_credentials"
            
        } elseif ($AuthMethod -eq "CloudAuth" -and $credData.CloudAuth) {
            $authUrl = "$apiBaseUrl/cloudauthsvcs/v1/admin/login"
            
            $body = @{
                grant_type = "client_credentials"
            } | ConvertTo-Json
            
            $response = Invoke-RestMethod -Uri $authUrl -Method Post -Headers @{
                Authorization = "Basic $($credData.CloudAuth)"
                'Content-Type' = 'application/json'
            } -Body $body
            
        } else {
            throw "No valid credentials found for $AuthMethod"
        }
        
        # Update global token
        $global:Five9CloudToken = @{
            AccessToken = $response.access_token
            TokenType = $response.token_type
            ExpiresIn = $response.expires_in
            ExpiresAt = (Get-Date).AddSeconds($response.expires_in)
            DomainId = $DomainId
            Region = $Region
            ApiBaseUrl = $apiBaseUrl
            RestBaseUrl = "https://api.five9.com/restadmin/api"
            RestBasicAuth = $($credData.CloudAuth)

        }
        
        return $true
        
    } catch {
        if (-not $Silent) {
            Write-Verbose "Auto-reconnect failed: $_"
        }
        return $false
    }
}