# Five9Cloud PowerShell Module
# Function: Get-Five9CloudVerintSettings
# Category: VerintSettings
function Get-Five9CloudVerintSettings {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)][string]$DomainId = $global:Five9CloudToken.DomainId,
        [Parameter(Mandatory = $true)][string]$UserUID
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/wfo-verint-config/v1/domains/$DomainId/users/$UserUID/verint-settings"
    
    try {
        Invoke-RestMethod -Uri $uri -Method Get -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        }
    } catch {
        # Handle 404 specifically - this means no Verint settings exist for the user
        if ($_.Exception.Response.StatusCode -eq 404) {
            Write-Host "No Verint settings found for user $UserUID"
        } else {
            Write-Error "Failed to get Verint settings: $_"
        }
    }
}