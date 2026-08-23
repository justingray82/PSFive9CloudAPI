function Set-Five9CloudCampaignProfileAniGroup {
    param(
        [string]$ProfileId,
        [string]$ProfileName,

        # ── Outbound calls ──────────────────────────────────────────────
        [string]$AniGroupId,
        [string]$AniGroupName,
        [string]$ContactFieldId,
        [string]$ContactFieldName,
        [string]$DefaultAni,
        [bool]$ApplyAniGroupToManualCalls,
        [bool]$ApplyContactFieldToManualCalls,
        [bool]$AgentDidNumber,

        # ── Transfers & conferences ─────────────────────────────────────
        [string]$TransfersAniGroupId,
        [string]$TransfersAniGroupName,
        [string]$TransfersContactFieldId,
        [string]$TransfersContactFieldName,
        [string]$DefaultAniForTransfers,
        [string]$DefaultAniForConferences,

        # ── Queue callbacks ─────────────────────────────────────────────
        [ValidateSet('USE_SPECIFIC_ANI','USE_DOMAIN_DEFAULT_ANI','USE_INBOUND_CAMPAIGN_DNIS')]
        [string]$QueueCallbackAniSelection,
        [string]$QueueCallbackDefaultAni
    )

    if (-not $ProfileId) { $ProfileId = Resolve-Five9CloudCampaignProfileId $ProfileName } ; if (-not $ProfileId) { return }

    # Resolve any names to ids (only when a name was supplied)
    if (-not $AniGroupId          -and $AniGroupName)          { $AniGroupId          = Resolve-Five9CloudAniGroupId     -AniGroupName $AniGroupName }          ; if ($AniGroupName          -and -not $AniGroupId)          { return }
    if (-not $ContactFieldId      -and $ContactFieldName)      { $ContactFieldId      = Resolve-Five9CloudContactFieldId -FieldName $ContactFieldName }         ; if ($ContactFieldName      -and -not $ContactFieldId)      { return }
    if (-not $TransfersAniGroupId -and $TransfersAniGroupName) { $TransfersAniGroupId = Resolve-Five9CloudAniGroupId     -AniGroupName $TransfersAniGroupName }  ; if ($TransfersAniGroupName -and -not $TransfersAniGroupId) { return }
    if (-not $TransfersContactFieldId -and $TransfersContactFieldName) { $TransfersContactFieldId = Resolve-Five9CloudContactFieldId -FieldName $TransfersContactFieldName } ; if ($TransfersContactFieldName -and -not $TransfersContactFieldId) { return }

    # E.164 normalizer (strip -> prepend 1 -> collapse leading 1s -> +). Empty in => empty out (clears).
    $toE164 = {
        param($n)
        $d = $n -replace '\D', ''
        if (-not $d) { return '' }
        $d = "1$d" -replace '^1{2,}', '1'
        "+$d"
    }

    # Pull current ani-settings and rebuild the write body from it so unspecified fields are preserved.
    # NOTE: GET (read) shape differs from PUT (write) shape — nested aniGroup/contactFieldToAniMapping
    # objects on read become flat aniGroupId/contactFieldId on write; *Owned flags are read-only.
    $current = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/routes/v1/domains/$($global:Five9.DomainId)/campaign-profiles/$ProfileId/ani-settings"
    if ($current -eq $false) { return }

    # ── Read current values defensively ─────────────────────────────────
    $curOutAniGroupId     = $null ; $curOutApplyAni     = $false
    $curOutContactFieldId = $null ; $curOutApplyContact = $false
    $curOutAgentDid       = $false ; $curOutDefaultAni  = ''
    if ($current.outboundCalls) {
        $oc = $current.outboundCalls
        if ($oc.aniGroup) { $curOutAniGroupId = $oc.aniGroup.aniGroupId; if ($null -ne $oc.aniGroup.applyToManualCalls) { $curOutApplyAni = [bool]$oc.aniGroup.applyToManualCalls } }
        if ($oc.contactFieldToAniMapping) { $curOutContactFieldId = $oc.contactFieldToAniMapping.contactFieldId; if ($null -ne $oc.contactFieldToAniMapping.applyToManualCalls) { $curOutApplyContact = [bool]$oc.contactFieldToAniMapping.applyToManualCalls } }
        if ($null -ne $oc.agentDidNumber) { $curOutAgentDid = [bool]$oc.agentDidNumber }
        if ($oc.defaultAni) { $curOutDefaultAni = $oc.defaultAni }
    }

    $curTransAniGroupId = $null ; $curTransContactFieldId = $null
    $curDefaultAniTrans = ''    ; $curDefaultAniConf      = ''
    if ($current.transfersAndConferences) {
        $tc = $current.transfersAndConferences
        if ($tc.aniGroup)                 { $curTransAniGroupId     = $tc.aniGroup.aniGroupId }
        if ($tc.contactFieldToAniMapping) { $curTransContactFieldId = $tc.contactFieldToAniMapping.contactFieldId }
        if ($tc.defaultAniForTransfers)   { $curDefaultAniTrans     = $tc.defaultAniForTransfers }
        if ($tc.defaultAniForConferences) { $curDefaultAniConf      = $tc.defaultAniForConferences }
    }

    $curQcSelection = 'USE_INBOUND_CAMPAIGN_DNIS' ; $curQcDefaultAni = ''
    if ($current.queueCallbacks) {
        if ($current.queueCallbacks.aniSelection) { $curQcSelection = $current.queueCallbacks.aniSelection }
        if ($current.queueCallbacks.defaultAni)   { $curQcDefaultAni = $current.queueCallbacks.defaultAni }
    }

    # ── Apply overrides only when explicitly passed; otherwise preserve current ──
    $outAniGroupId     = if ($AniGroupId)          { $AniGroupId }          else { $curOutAniGroupId }
    $outContactFieldId = if ($ContactFieldId)      { $ContactFieldId }      else { $curOutContactFieldId }
    $outApplyAni       = if ($PSBoundParameters.ContainsKey('ApplyAniGroupToManualCalls'))     { $ApplyAniGroupToManualCalls }     else { $curOutApplyAni }
    $outApplyContact   = if ($PSBoundParameters.ContainsKey('ApplyContactFieldToManualCalls')) { $ApplyContactFieldToManualCalls } else { $curOutApplyContact }
    $outAgentDid       = if ($PSBoundParameters.ContainsKey('AgentDidNumber'))                 { $AgentDidNumber }                 else { $curOutAgentDid }
    $outDefaultAni     = if ($PSBoundParameters.ContainsKey('DefaultAni'))                     { & $toE164 $DefaultAni }           else { $curOutDefaultAni }

    $transAniGroupId     = if ($TransfersAniGroupId)     { $TransfersAniGroupId }     else { $curTransAniGroupId }
    $transContactFieldId = if ($TransfersContactFieldId) { $TransfersContactFieldId } else { $curTransContactFieldId }
    $transDefaultAni     = if ($PSBoundParameters.ContainsKey('DefaultAniForTransfers'))   { & $toE164 $DefaultAniForTransfers }   else { $curDefaultAniTrans }
    $confDefaultAni      = if ($PSBoundParameters.ContainsKey('DefaultAniForConferences')) { & $toE164 $DefaultAniForConferences } else { $curDefaultAniConf }

    $qcSelection  = if ($QueueCallbackAniSelection) { $QueueCallbackAniSelection } else { $curQcSelection }
    $qcDefaultAni = if ($PSBoundParameters.ContainsKey('QueueCallbackDefaultAni')) { & $toE164 $QueueCallbackDefaultAni } else { $curQcDefaultAni }

    if ($qcSelection -eq 'USE_SPECIFIC_ANI' -and -not $qcDefaultAni) {
        Write-Error "Queue callback selection USE_SPECIFIC_ANI requires -QueueCallbackDefaultAni."; return
    }

    # ── Build write body ────────────────────────────────────────────────
    $outbound = @{
        applyContactFieldToManualCalls = $outApplyContact
        applyAniGroupToManualCalls     = $outApplyAni
        agentDidNumber                 = $outAgentDid
    }
    if ($outAniGroupId)     { $outbound.aniGroupId     = $outAniGroupId }
    if ($outContactFieldId) { $outbound.contactFieldId = $outContactFieldId }
    if ($outDefaultAni)     { $outbound.defaultAni     = $outDefaultAni }

    $transfers = @{}
    if ($transAniGroupId)     { $transfers.aniGroupId               = $transAniGroupId }
    if ($transContactFieldId) { $transfers.contactFieldId           = $transContactFieldId }
    if ($transDefaultAni)     { $transfers.defaultAniForTransfers   = $transDefaultAni }
    if ($confDefaultAni)      { $transfers.defaultAniForConferences = $confDefaultAni }

    $queueCallbacks = @{ aniSelection = $qcSelection }
    if ($qcSelection -eq 'USE_SPECIFIC_ANI' -and $qcDefaultAni) { $queueCallbacks.defaultAni = $qcDefaultAni }

    $body = @{
        outboundCalls           = $outbound
        transfersAndConferences = $transfers
        queueCallbacks          = $queueCallbacks
    }

    $profileLabel = if ($ProfileName)  { $ProfileName }  else { $ProfileId }
    $aniLabel     = if ($AniGroupName) { $AniGroupName } elseif ($outAniGroupId) { $outAniGroupId } else { '(unchanged)' }

    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/routes/v1/domains/$($global:Five9.DomainId)/campaign-profiles/$ProfileId/ani-settings" -Method Put -Body $body
    if ($result -ne $false) { Write-Host "ANI settings updated on campaign profile '$profileLabel' (ANI group: $aniLabel)." } else { Write-Host "Failed to update ANI settings on campaign profile '$profileLabel'."; return $false }
}