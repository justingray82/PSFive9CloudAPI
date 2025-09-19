# Five9Cloud PowerShell Module
# Function: Add-Five9CloudPermissionToUserProfile
# Category: UserProfiles
function Add-Five9CloudPermissionToUserProfile {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory = $true)][string]$UserProfileId,
        [Parameter(Mandatory = $true)][string]$Permission
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/acl/v1/domains/$($global:Five9CloudToken.DomainId)/user-profiles/$UserProfileId/permissions/$Permission"
    
    try {
        Invoke-RestMethod -Uri $uri -Method Post -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        } -Body "{}"
    } catch {
        Write-Error "Failed to add permission to user profile: $_"
    }
}
