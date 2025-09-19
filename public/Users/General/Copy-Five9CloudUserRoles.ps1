# Five9Cloud PowerShell Module
# Function: Copy-Five9CloudUserRoles
# Category: Users
function Copy-Five9CloudUserRoles {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory = $true)][string]$UserUID,
        [string]$FromUser
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/acl/v1/domains/$($global:Five9CloudToken.DomainId)/users/$UserUID/roles:copy"
    
    if ($FromUser) {
        $uri += "?fromUser=$FromUser"
    }
    
    try {
        Invoke-RestMethod -Uri $uri -Method Post -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        } -Body "{}"
    } catch {
        Write-Error "Failed to copy user roles: $_"
    }
}
