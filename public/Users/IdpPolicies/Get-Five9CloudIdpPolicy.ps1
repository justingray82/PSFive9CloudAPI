# Five9Cloud PowerShell Module
# Function: Get-Five9CloudIdpPolicy
# Category: IdpPolicies
# CONSOLIDATED VERSION - Combines 4 IDP policy Get functions

function Get-Five9CloudIdpPolicy {
    [CmdletBinding(DefaultParameterSetName = 'List')]
    param (
        [Parameter(Mandatory = $false)]
        [string]$DomainId = $global:Five9CloudToken.DomainId,
        
        # Single policy
        [Parameter(Mandatory = $true, ParameterSetName = 'Single', Position = 0)]
        [Parameter(Mandatory = $true, ParameterSetName = 'Legacy', Position = 0)]
        [string]$IdpPolicyId,
        
        # Legacy policy selector
        [Parameter(Mandatory = $true, ParameterSetName = 'Legacy')]
        [Parameter(Mandatory = $true, ParameterSetName = 'LegacyList')]
        [switch]$Legacy,
        
        # List parameters
        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [bool]$IncludeOrgPolicies,
        
        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [bool]$DefaultPolicy,
        
        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [Parameter(Mandatory = $false, ParameterSetName = 'Single')]
        [bool]$GetCount,
        
        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [string]$Fields,
        
        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [Parameter(Mandatory = $false, ParameterSetName = 'LegacyList')]
        [string[]]$Sort,
        
        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [Parameter(Mandatory = $false, ParameterSetName = 'LegacyList')]
        [int]$PageLimit,
        
        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [Parameter(Mandatory = $false, ParameterSetName = 'LegacyList')]
        [string]$PageCursor
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    # Build URI based on parameter set
    switch ($PSCmdlet.ParameterSetName) {
        'Single' {
            # Original: Get-Five9CloudIdpPolicy
            $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$DomainId/idp-policies/$IdpPolicyId"
            
            if ($PSBoundParameters.ContainsKey('GetCount')) {
                $uri += "?getCount=$GetCount"
            }
        }
        
        'List' {
            # Original: Get-Five9CloudIdpPolicies
            $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$DomainId/idp-policies"
        }
        
        'Legacy' {
            # Original: Get-Five9CloudLegacyIdpPolicy
            $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$DomainId/legacy-idp-policies/$IdpPolicyId"
        }
        
        'LegacyList' {
            # Original: Get-Five9CloudLegacyIdpPolicyList
            $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$DomainId/legacy-idp-policies"
        }
    }
    
    # Add query parameters for list operations
    if ($PSCmdlet.ParameterSetName -eq 'List') {
        $queryParams = @{}
        
        if ($PSBoundParameters.ContainsKey('IncludeOrgPolicies')) { 
            $queryParams['includeOrgPolicies'] = $IncludeOrgPolicies 
        }
        if ($PSBoundParameters.ContainsKey('DefaultPolicy')) { 
            $queryParams['defaultPolicy'] = $DefaultPolicy 
        }
        if ($PSBoundParameters.ContainsKey('GetCount')) { 
            $queryParams['getCount'] = $GetCount 
        }
        if ($Fields) { $queryParams['fields'] = $Fields }
        if ($Sort) { $queryParams['sort'] = $Sort -join ',' }
        if ($PageLimit) { $queryParams['pageLimit'] = $PageLimit }
        if ($PageCursor) { $queryParams['pageCursor'] = $PageCursor }
        
        if ($queryParams.Count -gt 0) {
            $uri += '?' + ($queryParams.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join '&'
        }
    } elseif ($PSCmdlet.ParameterSetName -eq 'LegacyList') {
        $queryParams = @{}
        
        if ($PageCursor) { $queryParams['pageCursor'] = $PageCursor }
        if ($PageLimit) { $queryParams['pageLimit'] = $PageLimit }
        if ($Sort) { $queryParams['sort'] = $Sort -join ',' }
        
        if ($queryParams.Count -gt 0) {
            $uri += '?' + ($queryParams.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join '&'
        }
    }
    
    try {
        Invoke-RestMethod -Uri $uri -Method Get -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        }
    } catch {
        Write-Error "Failed to retrieve IDP policy: $_"
    }
}
