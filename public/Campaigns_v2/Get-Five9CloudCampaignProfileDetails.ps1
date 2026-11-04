function Get-Five9CloudCampaignProfileDetails {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName = $true)][Alias('campaignProfileId')]
        [string]$ProfileId,
        [Parameter(ValueFromPipelineByPropertyName = $true)][Alias('name')]
        [string]$ProfileName,
        [ValidateSet('Dialing','Ani','Layout','Dispositions','Campaigns','Tags')]
        [string[]]$Include = @('Dialing','Ani','Layout','Dispositions','Campaigns','Tags'),
        [switch]$Raw
    )


    process {
        # Local copy — pipeline-bound params can carry over between records
        $id = Resolve-Five9CloudCampaignProfileId -ProfileName $ProfileName -ProfileId $ProfileId
        if (-not $id) { return }


        $base  = $global:Five9.ApiBaseUrl
        $d     = $global:Five9.DomainId
        $label = if ($ProfileName) { $ProfileName } else { $id }


        # ── General (always — supplies name/description) ────────────────
        # Not $profile — that's a PowerShell automatic variable.
        $cp = Invoke-Five9CloudApi "$base/campaigns/v1/domains/$d/campaign-profiles/$id"
        if (-not $cp) { Write-Error "Unable to retrieve campaign profile '$label'."; return }


        $rawOut = [ordered]@{ Profile = $cp }
        $out    = [ordered]@{
            ProfileId   = $cp.campaignProfileId
            Name        = $cp.name
            Description = $cp.description
        }


        # ── Dialing (General tab, lower half) ───────────────────────────
        # numberDialOrder / asap* live on the profile record; priority/timeout/charges on dialer config.
        if ($Include -contains 'Dialing') {
            $dc = Invoke-Five9CloudApi "$base/dialer/v1/domains/$d/campaign-profiles/$id/dialing-config"
            $rawOut.DialingConfig = $dc
            if ($dc -eq $false) { $dc = $null }


            $attempts = if ($null -ne $dc.numberOfDialAttempts) { $dc.numberOfDialAttempts } else { $cp.numberOfDialAttempts }


            # dialTimeout is ISO-8601 (e.g. PT20S) — expose seconds as well
            $timeoutSec = $null
            if ($dc.dialTimeout) {
                try { $timeoutSec = [int][System.Xml.XmlConvert]::ToTimeSpan($dc.dialTimeout).TotalSeconds } catch { $timeoutSec = $null }
            }


            $out.Dialing = [PSCustomObject]@{
                NumberOfDialAttempts = $attempts
                NumberDialOrder      = $cp.numberDialOrder
                AsapMaxDialAttempts  = $cp.asapMaxDialAttempts
                AsapListOrder        = $cp.asapListOrder
                CallPriority         = $dc.callPriority
                DialTimeout          = $dc.dialTimeout
                DialTimeoutSeconds   = $timeoutSec
                MaxCharges           = $dc.maxCharges
            }
        }


        # ── ANI ─────────────────────────────────────────────────────────
        # Property names mirror Set-Five9CloudCampaignProfileAniGroup parameters where possible.
        # Names resolve the way the admin console does: one bulk ani-groups call and one
        # PHONE-field call, loaded only when an id actually needs a name. Ids missing from
        # the bulk lists (beyond page 1, or a non-PHONE field) fall back to a direct lookup.
        if ($Include -contains 'Ani') {
            $ani = Invoke-Five9CloudApi "$base/routes/v1/domains/$d/campaign-profiles/$id/ani-settings"
            $rawOut.AniSettings = $ani
            if ($ani) {
                # Hashtables are mutated (not reassigned) inside the scriptblock so changes persist
                $lookup = @{ AniGroup = @{}; Field = @{}; Loaded = @{} }
                $getName = {
                    param([string]$Kind, $Key)
                    if (-not $Key) { return $null }
                    $map = $lookup[$Kind]


                    if (-not $lookup.Loaded[$Kind]) {
                        $lookup.Loaded[$Kind] = $true
                        if ($Kind -eq 'AniGroup') {
                            # Same list Resolve-Five9CloudAniGroupId uses; id may sit at .aniGroup.aniGroupId or .aniGroupId
                            $r = @(Get-Five9CloudAniGroups)
                            $rawOut.AniGroups = $r
                            $list = @()
                            foreach ($e in $r) { if ($e.items) { $list += @($e.items) } elseif ($e) { $list += $e } }
                            foreach ($g in $list) {
                                $gid = if ($g.aniGroup.aniGroupId) { $g.aniGroup.aniGroupId } else { $g.aniGroupId }
                                if ($gid) { $map[[string]$gid] = $g.name }
                            }
                        } else {
                            # Same call as Resolve-Five9CloudContactFieldId (no reverse id->name helper exists)
                            $r = Invoke-Five9CloudApi (Set-Five9CloudQueryUri "contacts/v2/domains/$d/fields" @{ filter = 'type==PHONE' })
                            $rawOut.PhoneFields = $r
                            if ($r) { foreach ($f in @($r.items)) { if ($f.id) { $map[[string]$f.id] = $f.title } } }
                        }
                    }


                    $k = [string]$Key
                    if (-not $map.ContainsKey($k)) {
                        if ($Kind -eq 'AniGroup') {
                            $r = Invoke-Five9CloudApi "$base/routes/v1/domains/$d/ani-groups/$k"
                            if ($r) { $map[$k] = $r.name } else { $map[$k] = $null }
                        } else {
                            $r = Invoke-Five9CloudApi "$base/contacts/v2/domains/$d/fields/$k"
                            if ($r) { $map[$k] = $r.title } else { $map[$k] = $null }
                        }
                    }
                    $map[$k]
                }


                $oc = $ani.outboundCalls
                $tc = $ani.transfersAndConferences
                $qc = $ani.queueCallbacks


                $out.AniSettings = [PSCustomObject]@{
                    OutboundCalls = [PSCustomObject]@{
                        AniGroupId                     = $oc.aniGroup.aniGroupId
                        AniGroupName                   = & $getName 'AniGroup' $oc.aniGroup.aniGroupId
                        ApplyAniGroupToManualCalls     = $oc.aniGroup.applyToManualCalls
                        ContactFieldId                 = $oc.contactFieldToAniMapping.contactFieldId
                        ContactFieldName               = & $getName 'Field' $oc.contactFieldToAniMapping.contactFieldId
                        ApplyContactFieldToManualCalls = $oc.contactFieldToAniMapping.applyToManualCalls
                        AgentDidNumber                 = $oc.agentDidNumber
                        DefaultAni                     = $oc.defaultAni
                        DefaultAniOwned                = $oc.defaultAniOwned
                    }
                    TransfersAndConferences = [PSCustomObject]@{
                        AniGroupId                    = $tc.aniGroup.aniGroupId
                        AniGroupName                  = & $getName 'AniGroup' $tc.aniGroup.aniGroupId
                        ContactFieldId                = $tc.contactFieldToAniMapping.contactFieldId
                        ContactFieldName              = & $getName 'Field' $tc.contactFieldToAniMapping.contactFieldId
                        DefaultAniForTransfers        = $tc.defaultAniForTransfers
                        DefaultAniForTransfersOwned   = $tc.defaultAniForTransfersOwned
                        DefaultAniForConferences      = $tc.defaultAniForConferences
                        DefaultAniForConferencesOwned = $tc.defaultAniForConferencesOwned
                    }
                    QueueCallbacks = [PSCustomObject]@{
                        AniSelection    = $qc.aniSelection
                        DefaultAni      = $qc.defaultAni
                        DefaultAniOwned = $qc.defaultAniOwned
                    }
                }
            } else { $out.AniSettings = $null }
        }


        # ── Contact Layout ──────────────────────────────────────────────
        # Fields mix CRM contact fields and CAV call variables (Type = CRM | CAV).
        if ($Include -contains 'Layout') {
            $lay = Invoke-Five9CloudApi "$base/contacts/v1/domains/$d/campaign-profiles/$id"
            $rawOut.Layout = $lay
            if ($lay) {
                $fields = @()
                foreach ($f in @($lay.fields)) {
                    if (-not $f) { continue }
                    $fields += [PSCustomObject]@{
                        Title     = $f.title
                        Type      = $f.type
                        FieldName = $f.fieldDetail.name
                        FieldId   = $f.fieldDetail.id
                        Width     = $f.width
                        Editable  = $f.editable
                    }
                }
                $out.Layout = [PSCustomObject]@{
                    FieldViewMode      = $lay.fieldViewMode
                    CtiForceToViewCavs = $lay.ctiForceToViewCavs
                    Fields             = $fields
                }
            } else { $out.Layout = $null }
        }


        # ── Disposition Menu ────────────────────────────────────────────
        # Both HAR samples had an empty treeNodes array — node shape not yet verified, so returned as-is.
        if ($Include -contains 'Dispositions') {
            $dm = Invoke-Five9CloudApi "$base/interactions/v1/domains/$d/campaign-profiles/$id/disposition-menu"
            $rawOut.DispositionMenu = $dm
            # Assign inside branches — an empty array returned from an if-expression unrolls to $null
            if ($dm) { $out.DispositionMenu = @($dm.treeNodes) } else { $out.DispositionMenu = $null }
        }


        # ── Campaigns using this profile ────────────────────────────────
        # Filter quoting matches the admin console (double quotes around the id).
        if ($Include -contains 'Campaigns') {
            $camps = @((Get-Five9CloudCampaignList -Sort 'name' -Filter "campaignProfile.campaignProfileId=='$($id)'").items)
            $rawOut.Campaigns = $camps


            $campList = @()
            foreach ($c in @($camps)) {
                if (-not $c) { continue }
                $campList += [PSCustomObject]@{
                    CampaignId          = $c.campaignId
                    Name                = $c.name
                    Type                = $c.type
                    State               = $c.state
                    Description         = $c.description
                    Agentic             = $c.agentic
                    StateLastModifiedOn = $c.stateLastModifiedOn
                }
            }
            $out.Campaigns = $campList
        }


        # ── Tags ────────────────────────────────────────────────────────
        # Profile tag list only carries tagId — names come from the ACL tag service.
        if ($Include -contains 'Tags') {
            $pt = Invoke-Five9CloudApi "$base/campaigns/v1/domains/$d/campaign-profiles/$id/tags"
            $rawOut.Tags = $pt
            if ($pt) {
                $tagIds = @()
                foreach ($item in @($pt.items)) { if ($item.tagId) { $tagIds += $item.tagId } }


                $tagDefs = @{}
                if ($tagIds.Count -gt 0) {
                    $defs = @((Get-Five9CloudDomainTags -Filter "tagId=in=($($tagIds -join ','))").items)
                    $rawOut.TagDefinitions = $defs
                    foreach ($def in $defs) { if ($def.tagId) { $tagDefs[$def.tagId] = $def } }
                }


                $tagList = @()
                foreach ($item in @($pt.items)) {
                    if (-not $item) { continue }
                    $def = $tagDefs[$item.tagId]
                    $tagList += [PSCustomObject]@{
                        TagId       = $item.tagId
                        Name        = $def.name
                        Description = $def.description
                        ParentTagId = $def.parent.tagId
                        CreatedOn   = $item.createdOn
                        CreatedBy   = $item.createdBy
                    }
                }
                $out.Tags = $tagList
            } else { $out.Tags = $null }
        }


        if ($Raw) { return [PSCustomObject]$rawOut }
        [PSCustomObject]$out
    }
}