# Five9Cloud PowerShell Module
# Function: Disable-Five9CloudDomainMigration
# Category: Migration

function Disable-Five9CloudDomainMigration {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)][string]$DomainId = $global:Five9CloudToken.DomainId,
        [Parameter(Mandatory = $true)]
        [ValidateSet('administrators', 'supervisors', 'agents', 'allUsers')]
        [string]$UserType
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$DomainId/migration/$UserType`:pause"
    
    try {
        Invoke-RestMethod -Uri $uri -Method Put -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        }
    } catch {
        Write-Error "Failed to disable domain migration: $_"
    }
}
