# Five9Cloud PowerShell Module
# Function: Get-Five9CloudUserAttribute
# Category: UserAttributes
# CONSOLIDATED VERSION - Combines 8 user attribute Get functions

function Get-Five9CloudUserAttribute {
    [CmdletBinding(DefaultParameterSetName = 'Applications')]
    param (


        
        # User identifier (required for all attribute queries)
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$UserUID,
        
        # Attribute type selectors
        [Parameter(Mandatory = $true, ParameterSetName = 'Applications')]
        [switch]$Applications,
        
        [Parameter(Mandatory = $true, ParameterSetName = 'AppPermissions')]
        [string]$AppId,  # For application permissions check
        
        [Parameter(Mandatory = $true, ParameterSetName = 'Permissions')]
        [switch]$Permissions,
        
        [Parameter(Mandatory = $true, ParameterSetName = 'PermissionRoles')]
        [switch]$PermissionRoles,
        
        [Parameter(Mandatory = $true, ParameterSetName = 'Roles')]
        [switch]$Roles,
        
        [Parameter(Mandatory = $true, ParameterSetName = 'Tags')]
        [switch]$Tags,
        
        [Parameter(Mandatory = $true, ParameterSetName = 'Numbers')]
        [switch]$Numbers,
        
        [Parameter(Mandatory = $true, ParameterSetName = 'MFAFactors')]
        [switch]$MFAFactors,
        
        # Additional parameters for specific queries
        [Parameter(Mandatory = $false, ParameterSetName = 'Permissions')]
        [ValidateSet('user', 'role', 'both')]
        [string]$From = "both",
        
        [Parameter(Mandatory = $false, ParameterSetName = 'Applications')]
        [string]$Included,
        
        # Pagination parameters for Tags
        [Parameter(Mandatory = $false, ParameterSetName = 'Tags')]
        [string]$Filter,
        
        [Parameter(Mandatory = $false, ParameterSetName = 'Tags')]
        [string]$PageCursor,
        
        [Parameter(Mandatory = $false, ParameterSetName = 'Tags')]
        [int]$PageLimit = 1000,
        
        [Parameter(Mandatory = $false, ParameterSetName = 'Tags')]
        [string[]]$Sort
    )
    
    if (-not (Test-Five9CloudConnection -AutoReconnect)) { return }
    
    # Build URI based on parameter set
    switch ($PSCmdlet.ParameterSetName) {
        'Applications' {
            # Original: Get-Five9CloudUserApplications
            $uri = "$($global:Five9CloudToken.ApiBaseUrl)/acl/v1/domains/$($global:Five9CloudToken.DomainId)/users/$UserUID/applications"
            if ($Included) {
                $uri += "?included=$Included"
            }
        }
        
        'AppPermissions' {
            # Original: Get-Five9CloudUserApplicationPermissions
            $uri = "$($global:Five9CloudToken.ApiBaseUrl)/acl/v1/domains/$($global:Five9CloudToken.DomainId)/users/$UserUID/applications/$AppId/check-permissions"
        }
        
        'Permissions' {
            # Original: Get-Five9CloudUserPermissions
            $uri = "$($global:Five9CloudToken.ApiBaseUrl)/acl/v1/domains/$($global:Five9CloudToken.DomainId)/users/$UserUID/permissions?from=$From"
        }
        
        'PermissionRoles' {
            # Original: Get-Five9CloudUserPermissionRoles
            $uri = "$($global:Five9CloudToken.ApiBaseUrl)/acl/v1/domains/$($global:Five9CloudToken.DomainId)/users/$UserUID/permissions-roles"
        }
        
        'Roles' {
            # Original: Get-Five9CloudUserRoles
            $uri = "$($global:Five9CloudToken.ApiBaseUrl)/acl/v1/domains/$($global:Five9CloudToken.DomainId)/users/$UserUID/roles"
        }
        
        'Tags' {
            # Original: Get-Five9CloudUserTags
            $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$($global:Five9CloudToken.DomainId)/users/$UserUID/tags"
            
            $queryParams = @{}
            if ($Filter) { $queryParams['filter'] = $Filter }
            if ($PageCursor) { $queryParams['pageCursor'] = $PageCursor }
            if ($PageLimit) { $queryParams['pageLimit'] = $PageLimit }
            if ($Sort) { $queryParams['sort'] = $Sort -join ',' }
            
            if ($queryParams.Count -gt 0) {
                $uri += '?' + ($queryParams.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join '&'
            }
        }
        
        'Numbers' {
            # Original: Get-Five9CloudUserNumbers
            $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$($global:Five9CloudToken.DomainId)/users/$UserUID/numbers"
        }
        
        'MFAFactors' {
            # Original: Get-Five9CloudUserMFAFactors
            $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$($global:Five9CloudToken.DomainId)/my-factors"
        }
    }
    
    try {
        Invoke-RestMethod -Uri $uri -Method Get -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        }
    } catch {
        Write-Error "Failed to retrieve user attribute: $_"
    }
}
