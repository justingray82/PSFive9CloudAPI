# Five9Cloud PowerShell Module
# Function: Get-Five9CloudVerintSetting
# Category: VerintSettings
# CONSOLIDATED VERSION - Single function (only one Get function exists)

function Get-Five9CloudVerintSetting {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)]
        [string]$DomainId = $global:Five9CloudToken.DomainId,
        
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$UserUID
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    # Original: Get-Five9CloudVerintSettings
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
