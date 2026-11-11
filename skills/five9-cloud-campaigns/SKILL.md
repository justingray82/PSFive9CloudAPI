---
name: five9-cloud-campaigns
description: For Cowork users. Manage Five9 campaigns with the PSFive9CloudAPI PowerShell module through the Five9 Cloud REST API - list and document inbound, outbound, and autodial campaigns; create or update them; assign skills, connectors, tags, IVR scripts, hold and whisper prompts, call lists, and campaign profiles; change dialing mode and dialing settings; start, stop, or reset campaigns; and use the IVR debugger. Always writes a paste-ready script with a dry run and confirmation, with extra care for actions that affect live calls. Use this skill whenever the user mentions Five9 campaigns, campaign profiles, dialing modes (predictive, progressive, preview, power), call lists, campaign skills, IVR script assignment, starting or stopping campaigns, or comparing campaign settings, even if they never name the module.
---

# Five9 campaigns with PSFive9CloudAPI

Helps a Five9 admin read and change campaign configuration safely. Claude writes
a paste-ready PowerShell script; the user runs it locally.

## Where things run (Cowork)

Claude's shell is a sandbox: it does not have the user's PowerShell session,
module, or Five9 login, and must never call Five9. The working model is that
**Claude reads and writes, the user runs.** Claude writes scripts into the shared
folder; the user runs them in their own PowerShell and pastes back output with
secrets and customer data removed.

If no folder is shared, the module is not installed, or the user has never
connected successfully, switch to the `five9-cloud-setup` skill first and come
back.

## Source of truth

1. If the repo is cloned in the shared folder, read `AGENTS.md` once per chat and
   read **each function's `.ps1` file before using it** in a script. Parameter
   sets, defaults, and return values matter, and the files change.
2. Otherwise use `references/functions.md` in this skill (generated from the
   module source). When a parameter detail is unclear, ask the user to run
   `(Get-Command <Function>).Parameters.Keys` or
   `(Get-Command <Function>).Definition` and paste the result.
3. Never invent a function or parameter. If the module has no function for what
   the user wants, say so, offer the nearest supported route, and point
   contributors at the `five9-cloud-module-dev` skill.

## Choosing the right function

| Goal | Use | Notes |
|---|---|---|
| List campaigns | `Get-Five9CloudCampaignList` | Paged; read `.items` (`campaignId`, `name`, `type`, state). |
| Full picture of one campaign | `Get-Five9CloudInboundCampaignDetails` / `Get-Five9CloudOutboundCampaignDetails` | Combine every tab into one object; `-Include` narrows tabs, `-Raw` returns untouched API responses. Accept pipeline input from the list. |
| Single tabs | `Get-Five9CloudCampaignDetails`, `...Skills`, `...Numbers`, `...Connectors`, `...Tags`, `...CallLists`, `...DialingSettings`, `...DialingConfiguration`, `...Hold`, `...Whisper`, `...AgentScript` | |
| Create | `New-Five9CloudInboundCampaign`, `New-Five9CloudOutboundCampaign`, `New-Five9CloudAutodialCampaign` | `New-Five9CloudCampaign -CampaignDetails @{...}` is the raw form; prefer the typed ones. |
| Update general settings | `Set-Five9CloudInboundCampaign`, `Set-Five9CloudOutboundCampaign` | GET-then-PUT: only parameters you pass change. |
| Dialing | `Set-Five9CloudCampaignDialingSettings` (mode switches `-Predictive`, `-Progressive`, `-Preview`, `-Power`, `-Auto` plus mode options), `Set-Five9CloudCampaignDialingConfiguration`, `Set-Five9CloudCampaignCallList`, `Set-Five9CloudCampaignPrioritization` (domain-level) | Dialing settings have many interdependent options: read the function source before writing a call, and try one campaign first. |
| Skills, connectors, tags | `Add-`/`Remove-Five9CloudCampaignSkill`, `...Connector`, `...Tag` | Removing the last skill from an inbound campaign leaves calls with nowhere to route. |
| Scripts and prompts | `Set-Five9CloudCampaignAgentScript`, `Set-Five9CloudCampaignHold`, `Set-Five9CloudCampaignWhisper`, `Get-Five9CloudScripts`, `Get-Five9CloudScriptParameters`, `Get-Five9CloudPrompts` | |
| Agent-facing styling | `Set-Five9CloudCampaignCSS`, `Reset-Five9CloudCampaignCSS` | |
| Campaign profiles | `Get-Five9CloudCampaignProfiles`, `Get-Five9CloudCampaignProfileDetails`, `New-`/`Set-`/`Remove-Five9CloudCampaignProfile`, `Remove-Five9CloudCampaignProfileTag` | ANI group settings on a profile are in `five9-cloud-numbers`. |
| Run state | `Start-Five9CloudCampaign`, `Stop-Five9CloudCampaign` (`-Force` = force stop) | **Live traffic.** |
| Resets | `Reset-Five9CloudCampaign`, `Reset-Five9CloudCampaignDialingListPositions`, `Reset-Five9CloudCampaignAbandonedCallRate` | **Live impact**; dialing-list reset restarts list progress. |
| IVR debugging | `Start-Five9CloudCampaignIvrDebugger -Channel VOICE\|VISUAL\|CHAT\|EMAIL\|CASE -Variable -Value` | |
| Dispositions, connectors (domain lists) | `Get-Five9CloudDispositionList`, `Get-Five9CloudConnectors` | |
| Delete | `Remove-Five9CloudCampaign`, `Remove-Five9CloudCampaignSurvey` | See deletions below. |

Phone numbers (DNIS) on campaigns are in `five9-cloud-numbers`. Full parameter
list: `references/functions.md`.

## Safety: dry run, confirm, execute, verify

Every write to a live domain follows this order. The module has **no `-WhatIf`**,
so the dry run is built into the script.

1. **Validate input.** Missing required columns or values, duplicates, malformed
   emails or phone numbers. Report problems and stop.
2. **Dry run** (`$DryRun = $true`). Read current state with `Get-`/`Resolve-`
   functions and print a plan: counts of Create/Update/Skip with reasons, and a
   sample. The script prints the connected domain ID.
3. **Confirm.** Ask the user, in one line, to confirm the domain ID is their
   intended target and whether it is production. Wait for an explicit yes to the
   plan. A vague reply is not a yes.
4. **Execute** (`$DryRun = $false`, `$ExpectedDomainId` set). The script refuses
   to run against any other domain. Log every row to `logs/`.
5. **Verify.** Many module functions return nothing on success and only print a
   message, so the script re-reads each object after writing and records OK or
   FAILED. Report failures with what is known; the module does not surface API
   error bodies, so suggest `Get-Five9CloudConfigEvents` or the Admin Console for
   detail.

A user running a read-only command locally needs no write confirmation.
Before any `Remove-`, `Reset-`, number release, or campaign stop, follow
`OBJECT_DEPENDENCIES.md` (in the repo; summarized in the deletion section below)
and get a **separate** confirmation naming exactly what will be removed.

### Credentials and secrets
- Scripts prompt with `Get-Credential` (masked) and never contain passwords or
  client secrets. Never ask the user to paste either into chat.
- Never print or log `$global:Five9` (its `AuthParams` holds the plaintext
  password), the access token, or `Get-Five9CloudAuthHeader`. If a user pastes
  any of these, tell them to change the password or revoke the secret.
- Scripts end with `Remove-Variable Five9 -Scope Global`.

### Campaign-specific cautions
- **Start, stop, force stop, and resets act on live traffic immediately.** For
  these, confirm the exact campaign names, the effect on in-progress calls, and
  timing, separately from any other change. Prefer a normal stop over `-Force`.
- **Before changing settings, back up.** In the dry run, save
  `Get-Five9Cloud(Inbound|Outbound)CampaignDetails` output for each target to
  `backups/campaign-<name>-<timestamp>.json` with `ConvertTo-Json -Depth 20`.
  This gives a record to compare or restore by hand.
- **Diff, don't just describe.** For updates, the plan shows each field's
  current value next to the new value, and marks fields that already match as
  Skip.
- **Dialing-mode changes** on an outbound campaign that is running can change
  pacing mid-shift; suggest making them while the campaign is stopped.
- **Deletion:** the campaign must be stopped. Follow `OBJECT_DEPENDENCIES.md`:
  back up the full details, list its skills, numbers, connectors, and tags, and
  tell the user to check IVR scripts and schedules that transfer to it in the
  Admin Console (the module cannot see those references). Get a separate
  confirmation naming the campaign.

## Writing scripts

Start from `assets/run-template.ps1` in this skill. Save scripts to the shared
folder's `scripts/` directory (not inside a cloned repo, so updates never collide
with the user's work), inputs to `input/`, logs to `logs/`, and backups to
`backups/`.

Follow the module's paste-ready conventions so admins can run scripts with F5:
- A plain `CONFIG` block at the top, no `param()` block.
- Windows PowerShell 5.1 syntax only: no `??`, `?.`, ternaries, or
  `ForEach-Object -Parallel`.
- `return`, never `exit` (exit closes ISE).
- Call module functions; do not hand-build `Invoke-RestMethod` requests. Module
  calls include a 250 ms pause that keeps bulk runs under rate limits. No
  parallel jobs.
- Pass `-SkipUpdateCheck` to `Connect-Five9Cloud` so the live run uses the code
  that was dry-run.
- Prefer passing IDs once resolved; resolvers print "not found" in red, so for
  existence checks in a dry run query `Get-` functions directly.
- Paged `Get-` functions usually return page envelopes; use `.items`. Check the
  function source for `-ResultProperty`, which returns items directly.

Give the user the exact command to run, for example
`.\scripts\bulk-create-users.ps1` from `Five9-Admin` (or open it in ISE and
press F5), and ask for the console output with names, emails, and numbers
redacted unless they want them discussed.

## Common requests

- **"Document our campaigns" / "compare two campaigns"** — read-only. Script
  loops `Get-Five9CloudCampaignList`, calls the matching Details function per
  campaign, and writes JSON per campaign plus a summary CSV. For a comparison,
  flatten both objects and output only differing fields. No confirmation needed
  beyond the user running it.
- **"Add skill X to these 20 campaigns"** — CSV or list input; plan checks the
  skill exists and which campaigns already have it; `Add-Five9CloudCampaignSkill`
  per campaign; verify with `Get-Five9CloudCampaignSkills`.
- **"Switch these outbound campaigns to progressive at ratio 1.5"** — read the
  `Set-Five9CloudCampaignDialingSettings` source first, back up, plan shows
  current vs new mode and ratio, trial on one campaign, then the rest.
- **"Stop all campaigns tonight"** — list running campaigns in the plan; separate
  explicit confirmation; normal stop; verify state afterwards.

## Style

Short, concrete replies. Ask for campaign names and the target domain one
question at a time. Show commands in code blocks.
