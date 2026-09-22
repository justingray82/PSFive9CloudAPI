function Get-Five9CloudCampaignProfileDetails {
    # Returns every tab of a campaign profile as one combined object.
    #
    # Usage:
    #   Get-Five9CloudCampaignProfileDetails -ProfileName 'Generic Outbound'
    #   Get-Five9CloudCampaignProfileDetails -ProfileId 144133 -Include Ani,Tags
    #   (Get-Five9CloudCampaignProfiles).items | Get-Five9CloudCampaignProfileDetails
    #   Get-Five9CloudCampaignProfileDetails -ProfileName 'Generic Outbound' -Raw   # untouched API responses
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
        $id = $ProfileId
        if (-not $id) {
            if (-not $ProfileName) { Write-Error "Specify -ProfileId or -ProfileName."; return }
            $id = Resolve-Five9CloudCampaignProfileId $ProfileName
        }
        if (-not $id) { return }

        $base  = $global:Five9.ApiBaseUrl
        $d     = $global:Five9.DomainId
        $label = if ($ProfileName) { $ProfileName } else { $id }

        # ── General (always — supplies name/description) ────────────────
        $profile = Invoke-Five9CloudApi "$base/campaigns/v1/domains/$d/campaign-profiles/$id"
        if (-not $profile) { Write-Error "Unable to retrieve campaign profile '$label'."; return }

        $rawOut = [ordered]@{ Profile = $profile }
        $out    = [ordered]@{
            ProfileId   = $profile.campaignProfileId
            Name        = $profile.name
            Description = $profile.description
        }

        # ── Dialing ─────────────────────────────────────────────────────
        # numberDialOrder / asap* live on the profile record; priority/timeout/charges on dialer config.
        if ($Include -contains 'Dialing') {
            $dc = Invoke-Five9CloudApi "$base/dialer/v1/domains/$d/campaign-profiles/$id/dialing-config"
            $rawOut.DialingConfig = $dc
            if ($dc -eq $false) { $dc = $null }

            $attempts = if ($null -ne $dc.numberOfDialAttempts) { $dc.numberOfDialAttempts } else { $profile.numberOfDialAttempts }

            # dialTimeout is ISO-8601 (e.g. PT20S) — expose seconds as well
            $timeoutSec = $null
            if ($dc.dialTimeout) {
                try { $timeoutSec = [int][System.Xml.XmlConvert]::ToTimeSpan($dc.dialTimeout).TotalSeconds } catch { $timeoutSec = $null }
            }

            $out.Dialing = [PSCustomObject]@{
                NumberOfDialAttempts = $attempts
                NumberDialOrder      = $profile.numberDialOrder
                AsapMaxDialAttempts  = $profile.asapMaxDialAttempts
                AsapListOrder        = $profile.asapListOrder
                CallPriority         = $dc.callPriority
                DialTimeout          = $dc.dialTimeout
                DialTimeoutSeconds   = $timeoutSec
                MaxCharges           = $dc.maxCharges
            }
        }

        # ── ANI ─────────────────────────────────────────────────────────
        # Property names mirror Set-Five9CloudCampaignProfileAniGroup parameters where possible.
        if ($Include -contains 'Ani') {
            $ani = Invoke-Five9CloudApi "$base/routes/v1/domains/$d/campaign-profiles/$id/ani-settings"
            $rawOut.AniSettings = $ani
            if ($ani) {
                # Outbound and transfers usually share ids — cache lookups
                $nameCache = @{}
                $getAniGroupName = {
                    param($gid)
                    if (-not $gid) { return $null }
                    $k = "ag:$gid"
                    if (-not $nameCache.ContainsKey($k)) {
                        $r = Invoke-Five9CloudApi "$base/routes/v1/domains/$d/ani-groups/$gid"
                        $nameCache[$k] = if ($r) { $r.name } else { $null }
                    }
                    $nameCache[$k]
                }
                $getFieldName = {
                    param($fid)
                    if (-not $fid) { return $null }
                    $k = "cf:$fid"
                    if (-not $nameCache.ContainsKey($k)) {
                        $r = Invoke-Five9CloudApi "$base/contacts/v2/domains/$d/fields/$fid"
                        $nameCache[$k] = if ($r) { $r.title } else { $null }
                    }
                    $nameCache[$k]
                }

                $oc = $ani.outboundCalls
                $tc = $ani.transfersAndConferences
                $qc = $ani.queueCallbacks

                $out.AniSettings = [PSCustomObject]@{
                    OutboundCalls = [PSCustomObject]@{
                        AniGroupId                     = $oc.aniGroup.aniGroupId
                        AniGroupName                   = & $getAniGroupName $oc.aniGroup.aniGroupId
                        ApplyAniGroupToManualCalls     = $oc.aniGroup.applyToManualCalls
                        ContactFieldId                 = $oc.contactFieldToAniMapping.contactFieldId
                        ContactFieldName               = & $getFieldName $oc.contactFieldToAniMapping.contactFieldId
                        ApplyContactFieldToManualCalls = $oc.contactFieldToAniMapping.applyToManualCalls
                        AgentDidNumber                 = $oc.agentDidNumber
                        DefaultAni                     = $oc.defaultAni
                        DefaultAniOwned                = $oc.defaultAniOwned
                    }
                    TransfersAndConferences = [PSCustomObject]@{
                        AniGroupId                    = $tc.aniGroup.aniGroupId
                        AniGroupName                  = & $getAniGroupName $tc.aniGroup.aniGroupId
                        ContactFieldId                = $tc.contactFieldToAniMapping.contactFieldId
                        ContactFieldName              = & $getFieldName $tc.contactFieldToAniMapping.contactFieldId
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

        # ── Layout ──────────────────────────────────────────────────────
        # Fields mix CRM contact fields and CAV call variables (Type = CRM | CAV).
        if ($Include -contains 'Layout') {
            $lay = Invoke-Five9CloudApi "$base/contacts/v1/domains/$d/campaign-profiles/$id"
            $rawOut.Layout = $lay
            if ($lay) {
                $out.Layout = [PSCustomObject]@{
                    FieldViewMode      = $lay.fieldViewMode
                    CtiForceToViewCavs = $lay.ctiForceToViewCavs
                    Fields             = @($lay.fields | ForEach-Object {
                        [PSCustomObject]@{
                            Title     = $_.title
                            Type      = $_.type
                            FieldName = $_.fieldDetail.name
                            FieldId   = $_.fieldDetail.id
                            Width     = $_.width
                            Editable  = $_.editable
                        }
                    })
                }
            } else { $out.Layout = $null }
        }

        # ── Dispositions ────────────────────────────────────────────────
        # HAR sample had an empty treeNodes array — node shape not yet verified, so returned as-is.
        if ($Include -contains 'Dispositions') {
            $dm = Invoke-Five9CloudApi "$base/interactions/v1/domains/$d/campaign-profiles/$id/disposition-menu"
            $rawOut.DispositionMenu = $dm
            # Assign inside branches — an empty array returned from an if-expression unrolls to $null
            if ($dm) { $out.DispositionMenu = @($dm.treeNodes) } else { $out.DispositionMenu = $null }
        }

        # ── Campaigns using this profile ────────────────────────────────
        if ($Include -contains 'Campaigns') {
            $uri   = Set-Five9CloudQueryUri "campaigns/v1/domains/$d/campaigns" @{ sort = 'name'; filter = "campaignProfile.campaignProfileId=='$id'" }
            $camps = Invoke-Five9CloudPagedApi -Uri $uri -ResultProperty 'items'
            $rawOut.Campaigns = $camps
            $out.Campaigns    = @($camps)
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
