# Five9Cloud PowerShell Module
# Function: Get-Five9CloudSpeedDial
# Category: SpeedDials
# CONSOLIDATED VERSION - Combines Get-Five9CloudSpeedDial, Get-Five9CloudSpeedDialList

function Get-Five9CloudSpeedDial {
    [CmdletBinding(DefaultParameterSetName = 'List')]
    param (
        [Parameter(Mandatory = $false)]
        [string]$DomainId = $global:Five9CloudToken.DomainId,
        
        # Single speed dial
        [Parameter(Mandatory = $true, ParameterSetName = 'Single', Position = 0)]
        [string]$SpeedDialId,
        
        # List parameters
        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [string]$Filter,
        
        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [string]$PageCursor,
        
        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [int]$PageLimit,
        
        [Parameter(Mandatory = $false, ParameterSetName = 'List')]
        [string[]]$Sort
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    # Build URI based on parameter set
    switch ($PSCmdlet.ParameterSetName) {
        'Single' {
            # Original: Get-Five9CloudSpeedDial
            $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$DomainId/speed-dials/$SpeedDialId"
        }
        
        'List' {
            # Original: Get-Five9CloudSpeedDialList
            $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$DomainId/speed-dials"
            
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
        Write-Error "Failed to retrieve speed dial(s): $_"
    }
}
