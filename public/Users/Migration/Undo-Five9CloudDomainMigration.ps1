# Five9Cloud PowerShell Module
# Function: Undo-Five9CloudDomainMigration
# Category: Migration

function Undo-Five9CloudDomainMigration {
    [CmdletBinding()]
    param (
[string]$DomainId = $global:Five9CloudToken.DomainId
    )
    
    if (-not (Test-Five9CloudConnection -AutoReconnect)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$($global:Five9CloudToken.DomainId)/migration:rollback"
    
    try {
        Invoke-RestMethod -Uri $uri -Method Put -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        }
    } catch {
        Write-Error "Failed to rollback domain migration: $_"
    }
}
