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
        [string[]]$Sort,
        
        # Migration-specific parameters
        [Parameter(Mandatory = $false, ParameterSetName = 'MigrationList')]
        [bool]$GetCount,
        
        [Parameter(Mandatory = $false, ParameterSetName = 'Migration')]
        [bool]$FitnessStats,
        
        [Parameter(Mandatory = $false, ParameterSetName = 'Migration')]
        [bool]$UserStats,
        
        # Pagination control
        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [Parameter(Mandatory = $false, ParameterSetName = 'ByApp')]
        [Parameter(Mandatory = $false, ParameterSetName = 'MigrationList')]
        [switch]$NoPagination  # If specified, only returns first page
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    # Helper function to build query string
    function Build-QueryString {
        param($QueryParams, $BaseUri)
        
        if ($QueryParams.Count -gt 0) {
            $separator = if ($BaseUri.Contains('?')) { '&' } else { '?' }
            return $BaseUri + $separator + ($QueryParams.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join '&'
        }
        return $BaseUri
    }
    
    # Helper function to extract items from response
    function Get-ItemsFromResponse {
        param($Response)
        
        # Handle different response structures
        if ($Response.items) {
            return @{
                Items = $Response.items
                NextCursor = $Response.nextPageCursor
            }
        }
        elseif ($Response.data) {
            return @{
                Items = $Response.data
                NextCursor = $Response.pageCursor
            }
        }
        elseif ($Response -is [Array]) {
            return @{
                Items = $Response
                NextCursor = $null
            }
        }
        else {
            # Single object response
            return @{
                Items = @($Response)
                NextCursor = $null
            }
        }
    }
    
    # Build base URI based on parameter set
    $baseUri = switch ($PSCmdlet.ParameterSetName) {
        'Single' {
            $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$($global:Five9CloudToken.DomainId)/users/$UserUID"
            if ($Fields) {
                $uri += "?fields=$Fields"
            }
            $uri
        }
        
        'List' {
            "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$($global:Five9CloudToken.DomainId)/users"
        }
        
        'ByApp' {
            "$($global:Five9CloudToken.ApiBaseUrl)/acl/v1/domains/$($global:Five9CloudToken.DomainId)/applications/$AppId/users"
        }
        
        'Migration' {
            if ($UserUID) {
                "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$($global:Five9CloudToken.DomainId)/users/$UserUID/migration"
            } else {
                $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$($global:Five9CloudToken.DomainId)/migration"
                
                $queryParams = @{}
                if ($PSBoundParameters.ContainsKey('FitnessStats')) { 
                    $queryParams['fitnessStats'] = $FitnessStats 
                }
                if ($PSBoundParameters.ContainsKey('UserStats')) { 
                    $queryParams['userStats'] = $UserStats 
                }
                
                Build-QueryString -QueryParams $queryParams -BaseUri $uri
            }
        }
        
        'MigrationList' {
            "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$($global:Five9CloudToken.DomainId)/users/migration"
        }
        
        'EmailVerification' {
            "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$($global:Five9CloudToken.DomainId)/email-verification"
        }
        
        'IdpLogin' {
            "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$($global:Five9CloudToken.DomainId)/my-idp"
        }
    }
    
    # For single item retrievals or non-paginated endpoints, just make one request
    if ($PSCmdlet.ParameterSetName -in @('Single', 'Migration', 'EmailVerification', 'IdpLogin')) {
        try {
            return Invoke-RestMethod -Uri $baseUri -Method Get -Headers @{
                Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
                'Content-Type' = 'application/json'
            }
        } catch {
            Write-Error "Failed to retrieve user(s): $_"
            return
        }
    }
    
    # For list operations, handle pagination
    $allItems = @()
    $currentCursor = $null
    $pageCount = 0
    
    do {
        # Build query parameters for this request
        $queryParams = @{}
        
        if ($UserUIDs) { $queryParams['userUID'] = $UserUIDs -join ',' }
        if ($UserIds) { $queryParams['userId'] = $UserIds -join ',' }
        if ($Role) { $queryParams['role'] = $Role }
        if ($Filter) { $queryParams['filter'] = $Filter }
        if ($PageLimit) { $queryParams['pageLimit'] = $PageLimit }
        if ($currentCursor) { $queryParams['pageCursor'] = $currentCursor }
        if ($Sort) { $queryParams['sort'] = $Sort -join ',' }
        if ($PSBoundParameters.ContainsKey('GetCount')) { 
            $queryParams['getCount'] = $GetCount 
        }
        
        $uri = Build-QueryString -QueryParams $queryParams -BaseUri $baseUri
        
        try {
            Write-Verbose "Fetching page $($pageCount + 1)..."
            $response = Invoke-RestMethod -Uri $uri -Method Get -Headers @{
                Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
                'Content-Type' = 'application/json'
            }
            
            $pageCount++
            
            # Extract items and next cursor from response
            $extracted = Get-ItemsFromResponse -Response $response
            
            if ($extracted.Items) {
                $allItems += $extracted.Items
                Write-Verbose "Retrieved $($extracted.Items.Count) items (Total: $($allItems.Count))"
            }
            
            # Update cursor for next iteration
            $currentCursor = $extracted.NextCursor
            
            # If NoPagination switch is set, break after first page
            if ($NoPagination) {
                break
            }
            
        } catch {
            Write-Error "Failed to retrieve users on page $($pageCount + 1): $_"
            break
        }
        
    } while ($currentCursor)
    
    Write-Verbose "Total items retrieved: $($allItems.Count) across $pageCount page(s)"
    
    # Return all items
    return $allItems
}