# Five9Cloud PowerShell Module
# Function: Remove-Five9CloudPermissionFromRole
# Category: Roles
function Remove-Five9CloudPermissionFromRole {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory = $true)][string]$Role,
        [Parameter(Mandatory = $true)][string]$Permission
    )
    
    if (-not (Test-Five9CloudConnection -AutoReconnect)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/acl/v1/domains/$($global:Five9CloudToken.DomainId)/roles/$Role/permissions/$Permission"
    
    try {
        Invoke-RestMethod -Uri $uri -Method Delete -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        }
    } catch {
        Write-Error "Failed to remove permission from role: $_"
    }
}
