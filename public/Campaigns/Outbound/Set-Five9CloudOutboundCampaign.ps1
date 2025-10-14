function Set-Five9CloudOutboundCampaign {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][string]$CampaignId,
        [string]$Name,
        [string]$Description,
        
        # Basic Campaign Settings
        [ValidateSet('ON_PREVIEW_TIMEOUT_DIAL_NUMBER', 'MANUAL_ONLY')]
        [string]$PreviewDialOption,
        [bool]$TrainingMode,
        
        # Dialing Campaign Data Parameters
        [string[]]$Lists,
        [string[]]$ListPriorities,
        [string[]]$CallWrapupStateSets,
        [int]$CallWrapupTime,
        [bool]$CallbackRestTime,
        [int]$MinCallbackRestMinutes,
        [int]$MaxAttempts,
        [string]$DialByField,
        [string]$DialByMapping,
        [string[]]$DispositionsTranscriptionOn,
        [bool]$SkipPreviewBeforeAgentAvailable,
        [bool]$FilterEnabled,
        [string]$FilterExpression,
        [bool]$ListOrderRandomization,
        [int]$RecordsPerAgent,
        [string[]]$CustomFieldMappings,
        [bool]$AutoAnswerEnabled,
        [int]$AutoAnswerDelay,
        
        # Common Campaign Data Parameters
        [string[]]$Skills,
        [string[]]$UserGroups,
        [string[]]$Users,
        [string]$ProfileName,
        [string]$ProfileId,
        [string[]]$Dispositions,
        [string[]]$DnsGroups,
        [string[]]$DnsNumbers,
        [bool]$RecordCall,
        [bool]$AllowRecording,
        [bool]$RecordingNameAsk,
        [bool]$StopRecordingOnTransfer,
        [string]$IvrScriptName,
        [string]$IvrScriptId,
        [string]$GateOpenHoursName,
        [string]$GateOpenHoursId,
        [bool]$AllowInternationalDials,
        [string[]]$Tags,
        [string]$CallerId,
        [bool]$CallerIdEnabled,
        [string]$CallerIdName,
        [bool]$UseAlternateCallerId,
        [string]$AlternateCallerId,
        [string]$AlternateCallerIdName,
        
        # Connectors Parameters
        [string[]]$ConnectorIds,
        [string[]]$ConnectorNames,
        [hashtable]$ConnectorConfigurations,
        [bool]$ConnectorsEnabled,
        [string]$ConnectorPriority,
        
        # WebRTC Settings
        [bool]$WebRtcEnabled,
        [string]$WebRtcGateway,
        
        # Compliance Settings
        [bool]$ComplianceRecordingEnabled,
        [string]$ComplianceRecordingPercentage,
        [bool]$TcpaComplianceEnabled,
        [string]$TcpaSafeHarborMessage,
        
        # Max Queue Time Parameters
        [int]$MaxQueueTimeSeconds,
        [int]$MaxQueueTimeMinutes,
        [int]$MaxQueueTimeHours,
        [bool]$UseTelemarketingMaxQueTimeEq1,
        
        # Dialing Mode Settings
        [ValidateSet('PREVIEW', 'PROGRESSIVE', 'PREDICTIVE', 'PREVIEW_AND_PROGRESSIVE', 'POWER', 'MANUAL')]
        [string]$DialingMode,
        [double]$CallsAgentRatio,
        [bool]$MonitorDroppedCalls,
        [float]$MaxDroppedCallsPercentage,
        [float]$TargetDroppedCallsPercentage,
        [int]$MaxRingTime,
        [int]$MinRingTime,
        
        # Call Analysis Settings
        [ValidateSet('DISABLED', 'CONNECT_ONLY', 'FULL', 'ADVANCED')]
        [string]$CallAnalysisMode,
        [int]$CallAnalysisTimeout,
        [float]$CallAnalysisConfidenceLevel,
        
        # Action on Answer Machine Parameters
        [ValidateSet('HANGUP', 'LEAVE_VOICEMAIL', 'TRANSFER_TO_IVR', 'TRANSFER_TO_AGENT')]
        [string]$AnswerMachineAction,
        [string]$AnswerMachineMessage,
        [string]$AnswerMachineMessageId,
        [string]$AnswerMachineIvrScript,
        [string]$AnswerMachineIvrScriptId,
        [bool]$AnswerMachineDetectionEnabled,
        [int]$AnswerMachineTimeout,
        
        # Action on Queue Expiration Parameters
        [ValidateSet('HANGUP', 'LEAVE_VOICEMAIL', 'TRANSFER_TO_IVR', 'CALLBACK')]
        [string]$QueueExpirationAction,
        [string]$QueueExpirationMessage,
        [string]$QueueExpirationMessageId,
        [string]$QueueExpirationIvrScript,
        [string]$QueueExpirationIvrScriptId,
        [bool]$QueueExpirationCallbackEnabled,
        
        # Preview Time Settings
        [bool]$LimitPreviewTime,
        [int]$MaxPreviewTimeSeconds,
        [int]$MaxPreviewTimeMinutes,
        [bool]$DialNumberOnTimeout,
        [bool]$PreviewDialImmediately,
        [bool]$ShowLeadInfo,
        [string[]]$PreviewFields,
        
        # Distribution Settings
        [ValidateSet('LONGEST_AVAILABLE_AGENT', 'WEIGHTED_SKILL_RATING', 'ROUND_ROBIN', 'SKILL_PRIORITY')]
        [string]$DistributionAlgorithm,
        [ValidateSet('CURRENT', 'SINCE_MIDNIGHT', 'LAST_24_HOURS', 'LAST_7_DAYS')]
        [string]$DistributionTimeFrame,
        [bool]$DistributionSticky,
        [int]$DistributionStickyDays,
        
        # Priority and Ratio
        [int]$DialingPriority,
        [int]$DialingRatio,
        [float]$MinimumAgentsBeforeDialing,
        
        # SMS DNIS Parameters
        [string]$SmsDnisGroupId,
        [string[]]$SmsDnisNumbers,
        [bool]$SmsEnabled,
        [string]$SmsTemplate,
        
        # Preview Campaign Interrupt Options
        [bool]$InterruptPreviewEnabled,
        [string[]]$InterruptDispositions,
        [string[]]$InterruptUsers,
        [string[]]$InterruptSkills,
        [int]$InterruptTimeout,
        [string]$InterruptAction,
        
        # Advanced Dialing Settings
        [bool]$RedialEnabled,
        [int]$RedialAttempts,
        [int]$RedialDelay,
        [string[]]$RedialOnDispositions,
        [bool]$SkipNonNumericNumbers,
        [bool]$RemoveDuplicates,
        [string]$DuplicateCheckField,
        [bool]$TimeZoneDetection,
        [string]$TimeZoneField,
        [bool]$LocalPresenceEnabled,
        [string]$LocalPresenceState,
        
        [string]$IfMatch = '*'
    )
    
    if (-not (Test-Five9CloudConnection -AuthType RestApi)) { return }
    
    $uri = "$($global:Five9CloudToken.RestBaseUrl)/v1/domains/$($global:Five9CloudToken.DomainId)/campaigns/outbound_campaigns/$CampaignId"
    
    $headers = @{
        Authorization = "Basic $($global:Five9CloudToken.RestBasicAuth)"
    }
    
    if ($IfMatch) {
        $headers['If-Match'] = $IfMatch
    }
    
    $body = @{}
    
    if ($Name) { $body['name'] = $Name }
    if ($Description) { $body['description'] = $Description }
    if ($PreviewDialOption) { $body['previewDialOption'] = $PreviewDialOption }
    if ($PSBoundParameters.ContainsKey('TrainingMode')) { $body['trainingMode'] = $TrainingMode }
    
    # Build DialingCampaignData hashtable if any related parameters are provided
    $dialingData = @{}
    if ($Lists) { $dialingData['lists'] = $Lists }
    if ($ListPriorities) { $dialingData['listPriorities'] = $ListPriorities }
    if ($CallWrapupStateSets) { $dialingData['callWrapupStateSets'] = $CallWrapupStateSets }
    if ($PSBoundParameters.ContainsKey('CallWrapupTime')) { $dialingData['callWrapupTime'] = $CallWrapupTime }
    if ($PSBoundParameters.ContainsKey('CallbackRestTime')) { $dialingData['callbackRestTime'] = $CallbackRestTime }
    if ($PSBoundParameters.ContainsKey('MinCallbackRestMinutes')) { 
        $dialingData['minCallbackRestMinutes'] = $MinCallbackRestMinutes 
    }
    if ($PSBoundParameters.ContainsKey('MaxAttempts')) { $dialingData['maxAttempts'] = $MaxAttempts }
    if ($DialByField) { $dialingData['dialByField'] = $DialByField }
    if ($DialByMapping) { $dialingData['dialByMapping'] = $DialByMapping }
    if ($DispositionsTranscriptionOn) { $dialingData['dispositionsTranscriptionOn'] = $DispositionsTranscriptionOn }
    if ($PSBoundParameters.ContainsKey('SkipPreviewBeforeAgentAvailable')) { 
        $dialingData['skipPreviewBeforeAgentAvailable'] = $SkipPreviewBeforeAgentAvailable 
    }
    if ($PSBoundParameters.ContainsKey('FilterEnabled')) { $dialingData['filterEnabled'] = $FilterEnabled }
    if ($FilterExpression) { $dialingData['filterExpression'] = $FilterExpression }
    if ($PSBoundParameters.ContainsKey('ListOrderRandomization')) { 
        $dialingData['listOrderRandomization'] = $ListOrderRandomization 
    }
    if ($PSBoundParameters.ContainsKey('RecordsPerAgent')) { $dialingData['recordsPerAgent'] = $RecordsPerAgent }
    if ($CustomFieldMappings) { $dialingData['customFieldMappings'] = $CustomFieldMappings }
    if ($PSBoundParameters.ContainsKey('AutoAnswerEnabled')) { $dialingData['autoAnswerEnabled'] = $AutoAnswerEnabled }
    if ($PSBoundParameters.ContainsKey('AutoAnswerDelay')) { $dialingData['autoAnswerDelay'] = $AutoAnswerDelay }
    if ($PSBoundParameters.ContainsKey('SkipNonNumericNumbers')) { 
        $dialingData['skipNonNumericNumbers'] = $SkipNonNumericNumbers 
    }
    if ($PSBoundParameters.ContainsKey('RemoveDuplicates')) { $dialingData['removeDuplicates'] = $RemoveDuplicates }
    if ($DuplicateCheckField) { $dialingData['duplicateCheckField'] = $DuplicateCheckField }
    if ($PSBoundParameters.ContainsKey('TimeZoneDetection')) { $dialingData['timeZoneDetection'] = $TimeZoneDetection }
    if ($TimeZoneField) { $dialingData['timeZoneField'] = $TimeZoneField }
    if ($PSBoundParameters.ContainsKey('LocalPresenceEnabled')) { 
        $dialingData['localPresenceEnabled'] = $LocalPresenceEnabled 
    }
    if ($LocalPresenceState) { $dialingData['localPresenceState'] = $LocalPresenceState }
    if ($dialingData.Count -gt 0) { $body['dialingCampaignData'] = $dialingData }
    
    # Build CommonCampaignData hashtable if any related parameters are provided
    $commonData = @{}
    if ($Skills) { $commonData['skills'] = $Skills }
    if ($UserGroups) { $commonData['userGroups'] = $UserGroups }
    if ($Users) { $commonData['users'] = $Users }
    if ($ProfileName) { $commonData['profileName'] = $ProfileName }
    if ($ProfileId) { $commonData['profileId'] = $ProfileId }
    if ($Dispositions) { $commonData['dispositions'] = $Dispositions }
    if ($DnsGroups) { $commonData['dnsGroups'] = $DnsGroups }
    if ($DnsNumbers) { $commonData['dnsNumbers'] = $DnsNumbers }
    if ($PSBoundParameters.ContainsKey('RecordCall')) { $commonData['recordCall'] = $RecordCall }
    if ($PSBoundParameters.ContainsKey('AllowRecording')) { $commonData['allowRecording'] = $AllowRecording }
    if ($PSBoundParameters.ContainsKey('RecordingNameAsk')) { $commonData['recordingNameAsk'] = $RecordingNameAsk }
    if ($PSBoundParameters.ContainsKey('StopRecordingOnTransfer')) { 
        $commonData['stopRecordingOnTransfer'] = $StopRecordingOnTransfer 
    }
    if ($IvrScriptName) { $commonData['ivrScriptName'] = $IvrScriptName }
    if ($IvrScriptId) { $commonData['ivrScriptId'] = $IvrScriptId }
    if ($GateOpenHoursName) { $commonData['gateOpenHoursName'] = $GateOpenHoursName }
    if ($GateOpenHoursId) { $commonData['gateOpenHoursId'] = $GateOpenHoursId }
    if ($PSBoundParameters.ContainsKey('AllowInternationalDials')) { 
        $commonData['allowInternationalDials'] = $AllowInternationalDials 
    }
    if ($Tags) { $commonData['tags'] = $Tags }
    if ($CallerId) { $commonData['callerId'] = $CallerId }
    if ($PSBoundParameters.ContainsKey('CallerIdEnabled')) { $commonData['callerIdEnabled'] = $CallerIdEnabled }
    if ($CallerIdName) { $commonData['callerIdName'] = $CallerIdName }
    if ($PSBoundParameters.ContainsKey('UseAlternateCallerId')) { 
        $commonData['useAlternateCallerId'] = $UseAlternateCallerId 
    }
    if ($AlternateCallerId) { $commonData['alternateCallerId'] = $AlternateCallerId }
    if ($AlternateCallerIdName) { $commonData['alternateCallerIdName'] = $AlternateCallerIdName }
    
    # Build Connectors section within CommonCampaignData
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
        $body = @{ commonCampaignData = @{ connectors = $connectors } }
    }
    
    # WebRTC Settings
    if ($PSBoundParameters.ContainsKey('WebRtcEnabled') -or $WebRtcGateway) {
        $webRtc = @{}
        if ($PSBoundParameters.ContainsKey('WebRtcEnabled')) { $webRtc['enabled'] = $WebRtcEnabled }
        if ($WebRtcGateway) { $webRtc['gateway'] = $WebRtcGateway }
        $commonData['webRtc'] = $webRtc
    }
    
    # Compliance Settings
    if ($PSBoundParameters.ContainsKey('ComplianceRecordingEnabled') -or $ComplianceRecordingPercentage -or
        $PSBoundParameters.ContainsKey('TcpaComplianceEnabled') -or $TcpaSafeHarborMessage) {
        $compliance = @{}
        if ($PSBoundParameters.ContainsKey('ComplianceRecordingEnabled')) { 
            $compliance['recordingEnabled'] = $ComplianceRecordingEnabled 
        }
        if ($ComplianceRecordingPercentage) { $compliance['recordingPercentage'] = $ComplianceRecordingPercentage }
        if ($PSBoundParameters.ContainsKey('TcpaComplianceEnabled')) { 
            $compliance['tcpaEnabled'] = $TcpaComplianceEnabled 
        }
        if ($TcpaSafeHarborMessage) { $compliance['tcpaSafeHarborMessage'] = $TcpaSafeHarborMessage }
        $commonData['compliance'] = $compliance
    }
    
    if ($commonData.Count -gt 0) { $body['commonCampaignData'] = $commonData }
    
    # Build MaxQueueTime hashtable if any related parameters are provided
    if ($PSBoundParameters.ContainsKey('MaxQueueTimeSeconds') -or 
        $PSBoundParameters.ContainsKey('MaxQueueTimeMinutes') -or 
        $PSBoundParameters.ContainsKey('MaxQueueTimeHours')) {
        $maxQueueTime = @{}
        if ($PSBoundParameters.ContainsKey('MaxQueueTimeSeconds')) { 
            $maxQueueTime['seconds'] = $MaxQueueTimeSeconds 
        }
        if ($PSBoundParameters.ContainsKey('MaxQueueTimeMinutes')) { 
            $maxQueueTime['minutes'] = $MaxQueueTimeMinutes 
        }
        if ($PSBoundParameters.ContainsKey('MaxQueueTimeHours')) { 
            $maxQueueTime['hours'] = $MaxQueueTimeHours 
        }
        $body['maxQueueTime'] = $maxQueueTime
    }
    
    if ($PSBoundParameters.ContainsKey('UseTelemarketingMaxQueTimeEq1')) { 
        $body['useTelemarketingMaxQueTimeEq1'] = $UseTelemarketingMaxQueTimeEq1 
    }
    
    # Dialing Mode Settings
    if ($DialingMode) { $body['dialingMode'] = $DialingMode }
    if ($PSBoundParameters.ContainsKey('CallsAgentRatio')) { $body['callsAgentRatio'] = $CallsAgentRatio }
    if ($PSBoundParameters.ContainsKey('MonitorDroppedCalls')) { $body['monitorDroppedCalls'] = $MonitorDroppedCalls }
    if ($PSBoundParameters.ContainsKey('MaxDroppedCallsPercentage')) { 
        $body['maxDroppedCallsPercentage'] = $MaxDroppedCallsPercentage 
    }
    if ($PSBoundParameters.ContainsKey('TargetDroppedCallsPercentage')) { 
        $body['targetDroppedCallsPercentage'] = $TargetDroppedCallsPercentage 
    }
    if ($PSBoundParameters.ContainsKey('MaxRingTime')) { $body['maxRingTime'] = $MaxRingTime }
    if ($PSBoundParameters.ContainsKey('MinRingTime')) { $body['minRingTime'] = $MinRingTime }
    
    # Call Analysis Settings
    if ($CallAnalysisMode) { $body['callAnalysisMode'] = $CallAnalysisMode }
    if ($PSBoundParameters.ContainsKey('CallAnalysisTimeout')) { 
        $body['callAnalysisTimeout'] = $CallAnalysisTimeout 
    }
    if ($PSBoundParameters.ContainsKey('CallAnalysisConfidenceLevel')) { 
        $body['callAnalysisConfidenceLevel'] = $CallAnalysisConfidenceLevel 
    }
    
    # Build ActionOnAnswerMachine hashtable if any related parameters are provided
    if ($AnswerMachineAction -or $AnswerMachineMessage -or $AnswerMachineMessageId -or 
        $AnswerMachineIvrScript -or $AnswerMachineIvrScriptId -or
        $PSBoundParameters.ContainsKey('AnswerMachineDetectionEnabled') -or 
        $PSBoundParameters.ContainsKey('AnswerMachineTimeout')) {
        $actionOnAnswerMachine = @{}
        if ($AnswerMachineAction) { $actionOnAnswerMachine['action'] = $AnswerMachineAction }
        if ($AnswerMachineMessage) { $actionOnAnswerMachine['message'] = $AnswerMachineMessage }
        if ($AnswerMachineMessageId) { $actionOnAnswerMachine['messageId'] = $AnswerMachineMessageId }
        if ($AnswerMachineIvrScript) { $actionOnAnswerMachine['ivrScript'] = $AnswerMachineIvrScript }
        if ($AnswerMachineIvrScriptId) { $actionOnAnswerMachine['ivrScriptId'] = $AnswerMachineIvrScriptId }
        if ($PSBoundParameters.ContainsKey('AnswerMachineDetectionEnabled')) { 
            $actionOnAnswerMachine['detectionEnabled'] = $AnswerMachineDetectionEnabled 
        }
        if ($PSBoundParameters.ContainsKey('AnswerMachineTimeout')) { 
            $actionOnAnswerMachine['timeout'] = $AnswerMachineTimeout 
        }
        $body['actionOnAnswerMachine'] = $actionOnAnswerMachine
    }
    
    # Build ActionOnQueueExpiration hashtable if any related parameters are provided
    if ($QueueExpirationAction -or $QueueExpirationMessage -or $QueueExpirationMessageId -or
        $QueueExpirationIvrScript -or $QueueExpirationIvrScriptId -or
        $PSBoundParameters.ContainsKey('QueueExpirationCallbackEnabled')) {
        $actionOnQueueExpiration = @{}
        if ($QueueExpirationAction) { $actionOnQueueExpiration['action'] = $QueueExpirationAction }
        if ($QueueExpirationMessage) { $actionOnQueueExpiration['message'] = $QueueExpirationMessage }
        if ($QueueExpirationMessageId) { $actionOnQueueExpiration['messageId'] = $QueueExpirationMessageId }
        if ($QueueExpirationIvrScript) { $actionOnQueueExpiration['ivrScript'] = $QueueExpirationIvrScript }
        if ($QueueExpirationIvrScriptId) { $actionOnQueueExpiration['ivrScriptId'] = $QueueExpirationIvrScriptId }
        if ($PSBoundParameters.ContainsKey('QueueExpirationCallbackEnabled')) { 
            $actionOnQueueExpiration['callbackEnabled'] = $QueueExpirationCallbackEnabled 
        }
        $body['actionOnQueueExpiration'] = $actionOnQueueExpiration
    }
    
    # Preview Time Settings
    if ($PSBoundParameters.ContainsKey('LimitPreviewTime')) { $body['limitPreviewTime'] = $LimitPreviewTime }
    if ($PSBoundParameters.ContainsKey('MaxPreviewTimeSeconds') -or 
        $PSBoundParameters.ContainsKey('MaxPreviewTimeMinutes')) {
        $maxPreviewTime = @{}
        if ($PSBoundParameters.ContainsKey('MaxPreviewTimeSeconds')) { 
            $maxPreviewTime['seconds'] = $MaxPreviewTimeSeconds 
        }
        if ($PSBoundParameters.ContainsKey('MaxPreviewTimeMinutes')) { 
            $maxPreviewTime['minutes'] = $MaxPreviewTimeMinutes 
        }
        $body['maxPreviewTime'] = $maxPreviewTime
    }
    if ($PSBoundParameters.ContainsKey('DialNumberOnTimeout')) { $body['dialNumberOnTimeout'] = $DialNumberOnTimeout }
    if ($PSBoundParameters.ContainsKey('PreviewDialImmediately')) { 
        $body['previewDialImmediately'] = $PreviewDialImmediately 
    }
    if ($PSBoundParameters.ContainsKey('ShowLeadInfo')) { $body['showLeadInfo'] = $ShowLeadInfo }
    if ($PreviewFields) { $body['previewFields'] = $PreviewFields }
    
    # Distribution Settings
    if ($DistributionAlgorithm) { $body['distributionAlgorithm'] = $DistributionAlgorithm }
    if ($DistributionTimeFrame) { $body['distributionTimeFrame'] = $DistributionTimeFrame }
    if ($PSBoundParameters.ContainsKey('DistributionSticky')) { $body['distributionSticky'] = $DistributionSticky }
    if ($PSBoundParameters.ContainsKey('DistributionStickyDays')) { 
        $body['distributionStickyDays'] = $DistributionStickyDays 
    }
    
    # Priority and Ratio
    if ($PSBoundParameters.ContainsKey('DialingPriority')) { $body['dialingPriority'] = $DialingPriority }
    if ($PSBoundParameters.ContainsKey('DialingRatio')) { $body['dialingRatio'] = $DialingRatio }
    if ($PSBoundParameters.ContainsKey('MinimumAgentsBeforeDialing')) { 
        $body['minimumAgentsBeforeDialing'] = $MinimumAgentsBeforeDialing 
    }
    
    # Build SmsDnis hashtable if any related parameters are provided
    if ($SmsDnisGroupId -or $SmsDnisNumbers -or $PSBoundParameters.ContainsKey('SmsEnabled') -or $SmsTemplate) {
        $smsDnis = @{}
        if ($SmsDnisGroupId) { $smsDnis['groupId'] = $SmsDnisGroupId }
        if ($SmsDnisNumbers) { $smsDnis['numbers'] = $SmsDnisNumbers }
        if ($PSBoundParameters.ContainsKey('SmsEnabled')) { $smsDnis['enabled'] = $SmsEnabled }
        if ($SmsTemplate) { $smsDnis['template'] = $SmsTemplate }
        $body['smsDnis'] = $smsDnis
    }
    
    # Build PreviewCampaignInterruptOptions hashtable if any related parameters are provided
    if ($PSBoundParameters.ContainsKey('InterruptPreviewEnabled') -or 
        $InterruptDispositions -or $InterruptUsers -or $InterruptSkills -or 
        $PSBoundParameters.ContainsKey('InterruptTimeout') -or $InterruptAction) {
        $interruptOptions = @{}
        if ($PSBoundParameters.ContainsKey('InterruptPreviewEnabled')) { 
            $interruptOptions['enabled'] = $InterruptPreviewEnabled 
        }
        if ($InterruptDispositions) { $interruptOptions['dispositions'] = $InterruptDispositions }
        if ($InterruptUsers) { $interruptOptions['users'] = $InterruptUsers }
        if ($InterruptSkills) { $interruptOptions['skills'] = $InterruptSkills }
        if ($PSBoundParameters.ContainsKey('InterruptTimeout')) { $interruptOptions['timeout'] = $InterruptTimeout }
        if ($InterruptAction) { $interruptOptions['action'] = $InterruptAction }
        $body['previewCampaignInterruptOptions'] = $interruptOptions
    }
    
    # Build Redial Settings if any related parameters are provided
    if ($PSBoundParameters.ContainsKey('RedialEnabled') -or 
        $PSBoundParameters.ContainsKey('RedialAttempts') -or 
        $PSBoundParameters.ContainsKey('RedialDelay') -or 
        $RedialOnDispositions) {
        $redialSettings = @{}
        if ($PSBoundParameters.ContainsKey('RedialEnabled')) { $redialSettings['enabled'] = $RedialEnabled }
        if ($PSBoundParameters.ContainsKey('RedialAttempts')) { $redialSettings['attempts'] = $RedialAttempts }
        if ($PSBoundParameters.ContainsKey('RedialDelay')) { $redialSettings['delay'] = $RedialDelay }
        if ($RedialOnDispositions) { $redialSettings['onDispositions'] = $RedialOnDispositions }
        $body['redialSettings'] = $redialSettings
    }
    
    try {
        Invoke-RestMethod -Uri $uri -Method Put -Headers $headers -Body ($body | ConvertTo-Json -Depth 10)
    } catch {
        Write-Error "Failed to update outbound campaign: $_"
    }
}
