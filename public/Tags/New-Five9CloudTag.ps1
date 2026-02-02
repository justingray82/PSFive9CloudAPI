# Five9Cloud PowerShell Module
# Function: New-Five9CloudTag
# Category: Tags
function New-Five9CloudTag {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory = $true)][string]$Name,
        [string]$Description,
        [hashtable]$Parent
    )
    
    if (-not (Test-Five9CloudConnection -AutoReconnect)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/acl/v1/domains/$($global:Five9CloudToken.DomainId)/tags"
    
    $body = @{
        name = $Name
    }
    if ($Description) { $body['description'] = $Description }
    if ($Parent) { $body['parent'] = $Parent }
    
    try {
        Invoke-RestMethod -Uri $uri -Method Post -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        } -Body ($body | ConvertTo-Json -Depth 10)
    } catch {
        Write-Error "Failed to create tag: $_"
    }
}
