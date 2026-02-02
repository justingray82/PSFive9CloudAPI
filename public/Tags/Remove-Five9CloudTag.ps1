# Five9Cloud PowerShell Module
# Function: Remove-Five9CloudTag
# Category: Tags
function Remove-Five9CloudTag {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory = $true)][string]$TagId
    )
    
    if (-not (Test-Five9CloudConnection -AutoReconnect)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/acl/v1/domains/$($global:Five9CloudToken.DomainId)/tags/$TagId"
    
    try {
        Invoke-RestMethod -Uri $uri -Method Delete -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        }
    } catch {
        Write-Error "Failed to delete tag: $_"
    }
}
