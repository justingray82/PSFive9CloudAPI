# Five9Cloud PowerShell Module
# Function: Get-Five9CloudProfileUsers
# Category: UserProfiles

function Get-Five9CloudProfileUsers {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)][string]$DomainId = $global:Five9CloudToken.DomainId,
        [Parameter(Mandatory = $true)][string]$UserProfileId,
        [string]$PageCursor,
        [int]$PageLimit,
        [string[]]$Sort
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$DomainId/user-profiles/$UserProfileId/users"
    
    $queryParams = @{}
    if ($PageCursor) { $queryParams['pageCursor'] = $PageCursor }
    if ($PageLimit) { $queryParams['pageLimit'] = $PageLimit }
    if ($Sort) { $queryParams['sort'] = $Sort -join ',' }
    
    if ($queryParams.Count -gt 0) {
        $uri += '?' + ($queryParams.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join '&'
    }
    
    try {Invoke-RestMethod -Uri $uri -Method Get -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        }
    } catch {
        Write-Error "Failed to get IDP policies: $_"
    }
}
