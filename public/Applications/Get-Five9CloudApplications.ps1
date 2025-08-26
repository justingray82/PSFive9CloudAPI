# Five9Cloud PowerShell Module
# Function: Get-Five9CloudApplications
# Category: Applications
function Get-Five9CloudApplications {
    [CmdletBinding()]
    param (
        [string]$Filter,
        [string]$Sort,
        [int]$PageLimit,
        [string]$PageCursor
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/acl/v1/applications"
    
    $queryParams = @{}
    if ($Filter) { $queryParams['filter'] = $Filter }
    if ($Sort) { $queryParams['sort'] = $Sort }
    if ($PageLimit) { $queryParams['pageLimit'] = $PageLimit }
    if ($PageCursor) { $queryParams['pageCursor'] = $PageCursor }
    
    if ($queryParams.Count -gt 0) {
        $uri += '?' + ($queryParams.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join '&'
    }
    
    try {
        Invoke-RestMethod -Uri $uri -Method Get -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        }
    } catch {
        Write-Error "Failed to list applications: $_"
    }
}
