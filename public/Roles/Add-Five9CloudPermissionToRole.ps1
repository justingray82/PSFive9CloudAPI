# Five9Cloud PowerShell Module
# Function: Add-Five9CloudPermissionToRole
# Category: Roles
function Add-Five9CloudPermissionToRole {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory = $true)][string]$Role,
        [Parameter(Mandatory = $true)][string]$Permission
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/acl/v1/domains/$($global:Five9CloudToken.DomainId)/roles/$Role/permissions/$Permission"
    
    try {
        Invoke-RestMethod -Uri $uri -Method Post -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        } -Body "{}"
    } catch {
        Write-Error "Failed to add permission to role: $_"
    }
}
