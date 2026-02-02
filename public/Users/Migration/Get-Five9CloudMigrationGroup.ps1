# Five9Cloud PowerShell Module
# Function: Get-Five9CloudMigrationGroup
# Category: MigrationGroups
# CONSOLIDATED VERSION - Combines Get-Five9CloudMigrationGroup, Get-Five9CloudMigrationGroupList, Get-Five9CloudMigrationGroupUsers

function Get-Five9CloudMigrationGroup {
    [CmdletBinding(DefaultParameterSetName = 'List')]
    param (


        
        # Single group or group users
        [Parameter(Mandatory = $true, ParameterSetName = 'Single', Position = 0)]
        [Parameter(Mandatory = $true, ParameterSetName = 'Users', Position = 0)]
        [string]$GroupId,
        
        # Get users in group
        [Parameter(Mandatory = $true, ParameterSetName = 'Users')]
        [switch]$Users,
        
        # Stats parameter for single/list
        [Parameter(Mandatory = $false, ParameterSetName = 'Single')]
        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [bool]$UserStats,
        
        # List parameters
        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [string]$Type,
        
        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [Parameter(Mandatory = $false, ParameterSetName = 'Users')]
        [string]$Filter,
        
        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [Parameter(Mandatory = $false, ParameterSetName = 'Users')]
        [string]$PageCursor,
        
        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [Parameter(Mandatory = $false, ParameterSetName = 'Users')]
        [int]$PageLimit = 1000,
        
        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [Parameter(Mandatory = $false, ParameterSetName = 'Users')]
        [string[]]$Sort
    )
    
    if (-not (Test-Five9CloudConnection -AutoReconnect)) { return }
    
    # Build URI based on parameter set
    switch ($PSCmdlet.ParameterSetName) {
        'Single' {
            # Original: Get-Five9CloudMigrationGroup
            $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$($global:Five9CloudToken.DomainId)/migration-groups/$GroupId"
            
            if ($PSBoundParameters.ContainsKey('UserStats')) {
                $uri += "?userStats=$UserStats"
            }
        }
        
        'List' {
            # Original: Get-Five9CloudMigrationGroupList
            $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$($global:Five9CloudToken.DomainId)/migration-groups"
            
            $queryParams = @{}
            if ($PSBoundParameters.ContainsKey('UserStats')) { 
                $queryParams['userStats'] = $UserStats 
            }
            if ($Type) { $queryParams['type'] = $Type }
            if ($Filter) { $queryParams['filter'] = $Filter }
            if ($PageCursor) { $queryParams['pageCursor'] = $PageCursor }
            if ($PageLimit) { $queryParams['pageLimit'] = $PageLimit }
            if ($Sort) { $queryParams['sort'] = $Sort -join ',' }
            
            if ($queryParams.Count -gt 0) {
                $uri += '?' + ($queryParams.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join '&'
            }
        }
        
        'Users' {
            # Original: Get-Five9CloudMigrationGroupUsers
            $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$($global:Five9CloudToken.DomainId)/migration-groups/$GroupId/users"
            
            $queryParams = @{}
            if ($Filter) { $queryParams['filter'] = $Filter }
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
        Write-Error "Failed to retrieve migration group(s): $_"
    }
}
