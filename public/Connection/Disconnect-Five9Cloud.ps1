function Disconnect-Five9Cloud {
    [CmdletBinding()]
    param (
        [switch]$KeepSavedCredentials
    )
    
    $domainId = $global:Five9CloudToken.DomainId
    
    # Clear all tokens
    $global:Five9CloudToken = @{
        ApiAccessControl = $null
        CloudAuth = $null
        RestApi = $null
        ApiBaseUrl = $null
        RestBaseUrl = "https://api.five9.com/restadmin/api"
        AccessToken = $null
        Authorization = $null
        DomainId = $null
        Region = $null
        ActiveAuthType = $null
        ExpiresAt = $null
    }
    
    Write-Host "Disconnected from Five9 Cloud" -ForegroundColor Green
    
    if (-not $KeepSavedCredentials -and $domainId) {
        $remove = Read-Host "Remove saved credentials? (Y/N)"
        if ($remove -eq 'Y') {
            Remove-Five9CloudCredentials -DomainId $domainId
        }
    }
}