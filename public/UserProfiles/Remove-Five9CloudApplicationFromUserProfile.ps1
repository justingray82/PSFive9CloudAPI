# Five9Cloud PowerShell Module
# Function: Remove-Five9CloudApplicationFromUserProfile
# Category: UserProfiles
function Remove-Five9CloudApplicationFromUserProfile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)][string]$DomainId = $global:Five9CloudToken.DomainId,
        [Parameter(Mandatory = $true)][string]$UserProfileId,
        [Parameter(Mandatory = $true)][string]$AppId
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/acl/v1/domains/$DomainId/user-profiles/$UserProfileId/applications/$AppId"
    
    try {
        Invoke-RestMethod -Uri $uri -Method Delete -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        }
    } catch {
        Write-Error "Failed to remove application from user profile: $_"
    }
}
