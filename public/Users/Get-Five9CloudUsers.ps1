# Five9Cloud PowerShell Module
# Function: Get-Five9CloudUsers
# Category: Users
function Get-Five9CloudUsers {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)][string]$DomainId = $global:Five9CloudToken.DomainId,
        [string]$UserUID,
        [string]$Role,
        [string]$Filter,
        [int]$PageLimit,
        [string]$PageCursor
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/acl/v1/domains/$DomainId/users"
    
    $queryParams = @{}
    if ($UserUID) { $queryParams['userUID'] = $UserUID }
    if ($Role) { $queryParams['role'] = $Role }
    if ($Filter) { $queryParams['filter'] = $Filter }
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
        Write-Error "Failed to retrieve users: $_"
    }
}
