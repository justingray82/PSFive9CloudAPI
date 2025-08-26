# Five9Cloud PowerShell Module
# Function: Get-Five9CloudDomainApplications
# Category: Applications
function Get-Five9CloudDomainApplications {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)][string]$DomainId = $global:Five9CloudToken.DomainId,
        [string]$Status,
        [string[]]$Id,
        [string]$Filter,
        [string]$Sort,
        [bool]$ApiOnly,
        [int]$PageLimit,
        [string]$PageCursor
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/acl/v1/domains/$DomainId/applications"
    
    $queryParams = @{}
    if ($Status) { $queryParams['status'] = $Status }
    if ($Id) { $queryParams['id'] = $Id -join ',' }
    if ($Filter) { $queryParams['filter'] = $Filter }
    if ($Sort) { $queryParams['sort'] = $Sort }
    if ($PSBoundParameters.ContainsKey('ApiOnly')) { $queryParams['apiOnly'] = $ApiOnly }
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
        Write-Error "Failed to list domain applications: $_"
    }
}
