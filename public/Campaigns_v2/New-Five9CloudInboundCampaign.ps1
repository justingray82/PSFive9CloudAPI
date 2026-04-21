function New-Five9CloudInboundCampaign {
    param(
        [Parameter(Mandatory)][string]$Name,
        [string]$Description,
        [string]$CampaignProfileId,
        [string]$CampaignProfileName,

        # Inbound required
        [Parameter(Mandatory)][string]$Timezone,
        [Parameter(Mandatory)][string]$DefaultScriptId,

        # Inbound optional
        [string]$Extension,
        [switch]$UseContactPhoneAsAniForConference,
        [int]$MaxNumVoiceLines,
        [int]$MaxNumVivrSessions,
        [int]$MaxNumTextInteractions,
        [int]$InboundLineUtilizationThreshold,
        [string[]]$InboundLineUtilizationEmails,
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

    $body = @{ type = 'INBOUND'; name = $Name; defaultScript = @{ ewScriptId = $DefaultScriptId }; timezone = $Timezone }
    if ($Description)            { $body.description   = $Description }
    if ($CampaignProfileId)      { $body.campaignProfile = @{ campaignProfileId = $CampaignProfileId } }
    if ($Extension)              { $body.extension     = $Extension }
    if ($UseContactPhoneAsAniForConference) { $body.useContactPhoneAsAniForConference = $true }
    if ($PSBoundParameters.ContainsKey('MaxNumVoiceLines'))               { $body.maxNumVoiceLines               = $MaxNumVoiceLines }
    if ($PSBoundParameters.ContainsKey('MaxNumVivrSessions'))             { $body.maxNumVivrSessions             = $MaxNumVivrSessions }
    if ($PSBoundParameters.ContainsKey('MaxNumTextInteractions'))         { $body.maxNumTextInteractions         = $MaxNumTextInteractions }
    if ($PSBoundParameters.ContainsKey('InboundLineUtilizationThreshold')){ $body.inboundLineUtilizationThreshold = $InboundLineUtilizationThreshold }
    if ($InboundLineUtilizationEmails)   { $body.inboundLineUtilizationEmails   = $InboundLineUtilizationEmails }
    if ($MaintenanceNotificationEmails)  { $body.maintenanceNotificationEmails  = $MaintenanceNotificationEmails }

    $recordings = @{}
    if ($AutoRecord)                      { $recordings.autoRecord                   = $true }
    if ($UserCanControlRecording)         { $recordings.userCanControlRecording       = $true }
    if ($RecordQueueCallbacks)            { $recordings.recordQueueCallbacks          = $true }
    if ($DisableRecordingFilenamePattern) { $recordings.disableFilenamePattern        = $true }
    if ($ContinueRecordTo3rdParty)        { $recordings.continueRecordTo3rdParty      = $true }
    if ($ContinueRecordOnHoldCaller)      { $recordings.continueRecordOnHoldCaller    = $true }
    if ($ContinueRecordOnHoldAgent)       { $recordings.continueRecordOnHoldAgent     = $true }
    if ($recordings.Count -gt 0)         { $body.recordings = $recordings }

    $transcripts = @{}
    if ($OverrideDomainTranscriptSettings)  { $transcripts.overrideDomainSettings     = $true }
    if ($ExportChatTranscripts)             { $transcripts.exportChat                 = $true }
    if ($ExportEmailTranscripts)            { $transcripts.exportEmail                = $true }
    if ($ExportSocialTranscripts)           { $transcripts.exportSocial               = $true }
    if ($DisableTranscriptFilenamePattern)  { $transcripts.disableFilenamePattern      = $true }
    if ($transcripts.Count -gt 0)          { $body.transcripts = $transcripts }

    if ($WrapupTimeLimit -or $WrapupSetAgentNotReady -or $WrapupReasonCodeId -or $WrapupDispositionId) {
        $wrapup = @{ setAgentNotReady = [bool]$WrapupSetAgentNotReady }
        if ($WrapupTimeLimit)      { $wrapup.timeLimit   = $WrapupTimeLimit }
        if ($WrapupReasonCodeId)   { $wrapup.reasonCode  = @{ reasonCodeId  = $WrapupReasonCodeId } }
        if ($WrapupDispositionId)  { $wrapup.disposition = @{ dispositionId = $WrapupDispositionId } }
        $body.callWrapup = $wrapup
    }

    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/campaigns/v1/domains/$($global:Five9.DomainId)/campaigns" -Method Post -Body $body
    if ($result -ne $false) { Write-Host "Inbound campaign '$Name' created successfully."; return $result } else { Write-Host "Failed to create inbound campaign '$Name'."; return $false }
}
