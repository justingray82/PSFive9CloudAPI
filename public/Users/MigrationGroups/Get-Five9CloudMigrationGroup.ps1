# Five9Cloud PowerShell Module
# Function: Get-Five9CloudMigrationGroup
# Category: MigrationGroups

function Get-Five9CloudMigrationGroup {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)][string]$DomainId = $global:Five9CloudToken.DomainId,
        [Parameter(Mandatory = $true)][string]$GroupId,
        [bool]$UserStats
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$DomainId/migration-groups/$GroupId"
    
    if ($PSBoundParameters.ContainsKey('UserStats')) {
        $uri += "?userStats=$UserStats"
    }
    
    try {
        Invoke-RestMethod -Uri $uri -Method Get -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        }
    } catch {
        Write-Error "Failed to get migration group: $_"
    }
}
