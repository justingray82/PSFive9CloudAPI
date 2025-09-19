# Five9Cloud PowerShell Module
# Function: Remove-Five9CloudVerintSettings
# Category: VerintSettings
function Remove-Five9CloudVerintSettings {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory = $true)][string]$UserUID
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/wfo-verint-config/v1/domains/$($global:Five9CloudToken.DomainId)/users/$UserUID/verint-settings"
    
    try {
        Invoke-RestMethod -Uri $uri -Method Delete -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        }
    } catch {
        Write-Error "Failed to remove Verint settings: $_"
    }
}