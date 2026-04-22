function Resolve-Five9CloudCampaignDialingSettings {
    param([string]$CampaignId, [string]$CampaignName)
    if (-not $CampaignId) { $CampaignId = Resolve-Five9CloudCampaignId $CampaignId $CampaignName } ; if (-not $CampaignId) { return }

    $raw = Get-Five9CloudCampaignDialingSettings -CampaignId $CampaignId
    if (-not $raw) { return }

    $mode = $raw.dialingMode
    $s    = $raw.$mode   # mode-specific sub-object

    $out = [ordered]@{ CampaignId = $CampaignId; DialingMode = $mode }

    switch ($mode) {

        'auto' {
            $out.AutoListDialingMode            = $s.listDialingMode
            $out.AutoMinDurationBeforeRedialing = $s.minDurationBeforeRedialing
            $out.VoiceDetectionLevel            = $s.voiceDetectionLevel
        }

        'preview' {
            $out.ExtendedStrategy                  = $s.extendedStrategy
            $out.PreviewMinDurationBeforeRedialing  = $s.minDurationBeforeRedialing
            $out.PreviewDialingPriority             = $s.dialingPriority
            $out.PreviewDialingRatio                = $s.dialingRatio
            $out.PreviewOptionsType                 = $s.previewOptions.optionType
            $out.LimitedPreviewActionType           = $s.previewOptions.limited.actionType
            $out.LimitedPreviewMaxTime              = $s.previewOptions.limited.maxPreviewTime
            $out.InterruptCalls                     = $s.interruptOptions.calls
            $out.InterruptSkillVoicemails           = $s.interruptOptions.skillVoicemails
        }

        default {
            # predictive / progressive / power
            $out.ListDialingMode            = $s.listDialingMode
            $out.MinDurationBeforeRedialing = $s.minDurationBeforeRedialing
            $out.DialingPriority            = $s.dialingPriority
            $out.DialingRatio               = $s.dialingRatio
            $out.MaxAbandonCallPercentage   = $s.maxAbandonCallPercentage
            $out.CallAnalysisMode           = $s.callAnalysis.mode
            $out.AmdVoiceDetectionLevel     = $s.callAnalysis.answeringMachineData.voiceDetectionLevel
            $out.AmdActionType              = $s.callAnalysis.answeringMachineData.answerMachineAction.actionType
            $out.AmdPlayPromptId            = $s.callAnalysis.answeringMachineData.answerMachineAction.playPrompt.prompt.promptId
            $out.AmdPlayPromptMaxGreetingTime = $s.callAnalysis.answeringMachineData.answerMachineAction.playPrompt.maxGreetingTime
            $out.AmdStartScriptId           = $s.callAnalysis.answeringMachineData.answerMachineAction.startScript.scriptId
            $out.QueueExpirationActionType  = $s.queueExpirationAction.actionType
            $out.QueueExpirationPlayPromptId = $s.queueExpirationAction.playPrompt.promptId
            $out.QueueExpirationStartScriptId = $s.queueExpirationAction.startScript.scriptId
            if ($mode -eq 'power') { $out.CallToAgentRatio = $s.callToAgentRatio }
        }
    }

    [pscustomobject]$out
}
