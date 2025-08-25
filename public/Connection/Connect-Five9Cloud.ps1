function Connect-Five9Cloud {
    [CmdletBinding(DefaultParameterSetName = 'Interactive')]
    param (
        [Parameter(ParameterSetName = 'ExistingAuth')]
        [bool]$ExistingAuthorization,
        
        [Parameter(Mandatory = $true)]
        [string]$DomainId,
        
        [Parameter(ParameterSetName = 'ApiControl')]
        [Parameter(ParameterSetName = 'Interactive')]
        [string]$CustomerKey,
        
        [Parameter(ParameterSetName = 'ApiControl')]
        [Parameter(ParameterSetName = 'Interactive')]
        [string]$SecretId,
        
        [Parameter(ParameterSetName = 'CloudAuth')]
        [Parameter(ParameterSetName = 'Interactive')]
        [string]$Username,
        
        [Parameter(ParameterSetName = 'CloudAuth')]
        [Parameter(ParameterSetName = 'Interactive')]
        [string]$Password,
        
        [Parameter(ParameterSetName = 'ApiControl')]
        [Parameter(ParameterSetName = 'CloudAuth')]
        [Parameter(ParameterSetName = 'Interactive')]
        [Parameter(ParameterSetName = 'ExistingAuth')]
        [ValidateSet("ApiControl", "CloudAuth")]
        [string]$AuthEndpoint,
        
        [ValidateSet("us", "ca", "eu", "in", "uk")]
        [string]$Region = "us"
    )

    $credsPath = "$env:USERPROFILE\.five9cloud\$DomainId.cred"
    $apiBaseUrl = "https://api.prod.$Region.five9.net"

    # Handle existing authorization
    if ($PSCmdlet.ParameterSetName -eq 'ExistingAuth' -and $ExistingAuthorization) {
        if (-not (Test-Path $credsPath)) {
            throw "No stored credentials found for domain ID '$DomainId'. Please run without -ExistingAuthorization to provide credentials."
        }
        
        try {
            $credData = Get-Content $credsPath -Raw | ConvertFrom-Json
            
            # Determine which auth method to use
            $authMethod = $AuthEndpoint
            if (-not $authMethod) {
                # If no AuthEndpoint specified, check what's available and choose
                $availableMethods = @()
                if ($credData.ApiControl) { $availableMethods += "ApiControl" }
                if ($credData.CloudAuth) { $availableMethods += "CloudAuth" }
                
                if ($availableMethods.Count -eq 0) {
                    throw "No valid credentials found in stored file."
                } elseif ($availableMethods.Count -eq 1) {
                    $authMethod = $availableMethods[0]
                    Write-Host "Using stored $authMethod credentials"
                } else {
                    Write-Host "Multiple stored credentials found. Choose authentication method:"
                    for ($i = 0; $i -lt $availableMethods.Count; $i++) {
                        Write-Host "$($i + 1). $($availableMethods[$i])"
                    }
                    do {
                        $choice = Read-Host "Enter choice (1-$($availableMethods.Count))"
                    } while ($choice -notin (1..$availableMethods.Count))
                    $authMethod = $availableMethods[$choice - 1]
                }
            }
            
            # Use the selected auth method
            if ($authMethod -eq "ApiControl" -and $credData.ApiControl) {
                $result = Invoke-ApiControlAuth -ApiBaseUrl $apiBaseUrl -EncodedCreds $credData.ApiControl
            } elseif ($authMethod -eq "CloudAuth" -and $credData.CloudAuth) {
                $result = Invoke-CloudAuth -ApiBaseUrl $apiBaseUrl -EncodedCreds $credData.CloudAuth
            } else {
                throw "No stored credentials found for $authMethod authentication method."
            }
            
            Set-GlobalToken -TokenData $result -DomainId $DomainId -Region $Region -ApiBaseUrl $apiBaseUrl
            Write-Host "Connected using stored $authMethod credentials for domain $DomainId in region $Region"
            return
        } catch {
            Write-Error "Failed to authenticate with stored credentials: $_"
            return
        }
    }

    # Interactive mode - determine auth method if not specified
    if ($PSCmdlet.ParameterSetName -eq 'Interactive' -and -not $AuthEndpoint) {
        Write-Host "Choose authentication method:"
        Write-Host "1. API Control (OAuth2 with CustomerKey/SecretId)"
        Write-Host "2. Cloud Auth (Username/Password)"
        
        do {
            $choice = Read-Host "Enter choice (1 or 2)"
        } while ($choice -notin @('1', '2'))
        
        $AuthEndpoint = if ($choice -eq '1') { 'ApiControl' } else { 'CloudAuth' }
    }
    
    # Set default auth endpoint for parameter sets if not specified
    if (-not $AuthEndpoint) {
        if ($PSCmdlet.ParameterSetName -eq 'ApiControl') {
            $AuthEndpoint = 'ApiControl'
        } elseif ($PSCmdlet.ParameterSetName -eq 'CloudAuth') {
            $AuthEndpoint = 'CloudAuth'
        }
    }

    # Collect credentials based on auth method
    if ($AuthEndpoint -eq 'ApiControl' -or $PSCmdlet.ParameterSetName -eq 'ApiControl') {
        if (-not $CustomerKey -or -not $SecretId) {
            if (-not $CustomerKey) {
                $CustomerKey = Read-Host "Enter CustomerKey"
            }
            if (-not $SecretId) {
                $SecretId = Read-Host "Enter SecretId" -AsSecureString
                $SecretId = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecretId))
            }
        }
        
        $authString = "${CustomerKey}:${SecretId}"
        $encodedCreds = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($authString))
        $authType = "ApiControl"
        
        try {
            $result = Invoke-ApiControlAuth -ApiBaseUrl $apiBaseUrl -EncodedCreds $encodedCreds
        } catch {
            Write-Error "Failed to authenticate with API Control: $_"
            return
        }
        
    } elseif ($AuthEndpoint -eq 'CloudAuth' -or $PSCmdlet.ParameterSetName -eq 'CloudAuth') {
        if (-not $Username -or -not $Password) {
            if (-not $Username) {
                $Username = Read-Host "Enter Username"
            }
            if (-not $Password) {
                $Password = Read-Host "Enter Password" -AsSecureString
                $Password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password))
            }
        }
        
        $authString = "${Username}:${Password}"
        $encodedCreds = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($authString))
        $authType = "CloudAuth"
        
        try {
            $result = Invoke-CloudAuth -ApiBaseUrl $apiBaseUrl -EncodedCreds $encodedCreds
        } catch {
            Write-Error "Failed to authenticate with Cloud Auth: $_"
            return
        }
    }

    # Set global token
    Set-GlobalToken -TokenData $result -DomainId $DomainId -Region $Region -ApiBaseUrl $apiBaseUrl

    # Offer to save credentials
    $save = Read-Host "Do you want to save these credentials for future use? (y/n)"
    if ($save -match '^(y|yes)$') {
        # Read existing credentials if they exist
        $credData = @{}
        if (Test-Path $credsPath) {
            try {
                $credData = Get-Content $credsPath -Raw | ConvertFrom-Json -AsHashtable
            } catch {
                Write-Warning "Could not read existing credential file. Creating new one."
                $credData = @{}
            }
        }
        
        # Add/update the current auth method
        $credData[$authType] = $encodedCreds
        
        if (-not (Test-Path (Split-Path $credsPath))) {
            New-Item -ItemType Directory -Path (Split-Path $credsPath) -Force | Out-Null
        }
        
        Set-Content -Path $credsPath -Value ($credData | ConvertTo-Json) -Force
        Write-Host "Credentials saved to $credsPath"
    }

    Write-Host "Connected to domain $DomainId in region $Region using $authType"
    Write-Host "API Base URL: $apiBaseUrl"
    Write-Host "Access Token Acquired"
}

function Invoke-ApiControlAuth {
    param (
        [string]$ApiBaseUrl,
        [string]$EncodedCreds
    )
    
    $authUrl = "$ApiBaseUrl/oauth2/v1/token"
    
    $response = Invoke-RestMethod -Uri $authUrl -Method Post -Headers @{
        Authorization = "Basic $EncodedCreds"
    } -ContentType "application/x-www-form-urlencoded" -Body "grant_type=client_credentials"
    
    return $response
}

function Invoke-CloudAuth {
    param (
        [string]$ApiBaseUrl,
        [string]$EncodedCreds
    )
    
    # Five9 Cloud Auth endpoint
    $authUrl = "$ApiBaseUrl/cloudauthsvcs/v1/admin/login"
    
    # Create JSON body with grant_type
    $body = @{
        grant_type = "client_credentials"
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri $authUrl -Method Post -Headers @{
        Authorization = "Basic $EncodedCreds"
        'Content-Type' = 'application/json'
    } -Body $body
    
    return $response
}

function Set-GlobalToken {
    param (
        [object]$TokenData,
        [string]$DomainId,
        [string]$Region,
        [string]$ApiBaseUrl
    )
    
    $global:Five9CloudToken = @{
        AccessToken = $TokenData.access_token
        TokenType = $TokenData.token_type
        ExpiresIn = $TokenData.expires_in
        ExpiresAt = (Get-Date).AddSeconds($TokenData.expires_in)
        DomainId = $DomainId
        Region = $Region
        ApiBaseUrl = $ApiBaseUrl
    }
}