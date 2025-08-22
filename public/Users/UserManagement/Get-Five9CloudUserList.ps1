# Five9Cloud PowerShell Module
# Function: Get-Five9CloudUserList
# Category: UserManagement

function Get-Five9CloudUserList {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)][string]$DomainId = $global:Five9CloudToken.DomainId,
        [string]$Fields,
        [string[]]$UserUID,
        [string[]]$UserId,
        [string]$Role,
        [string]$Filter,
        [string]$PageCursor,
        [int]$PageLimit,
        [string[]]$Sort
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$DomainId/users"
    
    $queryParams = @{}
    if ($Fields) { $queryParams['fields'] = $Fields }
    if ($UserUID) { $queryParams['userUID'] = $UserUID -join ',' }
    if ($UserId) { $queryParams['userId'] = $UserId -join ',' }
    if ($Role) { $queryParams['role'] = $Role }
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
        Write-Error "Failed to list users: $_"
    }
}
