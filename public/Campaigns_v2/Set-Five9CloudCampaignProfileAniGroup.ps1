function Set-Five9CloudCampaignProfileAniGroup {
    param(
        [string]$ProfileId,
        [string]$ProfileName,

        # Outbound ANI group (name resolves to id). Omit both to keep the profile's current group.
        [string]$AniGroupId,
        [string]$AniGroupName,

        # Contact-variable-to-ANI mapping (PHONE-type contact field). Omit both to keep current.
        [string]$ContactFieldId,
        [string]$ContactFieldName,

        # Optional outbound overrides — omit to preserve the profile's current values
        [string]$DefaultAni,
        [bool]$ApplyAniGroupToManualCalls,
        [bool]$ApplyContactFieldToManualCalls,
        [bool]$AgentDidNumber
    )

    if (-not $ProfileId) { $ProfileId = Resolve-Five9CloudCampaignProfileId $ProfileName } ; if (-not $ProfileId) { return }
    if (-not $AniGroupId -and $AniGroupName)         { $AniGroupId     = Resolve-Five9CloudAniGroupId -AniGroupName $AniGroupName } ; if ($AniGroupName -and -not $AniGroupId) { return }
    if (-not $ContactFieldId -and $ContactFieldName) { $ContactFieldId = Resolve-Five9CloudContactFieldId -FieldName $ContactFieldName } ; if ($ContactFieldName -and -not $ContactFieldId) { return }

    # Pull current ani-settings and rebuild the write body from it so unspecified fields are preserved.
    # NOTE: the GET (read) shape differs from the PUT (write) shape — see the read->write mapping below.
    $current = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/routes/v1/domains/$($global:Five9.DomainId)/campaign-profiles/$ProfileId/ani-settings"
    if ($current -eq $false) { return }

    # ── Read current values defensively ────────────────────────────────────────
    $curAniGroupId     = $null
    $curApplyAni       = $false
    $curContactFieldId = $null
    $curApplyContact   = $false
    $curAgentDid       = $false
    $curDefaultAni     = ''
    $curSelection      = 'USE_INBOUND_CAMPAIGN_DNIS'

    if ($current.outboundCalls) {
        $oc = $current.outboundCalls
        if ($oc.aniGroup) {
            $curAniGroupId = $oc.aniGroup.aniGroupId
            if ($null -ne $oc.aniGroup.applyToManualCalls) { $curApplyAni = [bool]$oc.aniGroup.applyToManualCalls }
        }
        if ($oc.contactFieldToAniMapping) {
            $curContactFieldId = $oc.contactFieldToAniMapping.contactFieldId
            if ($null -ne $oc.contactFieldToAniMapping.applyToManualCalls) { $curApplyContact = [bool]$oc.contactFieldToAniMapping.applyToManualCalls }
        }
        if ($null -ne $oc.agentDidNumber) { $curAgentDid = [bool]$oc.agentDidNumber }
        if ($oc.defaultAni) { $curDefaultAni = $oc.defaultAni }
    }
    if ($current.queueCallbacks -and $current.queueCallbacks.aniSelection) { $curSelection = $current.queueCallbacks.aniSelection }

    # ── Apply overrides only when explicitly passed; otherwise preserve current ─
    $aniGroupId    = if ($AniGroupId)     { $AniGroupId }     else { $curAniGroupId }
    $contactFldId  = if ($ContactFieldId) { $ContactFieldId } else { $curContactFieldId }
    $applyAniGroup = if ($PSBoundParameters.ContainsKey('ApplyAniGroupToManualCalls'))     { $ApplyAniGroupToManualCalls }     else { $curApplyAni }
    $applyContact  = if ($PSBoundParameters.ContainsKey('ApplyContactFieldToManualCalls')) { $ApplyContactFieldToManualCalls } else { $curApplyContact }
    $agentDid      = if ($PSBoundParameters.ContainsKey('AgentDidNumber'))                 { $AgentDidNumber }                 else { $curAgentDid }

    $defaultAniOut = $curDefaultAni
    if ($PSBoundParameters.ContainsKey('DefaultAni')) {
        $cleanAni = $DefaultAni -replace '\D', ''
        if ($cleanAni) { $cleanAni = "1$cleanAni" -replace '^1{2,}', '1'; $defaultAniOut = "+$cleanAni" } else { $defaultAniOut = '' }
    }

    # ── Build write body (contactFieldId / aniGroupId / defaultAni only when present) ─
    $outbound = @{
        applyContactFieldToManualCalls = $applyContact
        applyAniGroupToManualCalls     = $applyAniGroup
        agentDidNumber                 = $agentDid
    }
    if ($aniGroupId)    { $outbound.aniGroupId     = $aniGroupId }
    if ($contactFldId)  { $outbound.contactFieldId = $contactFldId }
    if ($defaultAniOut) { $outbound.defaultAni     = $defaultAniOut }

    $body = @{
        outboundCalls           = $outbound
        transfersAndConferences = @{}
        queueCallbacks          = @{ aniSelection = $curSelection }
    }

    $profileLabel = if ($ProfileName)  { $ProfileName }  else { $ProfileId }
    $aniLabel     = if ($AniGroupName) { $AniGroupName } elseif ($aniGroupId) { $aniGroupId } else { '(unchanged)' }

    $result = Invoke-Five9CloudApi "$($global:Five9.ApiBaseUrl)/routes/v1/domains/$($global:Five9.DomainId)/campaign-profiles/$ProfileId/ani-settings" -Method Put -Body $body
    if ($result -ne $false) { Write-Host "ANI settings updated on campaign profile '$profileLabel' (ANI group: $aniLabel)." } else { Write-Host "Failed to update ANI settings on campaign profile '$profileLabel'."; return $false }
}