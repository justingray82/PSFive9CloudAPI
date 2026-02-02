# Five9Cloud PowerShell Module
# Function: Get-Five9CloudUserProfile
# Category: UserProfiles
# CONSOLIDATED VERSION - Combines Get-Five9CloudUserProfiles, Get-Five9CloudProfileUsers

function Get-Five9CloudUserProfile {
    [CmdletBinding(DefaultParameterSetName = 'List')]
    param (


        
        # Get users for a specific profile
        [Parameter(Mandatory = $true, ParameterSetName = 'Users', Position = 0)]
        [string]$UserProfileId,
        
        [Parameter(Mandatory = $true, ParameterSetName = 'Users')]
        [switch]$Users,
        
        # List parameters
        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [string[]]$UserProfileIds,
        
        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [string]$WithRel,
        
        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [string]$WithoutRel,
        
        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [string]$Name,
        
        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
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
        'List' {
            # Original: Get-Five9CloudUserProfiles
            $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$($global:Five9CloudToken.DomainId)/user-profiles"
            
            $queryParams = @{}
            if ($UserProfileIds) { $queryParams['userProfileId'] = $UserProfileIds -join ',' }
            if ($WithRel) { $queryParams['withRel'] = $WithRel }
            if ($WithoutRel) { $queryParams['withoutRel'] = $WithoutRel }
            if ($Name) { $queryParams['name'] = $Name }
            if ($Filter) { $queryParams['filter'] = $Filter }
            if ($PageCursor) { $queryParams['pageCursor'] = $PageCursor }
            if ($PageLimit) { $queryParams['pageLimit'] = $PageLimit }
            if ($Sort) { $queryParams['sort'] = $Sort -join ',' }
            
            if ($queryParams.Count -gt 0) {
                $uri += '?' + ($queryParams.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join '&'
            }
        }
        
        'Users' {
            # Original: Get-Five9CloudProfileUsers
            $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$($global:Five9CloudToken.DomainId)/user-profiles/$UserProfileId/users"
            
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
        Write-Error "Failed to retrieve user profile(s): $_"
    }
}
