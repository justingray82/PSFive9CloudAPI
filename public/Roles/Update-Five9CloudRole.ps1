# Five9Cloud PowerShell Module
# Function: Update-Five9CloudRole
# Category: Roles
function Update-Five9CloudRole {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory = $true)][string]$Role,
        [string]$Name,
        [string]$Description,
        [string]$Status,
        [hashtable]$Filter
    )
    
    if (-not (Test-Five9CloudConnection -AutoReconnect)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/acl/v1/domains/$($global:Five9CloudToken.DomainId)/roles/$Role"
    
    $body = @{}
    if ($Name) { $body['name'] = $Name }
    if ($Description) { $body['description'] = $Description }
    if ($Status) { $body['status'] = $Status }
    if ($Filter) { $body['filter'] = $Filter }
    
    try {
        Invoke-RestMethod -Uri $uri -Method Put -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        } -Body ($body | ConvertTo-Json -Depth 10)
    } catch {
        Write-Error "Failed to update role: $_"
    }
}
