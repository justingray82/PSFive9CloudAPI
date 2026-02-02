# Five9Cloud PowerShell Module
# Function: Remove-Five9CloudDefaultIdpPolicy
# Category: UserProfiles

function Remove-Five9CloudDefaultIdpPolicy {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory = $true)][string]$IdpPolicyId
    )
    
    if (-not (Test-Five9CloudConnection -AutoReconnect)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$($global:Five9CloudToken.DomainId)/idp-policies/$IdpPolicyId:default"
    
    try {
        Invoke-RestMethod -Uri $uri -Method Delete -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        }
    } catch {
        Write-Error "Failed to remove default IDP policy: $_"
    }
}
