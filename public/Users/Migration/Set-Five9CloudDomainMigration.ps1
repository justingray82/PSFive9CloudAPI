# Five9Cloud PowerShell Module
# Function: Set-Five9CloudDomainMigration
# Category: Migration
# CONSOLIDATED from Enable-Five9CloudDomainMigration and Disable-Five9CloudDomainMigration

function Set-Five9CloudDomainMigration {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)][string]$DomainId = $global:Five9CloudToken.DomainId,
        [Parameter(Mandatory = $true)]
        [bool]$Enable
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    # Determine the action based on Enable parameter
    $action = if ($Enable) { ':enable' } else { ':disable' }
    
    # Extract the base URI from the original functions
    $baseUri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$DomainId"
        # Note: Original functions had UserType parameter
    [Parameter(Mandatory = $true)]
    [ValidateSet('administrators', 'supervisors', 'agents', 'allUsers')]
    [string]$UserType
    
    $actionVerb = if ($Enable) { 'start' } else { 'pause' }
    $uri = "$baseUri/migration/${$UserType}:$actionVerb"    
    try {
        Invoke-RestMethod -Uri $uri -Method Put -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        }
    } catch {
        $actionText = if ($Enable) { 'enable' } else { 'disable' }
        Write-Error "Failed to ${$actionText}: $_"
    }
}
