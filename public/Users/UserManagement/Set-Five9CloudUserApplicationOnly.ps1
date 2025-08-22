# Five9Cloud PowerShell Module
# Function: Set-Five9CloudUserApplicationOnly
# Category: UserManagement

function Set-Five9CloudUserApplicationOnly {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)][string]$DomainId = $global:Five9CloudToken.DomainId,
        [Parameter(Mandatory = $true)][string]$UserUID
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$DomainId/users/$UserUID:make-app-only-user"
    
    try {
        Invoke-RestMethod -Uri $uri -Method Put -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        }
    } catch {
        Write-Error "Failed to make application only user: $_"
    }
}
