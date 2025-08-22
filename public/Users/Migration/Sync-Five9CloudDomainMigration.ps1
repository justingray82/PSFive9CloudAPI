# Five9Cloud PowerShell Module
# Function: Sync-Five9CloudDomainMigration
# Category: Migration

function Sync-Five9CloudDomainMigration {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)][string]$DomainId = $global:Five9CloudToken.DomainId,
        [Parameter(Mandatory = $true)]
        [ValidateSet('administrators', 'supervisors', 'agents', 'allUsers')]
        [string]$UserType,
        [string]$UserUID,
        [bool]$ProcessOnlyFailures
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$DomainId/migration/$UserType`:sync"
    
    $queryParams = @{}
    if ($UserUID) { $queryParams['userUID'] = $UserUID }
    if ($PSBoundParameters.ContainsKey('ProcessOnlyFailures')) { $queryParams['processOnlyFailures'] = $ProcessOnlyFailures }
    
    if ($queryParams.Count -gt 0) {
        $uri += '?' + ($queryParams.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join '&'
    }
    
    try {
        Invoke-RestMethod -Uri $uri -Method Put -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        }
    } catch {
        Write-Error "Failed to sync domain migration: $_"
    }
}
