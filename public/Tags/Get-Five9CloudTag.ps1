# Five9Cloud PowerShell Module
# Function: Get-Five9CloudTag
# Category: Tags
# CONSOLIDATED VERSION - Combines Get-Five9CloudTags, Get-Five9CloudTagById, Get-Five9CloudCurrentUserTags

function Get-Five9CloudTag {
    [CmdletBinding(DefaultParameterSetName = 'List')]
    param (


        
        # Single tag by ID
        [Parameter(Mandatory = $true, ParameterSetName = 'Single', Position = 0)]
        [string]$TagId,
        
        # Current user tags
        [Parameter(Mandatory = $true, ParameterSetName = 'CurrentUser')]
        [switch]$CurrentUser,
        
        # List parameters
        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [string]$PageCursor,
        
        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [int]$PageLimit = 1000,
        
        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [string]$Filter
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    # Build URI based on parameter set
    switch ($PSCmdlet.ParameterSetName) {
        'Single' {
            # Original: Get-Five9CloudTagById
            $uri = "$($global:Five9CloudToken.ApiBaseUrl)/acl/v1/domains/$($global:Five9CloudToken.DomainId)/tags/$TagId"
        }
        
        'List' {
            # Original: Get-Five9CloudTags
            $uri = "$($global:Five9CloudToken.ApiBaseUrl)/acl/v1/domains/$($global:Five9CloudToken.DomainId)/tags"
            
            $queryParams = @{}
            if ($PageCursor) { $queryParams['pageCursor'] = $PageCursor }
            if ($PageLimit) { $queryParams['pageLimit'] = $PageLimit }
            if ($Filter) { $queryParams['filter'] = $Filter }
            
            if ($queryParams.Count -gt 0) {
                $uri += '?' + ($queryParams.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join '&'
            }
        }
        
        'CurrentUser' {
            # Original: Get-Five9CloudCurrentUserTags
            $uri = "$($global:Five9CloudToken.ApiBaseUrl)/acl/v1/domains/$($global:Five9CloudToken.DomainId)/my-tags"
        }
    }
    
    try {
        Invoke-RestMethod -Uri $uri -Method Get -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        }
    } catch {
        Write-Error "Failed to retrieve tag(s): $_"
    }
}
