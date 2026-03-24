function Set-Five9CloudUserVerintSettings {
    param(
        [string]$Username,
        [string]$UserUID,
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

    if (-not $UserUID) { $UserUID = Resolve-Five9CloudUserUID $Username } if (-not $UserUID) { return }
    $newDetails = Get-Five9CloudUserVerintDetails -UserUID $UserUID
    if ($ScreenRecordingDomainName) { $newDetails.screenRecordingLoginSettings.domainName = $ScreenRecordingDomainName }
    if ($ScreenRecordingLoginName) { $newDetails.screenRecordingLoginSettings.loginName = $ScreenRecordingLoginName }
    if ($Packages) { $newDetails.packages = $Packages }
    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/wfo-verint-config/v1/domains/$($global:Five9.DomainId)/users/$($UserUID)/verint-settings" -Method Put -Body $newDetails
    if ($result -ne $false) { Write-Host "Verint settings for $UserUID updated successfully." } else { Write-Host "Unable to update Verint settings for $UserUID." }
}