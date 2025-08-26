# Five9Cloud PowerShell Module
# Function: Get-Five9CloudApplication
# Category: Applications
function Get-Five9CloudApplication {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][string]$AppId
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/acl/v1/applications/$AppId"
    
    try {
        Invoke-RestMethod -Uri $uri -Method Get -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        }
    } catch {
        Write-Error "Failed to retrieve application: $_"
    }
}
