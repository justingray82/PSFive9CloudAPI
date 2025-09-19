# Five9Cloud PowerShell Module
# Function: Get-Five9CloudApplication
# Category: Applications
# CONSOLIDATED VERSION - Combines 5 application Get functions

function Get-Five9CloudApplication {
    [CmdletBinding(DefaultParameterSetName = 'List')]
    param (


        
        # Single application
        [Parameter(Mandatory = $true, ParameterSetName = 'Single', Position = 0)]
        [string]$AppId,
        
        # Domain-specific query
        [Parameter(Mandatory = $true, ParameterSetName = 'Domain')]
        [switch]$DomainSpecific,
        
        # Current user applications
        [Parameter(Mandatory = $true, ParameterSetName = 'CurrentUser')]
        [switch]$CurrentUser,
        
        # List parameters
        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [Parameter(Mandatory = $false, ParameterSetName = 'Domain')]
        [string]$Status,
        
        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [Parameter(Mandatory = $false, ParameterSetName = 'Domain')]
        [string[]]$Id,
        
        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [Parameter(Mandatory = $false, ParameterSetName = 'Domain')]
        [string]$Filter,
        
        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [Parameter(Mandatory = $false, ParameterSetName = 'Domain')]
        [string]$Sort,
        
        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [Parameter(Mandatory = $false, ParameterSetName = 'Domain')]
        [bool]$ApiOnly,
        
        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [Parameter(Mandatory = $false, ParameterSetName = 'Domain')]
        [int]$PageLimit = 1000,
        
        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [Parameter(Mandatory = $false, ParameterSetName = 'Domain')]
        [string]$PageCursor
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    # Build URI based on parameter set
    switch ($PSCmdlet.ParameterSetName) {
        'Single' {
            if ($DomainSpecific) {
                # Original: Get-Five9CloudDomainApplication
                $uri = "$($global:Five9CloudToken.ApiBaseUrl)/acl/v1/domains/$($global:Five9CloudToken.DomainId)/applications/$AppId"
            } else {
                # Original: Get-Five9CloudApplication
                $uri = "$($global:Five9CloudToken.ApiBaseUrl)/acl/v1/applications/$AppId"
            }
        }
        
        'List' {
            # Original: Get-Five9CloudApplications
            $uri = "$($global:Five9CloudToken.ApiBaseUrl)/acl/v1/applications"
        }
        
        'Domain' {
            # Original: Get-Five9CloudDomainApplications
            $uri = "$($global:Five9CloudToken.ApiBaseUrl)/acl/v1/domains/$($global:Five9CloudToken.DomainId)/applications"
        }
        
        'CurrentUser' {
            # Original: Get-Five9CloudCurrentUserApplications
            $uri = "$($global:Five9CloudToken.ApiBaseUrl)/acl/v1/domains/$($global:Five9CloudToken.DomainId)/my-applications"
        }
    }
    
    # Add query parameters for list operations
    if ($PSCmdlet.ParameterSetName -in @('List', 'Domain')) {
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
        Write-Error "Failed to retrieve application(s): $_"
    }
}
