# Five9Cloud PowerShell Module
# Function: Get-Five9CloudRole
# Category: Roles
# CONSOLIDATED VERSION - Combines 5 role Get functions

function Get-Five9CloudRole {
    [CmdletBinding(DefaultParameterSetName = 'All')]
    param (


        
        # Single role (custom or system)
        [Parameter(Mandatory = $true, ParameterSetName = 'Custom', Position = 0)]
        [Parameter(Mandatory = $true, ParameterSetName = 'System', Position = 0)]
        [string]$Role,
        
        # Role type selector
        [Parameter(Mandatory = $true, ParameterSetName = 'Custom')]
        [switch]$Custom,
        
        [Parameter(Mandatory = $true, ParameterSetName = 'System')]
        [switch]$System,
        
        [Parameter(Mandatory = $true, ParameterSetName = 'SystemList')]
        [switch]$SystemOnly,
        
        # User profile role
        [Parameter(Mandatory = $true, ParameterSetName = 'ProfileRole')]
        [string]$UserProfileId,
        
        # List parameters
        [Parameter(Mandatory = $false, ParameterSetName = 'All')]
        [Parameter(Mandatory = $false, ParameterSetName = 'SystemList')]
        [string]$Status,
        
        [Parameter(Mandatory = $false, ParameterSetName = 'All')]
        [string[]]$Id,
        
        [Parameter(Mandatory = $false, ParameterSetName = 'All')]
        [string]$Filter,
        
        [Parameter(Mandatory = $false, ParameterSetName = 'All')]
        [string]$Sort,
        
        [Parameter(Mandatory = $false, ParameterSetName = 'All')]
        [bool]$ApiOnly,
        
        [Parameter(Mandatory = $false, ParameterSetName = 'All')]
        [Parameter(Mandatory = $false, ParameterSetName = 'SystemList')]
        [int]$PageLimit = 1000,
        
        [Parameter(Mandatory = $false, ParameterSetName = 'All')]
        [Parameter(Mandatory = $false, ParameterSetName = 'SystemList')]
        [string]$PageCursor
    )
    
    if (-not (Test-Five9CloudConnection -AutoReconnect)) { return }
    
    # Build URI based on parameter set
    switch ($PSCmdlet.ParameterSetName) {
        'Custom' {
            # Original: Get-Five9CloudCustomRole
            $uri = "$($global:Five9CloudToken.ApiBaseUrl)/acl/v1/domains/$($global:Five9CloudToken.DomainId)/roles/$Role"
        }
        
        'System' {
            # Original: Get-Five9CloudSystemRole
            $uri = "$($global:Five9CloudToken.ApiBaseUrl)/acl/v1/domains/$($global:Five9CloudToken.DomainId)/system-roles/$Role"
        }
        
        'SystemList' {
            # Original: Get-Five9CloudSystemRoles
            $uri = "$($global:Five9CloudToken.ApiBaseUrl)/acl/v1/domains/$($global:Five9CloudToken.DomainId)/system-roles"
        }
        
        'All' {
            # Original: Get-Five9CloudCustomAndSystemRoles
            $uri = "$($global:Five9CloudToken.ApiBaseUrl)/acl/v1/domains/$($global:Five9CloudToken.DomainId)/roles"
        }
        
        'ProfileRole' {
            # Original: Get-Five9CloudUserProfileRole
            $uri = "$($global:Five9CloudToken.ApiBaseUrl)/acl/v1/domains/$($global:Five9CloudToken.DomainId)/user-profiles/$UserProfileId/role"
        }
    }
    
    # Add query parameters for list operations
    if ($PSCmdlet.ParameterSetName -in @('All', 'SystemList')) {
        $queryParams = @{}
        
        if ($Status) { $queryParams['status'] = $Status }
        if ($Id) { $queryParams['id'] = $Id -join ',' }
        if ($Filter) { $queryParams['filter'] = $Filter }
        if ($Sort) { $queryParams['sort'] = $Sort }
        if ($PSBoundParameters.ContainsKey('ApiOnly')) { 
            $queryParams['apiOnly'] = $ApiOnly 
        }
        if ($PageLimit) { $queryParams['pageLimit'] = $PageLimit }
        if ($PageCursor) { $queryParams['pageCursor'] = $PageCursor }
        
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
        Write-Error "Failed to retrieve role(s): $_"
    }
}
