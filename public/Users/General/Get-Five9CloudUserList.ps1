function Get-Five9CloudUserList {
    [CmdletBinding()]
    param (
        [string]$Sort,
        [long]$Offset,
        [long]$Limit,
        [string]$PageCursor,
        [int]$PageLimit = 1000,
        [string]$Filter
    )
    
    if (-not (Test-Five9CloudConnection -AutoReconnect)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$($global:Five9CloudToken.DomainId)/users"
    
    $queryParams = @{}
    if ($Fields) { $queryParams['fields'] = $Fields }
    if ($Sort) { $queryParams['sort'] = $Sort }
    if ($Order) { $queryParams['order'] = $Order }
    if ($PSBoundParameters.ContainsKey('Offset')) { $queryParams['offset'] = $Offset }
    if ($PSBoundParameters.ContainsKey('Limit')) { $queryParams['limit'] = $Limit }
    if ($PageCursor) { $queryParams['pageCursor'] = $PageCursor }
    if ($PageLimit) { $queryParams['pageLimit'] = $PageLimit }
    if ($Filter) { $queryParams['filter'] = $Filter }
    
    if ($queryParams.Count -gt 0) {
        $queryString = ($queryParams.GetEnumerator() | ForEach-Object { 
            "$($_.Key)=$([System.Web.HttpUtility]::UrlEncode($_.Value))" 
        }) -join '&'
        $uri += "?$queryString"
    }
    
    try {
        Invoke-RestMethod -Uri $uri -Method Get -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
        }
    } catch {
        Write-Error "Failed to list users: $_"
    }
}