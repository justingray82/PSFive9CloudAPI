# Five9Cloud PowerShell Module
# Function: New-Five9CloudRole
# Category: Roles
function New-Five9CloudRole {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)][string]$DomainId = $global:Five9CloudToken.DomainId,
        [string]$FromRole,
        [Parameter(Mandatory = $true)][string]$Name,
        [string]$Description,
        [string]$Status,
        [string[]]$Permissions,
        [hashtable]$Filter
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/acl/v1/domains/$DomainId/roles"
    
    if ($FromRole) {
        $uri += "?fromRole=$FromRole"
    }
    
    $body = @{
        name = $Name
    }
    if ($Description) { $body['description'] = $Description }
    if ($Status) { $body['status'] = $Status }
    if ($Permissions) { $body['permissions'] = $Permissions }
    if ($Filter) { $body['filter'] = $Filter }
    
    try {
        Invoke-RestMethod -Uri $uri -Method Post -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        } -Body ($body | ConvertTo-Json -Depth 10)
    } catch {
        Write-Error "Failed to create role: $_"
    }
}
