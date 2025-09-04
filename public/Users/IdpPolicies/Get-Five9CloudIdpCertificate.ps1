# Five9Cloud PowerShell Module
# Function: Get-Five9CloudIdpCertificate
# Category: IdpCertificates
# CONSOLIDATED VERSION - Combines 4 IDP certificate Get functions

function Get-Five9CloudIdpCertificate {
    [CmdletBinding(DefaultParameterSetName = 'List')]
    param (
        [Parameter(Mandatory = $false)]
        [string]$DomainId = $global:Five9CloudToken.DomainId,
        
        # IDP Policy ID (required for all certificate operations)
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$IdpPolicyId,
        
        # Single certificate ID
        [Parameter(Mandatory = $true, ParameterSetName = 'Single')]
        [Parameter(Mandatory = $true, ParameterSetName = 'Legacy')]
        [string]$IdpCertificateId,
        
        # Legacy certificate selector
        [Parameter(Mandatory = $true, ParameterSetName = 'Legacy')]
        [Parameter(Mandatory = $true, ParameterSetName = 'LegacyList')]
        [switch]$Legacy,
        
        # Pagination parameters
        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [Parameter(Mandatory = $false, ParameterSetName = 'LegacyList')]
        [int]$PageLimit,
        
        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [Parameter(Mandatory = $false, ParameterSetName = 'LegacyList')]
        [string]$PageCursor,
        
        [Parameter(Mandatory = $false, ParameterSetName = 'LegacyList')]
        [string[]]$Sort
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    # Build URI based on parameter set
    switch ($PSCmdlet.ParameterSetName) {
        'Single' {
            # Original: Get-Five9CloudIdpPolicyCertificate
            $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$DomainId/idp-policies/$IdpPolicyId/certificates/$IdpCertificateId"
        }
        
        'List' {
            # Original: Get-Five9CloudIdpPolicyCertificates
            $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$DomainId/idp-policies/$IdpPolicyId/certificates"
            
            $queryParams = @{}
            if ($PageLimit) { $queryParams['pageLimit'] = $PageLimit }
            if ($PageCursor) { $queryParams['pageCursor'] = $PageCursor }
            
            if ($queryParams.Count -gt 0) {
                $uri += '?' + ($queryParams.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join '&'
            }
        }
        
        'Legacy' {
            # Original: Get-Five9CloudLegacyIdpCertificate
            $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$DomainId/legacy-idp-policies/$IdpPolicyId/certificates/$IdpCertificateId"
        }
        
        'LegacyList' {
            # Original: Get-Five9CloudLegacyIdpCertificateList
            $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$DomainId/legacy-idp-policies/$IdpPolicyId/certificates"
            
            $queryParams = @{}
            if ($PageCursor) { $queryParams['pageCursor'] = $PageCursor }
            if ($PageLimit) { $queryParams['pageLimit'] = $PageLimit }
            if ($Sort) { $queryParams['sort'] = $Sort -join ',' }
            
            if ($queryParams.Count -gt 0) {
                $uri += '?' + ($queryParams.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join '&'
            }
        }
    }
    
    try {
        Invoke-RestMethod -Uri $uri -Method Get -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        }
    } catch {
        Write-Error "Failed to retrieve IDP certificate(s): $_"
    }
}
