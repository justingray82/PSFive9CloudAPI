# Five9Cloud PowerShell Module
# Function: Remove-Five9CloudTagFromUser
# Category: Tags
function Remove-Five9CloudTagFromUser {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory = $true)][string]$UserUID,
        [Parameter(Mandatory = $true)][string]$TagId
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/acl/v1/domains/$($global:Five9CloudToken.DomainId)/users/$UserUID/tags/$TagId"
    
    try {
        Invoke-RestMethod -Uri $uri -Method Delete -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        }
    } catch {
        Write-Error "Failed to remove tag from user: $_"
    }
}
