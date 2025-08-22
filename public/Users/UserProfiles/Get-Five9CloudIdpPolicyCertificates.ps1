# Five9Cloud PowerShell Module
# Function: Get-Five9CloudIdpPolicyCertificates
# Category: UserProfiles

function Get-Five9CloudIdpPolicyCertificates {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)][string]$DomainId = $global:Five9CloudToken.DomainId,
        [Parameter(Mandatory = $true)][string]$IdpPolicyId,
        [int]$PageLimit,
        [string]$PageCursor
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$DomainId/idp-policies/$IdpPolicyId/certificates"
    
    $queryParams = @{}
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
        Write-Error "Failed to get IDP policy certificates: $_"
    }
}
