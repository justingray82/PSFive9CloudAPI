# Five9Cloud PowerShell Module
# Function: Get-Five9CloudMigrationGroupList
# Category: MigrationGroups

function Get-Five9CloudMigrationGroupList {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)][string]$DomainId = $global:Five9CloudToken.DomainId,
        [bool]$UserStats,
        [string]$Type,
        [string]$Filter,
        [string]$PageCursor,
        [int]$PageLimit,
        [string[]]$Sort
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$DomainId/migration-groups"
    
    $queryParams = @{}
    if ($PSBoundParameters.ContainsKey('UserStats')) { $queryParams['userStats'] = $UserStats }
    if ($Type) { $queryParams['type'] = $Type }
    if ($Filter) { $queryParams['filter'] = $Filter }
    if ($PageCursor) { $queryParams['pageCursor'] = $PageCursor }
    if ($PageLimit) { $queryParams['pageLimit'] = $PageLimit }
    if ($Sort) { $queryParams['sort'] = $Sort -join ',' }
    
    if ($queryParams.Count -gt 0) {
        $uri += '?' + ($queryParams.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join '&'
    }
    
    try {
        Invoke-RestMethod -Uri $uri -Method Get -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        }
    } catch {
        Write-Error "Failed to get migration groups: $_"
    }
}
