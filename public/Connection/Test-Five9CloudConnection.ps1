function Test-Five9CloudConnection {
    [CmdletBinding()]
    param (
        [ValidateSet('Any', 'ApiAccessControl', 'CloudAuth', 'RestApi')]
        [string]$AuthType = 'Any',
        
        [switch]$AutoReconnect,
        [switch]$Silent
    )
    
    # Check if basic connection info exists
    if (-not $global:Five9CloudToken.DomainId) {
        if (-not $Silent) {
            Write-Warning "Not connected to Five9 Cloud. Please run Connect-Five9Cloud first."
        }
        return $false
    }
    
    # Determine which auth type to check
    $typesToCheck = @()
    if ($AuthType -eq 'Any') {
        if ($global:Five9CloudToken.ApiAccessControl) { $typesToCheck += 'ApiAccessControl' }
        if ($global:Five9CloudToken.CloudAuth) { $typesToCheck += 'CloudAuth' }
        if ($global:Five9CloudToken.RestApi) { $typesToCheck += 'RestApi' }
    }
    else {
        $typesToCheck = @($AuthType)
    }
    
    if ($typesToCheck.Count -eq 0) {
        if (-not $Silent) {
            Write-Warning "Not connected to Five9 Cloud. Please run Connect-Five9Cloud first."
        }
        return $false
    }
    
    $allValid = $true
    
    foreach ($type in $typesToCheck) {
        $isValid = $false
        
        switch ($type) {
            'ApiAccessControl' {
                if ($global:Five9CloudToken.ApiAccessControl) {
                    if ($global:Five9CloudToken.ApiAccessControl.ExpiresAt) {
                        if ((Get-Date) -lt $global:Five9CloudToken.ApiAccessControl.ExpiresAt) {
                            $isValid = $true
                            Write-Verbose "API Access Control token is valid"
                        }
                        else {
                            if (-not $Silent) {
                                Write-Verbose "API Access Control token has expired"
                            }
                            
                            if ($AutoReconnect) {
                                $isValid = Reconnect-Five9Cloud -AuthType 'ApiAccessControl'
                            }
                        }
                    }
                }
            }
            
            'CloudAuth' {
                if ($global:Five9CloudToken.CloudAuth) {
                    if ($global:Five9CloudToken.CloudAuth.ExpiresAt) {
                        if ((Get-Date) -lt $global:Five9CloudToken.CloudAuth.ExpiresAt) {
                            $isValid = $true
                            Write-Verbose "CloudAuth token is valid"
                        }
                        else {
                            if (-not $Silent) {
                                Write-Verbose "CloudAuth token has expired"
                            }
                            
                            if ($AutoReconnect) {
                                $isValid = Reconnect-Five9Cloud -AuthType 'CloudAuth'
                            }
                        }
                    }
                }
            }
            
            'RestApi' {
                if ($global:Five9CloudToken.RestApi -and $global:Five9CloudToken.RestApi.Authorization) {
                    $isValid = $true
                    Write-Verbose "REST API credentials are present"
                }
                else {
                    if (-not $Silent) {
                        Write-Warning "REST API credentials not found"
                    }
                }
            }
        }
        
        if (-not $isValid) {
            $allValid = $false
        }
    }
    
    if (-not $allValid -and -not $AutoReconnect -and -not $Silent) {
        Write-Host "Authentication expired or not established. Please run Connect-Five9Cloud to authenticate." -ForegroundColor Yellow
    }
    
    return $allValid
}
#endregion

#region Reconnection Function
function Reconnect-Five9Cloud {
    param (
        [ValidateSet('ApiAccessControl', 'CloudAuth')]
        [string]$AuthType
    )
    
    Write-Verbose "Attempting to reconnect to $AuthType..."
    
    $domainId = $global:Five9CloudToken.DomainId
    if (-not $domainId) {
        Write-Warning "No domain ID found. Cannot auto-reconnect."
        return $false
    }
    
    # Try to load saved credentials
    $savedCreds = Load-Five9CloudCredentials -DomainId $domainId -AuthType $AuthType
    
    if ($savedCreds) {
        Write-Verbose "Found saved credentials, attempting reconnection..."
        
        # Update region and ApiBaseUrl
        if ($savedCreds.Region) {
            $global:Five9CloudToken.Region = $savedCreds.Region
            $global:Five9CloudToken.ApiBaseUrl = "https://api.prod.$($savedCreds.Region).five9.net"
        }
        
        if ($AuthType -eq 'ApiAccessControl') {
            return Connect-ApiAccessControl -DomainId $domainId `
                                           -Region $savedCreds.Region `
                                           -ClientId $savedCreds.ClientId `
                                           -ClientSecret $savedCreds.ClientSecret
        }
        else {
            $cloudAuthResult = Connect-CloudAuth -DomainId $domainId `
                                                -Region $savedCreds.Region `
                                                -Username $savedCreds.Username `
                                                -Password $savedCreds.Password
            
            # Also reconnect REST API if it was previously connected
            if ($cloudAuthResult -and $global:Five9CloudToken.RestApi) {
                $restResult = Connect-RestApi -Username $savedCreds.Username `
                                            -Password $savedCreds.Password
                return $cloudAuthResult -and $restResult
            }
            
            return $cloudAuthResult
        }
    }
    else {
        Write-Warning "No saved credentials found for auto-reconnection."
        Write-Host "Please run Connect-Five9Cloud to re-authenticate." -ForegroundColor Yellow
        return $false
    }
}