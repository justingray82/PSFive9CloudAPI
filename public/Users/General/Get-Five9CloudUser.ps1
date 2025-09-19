# Five9Cloud PowerShell Module
# Function: Get-Five9CloudUser
# Category: Users
# CONSOLIDATED VERSION - Combines 8 user-related Get functions

function Get-Five9CloudUser {
    [CmdletBinding(DefaultParameterSetName = 'List')]
    param (


        
        # Single user retrieval
        [Parameter(Mandatory = $true, ParameterSetName = 'Single', Position = 0)]
        [string]$UserUID,
        
        [Parameter(Mandatory = $false, ParameterSetName = 'Single')]
        [string]$Fields,
        
        # List/Filter parameters
        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [string[]]$UserUIDs,
        
        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [string[]]$UserIds,
        
        # By Application
        [Parameter(Mandatory = $true, ParameterSetName = 'ByApp')]
        [string]$AppId,
        
        # Migration specific
        [Parameter(Mandatory = $true, ParameterSetName = 'Migration')]
        [switch]$Migration,
        
        [Parameter(Mandatory = $true, ParameterSetName = 'MigrationList')]
        [switch]$AllMigrations,
        
        # Email verification
        [Parameter(Mandatory = $true, ParameterSetName = 'EmailVerification')]
        [switch]$EmailVerification,
        
        # IDP Login
        [Parameter(Mandatory = $true, ParameterSetName = 'IdpLogin')]
        [switch]$IdpLogin,
        
        # Common parameters for lists
        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [Parameter(Mandatory = $false, ParameterSetName = 'ByApp')]
        [Parameter(Mandatory = $false, ParameterSetName = 'MigrationList')]
        [string]$Role,
        
        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [Parameter(Mandatory = $false, ParameterSetName = 'ByApp')]
        [Parameter(Mandatory = $false, ParameterSetName = 'MigrationList')]
        [string]$Filter,
        
        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [Parameter(Mandatory = $false, ParameterSetName = 'ByApp')]
        [Parameter(Mandatory = $false, ParameterSetName = 'MigrationList')]
        [int]$PageLimit = 1000,
        
        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [Parameter(Mandatory = $false, ParameterSetName = 'ByApp')]
        [Parameter(Mandatory = $false, ParameterSetName = 'MigrationList')]
        [string]$PageCursor,
        
        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [Parameter(Mandatory = $false, ParameterSetName = 'ByApp')]
        [Parameter(Mandatory = $false, ParameterSetName = 'MigrationList')]
        [string[]]$Sort,
        
        # Migration-specific parameters
        [Parameter(Mandatory = $false, ParameterSetName = 'MigrationList')]
        [bool]$GetCount,
        
        [Parameter(Mandatory = $false, ParameterSetName = 'Migration')]
        [bool]$FitnessStats,
        
        [Parameter(Mandatory = $false, ParameterSetName = 'Migration')]
        [bool]$UserStats
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    # Build URI based on parameter set
    switch ($PSCmdlet.ParameterSetName) {
        'Single' {
            # Original: Get-Five9CloudUser
            $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$($global:Five9CloudToken.DomainId)/users/$UserUID"
            if ($Fields) {
                $uri += "?fields=$Fields"
            }
        }
        
        'List' {
            # Original: Get-Five9CloudUsers / Get-Five9CloudUserList
            $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$($global:Five9CloudToken.DomainId)/users"
        }
        
        'ByApp' {
            # Original: Get-Five9CloudUsersByAppId
            $uri = "$($global:Five9CloudToken.ApiBaseUrl)/acl/v1/domains/$($global:Five9CloudToken.DomainId)/applications/$AppId/users"
        }
        
        'Migration' {
            # Original: Get-Five9CloudUserMigrationDetails / Get-Five9CloudDomainMigrationDetails
            if ($UserUID) {
                $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$($global:Five9CloudToken.DomainId)/users/$UserUID/migration"
            } else {
                $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$($global:Five9CloudToken.DomainId)/migration"
                
                $queryParams = @{}
                if ($PSBoundParameters.ContainsKey('FitnessStats')) { 
                    $queryParams['fitnessStats'] = $FitnessStats 
                }
                if ($PSBoundParameters.ContainsKey('UserStats')) { 
                    $queryParams['userStats'] = $UserStats 
                }
                
                if ($queryParams.Count -gt 0) {
                    $uri += '?' + ($queryParams.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join '&'
                }
            }
        }
        
        'MigrationList' {
            # Original: Get-Five9CloudUsersMigrationDetails
            $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$($global:Five9CloudToken.DomainId)/users/migration"
        }
        
        'EmailVerification' {
            # Original: Get-Five9CloudUserEmailVerificationStatus
            $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$($global:Five9CloudToken.DomainId)/email-verification"
        }
        
        'IdpLogin' {
            # Original: Get-Five9CloudUserIdpLoginDetails
            $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$($global:Five9CloudToken.DomainId)/my-idp"
        }
    }
    
    # Add query parameters for list operations
    if ($PSCmdlet.ParameterSetName -in @('List', 'ByApp', 'MigrationList')) {
        $queryParams = @{}
        
        if ($UserUIDs) { $queryParams['userUID'] = $UserUIDs -join ',' }
        if ($UserIds) { $queryParams['userId'] = $UserIds -join ',' }
        if ($Role) { $queryParams['role'] = $Role }
        if ($Filter) { $queryParams['filter'] = $Filter }
        if ($PageLimit) { $queryParams['pageLimit'] = $PageLimit }
        if ($PageCursor) { $queryParams['pageCursor'] = $PageCursor }
        if ($Sort) { $queryParams['sort'] = $Sort -join ',' }
        if ($PSBoundParameters.ContainsKey('GetCount')) { 
            $queryParams['getCount'] = $GetCount 
        }
        
        if ($queryParams.Count -gt 0) {
            $separator = if ($uri.Contains('?')) { '&' } else { '?' }
            $uri += $separator + ($queryParams.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join '&'
        }
    }
    
    try {
        Invoke-RestMethod -Uri $uri -Method Get -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        }
    } catch {
        Write-Error "Failed to retrieve user(s): $_"
    }
}
