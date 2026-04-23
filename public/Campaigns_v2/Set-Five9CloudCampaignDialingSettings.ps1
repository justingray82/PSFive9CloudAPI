function Set-Five9CloudCampaignDialingSettings {
    [CmdletBinding(DefaultParameterSetName = 'Predictive')]
    param(
        [string]$CampaignId,
        [string]$CampaignName,

        #  Mode selectors
        [Parameter(Mandatory, ParameterSetName = 'Predictive')][switch]$Predictive,
        [Parameter(Mandatory, ParameterSetName = 'Progressive')][switch]$Progressive,
        [Parameter(Mandatory, ParameterSetName = 'Power')][switch]$Power,
        [Parameter(Mandatory, ParameterSetName = 'Preview')][switch]$Preview,
        [Parameter(Mandatory, ParameterSetName = 'Auto')][switch]$Auto,

        #  Base settings  (Predictive / Progressive / Power)
        [Parameter(ParameterSetName = 'Predictive')]
        [Parameter(ParameterSetName = 'Progressive')]
        [Parameter(ParameterSetName = 'Power')]
        [ValidateSet('listPenetration','verticalDialing','extendedStrategy')]
        [string]$ListDialingMode,

        [Parameter(ParameterSetName = 'Predictive')]
        [Parameter(ParameterSetName = 'Progressive')]
        [Parameter(ParameterSetName = 'Power')]
        [string]$MinDurationBeforeRedialing,

        [Parameter(ParameterSetName = 'Predictive')]
        [Parameter(ParameterSetName = 'Progressive')]
        [Parameter(ParameterSetName = 'Power')]
        [ValidateRange(1,99)][int]$DialingPriority,

        [Parameter(ParameterSetName = 'Predictive')]
        [Parameter(ParameterSetName = 'Progressive')]
        [Parameter(ParameterSetName = 'Power')]
        [ValidateRange(1,99)][int]$DialingRatio,

        [Parameter(ParameterSetName = 'Predictive')]
        [Parameter(ParameterSetName = 'Progressive')]
        [Parameter(ParameterSetName = 'Power')]
        [ValidateRange(0.0,10.0)][float]$MaxAbandonCallPercentage,

        # Call Analysis
        [Parameter(ParameterSetName = 'Predictive')]
        [Parameter(ParameterSetName = 'Progressive')]
        [Parameter(ParameterSetName = 'Power')]
        [ValidateSet('noAnalysis','faxOnly','faxAndAnsweringMachine')]
        [string]$CallAnalysisMode,

        [Parameter(ParameterSetName = 'Predictive')]
        [Parameter(ParameterSetName = 'Progressive')]
        [Parameter(ParameterSetName = 'Power')]
        [ValidateRange(20,100)][int]$AmdVoiceDetectionLevel,

        [Parameter(ParameterSetName = 'Predictive')]
        [Parameter(ParameterSetName = 'Progressive')]
        [Parameter(ParameterSetName = 'Power')]
        [ValidateSet('dropCall','playPrompt','startScript')]
        [string]$AmdActionType,

        [Parameter(ParameterSetName = 'Predictive')]
        [Parameter(ParameterSetName = 'Progressive')]
        [Parameter(ParameterSetName = 'Power')]
        [string]$AmdPlayPromptId,

        [Parameter(ParameterSetName = 'Predictive')]
        [Parameter(ParameterSetName = 'Progressive')]
        [Parameter(ParameterSetName = 'Power')]
        [string]$AmdPlayPromptMaxGreetingTime,

        [Parameter(ParameterSetName = 'Predictive')]
        [Parameter(ParameterSetName = 'Progressive')]
        [Parameter(ParameterSetName = 'Power')]
        [string]$AmdStartScriptId,

        # Queue Expiration Action
        [Parameter(ParameterSetName = 'Predictive')]
        [Parameter(ParameterSetName = 'Progressive')]
        [Parameter(ParameterSetName = 'Power')]
        [ValidateSet('abandonCall','playPrompt','startScript')]
        [string]$QueueExpirationActionType,

        [Parameter(ParameterSetName = 'Predictive')]
        [Parameter(ParameterSetName = 'Progressive')]
        [Parameter(ParameterSetName = 'Power')]
        [string]$QueueExpirationPlayPromptId,

        [Parameter(ParameterSetName = 'Predictive')]
        [Parameter(ParameterSetName = 'Progressive')]
        [Parameter(ParameterSetName = 'Power')]
        [string]$QueueExpirationStartScriptId,

        #  Power-only
        [Parameter(ParameterSetName = 'Power')]
        [ValidateRange(0.0,10.0)][float]$CallToAgentRatio,

        #  Preview
        [Parameter(ParameterSetName = 'Preview')][bool]$ExtendedStrategy,
        [Parameter(ParameterSetName = 'Preview')][string]$PreviewMinDurationBeforeRedialing,
        [Parameter(ParameterSetName = 'Preview')][ValidateRange(1,99)][int]$PreviewDialingPriority,
        [Parameter(ParameterSetName = 'Preview')][ValidateRange(1,99)][int]$PreviewDialingRatio,

        [Parameter(ParameterSetName = 'Preview')]
        [ValidateSet('unlimited','limited','dialImmediately')]
        [string]$PreviewOptionsType,

        [Parameter(ParameterSetName = 'Preview')]
        [ValidateSet('dial','switchAgentToNotReady')]
        [string]$LimitedPreviewActionType,

        [Parameter(ParameterSetName = 'Preview')][string]$LimitedPreviewMaxTime,
        [Parameter(ParameterSetName = 'Preview')][bool]$InterruptCalls,
        [Parameter(ParameterSetName = 'Preview')][bool]$InterruptSkillVoicemails,

        #  Auto
        [Parameter(ParameterSetName = 'Auto')]
        [ValidateSet('listPenetration','verticalDialing','extendedStrategy')]
        [string]$AutoListDialingMode,

        [Parameter(ParameterSetName = 'Auto')][string]$AutoMinDurationBeforeRedialing,
        [Parameter(ParameterSetName = 'Auto')][ValidateRange(20,100)][int]$VoiceDetectionLevel
    )

    if (-not $CampaignId) { $CampaignId = Resolve-Five9CloudCampaignId $CampaignId $CampaignName } ; if (-not $CampaignId) { return }

    # GET current settings — this is the base we patch into
    $raw = Get-Five9CloudCampaignDialingSettings -CampaignId $CampaignId
    if (-not $raw -or $raw -is [bool]) { Write-Host "Failed to retrieve current dialing settings for campaign '$CampaignName'."; return $false }

    $mode = $PSCmdlet.ParameterSetName.ToLower()

    # Extract the current mode sub-object using explicit property names.
    # When the campaign is in a different mode, $curr will be $null and we fall back
    # to a default object that has the full nested structure needed for property assignment.
    $curr = switch ($mode) {
        'predictive'  { $raw.predictive }
        'progressive' { $raw.progressive }
        'power'       { $raw.power }
        'preview'     { $raw.preview }
        'auto'        { $raw.auto }
    }

    if (-not $curr) {
        Write-Host "Campaign is currently in '$($raw.dialingMode)' mode — switching to '$mode'. Only explicitly provided parameters will be set; all other fields will use system defaults."

        $curr = switch ($mode) {
            'auto' {
                [PSCustomObject]@{
                    listDialingMode            = 'listPenetration'
                    minDurationBeforeRedialing = 'PT8H'
                    voiceDetectionLevel        = 20
                }
            }
            'preview' {
                [PSCustomObject]@{
                    extendedStrategy           = $false
                    minDurationBeforeRedialing = 'PT8H'
                    previewOptions             = [PSCustomObject]@{
                        optionType = 'limited'
                        limited    = [PSCustomObject]@{
                            actionType     = 'switchAgentToNotReady'
                            maxPreviewTime = 'PT2M'
                        }
                    }
                }
            }
            default {
                # predictive / progressive / power — full nested structure required
                $obj = [PSCustomObject]@{
                    listDialingMode            = 'listPenetration'
                    minDurationBeforeRedialing = 'PT8H'
                    dialingPriority            = 3
                    dialingRatio               = 50
                    maxAbandonCallPercentage   = 3.0
                    callAnalysis               = [PSCustomObject]@{
                        mode                 = 'faxAndAnsweringMachine'
                        answeringMachineData = [PSCustomObject]@{
                            voiceDetectionLevel = 20
                            answerMachineAction = [PSCustomObject]@{
                                actionType = 'dropCall'
                                playPrompt = [PSCustomObject]@{}
                            }
                        }
                    }
                    queueExpirationAction      = [PSCustomObject]@{
                        actionType = 'abandonCall'
                    }
                }
                if ($mode -eq 'power') { $obj | Add-Member -MemberType NoteProperty -Name callToAgentRatio -Value 1.0 }
                $obj
            }
        }
    }

    # Patch only the params that were explicitly provided — everything else stays as-is
    switch ($PSCmdlet.ParameterSetName) {

        'Auto' {
            if ($PSBoundParameters.ContainsKey('AutoListDialingMode'))            { $curr.listDialingMode            = $AutoListDialingMode }
            if ($PSBoundParameters.ContainsKey('AutoMinDurationBeforeRedialing')) { $curr.minDurationBeforeRedialing = $AutoMinDurationBeforeRedialing }
            if ($PSBoundParameters.ContainsKey('VoiceDetectionLevel'))            { $curr.voiceDetectionLevel        = $VoiceDetectionLevel }
        }

        'Preview' {
            if ($PSBoundParameters.ContainsKey('ExtendedStrategy'))                  { $curr.extendedStrategy           = $ExtendedStrategy }
            if ($PSBoundParameters.ContainsKey('PreviewMinDurationBeforeRedialing')) { $curr.minDurationBeforeRedialing = $PreviewMinDurationBeforeRedialing }
            if ($PSBoundParameters.ContainsKey('PreviewDialingPriority'))            { $curr.dialingPriority            = $PreviewDialingPriority }
            if ($PSBoundParameters.ContainsKey('PreviewDialingRatio'))               { $curr.dialingRatio               = $PreviewDialingRatio }
            if ($PSBoundParameters.ContainsKey('PreviewOptionsType'))                { $curr.previewOptions.optionType  = $PreviewOptionsType }
            if ($PSBoundParameters.ContainsKey('LimitedPreviewActionType'))          { $curr.previewOptions.limited.actionType     = $LimitedPreviewActionType }
            if ($PSBoundParameters.ContainsKey('LimitedPreviewMaxTime'))             { $curr.previewOptions.limited.maxPreviewTime = $LimitedPreviewMaxTime }
            if ($PSBoundParameters.ContainsKey('InterruptCalls') -or $PSBoundParameters.ContainsKey('InterruptSkillVoicemails')) {
                if (-not $curr.interruptOptions) {
                    $curr | Add-Member -MemberType NoteProperty -Name interruptOptions -Value ([PSCustomObject]@{ calls = $false; skillVoicemails = $false })
                }
                if ($PSBoundParameters.ContainsKey('InterruptCalls'))           { $curr.interruptOptions.calls           = $InterruptCalls }
                if ($PSBoundParameters.ContainsKey('InterruptSkillVoicemails')) { $curr.interruptOptions.skillVoicemails = $InterruptSkillVoicemails }
            }
        }

        default {
            # Predictive, Progressive, Power — flat fields
            if ($PSBoundParameters.ContainsKey('ListDialingMode'))            { $curr.listDialingMode            = $ListDialingMode }
            if ($PSBoundParameters.ContainsKey('MinDurationBeforeRedialing')) { $curr.minDurationBeforeRedialing = $MinDurationBeforeRedialing }
            if ($PSBoundParameters.ContainsKey('DialingPriority'))            { $curr.dialingPriority            = $DialingPriority }
            if ($PSBoundParameters.ContainsKey('DialingRatio'))               { $curr.dialingRatio               = $DialingRatio }
            if ($PSBoundParameters.ContainsKey('MaxAbandonCallPercentage'))   { $curr.maxAbandonCallPercentage   = $MaxAbandonCallPercentage }
            if ($PSCmdlet.ParameterSetName -eq 'Power' -and $PSBoundParameters.ContainsKey('CallToAgentRatio')) {
                $curr.callToAgentRatio = $CallToAgentRatio
            }

            # callAnalysis fields
            if ($PSBoundParameters.ContainsKey('CallAnalysisMode')) {
                $curr.callAnalysis.mode = $CallAnalysisMode
                # Remove answeringMachineData when switching away from faxAndAnsweringMachine
                if ($CallAnalysisMode -ne 'faxAndAnsweringMachine') {
                    $curr.callAnalysis.PSObject.Properties.Remove('answeringMachineData')
                }
            }
            if ($PSBoundParameters.ContainsKey('AmdVoiceDetectionLevel'))      { $curr.callAnalysis.answeringMachineData.voiceDetectionLevel                          = $AmdVoiceDetectionLevel }
            if ($PSBoundParameters.ContainsKey('AmdActionType'))                { $curr.callAnalysis.answeringMachineData.answerMachineAction.actionType               = $AmdActionType }
            if ($PSBoundParameters.ContainsKey('AmdPlayPromptId'))              { $curr.callAnalysis.answeringMachineData.answerMachineAction.playPrompt.promptId      = $AmdPlayPromptId }
            if ($PSBoundParameters.ContainsKey('AmdPlayPromptMaxGreetingTime')) { $curr.callAnalysis.answeringMachineData.answerMachineAction.playPrompt.maxGreetingTime = $AmdPlayPromptMaxGreetingTime }
            if ($PSBoundParameters.ContainsKey('AmdStartScriptId')) {
                if (-not $curr.callAnalysis.answeringMachineData.answerMachineAction.startScript) {
                    $curr.callAnalysis.answeringMachineData.answerMachineAction | Add-Member -MemberType NoteProperty -Name startScript -Value ([PSCustomObject]@{})
                }
                $curr.callAnalysis.answeringMachineData.answerMachineAction.startScript.scriptId = $AmdStartScriptId
            }

            # queueExpirationAction fields
            if ($PSBoundParameters.ContainsKey('QueueExpirationActionType'))    { $curr.queueExpirationAction.actionType = $QueueExpirationActionType }
            if ($PSBoundParameters.ContainsKey('QueueExpirationPlayPromptId')) {
                if (-not $curr.queueExpirationAction.playPrompt) {
                    $curr.queueExpirationAction | Add-Member -MemberType NoteProperty -Name playPrompt -Value ([PSCustomObject]@{})
                }
                $curr.queueExpirationAction.playPrompt.promptId = $QueueExpirationPlayPromptId
            }
            if ($PSBoundParameters.ContainsKey('QueueExpirationStartScriptId')) {
                if (-not $curr.queueExpirationAction.startScript) {
                    $curr.queueExpirationAction | Add-Member -MemberType NoteProperty -Name startScript -Value ([PSCustomObject]@{})
                }
                $curr.queueExpirationAction.startScript.scriptId = $QueueExpirationStartScriptId
            }
        }
    }

    $body = @{ dialingMode = $mode }
    $body[$mode] = $curr

    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/dialer/v1/domains/$($global:Five9.DomainId)/campaigns/$CampaignId/dialing-settings" -Method Put -Body $body
    if ($result -ne $false) { Write-Host "Dialing settings updated for campaign '$CampaignName'."; return $result } else { Write-Host "Failed to update dialing settings for campaign '$CampaignName'."; return $false }
}