function Get-Five9CloudUserList {
    [CmdletBinding()]
    param (
        [string]$Sort,
        [long]$Offset,
        [long]$Limit,
        [string]$PageCursor,
        [int]$PageLimit = 1000,
        [string]$Filter,
        [switch]$NoPagination
    )
    
    if (-not (Test-Five9CloudConnection -AutoReconnect)) { return }
    
    $baseUri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$($global:Five9CloudToken.DomainId)/users"
    
    # Build initial query parameters
    $queryParams = @{}
    if ($Sort) { $queryParams['sort'] = $Sort }
    if ($PSBoundParameters.ContainsKey('Offset')) { $queryParams['offset'] = $Offset }
    if ($PSBoundParameters.ContainsKey('Limit')) { $queryParams['limit'] = $Limit }
    if ($PageCursor) { $queryParams['pageCursor'] = $PageCursor }
    if ($PageLimit) { $queryParams['pageLimit'] = $PageLimit }
    if ($Filter) { $queryParams['filter'] = $Filter }
    
    $allResults = @()
    $nextPagePath = $null
    $pageCount = 0
    
    try {
        do {
            $pageCount++
            Write-Verbose "Fetching page $pageCount..."
            
            # Build URI
            if ($nextPagePath) {
                # Use the full path returned by the API
                $uri = "$($global:Five9CloudToken.ApiBaseUrl)$nextPagePath"
            } else {
                # First request - build from parameters
                $uri = $baseUri
                if ($queryParams.Count -gt 0) {
                    $queryString = ($queryParams.GetEnumerator() | ForEach-Object { 
                        "$($_.Key)=$([System.Web.HttpUtility]::UrlEncode($_.Value))" 
                    }) -join '&'
                    $uri += "?$queryString"
                }
            }
            
            Write-Verbose "Request URI: $uri"
            
            # Make API request
            $response = Invoke-RestMethod -Uri $uri -Method Get -Headers @{
                Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            }
            
            # Collect results
            $pageResults = $null
            if ($response.users) {
                $pageResults = $response.users
            } elseif ($response.items) {
                $pageResults = $response.items
            } elseif ($response.data) {
                $pageResults = $response.data
            } elseif ($response -is [Array]) {
                $pageResults = $response
            }
            
            if ($pageResults) {
                $allResults += $pageResults
                Write-Verbose "Retrieved $($pageResults.Count) users on page $pageCount (Total: $($allResults.Count))"
            }
            
            # Get next page path from paging.next
            $nextPagePath = $null
            if ($response.paging -and $response.paging.next) {
                $nextPagePath = $response.paging.next
                Write-Verbose "Next page path: $nextPagePath"
            }
            
            # Break if NoPagination switch is used or no more pages
            if ($NoPagination -or -not $nextPagePath) {
                break
            }
            
        } while ($nextPagePath)
        
        Write-Verbose "Pagination complete. Total records retrieved: $($allResults.Count)"
        
        return $allResults
        
    } catch {
        Write-Error "Failed to list users: $_"
        Write-Error $_.Exception.Message
    }
}