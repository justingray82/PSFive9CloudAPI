# Five9Cloud PowerShell Module
# Function: Get-Five9CloudInternalUserPermissions
# Category: Users
function Get-Five9CloudInternalUserPermissions {
    [CmdletBinding()]
    param ()
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/acl/v1/my-ui-permissions"
    
    try {
        Invoke-RestMethod -Uri $uri -Method Get -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        }
    } catch {
        Write-Error "Failed to list internal user permissions: $_"
    }
}
