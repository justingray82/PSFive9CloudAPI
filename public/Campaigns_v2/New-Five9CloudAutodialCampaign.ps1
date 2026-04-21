function New-Five9CloudAutodialCampaign {
    param(
        [Parameter(Mandatory)][string]$Name,
        [string]$Description,
        [string]$CampaignProfileId,
        [string]$CampaignProfileName,

        # Autodial optional
        [string]$Timezone,
        [string]$DefaultScriptId,
        [switch]$UseContactPhoneAsAniForConference,
        [int]$MaxNumOfLines,
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

    if (-not $CampaignProfileId -and $CampaignProfileName) { $CampaignProfileId = Resolve-Five9CloudCampaignProfileId $CampaignProfileName ; if (-not $CampaignProfileId) { return } }

    $body = @{ type = 'AUTODIAL'; name = $Name }
    if ($Description)       { $body.description     = $Description }
    if ($CampaignProfileId) { $body.campaignProfile = @{ campaignProfileId = $CampaignProfileId } }
    if ($Timezone)          { $body.timezone         = $Timezone }
    if ($DefaultScriptId)   { $body.defaultScript    = @{ ewScriptId = $DefaultScriptId } }
    if ($UseContactPhoneAsAniForConference)         { $body.useContactPhoneAsAniForConference = $true }
    if ($PSBoundParameters.ContainsKey('MaxNumOfLines')) { $body.maxNumOfLines = $MaxNumOfLines }
    if ($MaintenanceNotificationEmails) { $body.maintenanceNotificationEmails = $MaintenanceNotificationEmails }

    $recordings = @{}
    if ($AutoRecord)                      { $recordings.autoRecord                = $true }
    if ($UserCanControlRecording)         { $recordings.userCanControlRecording    = $true }
    if ($RecordQueueCallbacks)            { $recordings.recordQueueCallbacks       = $true }
    if ($DisableRecordingFilenamePattern) { $recordings.disableFilenamePattern     = $true }
    if ($ContinueRecordTo3rdParty)        { $recordings.continueRecordTo3rdParty   = $true }
    if ($ContinueRecordOnHoldCaller)      { $recordings.continueRecordOnHoldCaller = $true }
    if ($ContinueRecordOnHoldAgent)       { $recordings.continueRecordOnHoldAgent  = $true }
    if ($recordings.Count -gt 0)         { $body.recordings = $recordings }

    $transcripts = @{}
    if ($OverrideDomainTranscriptSettings) { $transcripts.overrideDomainSettings  = $true }
    if ($ExportChatTranscripts)            { $transcripts.exportChat              = $true }
    if ($ExportEmailTranscripts)           { $transcripts.exportEmail             = $true }
    if ($ExportSocialTranscripts)          { $transcripts.exportSocial            = $true }
    if ($DisableTranscriptFilenamePattern) { $transcripts.disableFilenamePattern  = $true }
    if ($transcripts.Count -gt 0)         { $body.transcripts = $transcripts }

    if ($WrapupTimeLimit -or $WrapupSetAgentNotReady -or $WrapupReasonCodeId -or $WrapupDispositionId) {
        $wrapup = @{ setAgentNotReady = [bool]$WrapupSetAgentNotReady }
        if ($WrapupTimeLimit)     { $wrapup.timeLimit   = $WrapupTimeLimit }
        if ($WrapupReasonCodeId)  { $wrapup.reasonCode  = @{ reasonCodeId  = $WrapupReasonCodeId } }
        if ($WrapupDispositionId) { $wrapup.disposition = @{ dispositionId = $WrapupDispositionId } }
        $body.callWrapup = $wrapup
    }

    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/campaigns/v1/domains/$($global:Five9.DomainId)/campaigns" -Method Post -Body $body
    if ($result -ne $false) { Write-Host "Autodial campaign '$Name' created successfully."; return $result } else { Write-Host "Failed to create autodial campaign '$Name'."; return $false }
}
