# Five9Cloud PowerShell Module
# Function: Set-Five9CloudAllowedCorsOrigins
# Category: AllowedCorsOrigins
function Set-Five9CloudAllowedCorsOrigins {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)][string]$DomainId = $global:Five9CloudToken.DomainId,
        [Parameter(Mandatory = $true)][array]$Items
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/acl/v1/domains/$DomainId/allowed-cors-origins"
    
    $body = @{
        items = $Items
    }
    
    try {
        Invoke-RestMethod -Uri $uri -Method Put -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        } -Body ($body | ConvertTo-Json -Depth 10)
    } catch {
        Write-Error "Failed to modify allowed CORS origins: $_"
    }
}
