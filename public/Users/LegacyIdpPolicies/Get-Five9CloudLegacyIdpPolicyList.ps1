# Five9Cloud PowerShell Module
# Function: Get-Five9CloudLegacyIdpPolicyList
# Category: LegacyIdpPolicies

function Get-Five9CloudLegacyIdpPolicyList {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)][string]$DomainId = $global:Five9CloudToken.DomainId,
        [string]$PageCursor,
        [int]$PageLimit,
        [string[]]$Sort
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$DomainId/legacy-idp-policies"
    
    $queryParams = @{}
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
        Write-Error "Failed to get legacy IDP policies: $_"
    }
}
