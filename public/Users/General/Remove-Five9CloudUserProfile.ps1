# Five9Cloud PowerShell Module
# Function: Remove-Five9CloudUserProfile
# Category: General

function Remove-Five9CloudUserProfile {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory = $true)][string]$UserProfileId,
        [Parameter(Mandatory = $true)][string]$UserUID
    )
    
    if (-not (Test-Five9CloudConnection -AutoReconnect)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$($global:Five9CloudToken.DomainId)/user-profiles/$UserProfileId/users/$UserUID"
    
    try {
        Invoke-RestMethod -Uri $uri -Method Delete -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        }
    } catch {
        Write-Error "Failed to disassociate user profile: $_"
    }
}
