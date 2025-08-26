# Five9Cloud PowerShell Module
# Function: Add-Five9CloudApplicationToUserProfile
# Category: UserProfiles
function Add-Five9CloudApplicationToUserProfile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)][string]$DomainId = $global:Five9CloudToken.DomainId,
        [Parameter(Mandatory = $true)][string]$UserProfileId,
        [Parameter(Mandatory = $true)][string]$AppId
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/acl/v1/domains/$DomainId/user-profiles/$UserProfileId/applications/$AppId"
    
    try {
        Invoke-RestMethod -Uri $uri -Method Post -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        } -Body "{}"
    } catch {
        Write-Error "Failed to add application to user profile: $_"
    }
}
