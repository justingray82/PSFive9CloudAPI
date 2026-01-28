# Five9Cloud PowerShell Module
# Function: Add-Five9CloudVerintSettings
# Category: VerintSettings
function Set-Five9CloudVerintSettings {
    [CmdletBinding()]
    param (

        [Parameter(Mandatory = $true)][string]$UserUID,
        [Parameter(Mandatory = $true)]
        [ValidateSet(
            'call-recording',
            'call-recording.screen-recording',
            'call-recording.quality-monitoring',
            'call-recording.quality-monitoring.analytics-driven-quality',
            'call-recording.speech-analytics',
            'workforce-management',
            'performance-management',
            'call-recording.advanced-desktop-analytics'
        )]
        [string[]]$Packages,
		[string]$ScreenRecordingDomainName,
		[string]$ScreenRecordingLoginName
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.ApiBaseUrl)/wfo-verint-config/v1/domains/$($global:Five9CloudToken.DomainId)/users/$UserUID/verint-settings"
    
    # Validate that both screen recording parameters are provided together or neither is provided
    $hasDomainName = -not [string]::IsNullOrEmpty($ScreenRecordingDomainName)
    $hasLoginName = -not [string]::IsNullOrEmpty($ScreenRecordingLoginName)
    
    if ($hasDomainName -xor $hasLoginName) {
        Write-Host "Missing required paired parameter. Parameters Domain Name and Login Name are dependent and must be used together."
        return
    }
    
    # Build the base body with packages
    $body = @{
        packages = $Packages
    }
    
    # Add screenRecordingLoginSettings if both domain name and login name are provided
    if ($hasDomainName -and $hasLoginName) {
        $body['screenRecordingLoginSettings'] = @{
            domainName = $ScreenRecordingDomainName
            loginName = $ScreenRecordingLoginName
        }
    }
    
    $jsonBody = $body | ConvertTo-Json -Depth 3
    
    try {
        Invoke-RestMethod -Uri $uri -Method Put -Headers @{
            Authorization = "Bearer $($global:Five9CloudToken.AccessToken)"
            'Content-Type' = 'application/json'
        } -Body $jsonBody
    } catch {
        Write-Error "Failed to add Verint settings: $_"
    }
}