# Five9Cloud PowerShell Module
# Function: Undo-Five9CloudUserMigration
# Category: Migration

function Undo-Five9CloudUserMigration {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory = $true)][string]$UserUID
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$($global:Five9CloudToken.DomainId)/migration/users/$UserUID:rollback"
    
    try {
        Invoke-RestMethod -Uri $uri -Method Put -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        }
    } catch {
        Write-Error "Failed to rollback user migration: $_"
    }
}
