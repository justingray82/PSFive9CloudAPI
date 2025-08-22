# Five9Cloud PowerShell Module
# Function: Get-Five9CloudSpeedDialList
# Category: SpeedDials

function Get-Five9CloudSpeedDialList {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)][string]$DomainId = $global:Five9CloudToken.DomainId,
        [string]$Filter,
        [string]$PageCursor,
        [int]$PageLimit,
        [string[]]$Sort
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$DomainId/speed-dials"
    
    $queryParams = @{}
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
        Write-Error "Failed to list speed dials: $_"
    }
}
