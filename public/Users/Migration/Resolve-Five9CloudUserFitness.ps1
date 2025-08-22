# Five9Cloud PowerShell Module
# Function: Resolve-Five9CloudUserFitness
# Category: Migration

function Resolve-Five9CloudUserFitness {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)][string]$DomainId = $global:Five9CloudToken.DomainId,
        [Parameter(Mandatory = $true)][string]$UserUID,
        [Parameter(Mandatory = $true)]
        [ValidateSet('administrators', 'supervisors', 'agents', 'allUsers')]
        [string]$UserType
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/users/v1/domains/$DomainId/users/$UserUID/migration/$UserType`:ready"
    
    try {
        Invoke-RestMethod -Uri $uri -Method Put -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        }
    } catch {
        Write-Error "Failed to resolve user fitness: $_"
    }
}
