# Five9Cloud PowerShell Module
# Function: Get-Five9CloudDomainMigrationDetails
# Category: Migration

function Get-Five9CloudDomainMigrationDetails {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)][string]$DomainId = $global:Five9CloudToken.DomainId,
        [bool]$FitnessStats,
        [bool]$UserStats
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$DomainId/migration"
    
    $queryParams = @{}
    if ($PSBoundParameters.ContainsKey('FitnessStats')) { $queryParams['fitnessStats'] = $FitnessStats }
    if ($PSBoundParameters.ContainsKey('UserStats')) { $queryParams['userStats'] = $UserStats }
    
    if ($queryParams.Count -gt 0) {
        $uri += '?' + ($queryParams.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join '&'
    }
    
    try {
        Invoke-RestMethod -Uri $uri -Method Get -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        }
    } catch {
        Write-Error "Failed to retrieve domain migration details: $_"
    }
}
