function Set-Five9CloudInboundCampaign {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][string]$CampaignId,
        [string]$Name,
        [string]$Description,
        
        # IVR Schedule - Default Schedule Entry Parameters
        [string]$DefaultScriptId,
        [string]$DefaultScriptName,
        [hashtable[]]$DefaultScriptParameters,
        
        # IVR Schedule - Default Visual Channel Settings
        [bool]$DefaultCallbackEnabled,
        [bool]$DefaultChatEnabled,
        [bool]$DefaultVideoEnabled,
        [bool]$DefaultSentimentFeedbackEnabled,
        [bool]$DefaultEmailEnabled,
        [string]$DefaultTheme,
        [string]$DefaultCssThemeId,
        [bool]$DefaultXFrameOptionsEnabled,
        [string]$DefaultXFrameOption,
        [string]$DefaultXFrameOptionUrl,
        
        # IVR Schedule - General Settings
        [string]$TimeZoneId,
        [hashtable[]]$CustomScheduleEntries,
        
        # Line Capacity Settings
        [int]$MaxNumOfLines,
        [int]$MaxNumVivrSessions,
        [int]$MaxNumUniversalWfSessions,
        
        # Common Campaign Data - Basic Settings
        [string]$Mode,
        [string]$ProfileId,
        [string]$ProfileName,
        
        # Common Campaign Data - Skills
        [string[]]$Skills,
        [string[]]$SkillIds,
        
        # Common Campaign Data - Dispositions
        [string[]]$Dispositions,
        [hashtable[]]$DispositionAttributes,
        
        # Common Campaign Data - Recording Settings
        [bool]$AutoRecord,
        [bool]$UserCanControlRecording,
        [bool]$RecordQueueCallbacks,
        [bool]$ContinueRecordTo3rdParty,
        [bool]$RecordingNameAsSid,
        [bool]$ContinueRecordOnHoldAgent,
        [bool]$ContinueRecordOnHold,
        
        # Common Campaign Data - Recording FTP/SFTP Settings
        [ValidateSet('FTP', 'SFTP')]
        [string]$RecordingTransferType,
        [string]$RecordingFtpHost,
        [string]$RecordingFtpUserName,
        [string]$RecordingFtpPassword,
        [int]$RecordingFtpPort,
        [string]$RecordingSftpUserKey,
        [bool]$RecordingRewriteExistingFiles,
        
        # Common Campaign Data - Transcript Settings
        [bool]$ExportAsAID,
        [bool]$ExportChat,
        [bool]$ExportEmail,
        [bool]$ExportSocial,
        [bool]$ExportTranscript,
        
        # Common Campaign Data - Transcript Transfer Settings
        [ValidateSet('FTP', 'SFTP')]
        [string]$TranscriptTransferType,
        [string]$TranscriptFtpHost,
        [string]$TranscriptFtpUserName,
        [string]$TranscriptFtpPassword,
        [int]$TranscriptFtpPort,
        [string]$TranscriptSftpUserKey,
        [bool]$TranscriptRewriteExistingFiles,
        
        # Common Campaign Data - Call Wrapup Settings
        [string]$WrapupDispositionId,
        [int]$WrapupTimeoutDays,
        [int]$WrapupTimeoutHours,
        [int]$WrapupTimeoutMinutes,
        [int]$WrapupTimeoutSeconds,
        [string]$WrapupReasonCodeName,
        [string]$WrapupReasonCodeId,
        [bool]$WrapupAgentNotReady,
        [bool]$WrapupEnabled,
        
        # Common Campaign Data - Connectors
        [string[]]$ConnectorIds,
        [string[]]$ConnectorNames,
        [hashtable]$ConnectorConfigurations,
        [bool]$ConnectorsEnabled,
        
        # Common Campaign Data - Prompts
        [string]$PromptId,
        [string]$PromptName,
        [string]$PromptForWhisperingId,
        [string]$PromptForWhisperingName,
        
        # Common Campaign Data - Survey Settings
        [bool]$SurveyEnabled,
        [string]$SurveyCampaignId,
        [string]$SurveyCampaignName,
        [string]$SurveyCavId,
        [string]$SurveyCavName,
        [string]$SurveyName,
        [string]$SurveyDescription,
        
        # Common Campaign Data - Other Settings
        [string]$NoticeEmail,
        [string]$ConferenceOption,
        [bool]$DnisAsAniForConference,
        
        # Campaign-specific Settings
        [string]$Extension,
        [string[]]$DnisIds,
        [string[]]$DnisNames,
        
        # Line Utilization Settings
        [int]$InboundLineUtilizationThreshold,
        [string]$InboundLineUtilizationEmails,
        
        [string]$IfMatch = '*'
    )
    
    if (-not (Test-Five9CloudConnection)) { return }
    
    $uri = "$($global:Five9CloudToken.RestBaseUrl)/v1/domains/$($global:Five9CloudToken.DomainId)/campaigns/inbound_campaigns/$CampaignId"
    
    $headers = @{
        Authorization = "Basic $($global:Five9CloudToken.RestBasicAuth)"
        'Content-Type' = 'application/json'
    }
    
    if ($IfMatch) {
        $headers['If-Match'] = $IfMatch
    }
    
    $body = @{}
    
    if ($Name) { $body['name'] = $Name }
    if ($Description) { $body['description'] = $Description }
    
    # Build IVR Schedule if any related parameters are provided
    $ivrSchedule = @{}
    
    # Build Default Schedule Entry
    if ($DefaultScriptId -or $DefaultScriptName -or $DefaultScriptParameters -or
        $PSBoundParameters.ContainsKey('DefaultCallbackEnabled') -or 
        $PSBoundParameters.ContainsKey('DefaultChatEnabled') -or
        $DefaultTheme -or $DefaultCssThemeId) {
        
        $defaultScheduleEntry = @{}
        
        # General Data for default entry
        if ($DefaultScriptId -or $DefaultScriptName -or $DefaultScriptParameters) {
            $generalData = @{}
            if ($DefaultScriptId -or $DefaultScriptName) {
                $script = @{}
                if ($DefaultScriptId) { $script['id'] = $DefaultScriptId }
                if ($DefaultScriptName) { $script['name'] = $DefaultScriptName }
                $generalData['script'] = $script
            }
            if ($DefaultScriptParameters) { $generalData['scriptParameters'] = $DefaultScriptParameters }
            $defaultScheduleEntry['generalData'] = $generalData
        }
        
        # Visual Channel Settings for default entry
        $visualChannelSettings = @{}
        if ($PSBoundParameters.ContainsKey('DefaultCallbackEnabled')) { 
            $visualChannelSettings['callbackEnabled'] = $DefaultCallbackEnabled 
        }
        if ($PSBoundParameters.ContainsKey('DefaultChatEnabled')) { 
            $visualChannelSettings['chatEnabled'] = $DefaultChatEnabled 
        }
        if ($PSBoundParameters.ContainsKey('DefaultVideoEnabled')) { 
            $visualChannelSettings['videoEnabled'] = $DefaultVideoEnabled 
        }
        if ($PSBoundParameters.ContainsKey('DefaultSentimentFeedbackEnabled')) { 
            $visualChannelSettings['sentimentFeedbackEnabled'] = $DefaultSentimentFeedbackEnabled 
        }
        if ($PSBoundParameters.ContainsKey('DefaultEmailEnabled')) { 
            $visualChannelSettings['emailEnabled'] = $DefaultEmailEnabled 
        }
        if ($DefaultTheme) { $visualChannelSettings['theme'] = $DefaultTheme }
        if ($DefaultCssThemeId) {
            $visualChannelSettings['cssTheme'] = @{ id = $DefaultCssThemeId }
        }
        if ($PSBoundParameters.ContainsKey('DefaultXFrameOptionsEnabled')) { 
            $visualChannelSettings['xFrameOptionsEnabled'] = $DefaultXFrameOptionsEnabled 
        }
        if ($DefaultXFrameOption) { $visualChannelSettings['xFrameOption'] = $DefaultXFrameOption }
        if ($DefaultXFrameOptionUrl) { $visualChannelSettings['xFrameOptionUrl'] = $DefaultXFrameOptionUrl }
        
        if ($visualChannelSettings.Count -gt 0) { 
            $defaultScheduleEntry['visualChannelSettings'] = $visualChannelSettings 
        }
        
        if ($defaultScheduleEntry.Count -gt 0) { $ivrSchedule['defaultScheduleEntry'] = $defaultScheduleEntry }
    }
    
    if ($TimeZoneId) { $ivrSchedule['timeZoneId'] = $TimeZoneId }
    if ($CustomScheduleEntries) { $ivrSchedule['customScheduleEntries'] = $CustomScheduleEntries }
    
    if ($ivrSchedule.Count -gt 0) { $body['ivrSchedule'] = $ivrSchedule }
    
    # Line Capacity Settings
    if ($PSBoundParameters.ContainsKey('MaxNumOfLines')) { $body['maxNumOfLines'] = $MaxNumOfLines }
    if ($PSBoundParameters.ContainsKey('MaxNumVivrSessions')) { $body['maxNumVivrSessions'] = $MaxNumVivrSessions }
    if ($PSBoundParameters.ContainsKey('MaxNumUniversalWfSessions')) { 
        $body['maxNumUniversalWfSessions'] = $MaxNumUniversalWfSessions 
    }
    
    # Build Common Campaign Data
    $commonCampaignData = @{}
    
    if ($Mode) { $commonCampaignData['mode'] = $Mode }
    
    # Profile
    if ($ProfileId -or $ProfileName) {
        $profile = @{}
        if ($ProfileId) { $profile['id'] = $ProfileId }
        if ($ProfileName) { $profile['name'] = $ProfileName }
        $commonCampaignData['profile'] = $profile
    }
    
    # Skills
    if ($Skills -or $SkillIds) {
        $skillsList = @()
        if ($Skills) {
            foreach ($skill in $Skills) {
                $skillsList += @{ name = $skill }
            }
        }
        if ($SkillIds) {
            foreach ($skillId in $SkillIds) {
                $skillsList += @{ id = $skillId }
            }
        }
        $commonCampaignData['skills'] = $skillsList
    }
    
    # Dispositions
    if ($Dispositions) { $commonCampaignData['dispositions'] = $Dispositions }
    if ($DispositionAttributes) { $commonCampaignData['dispositionAttributes'] = $DispositionAttributes }
    
    # Recording Settings
    if ($PSBoundParameters.ContainsKey('AutoRecord') -or 
        $PSBoundParameters.ContainsKey('UserCanControlRecording') -or
        $PSBoundParameters.ContainsKey('RecordQueueCallbacks') -or
        $RecordingTransferType -or $RecordingFtpHost) {
        
        $recording = @{}
        if ($PSBoundParameters.ContainsKey('AutoRecord')) { $recording['autoRecord'] = $AutoRecord }
        if ($PSBoundParameters.ContainsKey('UserCanControlRecording')) { 
            $recording['userCanControlRecording'] = $UserCanControlRecording 
        }
        if ($PSBoundParameters.ContainsKey('RecordQueueCallbacks')) { 
            $recording['recordQueueCallbacks'] = $RecordQueueCallbacks 
        }
        if ($PSBoundParameters.ContainsKey('ContinueRecordTo3rdParty')) { 
            $recording['continueRecordTo3rdParty'] = $ContinueRecordTo3rdParty 
        }
        if ($PSBoundParameters.ContainsKey('RecordingNameAsSid')) { 
            $recording['recordingNameAsSid'] = $RecordingNameAsSid 
        }
        if ($PSBoundParameters.ContainsKey('ContinueRecordOnHoldAgent')) { 
            $recording['continueRecordOnHoldAgent'] = $ContinueRecordOnHoldAgent 
        }
        if ($PSBoundParameters.ContainsKey('ContinueRecordOnHold')) { 
            $recording['continueRecordOnHold'] = $ContinueRecordOnHold 
        }
        
        # FTP/SFTP Credentials
        if ($RecordingTransferType -or $RecordingFtpHost -or $RecordingFtpUserName) {
            $ftpCredentials = @{}
            if ($RecordingTransferType) { $ftpCredentials['type'] = $RecordingTransferType }
            
            if ($RecordingTransferType -eq 'FTP' -or -not $RecordingTransferType) {
                $ftp = @{}
                if ($RecordingFtpHost) { $ftp['host'] = $RecordingFtpHost }
                if ($RecordingFtpUserName) { $ftp['userName'] = $RecordingFtpUserName }
                if ($RecordingFtpPassword) { $ftp['password'] = $RecordingFtpPassword }
                if ($PSBoundParameters.ContainsKey('RecordingFtpPort')) { $ftp['port'] = $RecordingFtpPort }
                if ($ftp.Count -gt 0) { $ftpCredentials['ftp'] = $ftp }
            }
            
            if ($RecordingTransferType -eq 'SFTP') {
                $sftp = @{}
                if ($RecordingFtpHost) { $sftp['host'] = $RecordingFtpHost }
                if ($RecordingFtpUserName) { $sftp['userName'] = $RecordingFtpUserName }
                if ($RecordingFtpPassword) { $sftp['password'] = $RecordingFtpPassword }
                if ($PSBoundParameters.ContainsKey('RecordingFtpPort')) { $sftp['port'] = $RecordingFtpPort }
                if ($RecordingSftpUserKey) { $sftp['userKey'] = $RecordingSftpUserKey }
                if ($sftp.Count -gt 0) { $ftpCredentials['sftp'] = $sftp }
            }
            
            if ($PSBoundParameters.ContainsKey('RecordingRewriteExistingFiles')) { 
                $ftpCredentials['rewriteExistingFiles'] = $RecordingRewriteExistingFiles 
            }
            
            if ($ftpCredentials.Count -gt 0) { $recording['ftpCredentials'] = $ftpCredentials }
        }
        
        if ($recording.Count -gt 0) { $commonCampaignData['recording'] = $recording }
    }
    
    # Transcript Settings
    if ($PSBoundParameters.ContainsKey('ExportAsAID') -or 
        $PSBoundParameters.ContainsKey('ExportChat') -or
        $PSBoundParameters.ContainsKey('ExportEmail') -or
        $TranscriptTransferType -or $TranscriptFtpHost) {
        
        $transcripts = @{}
        if ($PSBoundParameters.ContainsKey('ExportAsAID')) { $transcripts['exportAsAID'] = $ExportAsAID }
        if ($PSBoundParameters.ContainsKey('ExportChat')) { $transcripts['exportChat'] = $ExportChat }
        if ($PSBoundParameters.ContainsKey('ExportEmail')) { $transcripts['exportEmail'] = $ExportEmail }
        if ($PSBoundParameters.ContainsKey('ExportSocial')) { $transcripts['exportSocial'] = $ExportSocial }
        if ($PSBoundParameters.ContainsKey('ExportTranscript')) { $transcripts['exportTranscript'] = $ExportTranscript }
        
        # Transcript Transfer Credentials
        if ($TranscriptTransferType -or $TranscriptFtpHost -or $TranscriptFtpUserName) {
            $transcriptsCredentials = @{}
            if ($TranscriptTransferType) { $transcriptsCredentials['type'] = $TranscriptTransferType }
            
            if ($TranscriptTransferType -eq 'FTP' -or -not $TranscriptTransferType) {
                $ftp = @{}
                if ($TranscriptFtpHost) { $ftp['host'] = $TranscriptFtpHost }
                if ($TranscriptFtpUserName) { $ftp['userName'] = $TranscriptFtpUserName }
                if ($TranscriptFtpPassword) { $ftp['password'] = $TranscriptFtpPassword }
                if ($PSBoundParameters.ContainsKey('TranscriptFtpPort')) { $ftp['port'] = $TranscriptFtpPort }
                if ($ftp.Count -gt 0) { $transcriptsCredentials['ftp'] = $ftp }
            }
            
            if ($TranscriptTransferType -eq 'SFTP') {
                $sftp = @{}
                if ($TranscriptFtpHost) { $sftp['host'] = $TranscriptFtpHost }
                if ($TranscriptFtpUserName) { $sftp['userName'] = $TranscriptFtpUserName }
                if ($TranscriptFtpPassword) { $sftp['password'] = $TranscriptFtpPassword }
                if ($PSBoundParameters.ContainsKey('TranscriptFtpPort')) { $sftp['port'] = $TranscriptFtpPort }
                if ($TranscriptSftpUserKey) { $sftp['userKey'] = $TranscriptSftpUserKey }
                if ($sftp.Count -gt 0) { $transcriptsCredentials['sftp'] = $sftp }
            }
            
            if ($PSBoundParameters.ContainsKey('TranscriptRewriteExistingFiles')) { 
                $transcriptsCredentials['rewriteExistingFiles'] = $TranscriptRewriteExistingFiles 
            }
            
            if ($transcriptsCredentials.Count -gt 0) { $transcripts['transcriptsCredentials'] = $transcriptsCredentials }
        }
        
        if ($transcripts.Count -gt 0) { $commonCampaignData['transcripts'] = $transcripts }
    }
    
    # Call Wrapup Settings
    if ($WrapupDispositionId -or $PSBoundParameters.ContainsKey('WrapupTimeoutDays') -or
        $WrapupReasonCodeName -or $PSBoundParameters.ContainsKey('WrapupEnabled')) {
        
        $callWrapup = @{}
        
        if ($WrapupDispositionId) { $callWrapup['disposition'] = @{ id = $WrapupDispositionId } }
        
        if ($PSBoundParameters.ContainsKey('WrapupTimeoutDays') -or 
            $PSBoundParameters.ContainsKey('WrapupTimeoutHours') -or
            $PSBoundParameters.ContainsKey('WrapupTimeoutMinutes') -or
            $PSBoundParameters.ContainsKey('WrapupTimeoutSeconds')) {
            $timeout = @{}
            if ($PSBoundParameters.ContainsKey('WrapupTimeoutDays')) { $timeout['days'] = $WrapupTimeoutDays }
            if ($PSBoundParameters.ContainsKey('WrapupTimeoutHours')) { $timeout['hours'] = $WrapupTimeoutHours }
            if ($PSBoundParameters.ContainsKey('WrapupTimeoutMinutes')) { $timeout['minutes'] = $WrapupTimeoutMinutes }
            if ($PSBoundParameters.ContainsKey('WrapupTimeoutSeconds')) { $timeout['seconds'] = $WrapupTimeoutSeconds }
            $callWrapup['timeout'] = $timeout
        }
        
        if ($WrapupReasonCodeName) { $callWrapup['reasonCodeName'] = $WrapupReasonCodeName }
        if ($WrapupReasonCodeId) { $callWrapup['reasonCode'] = @{ id = $WrapupReasonCodeId } }
        if ($PSBoundParameters.ContainsKey('WrapupAgentNotReady')) { $callWrapup['agentNotReady'] = $WrapupAgentNotReady }
        if ($PSBoundParameters.ContainsKey('WrapupEnabled')) { $callWrapup['enabled'] = $WrapupEnabled }
        
        if ($callWrapup.Count -gt 0) { $commonCampaignData['callWrapup'] = $callWrapup }
    }
    
    # Connectors
    if ($ConnectorIds -or $ConnectorNames -or $ConnectorConfigurations -or 
        $PSBoundParameters.ContainsKey('ConnectorsEnabled') -or $ConnectorPriority) {

        $connectors = @()
        
        $names = @($ConnectorNames)
        $ids   = @($ConnectorIds)
        $max = [Math]::Max($names.Count, $ids.Count)
            for ($i = 0; $i -lt $max; $i++) {
            $c = @{}
            if ($i -lt $names.Count -and $names[$i]) { $c.name = $names[$i] }
            if ($i -lt $ids.Count   -and $ids[$i])   { $c.id   = $ids[$i] }
            if ($ConnectorConfigurations)            { $c.configurations = $ConnectorConfigurations }
            if ($PSBoundParameters.ContainsKey('ConnectorsEnabled')) { $c.enabled  = $ConnectorsEnabled }
            if ($ConnectorPriority)                  { $c.priority = $ConnectorPriority }
            if ($c.Count -gt 0) { $connectors += $c }
            }
        if ($connectors.Count -gt 0) { $commonCampaignData['connectors'] = $connectors }
    }
    
    # Prompts
    if ($PromptId -or $PromptName) {
        $prompt = @{}
        if ($PromptId) { $prompt['id'] = $PromptId }
        if ($PromptName) { $prompt['name'] = $PromptName }
        $commonCampaignData['prompt'] = $prompt
    }
    
    if ($PromptForWhisperingId -or $PromptForWhisperingName) {
        $promptForWhispering = @{}
        if ($PromptForWhisperingId) { $promptForWhispering['id'] = $PromptForWhisperingId }
        if ($PromptForWhisperingName) { $promptForWhispering['name'] = $PromptForWhisperingName }
        $commonCampaignData['promptForWhispering'] = $promptForWhispering
    }
    
    # Survey Settings
    if ($PSBoundParameters.ContainsKey('SurveyEnabled')) { $commonCampaignData['surveyEnabled'] = $SurveyEnabled }
    if ($SurveyCampaignId -or $SurveyCampaignName) {
        $surveyCampaign = @{}
        if ($SurveyCampaignId) { $surveyCampaign['id'] = $SurveyCampaignId }
        if ($SurveyCampaignName) { $surveyCampaign['name'] = $SurveyCampaignName }
        $commonCampaignData['surveyCampaign'] = $surveyCampaign
    }
    if ($SurveyCavId -or $SurveyCavName) {
        $surveyCav = @{}
        if ($SurveyCavId) { $surveyCav['id'] = $SurveyCavId }
        if ($SurveyCavName) { $surveyCav['name'] = $SurveyCavName }
        $commonCampaignData['surveyCav'] = $surveyCav
    }
    if ($SurveyName) { $commonCampaignData['surveyName'] = $SurveyName }
    if ($SurveyDescription) { $commonCampaignData['surveyDescription'] = $SurveyDescription }
    
    # Other Settings
    if ($NoticeEmail) { $commonCampaignData['noticeEmail'] = $NoticeEmail }
    if ($ConferenceOption) { $commonCampaignData['conferenceOption'] = $ConferenceOption }
    if ($PSBoundParameters.ContainsKey('DnisAsAniForConference')) { 
        $commonCampaignData['dnisAsAniForConference'] = $DnisAsAniForConference 
    }
    
    if ($commonCampaignData.Count -gt 0) { $body['commonCampaignData'] = $commonCampaignData }
    
    # Campaign-specific Settings
    if ($Extension) { $body['extension'] = $Extension }
    
    # DNIS Settings
    if ($DnisIds -or $DnisNames) {
        $dnises = @()
        if ($DnisIds) {
            foreach ($dnisId in $DnisIds) {
                $dnises += @{ id = $dnisId }
            }
        }
        if ($DnisNames) {
            foreach ($dnisName in $DnisNames) {
                $dnises += @{ name = $dnisName }
            }
        }
        $body['dnises'] = $dnises
    }
    
    # Line Utilization Settings
    if ($PSBoundParameters.ContainsKey('InboundLineUtilizationThreshold')) { 
        $body['inboundLineUtilizationThreshold'] = $InboundLineUtilizationThreshold 
    }
    if ($InboundLineUtilizationEmails) { 
        $body['inboundLineUtilizationEmails'] = $InboundLineUtilizationEmails 
    }
    
    try {
        Invoke-RestMethod -Uri $uri -Method Put -Headers $headers -Body ($body | ConvertTo-Json -Depth 10)
    } catch {
        Write-Error "Failed to update inbound campaign: $_"
    }
}