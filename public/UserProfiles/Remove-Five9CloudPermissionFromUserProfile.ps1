# Five9Cloud PowerShell Module
# Function: Remove-Five9CloudPermissionFromUserProfile
# Category: UserProfiles
function Remove-Five9CloudPermissionFromUserProfile {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory = $true)][string]$UserProfileId,
        [Parameter(Mandatory = $true)][string]$Permission
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/acl/v1/domains/$($global:Five9CloudToken.DomainId)/user-profiles/$UserProfileId/permissions/$Permission"
    
    try {
        Invoke-RestMethod -Uri $uri -Method Delete -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        }
    } catch {
        Write-Error "Failed to remove permission from user profile: $_"
    }
}
