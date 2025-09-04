# Five9Cloud PowerShell Module
# Function: Get-Five9CloudPermission
# Category: Permissions
# CONSOLIDATED VERSION - Combines 6 permission Get functions

function Get-Five9CloudPermission {
    [CmdletBinding(DefaultParameterSetName = 'List')]
    param (
        [Parameter(Mandatory = $false)]
        [string]$DomainId = $global:Five9CloudToken.DomainId,
        
        # Single permission
        [Parameter(Mandatory = $true, ParameterSetName = 'Single', Position = 0)]
        [string]$Permission,
        
        # Current user permissions
        [Parameter(Mandatory = $true, ParameterSetName = 'CurrentUser')]
        [switch]$CurrentUser,
        
        # Internal user permissions
        [Parameter(Mandatory = $true, ParameterSetName = 'Internal')]
        [switch]$Internal,
        
        # Role permissions
        [Parameter(Mandatory = $true, ParameterSetName = 'ByRole')]
        [string]$Role,
        
        # User profile permissions
        [Parameter(Mandatory = $true, ParameterSetName = 'ByProfile')]
        [string]$UserProfileId,
        
        # List parameters
        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [string]$Status,
        
        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [string[]]$Id,
        
        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [string]$Filter,
        
        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [string]$Sort,
        
        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [bool]$ApiOnly,
        
        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [Parameter(Mandatory = $false, ParameterSetName = 'ByProfile')]
        [int]$PageLimit,
        
        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [Parameter(Mandatory = $false, ParameterSetName = 'ByProfile')]
        [string]$PageCursor
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    # Build URI based on parameter set
    switch ($PSCmdlet.ParameterSetName) {
        'Single' {
            # Original: Get-Five9CloudPermission
            $uri = "$($global:Five9CloudToken.ApiBaseUrl)/acl/v1/domains/$DomainId/permissions/$Permission"
        }
        
        'List' {
            # Original: Get-Five9CloudPermissions
            $uri = "$($global:Five9CloudToken.ApiBaseUrl)/acl/v1/domains/$DomainId/permissions"
        }
        
        'CurrentUser' {
            # Original: Get-Five9CloudCurrentUserPermissions
            $uri = "$($global:Five9CloudToken.ApiBaseUrl)/acl/v1/domains/$DomainId/my-ui-permissions"
        }
        
        'Internal' {
            # Original: Get-Five9CloudInternalUserPermissions
            $uri = "$($global:Five9CloudToken.ApiBaseUrl)/acl/v1/my-ui-permissions"
        }
        
        'ByRole' {
            # Original: Get-Five9CloudRolePermissions
            $uri = "$($global:Five9CloudToken.ApiBaseUrl)/acl/v1/domains/$DomainId/roles/$Role/permissions"
        }
        
        'ByProfile' {
            # Original: Get-Five9CloudUserProfilePermissions
            $uri = "$($global:Five9CloudToken.ApiBaseUrl)/acl/v1/domains/$DomainId/user-profiles/$UserProfileId/permissions"
        }
    }
    
    # Add query parameters
    if ($PSCmdlet.ParameterSetName -eq 'List') {
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
    } elseif ($PSCmdlet.ParameterSetName -eq 'ByProfile') {
        $queryParams = @{}
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
        Write-Error "Failed to retrieve permission(s): $_"
    }
}
