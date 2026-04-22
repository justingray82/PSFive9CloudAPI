function Set-Five9CloudCampaignDialingSettings {
    [CmdletBinding(DefaultParameterSetName = 'Predictive')]
    param(
        [string]$CampaignId,
        [string]$CampaignName,

        # ── Mode selectors ──────────────────────────────────────────────────────
        [Parameter(Mandatory, ParameterSetName = 'Predictive')][switch]$Predictive,
        [Parameter(Mandatory, ParameterSetName = 'Progressive')][switch]$Progressive,
        [Parameter(Mandatory, ParameterSetName = 'Power')][switch]$Power,
        [Parameter(Mandatory, ParameterSetName = 'Preview')][switch]$Preview,
        [Parameter(Mandatory, ParameterSetName = 'Auto')][switch]$Auto,

        # ── Base settings  (Predictive / Progressive / Power) ──────────────────
        [Parameter(Mandatory, ParameterSetName = 'Predictive')]
        [Parameter(Mandatory, ParameterSetName = 'Progressive')]
        [Parameter(Mandatory, ParameterSetName = 'Power')]
        [ValidateSet('listPenetration','verticalDialing','extendedStrategy')]
        [string]$ListDialingMode,

        [Parameter(Mandatory, ParameterSetName = 'Predictive')]
        [Parameter(Mandatory, ParameterSetName = 'Progressive')]
        [Parameter(Mandatory, ParameterSetName = 'Power')]
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
        [Parameter(Mandatory, ParameterSetName = 'Predictive')]
        [Parameter(Mandatory, ParameterSetName = 'Progressive')]
        [Parameter(Mandatory, ParameterSetName = 'Power')]
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
        [Parameter(Mandatory, ParameterSetName = 'Predictive')]
        [Parameter(Mandatory, ParameterSetName = 'Progressive')]
        [Parameter(Mandatory, ParameterSetName = 'Power')]
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

        # ── Power-only ──────────────────────────────────────────────────────────
        [Parameter(ParameterSetName = 'Power')]
        [ValidateRange(0.0,10.0)][float]$CallToAgentRatio,

        # ── Preview ─────────────────────────────────────────────────────────────
        [Parameter(Mandatory, ParameterSetName = 'Preview')][bool]$ExtendedStrategy,
        [Parameter(Mandatory, ParameterSetName = 'Preview')][string]$PreviewMinDurationBeforeRedialing,

        [Parameter(ParameterSetName = 'Preview')]
        [ValidateRange(1,99)][int]$PreviewDialingPriority,

        [Parameter(ParameterSetName = 'Preview')]
        [ValidateRange(1,99)][int]$PreviewDialingRatio,

        [Parameter(Mandatory, ParameterSetName = 'Preview')]
        [ValidateSet('unlimited','limited','dialImmediately')]
        [string]$PreviewOptionsType,

        [Parameter(ParameterSetName = 'Preview')]
        [ValidateSet('dial','switchToAgent')]
        [string]$LimitedPreviewActionType,

        [Parameter(ParameterSetName = 'Preview')]
        [string]$LimitedPreviewMaxTime,

        [Parameter(ParameterSetName = 'Preview')][bool]$InterruptCalls,
        [Parameter(ParameterSetName = 'Preview')][bool]$InterruptSkillVoicemails,

        # ── Auto ────────────────────────────────────────────────────────────────
        [Parameter(Mandatory, ParameterSetName = 'Auto')]
        [ValidateSet('listPenetration','verticalDialing','extendedStrategy')]
        [string]$AutoListDialingMode,

        [Parameter(Mandatory, ParameterSetName = 'Auto')]
        [string]$AutoMinDurationBeforeRedialing,

        [Parameter(Mandatory, ParameterSetName = 'Auto')]
        [ValidateRange(20,100)][int]$VoiceDetectionLevel
    )

    if (-not $CampaignId) { $CampaignId = Resolve-Five9CloudCampaignId $CampaignId $CampaignName } ; if (-not $CampaignId) { return }

    $mode = $PSCmdlet.ParameterSetName.ToLower()
    $body = @{ dialingMode = $mode }

    switch ($PSCmdlet.ParameterSetName) {

        'Auto' {
            $body.auto = @{
                listDialingMode            = $AutoListDialingMode
                minDurationBeforeRedialing = $AutoMinDurationBeforeRedialing
                voiceDetectionLevel        = $VoiceDetectionLevel
            }
        }

        'Preview' {
            $settings = @{
                extendedStrategy           = $ExtendedStrategy
                minDurationBeforeRedialing = $PreviewMinDurationBeforeRedialing
            }
            if ($PSBoundParameters.ContainsKey('PreviewDialingPriority')) { $settings.dialingPriority = $PreviewDialingPriority }
            if ($PSBoundParameters.ContainsKey('PreviewDialingRatio'))    { $settings.dialingRatio    = $PreviewDialingRatio }

            $previewOptions = @{ optionType = $PreviewOptionsType }
            if ($PreviewOptionsType -eq 'limited' -and ($LimitedPreviewActionType -or $LimitedPreviewMaxTime)) {
                $limited = @{}
                if ($LimitedPreviewActionType) { $limited.actionType    = $LimitedPreviewActionType }
                if ($LimitedPreviewMaxTime)    { $limited.maxPreviewTime = $LimitedPreviewMaxTime }
                $previewOptions.limited = $limited
            }
            $settings.previewOptions = $previewOptions

            if ($PSBoundParameters.ContainsKey('InterruptCalls') -or $PSBoundParameters.ContainsKey('InterruptSkillVoicemails')) {
                $settings.interruptOptions = @{
                    calls           = [bool]$InterruptCalls
                    skillVoicemails = [bool]$InterruptSkillVoicemails
                }
            }
            $body.preview = $settings
        }

        default {
            # Predictive, Progressive, Power
            $settings = @{
                listDialingMode            = $ListDialingMode
                minDurationBeforeRedialing = $MinDurationBeforeRedialing
            }
            if ($PSBoundParameters.ContainsKey('DialingPriority'))          { $settings.dialingPriority          = $DialingPriority }
            if ($PSBoundParameters.ContainsKey('DialingRatio'))              { $settings.dialingRatio             = $DialingRatio }
            if ($PSBoundParameters.ContainsKey('MaxAbandonCallPercentage'))  { $settings.maxAbandonCallPercentage = $MaxAbandonCallPercentage }
            if ($PSCmdlet.ParameterSetName -eq 'Power' -and $PSBoundParameters.ContainsKey('CallToAgentRatio')) {
                $settings.callToAgentRatio = $CallToAgentRatio
            }

            # Build callAnalysis
            $callAnalysis = @{ mode = $CallAnalysisMode }
            if ($CallAnalysisMode -eq 'faxAndAnsweringMachine' -and $AmdActionType) {
                $amdData   = @{}
                $amdAction = @{ actionType = $AmdActionType }
                if ($PSBoundParameters.ContainsKey('AmdVoiceDetectionLevel')) { $amdData.voiceDetectionLevel = $AmdVoiceDetectionLevel }
                if ($AmdActionType -eq 'playPrompt' -and $AmdPlayPromptId) {
                    $playPrompt = @{ prompt = @{ promptId = $AmdPlayPromptId } }
                    if ($AmdPlayPromptMaxGreetingTime) { $playPrompt.maxGreetingTime = $AmdPlayPromptMaxGreetingTime }
                    $amdAction.playPrompt = $playPrompt
                }
                if ($AmdActionType -eq 'startScript' -and $AmdStartScriptId) {
                    $amdAction.startScript = @{ scriptId = $AmdStartScriptId }
                }
                $amdData.answerMachineAction = $amdAction
                $callAnalysis.answeringMachineData = $amdData
            }
            $settings.callAnalysis = $callAnalysis

            # Build queueExpirationAction
            $queueAction = @{ actionType = $QueueExpirationActionType }
            if ($QueueExpirationActionType -eq 'playPrompt' -and $QueueExpirationPlayPromptId) {
                $queueAction.playPrompt = @{ promptId = $QueueExpirationPlayPromptId }
            }
            if ($QueueExpirationActionType -eq 'startScript' -and $QueueExpirationStartScriptId) {
                $queueAction.startScript = @{ scriptId = $QueueExpirationStartScriptId }
            }
            $settings.queueExpirationAction = $queueAction

            $body[$mode] = $settings
        }
    }

    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/dialer/v1/domains/$($global:Five9.DomainId)/campaigns/$CampaignId/dialing-settings" -Method Put -Body $body
    if ($result -ne $false) { Write-Host "Dialing settings updated for campaign '$CampaignName'."; return $result } else { Write-Host "Failed to update dialing settings for campaign '$CampaignName'."; return $false }
}
