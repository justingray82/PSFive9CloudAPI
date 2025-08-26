# Five9Cloud PowerShell Module
# Function: Get-Five9CloudScopes
# Category: Scopes
function Get-Five9CloudScopes {
    [CmdletBinding()]
    param (
        [string]$Scopes
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/acl/v1/scopes"
    
    if ($Scopes) {
        $uri += "?scopes=$Scopes"
    }
    
    try {
        Invoke-RestMethod -Uri $uri -Method Get -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        }
    } catch {
        Write-Error "Failed to list scopes: $_"
    }
}
