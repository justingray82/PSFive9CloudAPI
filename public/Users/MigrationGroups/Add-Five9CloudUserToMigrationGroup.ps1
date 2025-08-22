# Five9Cloud PowerShell Module
# Function: Add-Five9CloudUserToMigrationGroup
# Category: MigrationGroups

function Add-Five9CloudUserToMigrationGroup {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)][string]$DomainId = $global:Five9CloudToken.DomainId,
        [Parameter(Mandatory = $true)][string]$GroupId,
        [Parameter(Mandatory = $true)][string]$UserUID
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$DomainId/migration-groups/$GroupId/users/$UserUID"
    
    try {
        Invoke-RestMethod -Uri $uri -Method Put -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        }
    } catch {
        Write-Error "Failed to assign user to migration group: $_"
    }
}
