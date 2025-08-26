# Five9Cloud PowerShell Module
# Function: Get-Five9CloudScopesForDomain
# Category: Scopes
function Get-Five9CloudScopesForDomain {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)][string]$DomainId = $global:Five9CloudToken.DomainId,
        [string]$Filter
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/acl/v1/domains/$DomainId/scopes"
    
    if ($Filter) {
        $uri += "?filter=$Filter"
    }
    
    try {
        Invoke-RestMethod -Uri $uri -Method Get -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        }
    } catch {
        Write-Error "Failed to list scopes for domain: $_"
    }
}
