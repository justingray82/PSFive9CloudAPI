# Five9Cloud PowerShell Module
# Function: Get-Five9CloudUsersMigrationDetails
# Category: Migration

function Get-Five9CloudUsersMigrationDetails {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)][string]$DomainId = $global:Five9CloudToken.DomainId,
        [string]$Role,
        [string]$Filter,
        [string]$PageCursor,
        [int]$PageLimit,
        [string[]]$Sort,
        [bool]$GetCount
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$DomainId/users/migration"
    
    $queryParams = @{}
    if ($Role) { $queryParams['role'] = $Role }
    if ($Filter) { $queryParams['filter'] = $Filter }
    if ($PageCursor) { $queryParams['pageCursor'] = $PageCursor }
    if ($PageLimit) { $queryParams['pageLimit'] = $PageLimit }
    if ($Sort) { $queryParams['sort'] = $Sort -join ',' }
    if ($PSBoundParameters.ContainsKey('GetCount')) { $queryParams['getCount'] = $GetCount }
    
    if ($queryParams.Count -gt 0) {
        $uri += '?' + ($queryParams.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join '&'
    }
    
    try {
        Invoke-RestMethod -Uri $uri -Method Get -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        }
    } catch {
        Write-Error "Failed to retrieve users migration details: $_"
    }
}
