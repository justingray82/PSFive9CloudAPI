# Five9Cloud PowerShell Module
# Function: Set-Five9CloudDefaultIdpPolicy
# Category: UserProfiles

function Set-Five9CloudDefaultIdpPolicy {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory = $true)][string]$IdpPolicyId
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$($global:Five9CloudToken.DomainId)/idp-policies/$IdpPolicyId:default"
    
    try {
        Invoke-RestMethod -Uri $uri -Method Put -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        }
    } catch {
        Write-Error "Failed to set default IDP policy: $_"
    }
}
