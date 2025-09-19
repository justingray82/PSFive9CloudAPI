# Five9Cloud PowerShell Module
# Function: Remove-Five9CloudUserIdpPolicy
# Category: UserManagement

function Remove-Five9CloudUserIdpPolicy {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory = $true)][string]$UserUID,
        [Parameter(Mandatory = $true)][string]$IdpPolicyId
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$($global:Five9CloudToken.DomainId)/users/$UserUID/idp-policies/$IdpPolicyId"
    
    try {
        Invoke-RestMethod -Uri $uri -Method Delete -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        }
    } catch {
        Write-Error "Failed to delete user IDP policy: $_"
    }
}

