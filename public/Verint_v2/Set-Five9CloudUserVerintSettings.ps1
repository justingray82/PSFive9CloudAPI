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

    # Validate against packages enabled on this domain (skip check if the lookup fails)
    if ($Packages) {
        $available = @(Get-Five9CloudDomainVerintPackages)
        if ($available.Count -gt 0) {
            $invalid = @($Packages | Where-Object { $_ -notin $available })
            if ($invalid.Count -gt 0) {
                Write-Host "Package(s) not enabled on domain $($global:Five9.DomainId): $($invalid -join ', '). Available: $($available -join ', ')" -ForegroundColor Red 
            }
        }
    }

    $uri = "$($global:Five9.ApiBaseUrl)/wfo-verint-config/v1/domains/$($global:Five9.DomainId)/users/$($UserUID)/verint-settings"
    $newDetails = Get-Five9CloudUserVerintDetails -UserUID $UserUID -Suppress

    if (-not $newDetails -or $newDetails -is [bool]) {
        # No existing record (API returns 404): create via POST, matching the Admin UI payload
        $body = @{ user = @{ userUID = $UserUID } }
        if ($Packages) { $body.packages = $Packages }
        if ($ScreenRecordingDomainName -or $ScreenRecordingLoginName) {
            $body.screenRecordingLoginSettings = @{}
            if ($ScreenRecordingDomainName) { $body.screenRecordingLoginSettings.domainName = $ScreenRecordingDomainName }
            if ($ScreenRecordingLoginName) { $body.screenRecordingLoginSettings.loginName = $ScreenRecordingLoginName }
        }
        $result = Invoke-Five9CloudApi $uri -Method Post -Body $body
        if ($result -ne $false) { Write-Host "Verint settings for $UserUID created successfully." } else { Write-Host "Unable to create Verint settings for $UserUID." }
        return
    }

    # Existing record: modify and PUT
    if ($ScreenRecordingDomainName -or $ScreenRecordingLoginName) {
        if (-not $newDetails.screenRecordingLoginSettings) {
            $newDetails | Add-Member -NotePropertyName screenRecordingLoginSettings -NotePropertyValue ([PSCustomObject]@{}) -Force
        }
        if ($ScreenRecordingDomainName) { $newDetails.screenRecordingLoginSettings | Add-Member -NotePropertyName domainName -NotePropertyValue $ScreenRecordingDomainName -Force }
        if ($ScreenRecordingLoginName) { $newDetails.screenRecordingLoginSettings | Add-Member -NotePropertyName loginName -NotePropertyValue $ScreenRecordingLoginName -Force }
    }
    if ($Packages) { $newDetails | Add-Member -NotePropertyName packages -NotePropertyValue $Packages -Force }
    $result = Invoke-Five9CloudApi $uri -Method Put -Body $newDetails
    if ($result -ne $false) { Write-Host "Verint settings for $UserUID updated successfully." } else { Write-Host "Unable to update Verint settings for $UserUID." }
}