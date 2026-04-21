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

    $current = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/campaigns/v1/domains/$($global:Five9.DomainId)/campaigns/$CampaignId"
    if (-not $current) { return }
    $body = $current.items[0]

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
    if ($result -ne $false) { Write-Host "Outbound campaign '$CampaignName' updated successfully."; return $result } else { Write-Host "Failed to update outbound campaign '$CampaignName'."; return $false }
}
