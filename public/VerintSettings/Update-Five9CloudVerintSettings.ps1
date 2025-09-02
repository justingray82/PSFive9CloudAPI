# Five9Cloud PowerShell Module
# Function: Update-Five9CloudVerintSettings
# Category: VerintSettings
function Update-Five9CloudVerintSettings {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false)][string]$DomainId = $global:Five9CloudToken.DomainId,
        [Parameter(Mandatory = $true)][string]$UserUID,
        [Parameter(Mandatory = $true)]
        [ValidateSet(
            'call-recording',
            'call-recording.quality-monitoring',
            'call-recording.quality-monitoring.analytics-driven-quality',
            'call-recording.speech-analytics',
            'workforce-management',
            'performance-management',
            'call-recording.advanced-desktop-analytics'
        )]
        [string[]]$Packages
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/wfo-verint-config/v1/domains/$DomainId/users/$UserUID/verint-settings"
    
    $body = @{
        packages = $Packages
    } | ConvertTo-Json
    
    try {
        Invoke-RestMethod -Uri $uri -Method Put -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        } -Body $body
    } catch {
        Write-Error "Failed to update Verint settings: $_"
    }
}