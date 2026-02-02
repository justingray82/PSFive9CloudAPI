# Five9Cloud PowerShell Module
# Function: Set-Five9CloudTag
# Category: Tags
function Set-Five9CloudTag {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory = $true)][string]$TagId,
        [Parameter(Mandatory = $true)][string]$Name,
        [string]$Description,
        [hashtable]$Parent
    )
    
    if (-not (Test-Five9CloudConnection -AutoReconnect)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/acl/v1/domains/$($global:Five9CloudToken.DomainId)/tags/$TagId"
    
    $body = @{
        name = $Name
    }
    if ($Description) { $body['description'] = $Description }
    if ($Parent) { $body['parent'] = $Parent }
    
    try {
        Invoke-RestMethod -Uri $uri -Method Put -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        } -Body ($body | ConvertTo-Json -Depth 10)
    } catch {
        Write-Error "Failed to update tag: $_"
    }
}
