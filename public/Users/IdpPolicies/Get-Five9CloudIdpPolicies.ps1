# Five9Cloud PowerShell Module
# Function: Get-Five9CloudIdpPolicies
# Category: IdpPolicies

function Get-Five9CloudIdpPolicies {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)][string]$DomainId = $global:Five9CloudToken.DomainId,
        [bool]$IncludeOrgPolicies,
        [bool]$DefaultPolicy,
        [bool]$GetCount,
        [string]$Fields,
        [string[]]$Sort,
        [int]$PageLimit,
        [string]$PageCursor
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$DomainId/idp-policies"
    
    $queryParams = @{}
    if ($PSBoundParameters.ContainsKey('IncludeOrgPolicies')) { $queryParams['includeOrgPolicies'] = $IncludeOrgPolicies }
    if ($PSBoundParameters.ContainsKey('DefaultPolicy')) { $queryParams['defaultPolicy'] = $DefaultPolicy }
    if ($PSBoundParameters.ContainsKey('GetCount')) { $queryParams['getCount'] = $GetCount }
    if ($Fields) { $queryParams['fields'] = $Fields }
    if ($Sort) { $queryParams['sort'] = $Sort -join ',' }
    if ($PageLimit) { $queryParams['pageLimit'] = $PageLimit }
    if ($PageCursor) { $queryParams['pageCursor'] = $PageCursor }
    
    if ($queryParams.Count -gt 0) {
        $uri += '?' + ($queryParams.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join '&'
    }
    
    try {
        Invoke-RestMethod -Uri $uri -Method Put -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        }
    } catch {
        Write-Error "Failed to rollback user migration: $_"
    }
}
