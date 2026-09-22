function Get-Five9CloudOutboundCampaignDetails {
    # Returns every tab of an OUTBOUND campaign as one combined object.
    #
    # Usage:
    #   Get-Five9CloudOutboundCampaignDetails -CampaignName 'Agent Assist Outbound Campaign'
    #   Get-Five9CloudOutboundCampaignDetails -CampaignId 1137753 -Include Dialing,Dispositions
    #   foreach ($c in (Get-Five9CloudCampaignList).items) { if ($c.type -eq 'OUTBOUND') { Get-Five9CloudOutboundCampaignDetails -CampaignId $c.campaignId } }
    #   Get-Five9CloudOutboundCampaignDetails -CampaignId 1137753 -Raw   # untouched API responses
    #
    # NOTE: written without the $_ automatic variable so copy/paste can't mangle it.
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]$CampaignId,
        [Parameter(ValueFromPipelineByPropertyName = $true)][Alias('name')]
        [string]$CampaignName,
        [ValidateSet('Dialing','Lists','Recordings','Skills','Connectors','Dispositions','Digital','Prompts','Messaging','Script','Tags')]
        [string[]]$Include = @('Dialing','Lists','Recordings','Skills','Connectors','Dispositions','Digital','Prompts','Messaging','Script','Tags'),
        [switch]$Raw
    )

    process {
        # Local copy — pipeline-bound params can carry over between records
        $id = $CampaignId
        if (-not $id) {
            if (-not $CampaignName) { Write-Error "Specify -CampaignId or -CampaignName."; return }
            $id = Resolve-Five9CloudCampaignId $null $CampaignName
        }
        if (-not $id) { return }

        $base = $global:Five9.ApiBaseUrl
        $d    = $global:Five9.DomainId
        $cUri = "$base/campaigns/v1/domains/$d/campaigns/$id"

        # Looks up objects by id with an RSQL "in" filter, 50 ids per call. Returns @{ id = object }.
        $lookupIn = {
            param([string]$Path, [string]$Key, $Ids)
            $map  = @{}
            $list = @()
            foreach ($i in @($Ids)) { if ($i -and ($list -notcontains $i)) { $list += $i } }
            for ($n = 0; $n -lt $list.Count; $n += 50) {
                $chunk = $list[$n..([Math]::Min($n + 49, $list.Count - 1))]
                $r = Invoke-Five9CloudApi (Set-Five9CloudQueryUri $Path @{ filter = "$Key=in=($($chunk -join ','))" })
                if ($r) { foreach ($o in @($r.items)) { $map[[string]$o.$Key] = $o } }
            }
            $map
        }

        # ── General (always) ────────────────────────────────────────────
        $c = Invoke-Five9CloudApi $cUri
        if (-not $c) { Write-Error "Unable to retrieve campaign '$(if ($CampaignName) { $CampaignName } else { $id })'."; return }
        if ($c.type -ne 'OUTBOUND') { Write-Error "Campaign '$($c.name)' is $($c.type), not OUTBOUND — use Get-Five9CloudInboundCampaignDetails."; return }

        $rawOut = [ordered]@{ Campaign = $c }

        $out = [ordered]@{
            CampaignId  = $c.campaignId
            Name        = $c.name
            Description = $c.description
            Type        = $c.type
            State       = $c.state
            General     = [PSCustomObject]@{
                StateLastModifiedOn               = $c.stateLastModifiedOn
                Agentic                           = $c.agentic
                CampaignProfileId                 = $c.campaignProfile.campaignProfileId
                MaintenanceNotificationEmails     = @($c.maintenanceNotificationEmails)
                UseContactPhoneAsAniForConference = $c.useContactPhoneAsAniForConference
                SystemMessage                     = $c.systemMessage.message
            }
        }

        # ── Dialing ─────────────────────────────────────────────────────
        # Flattened with the module's resolver so property names match Set-Five9CloudCampaignDialingSettings.
        if ($Include -contains 'Dialing') {
            if ($Raw) { $rawOut.DialingSettings = Get-Five9CloudCampaignDialingSettings -CampaignId $id }
            else      { $out.Dialing = Resolve-Five9CloudCampaignDialingSettings -CampaignId $id }
        }

        # ── Lists ───────────────────────────────────────────────────────
        # Not captured in the HAR (Lists tab wasn't opened) — uses the existing module endpoint, items returned as-is.
        if ($Include -contains 'Lists') {
            $ls = @()
            foreach ($page in @(Get-Five9CloudCampaignCallLists -CampaignId $id)) { if ($page) { $ls += @($page.items) } }
            $rawOut.Lists = $ls
            $out.Lists    = $ls
        }

        # ── Recordings ──────────────────────────────────────────────────
        if ($Include -contains 'Recordings') {
            $rs = Invoke-Five9CloudApi "$base/recordings/v1/domains/$d/campaigns/$id/recording-settings"
            $rawOut.RecordingSettings = $rs
            $rec = $c.recordings
            $out.Recordings = [PSCustomObject]@{
                AutoRecord                 = $rec.autoRecord
                UserCanControlRecording    = $rec.userCanControlRecording
                RecordQueueCallbacks       = $rec.recordQueueCallbacks
                DisableFilenamePattern     = $rec.disableFilenamePattern
                ContinueRecordTo3rdParty   = $rec.continueRecordTo3rdParty
                ContinueRecordOnHoldCaller = $rec.continueRecordOnHoldCaller
                ContinueRecordOnHoldAgent  = $rec.continueRecordOnHoldAgent
                RecordingSettingsEnabled   = $rs.recordingSettingsEnabled
            }
        }

        # ── Skills ──────────────────────────────────────────────────────
        if ($Include -contains 'Skills') {
            $sk = @(Invoke-Five9CloudPagedApi -Uri (Set-Five9CloudQueryUri "campaigns/v1/domains/$d/campaigns/$id/skills" @{ pageLimit = 100 }) -ResultProperty 'items')
            $rawOut.Skills = $sk
            $ids = @(); foreach ($i in $sk) { $ids += $i.skill.skillId }
            $defs = & $lookupIn "skills/v1/domains/$d/skills" 'skillId' $ids
            $list = @()
            foreach ($i in $sk) {
                $def = $defs[[string]$i.skill.skillId]
                $list += [PSCustomObject]@{ SkillId = $i.skill.skillId; Name = $def.name; Description = $def.description }
            }
            $out.Skills = $list
        }

        # ── Connectors ──────────────────────────────────────────────────
        # HAR sample had no connectors — item shape not yet verified, returned as-is.
        if ($Include -contains 'Connectors') {
            $cn = @(Invoke-Five9CloudPagedApi -Uri (Set-Five9CloudQueryUri "campaigns/v1/domains/$d/campaigns/$id/connectors" @{ pageLimit = 100 }) -ResultProperty 'items')
            $rawOut.Connectors = $cn
            $out.Connectors    = $cn
        }

        # ── Dispositions ────────────────────────────────────────────────
        if ($Include -contains 'Dispositions') {
            # The console loads these in two groups: regular dispositions, then the preview-decline one.
            $cd = @()
            foreach ($f in @('callCategory!=^DECLINE_PREVIEW_AGENT_CALL', 'callCategory==^DECLINE_PREVIEW_AGENT_CALL')) {
                $cd += @(Invoke-Five9CloudPagedApi -Uri (Set-Five9CloudQueryUri "interactions/v1/domains/$d/campaigns/$id/dispositions" @{ filter = $f }) -ResultProperty 'items')
            }
            $rawOut.Dispositions = $cd

            $ids = @(); foreach ($i in $cd) { $ids += $i.dispositionId }
            $defs = & $lookupIn "interactions/v1/domains/$d/dispositions" 'dispositionId' $ids
            $rawOut.DispositionDefinitions = @($defs.Values)

            $list = @()
            foreach ($i in $cd) {
                $def = $defs[[string]$i.dispositionId]
                $list += [PSCustomObject]@{
                    DispositionId         = $i.dispositionId
                    Name                  = $def.name
                    Description           = $def.description
                    CallCategory          = $i.callCategory
                    AllowedCallCategories = @($i.allowedCallCategories)
                    Customized            = $i.customized
                    SystemManaged         = (@($i.useTags) -contains 'SYSTEM_MANAGED')
                }
            }
            $out.Dispositions = $list
        }

        # ── Digital (chat/email profiles, workflows, transcripts) ───────
        # Chat/email profile and email configuration objects were null in the sample — returned as-is.
        if ($Include -contains 'Digital') {
            $dc = Invoke-Five9CloudApi "$base/digital-config-svc/v1/domains/$d/campaigns/$id/digital-configurations"
            $wf = Invoke-Five9CloudApi "$base/digital-config-svc/v1/domains/$d/campaigns/$id/workflows"
            $dk = Invoke-Five9CloudApi "$base/digital-config-svc/v1/domains/$d/campaigns/$id/skills"
            $rawOut.DigitalConfigurations = $dc
            $rawOut.DigitalWorkflows      = $wf
            $rawOut.DigitalSkill          = $dk
            $tr = $c.transcripts
            $out.Digital = [PSCustomObject]@{
                EnableChatProfile                = $dc.enableChatProfile
                ChatProfile                      = $dc.chatProfile
                EnableEmailProfile               = $dc.enableEmailProfile
                EmailProfile                     = $dc.emailProfile
                EnableInboundEmailConfiguration  = $dc.enableInboundEmailConfiguration
                InboundEmailConfiguration        = $dc.inboundEmailConfiguration
                EnableOutboundEmailConfiguration = $dc.enableOutboundEmailConfiguration
                OutboundEmailConfiguration       = $dc.outboundEmailConfiguration
                EmailThreading                   = $dc.emailThreading
                Rule                             = $dc.rule
                UseCustomContactLayout           = $dc.useCustomContactLayout
                TranscriptTitle                  = $dc.transcriptTitle
                CustomerTranscript               = $dc.customerTranscript
                DigitalSkillId                   = $dk.skillId
                Workflows                        = [PSCustomObject]@{ Email = $wf.email; Chat = $wf.chat; ExternalRouting = $wf.externalRouting; Case = $wf.case }
                Transcripts                      = [PSCustomObject]@{
                    OverrideDomainSettings = $tr.overrideDomainSettings
                    ExportChat             = $tr.exportChat
                    ExportEmail            = $tr.exportEmail
                    ExportSocial           = $tr.exportSocial
                    DisableFilenamePattern = $tr.disableFilenamePattern
                }
            }
        }

        # ── Prompts (hold / connected-whisper) ──────────────────────────
        # Both were empty in the sample — item shape not yet verified, returned as-is.
        if ($Include -contains 'Prompts') {
            $hp = Invoke-Five9CloudApi "$base/prompts/v1/domains/$d/campaigns/$id/hold"
            $cp = Invoke-Five9CloudApi "$base/prompts/v1/domains/$d/campaigns/$id/connected"
            $rawOut.HoldPrompts      = $hp
            $rawOut.ConnectedPrompts = $cp
            $out.Prompts = [PSCustomObject]@{ Hold = @($hp.items); Connected = @($cp.items) }
        }

        # ── Messaging (WhatsApp handles) ────────────────────────────────
        # Empty in the sample — item shape not yet verified, returned as-is.
        if ($Include -contains 'Messaging') {
            $wa = @(Invoke-Five9CloudPagedApi -Uri "$base/messaging-config/v1/domains/$d/campaigns/$id/channels/WHATSAPP/campaign-handles" -ResultProperty 'items')
            $rawOut.WhatsAppHandles = $wa
            $out.WhatsAppHandles    = $wa
        }

        # ── Agent script ────────────────────────────────────────────────
        if ($Include -contains 'Script') {
            $as = Invoke-Five9CloudApi "$cUri/agent-script"
            $rawOut.AgentScript = $as
            $txt = $null
            if ($as) { $txt = ([string]$as.script).TrimStart([char]0xFEFF) }   # empty scripts come back as a lone BOM
            $out.AgentScript = $txt
        }

        # ── Tags ────────────────────────────────────────────────────────
        if ($Include -contains 'Tags') {
            $pt = Invoke-Five9CloudApi "$cUri/tags"
            $rawOut.Tags = $pt
            if ($pt) {
                $ids = @(); foreach ($i in @($pt.items)) { $ids += $i.tagId }
                $defs = & $lookupIn "acl/v1/domains/$d/tags" 'tagId' $ids
                $list = @()
                foreach ($i in @($pt.items)) {
                    $def = $defs[[string]$i.tagId]
                    $list += [PSCustomObject]@{
                        TagId       = $i.tagId
                        Name        = $def.name
                        Description = $def.description
                        ParentTagId = $def.parent.tagId
                        CreatedOn   = $i.createdOn
                        CreatedBy   = $i.createdBy
                    }
                }
                $out.Tags = $list
            } else { $out.Tags = $null }
        }

        if ($Raw) { return [PSCustomObject]$rawOut }
        [PSCustomObject]$out
    }
}
