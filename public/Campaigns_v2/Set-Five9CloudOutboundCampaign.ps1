function Set-Five9CloudOutboundCampaign {
    param(
        [string]$CampaignId,
        [string]$CampaignName,

        # Base fields
        [string]$Name,
        [string]$Description,
        [string]$CampaignProfileId,
        [string]$CampaignProfileName,

        # Outbound fields
        [switch]$UseContactPhoneAsAniForConference,
        [string[]]$MaintenanceNotificationEmails,

        # Recordings
        [switch]$AutoRecord,
        [switch]$UserCanControlRecording,
        [switch]$RecordQueueCallbacks,
        [switch]$DisableRecordingFilenamePattern,
        [switch]$ContinueRecordTo3rdParty,
        [switch]$ContinueRecordOnHoldCaller,
        [switch]$ContinueRecordOnHoldAgent,
        # [bool] not [switch] so -Byot $false can turn it back off.
        # Separate endpoint: recordings/v1/.../recording-settings (recordingSettingsEnabled = -not Byot)
        [bool]$Byot,

        # Transcripts
        [switch]$OverrideDomainTranscriptSettings,
        [switch]$ExportChatTranscripts,
        [switch]$ExportEmailTranscripts,
        [switch]$ExportSocialTranscripts,
        [switch]$DisableTranscriptFilenamePattern,

        # Call Wrapup
        [string]$WrapupTimeLimit,
        [switch]$WrapupSetAgentNotReady,
        [string]$WrapupReasonCodeId,
        [string]$WrapupDispositionId
    )

    if (-not $CampaignId) { $CampaignId = Resolve-Five9CloudCampaignId $CampaignId $CampaignName } ; if (-not $CampaignId) { return }
    if (-not $CampaignProfileId -and $CampaignProfileName) { $CampaignProfileId = Resolve-Five9CloudCampaignProfileId $CampaignProfileName ; if (-not $CampaignProfileId) { return } }

    $label = if ($CampaignName) { $CampaignName } else { $CampaignId }

    # ── BYOT (recording-settings endpoint) ──────────────────────────────
    if ($PSBoundParameters.ContainsKey('Byot')) {
        $rsUri    = "$($global:Five9.ApiBaseUrl)/recordings/v1/domains/$($global:Five9.DomainId)/campaigns/$CampaignId/recording-settings"
        $rsResult = Invoke-Five9CloudApi $rsUri -Method Put -Body @{ recordingSettingsEnabled = (-not $Byot) }
        if ($rsResult -ne $false) { Write-Host "BYOT $(if ($Byot) { 'enabled' } else { 'disabled' }) on outbound campaign '$label'." }
        else                      { Write-Host "Failed to update BYOT on outbound campaign '$label'." }
    }

    # Skip the campaign GET/PUT entirely if nothing for that endpoint was passed
    $hasCampaignChanges = $false
    foreach ($k in $PSBoundParameters.Keys) { if (@('CampaignId','CampaignName','Byot') -notcontains $k) { $hasCampaignChanges = $true } }
    if (-not $hasCampaignChanges) { return }

    $current = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/campaigns/v1/domains/$($global:Five9.DomainId)/campaigns/$CampaignId"
    if (-not $current) { return }

    # Convert to hashtable so we can safely mutate (avoids null-property assignment issues)
    $body = @{}
    $current.PSObject.Properties | ForEach-Object { $body[$_.Name] = $_.Value }

    # Strip fields the PUT endpoint rejects / are read-only metadata
    foreach ($ro in 'uri','state','stateLastModifiedOn','systemMessage') { $body.Remove($ro) }
    if ($body.campaignProfile) { $body.campaignProfile = @{ campaignProfileId = $body.campaignProfile.campaignProfileId } }
    if ($body.defaultScript)   { $body.defaultScript   = @{ ewScriptId        = $body.defaultScript.ewScriptId } }

    $body.type = 'OUTBOUND'
    if ($Name)              { $body.name            = $Name }
    if ($Description)       { $body.description     = $Description }
    if ($CampaignProfileId) { $body.campaignProfile = @{ campaignProfileId = $CampaignProfileId } }
    if ($UseContactPhoneAsAniForConference)   { $body.useContactPhoneAsAniForConference  = $true }
    if ($MaintenanceNotificationEmails)       { $body.maintenanceNotificationEmails       = $MaintenanceNotificationEmails }

    $recordings = if ($body.recordings) { $body.recordings } else { @{} }
    if ($AutoRecord)                      { $recordings.autoRecord                = $true }
    if ($UserCanControlRecording)         { $recordings.userCanControlRecording    = $true }
    if ($RecordQueueCallbacks)            { $recordings.recordQueueCallbacks       = $true }
    if ($DisableRecordingFilenamePattern) { $recordings.disableFilenamePattern     = $true }
    if ($ContinueRecordTo3rdParty)        { $recordings.continueRecordTo3rdParty   = $true }
    if ($ContinueRecordOnHoldCaller)      { $recordings.continueRecordOnHoldCaller = $true }
    if ($ContinueRecordOnHoldAgent)       { $recordings.continueRecordOnHoldAgent  = $true }
    $body.recordings = $recordings

    $transcripts = if ($body.transcripts) { $body.transcripts } else { @{} }
    if ($OverrideDomainTranscriptSettings) { $transcripts.overrideDomainSettings = $true }
    if ($ExportChatTranscripts)            { $transcripts.exportChat             = $true }
    if ($ExportEmailTranscripts)           { $transcripts.exportEmail            = $true }
    if ($ExportSocialTranscripts)          { $transcripts.exportSocial           = $true }
    if ($DisableTranscriptFilenamePattern) { $transcripts.disableFilenamePattern = $true }
    $body.transcripts = $transcripts

    if ($WrapupTimeLimit -or $WrapupSetAgentNotReady -or $WrapupReasonCodeId -or $WrapupDispositionId) {
        $wrapup = if ($body.callWrapup) { $body.callWrapup } else { @{ setAgentNotReady = $false } }
        if ($WrapupSetAgentNotReady)  { $wrapup.setAgentNotReady = $true }
        if ($WrapupTimeLimit)         { $wrapup.timeLimit   = $WrapupTimeLimit }
        if ($WrapupReasonCodeId)      { $wrapup.reasonCode  = @{ reasonCodeId  = $WrapupReasonCodeId } }
        if ($WrapupDispositionId)     { $wrapup.disposition = @{ dispositionId = $WrapupDispositionId } }
        $body.callWrapup = $wrapup
    }

    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/campaigns/v1/domains/$($global:Five9.DomainId)/campaigns/$CampaignId" -Method Put -Body $body
    if ($result -ne $false) { Write-Host "Outbound campaign '$label' updated successfully." } else { Write-Host "Failed to update outbound campaign '$label'." }
}