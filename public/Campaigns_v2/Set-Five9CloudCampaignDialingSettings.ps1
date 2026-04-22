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
        [ValidateSet('dial','switchToAgent')]
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

    # Seed current values — only used when the mode matches so we don't carry over
    # settings from a different mode into the new one
    $mode     = $PSCmdlet.ParameterSetName.ToLower()
    $defaults = Resolve-Five9CloudCampaignDialingSettings -CampaignId $CampaignId
    $d        = if ($defaults -and $defaults.DialingMode -eq $mode) { $defaults } else { $null }

    $body = @{ dialingMode = $mode }

    switch ($PSCmdlet.ParameterSetName) {

        'Auto' {
            $body.auto = @{
                listDialingMode            = if ($PSBoundParameters.ContainsKey('AutoListDialingMode'))            { $AutoListDialingMode }            elseif ($null -ne $d.AutoListDialingMode)            { $d.AutoListDialingMode }            else { 'listPenetration' }
                minDurationBeforeRedialing = if ($PSBoundParameters.ContainsKey('AutoMinDurationBeforeRedialing')) { $AutoMinDurationBeforeRedialing } elseif ($null -ne $d.AutoMinDurationBeforeRedialing) { $d.AutoMinDurationBeforeRedialing } else { 'PT8H' }
                voiceDetectionLevel        = if ($PSBoundParameters.ContainsKey('VoiceDetectionLevel'))            { $VoiceDetectionLevel }            elseif ($null -ne $d.VoiceDetectionLevel)            { $d.VoiceDetectionLevel }            else { 20 }
            }
        }

        'Preview' {
            $extStrat   = if ($PSBoundParameters.ContainsKey('ExtendedStrategy'))               { $ExtendedStrategy }               elseif ($null -ne $d.ExtendedStrategy)               { $d.ExtendedStrategy }               else { $false }
            $minDur     = if ($PSBoundParameters.ContainsKey('PreviewMinDurationBeforeRedialing')) { $PreviewMinDurationBeforeRedialing } elseif ($null -ne $d.PreviewMinDurationBeforeRedialing) { $d.PreviewMinDurationBeforeRedialing } else { 'PT8H' }
            $optionType = if ($PSBoundParameters.ContainsKey('PreviewOptionsType'))             { $PreviewOptionsType }             elseif ($null -ne $d.PreviewOptionsType)             { $d.PreviewOptionsType }             else { 'limited' }

            $settings = @{
                extendedStrategy           = $extStrat
                minDurationBeforeRedialing = $minDur
            }

            $dp = if ($PSBoundParameters.ContainsKey('PreviewDialingPriority')) { $PreviewDialingPriority } else { $d.PreviewDialingPriority }
            $dr = if ($PSBoundParameters.ContainsKey('PreviewDialingRatio'))    { $PreviewDialingRatio }    else { $d.PreviewDialingRatio }
            if ($null -ne $dp) { $settings.dialingPriority = $dp }
            if ($null -ne $dr) { $settings.dialingRatio    = $dr }

            $previewOptions = @{ optionType = $optionType }
            if ($optionType -eq 'limited') {
                $limAction  = if ($PSBoundParameters.ContainsKey('LimitedPreviewActionType')) { $LimitedPreviewActionType } elseif ($null -ne $d.LimitedPreviewActionType) { $d.LimitedPreviewActionType } else { 'switchToAgent' }
                $limMaxTime = if ($PSBoundParameters.ContainsKey('LimitedPreviewMaxTime'))    { $LimitedPreviewMaxTime }    elseif ($null -ne $d.LimitedPreviewMaxTime)    { $d.LimitedPreviewMaxTime }    else { 'PT2M' }
                $previewOptions.limited = @{ actionType = $limAction; maxPreviewTime = $limMaxTime }
            }
            $settings.previewOptions = $previewOptions

            if ($PSBoundParameters.ContainsKey('InterruptCalls') -or $PSBoundParameters.ContainsKey('InterruptSkillVoicemails') -or $null -ne $d.InterruptCalls) {
                $settings.interruptOptions = @{
                    calls           = if ($PSBoundParameters.ContainsKey('InterruptCalls'))           { $InterruptCalls }           elseif ($null -ne $d.InterruptCalls)           { $d.InterruptCalls }           else { $false }
                    skillVoicemails = if ($PSBoundParameters.ContainsKey('InterruptSkillVoicemails')) { $InterruptSkillVoicemails } elseif ($null -ne $d.InterruptSkillVoicemails) { $d.InterruptSkillVoicemails } else { $false }
                }
            }
            $body.preview = $settings
        }

        default {
            # Predictive, Progressive, Power
            # Required fields: explicit → current → hardcoded default
            $listMode    = if ($PSBoundParameters.ContainsKey('ListDialingMode'))            { $ListDialingMode }            elseif ($null -ne $d.ListDialingMode)            { $d.ListDialingMode }            else { 'listPenetration' }
            $minDur      = if ($PSBoundParameters.ContainsKey('MinDurationBeforeRedialing')) { $MinDurationBeforeRedialing } elseif ($null -ne $d.MinDurationBeforeRedialing) { $d.MinDurationBeforeRedialing } else { 'PT8H' }
            $caMode      = if ($PSBoundParameters.ContainsKey('CallAnalysisMode'))           { $CallAnalysisMode }           elseif ($null -ne $d.CallAnalysisMode)           { $d.CallAnalysisMode }           else { 'faxAndAnsweringMachine' }
            $queueType   = if ($PSBoundParameters.ContainsKey('QueueExpirationActionType'))  { $QueueExpirationActionType }  elseif ($null -ne $d.QueueExpirationActionType)  { $d.QueueExpirationActionType }  else { 'abandonCall' }

            $settings = @{
                listDialingMode            = $listMode
                minDurationBeforeRedialing = $minDur
            }

            # Optional fields: explicit → current → omit
            $dp  = if ($PSBoundParameters.ContainsKey('DialingPriority'))          { $DialingPriority }          else { $d.DialingPriority }
            $dr  = if ($PSBoundParameters.ContainsKey('DialingRatio'))             { $DialingRatio }             else { $d.DialingRatio }
            $acp = if ($PSBoundParameters.ContainsKey('MaxAbandonCallPercentage')) { $MaxAbandonCallPercentage } else { $d.MaxAbandonCallPercentage }
            if ($null -ne $dp)  { $settings.dialingPriority          = $dp }
            if ($null -ne $dr)  { $settings.dialingRatio             = $dr }
            if ($null -ne $acp) { $settings.maxAbandonCallPercentage = $acp }

            if ($PSCmdlet.ParameterSetName -eq 'Power') {
                $car = if ($PSBoundParameters.ContainsKey('CallToAgentRatio')) { $CallToAgentRatio } else { $d.CallToAgentRatio }
                if ($null -ne $car) { $settings.callToAgentRatio = $car }
            }

            # Build callAnalysis
            $callAnalysis = @{ mode = $caMode }
            if ($caMode -eq 'faxAndAnsweringMachine') {
                $amdAction = if ($PSBoundParameters.ContainsKey('AmdActionType')) { $AmdActionType } elseif ($null -ne $d.AmdActionType) { $d.AmdActionType } else { 'dropCall' }
                $vdl       = if ($PSBoundParameters.ContainsKey('AmdVoiceDetectionLevel')) { $AmdVoiceDetectionLevel } else { $d.AmdVoiceDetectionLevel }

                $amdData   = @{}
                if ($null -ne $vdl) { $amdData.voiceDetectionLevel = $vdl }

                $actionObj = @{ actionType = $amdAction }
                if ($amdAction -eq 'playPrompt') {
                    $promptId  = if ($PSBoundParameters.ContainsKey('AmdPlayPromptId'))             { $AmdPlayPromptId }             else { $d.AmdPlayPromptId }
                    $greetTime = if ($PSBoundParameters.ContainsKey('AmdPlayPromptMaxGreetingTime')) { $AmdPlayPromptMaxGreetingTime } else { $d.AmdPlayPromptMaxGreetingTime }
                    if ($promptId) {
                        $pp = @{ prompt = @{ promptId = $promptId } }
                        if ($greetTime) { $pp.maxGreetingTime = $greetTime }
                        $actionObj.playPrompt = $pp
                    }
                }
                if ($amdAction -eq 'startScript') {
                    $scriptId = if ($PSBoundParameters.ContainsKey('AmdStartScriptId')) { $AmdStartScriptId } else { $d.AmdStartScriptId }
                    if ($scriptId) { $actionObj.startScript = @{ scriptId = $scriptId } }
                }
                $amdData.answerMachineAction = $actionObj
                $callAnalysis.answeringMachineData = $amdData
            }
            $settings.callAnalysis = $callAnalysis

            # Build queueExpirationAction
            $queueAction = @{ actionType = $queueType }
            if ($queueType -eq 'playPrompt') {
                $pid = if ($PSBoundParameters.ContainsKey('QueueExpirationPlayPromptId')) { $QueueExpirationPlayPromptId } else { $d.QueueExpirationPlayPromptId }
                if ($pid) { $queueAction.playPrompt = @{ promptId = $pid } }
            }
            if ($queueType -eq 'startScript') {
                $sid = if ($PSBoundParameters.ContainsKey('QueueExpirationStartScriptId')) { $QueueExpirationStartScriptId } else { $d.QueueExpirationStartScriptId }
                if ($sid) { $queueAction.startScript = @{ scriptId = $sid } }
            }
            $settings.queueExpirationAction = $queueAction

            $body[$mode] = $settings
        }
    }

    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/dialer/v1/domains/$($global:Five9.DomainId)/campaigns/$CampaignId/dialing-settings" -Method Put -Body $body
    if ($result -ne $false) { Write-Host "Dialing settings updated for campaign '$CampaignName'."; return $result } else { Write-Host "Failed to update dialing settings for campaign '$CampaignName'."; return $false }
}
