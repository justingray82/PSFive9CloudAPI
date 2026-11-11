---
name: five9-cloud-domain
description: For Cowork users. Document and manage Five9 domain-level configuration with the PSFive9CloudAPI PowerShell module through the Five9 Cloud REST API - export a read-only snapshot of the whole domain (users, campaigns, profiles, skills, numbers, ANI groups, tags, schedules, permissions, settings) to JSON and CSV, review the config audit log, and change domain settings, tags and tag scopes, IVR schedules, email configurations and notification emails, internal call settings, and digital assistance responses. Changes always use a dry run and confirmation. Use this skill whenever the user wants to document, audit, back up, snapshot, or compare a Five9 domain, see who changed what, or manage Five9 tags, schedules, email settings, notification emails, internal calls, or digital assistance, even if they never name the module.
---

# Five9 domain configuration with PSFive9CloudAPI

Two jobs: **documenting** a domain (read-only, low risk, often the first thing a
new user wants) and **changing** domain-level settings (dry run and confirm).
Claude writes paste-ready PowerShell scripts; the user runs them locally.

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

## Part A: Document a domain (read-only)

Read-only scripts need no write confirmation, but still confirm the target domain
once, and remind the user that exports contain customer data (names, emails,
phone numbers) and belong in a private folder, not a public repo or ticket.

Build `scripts/export-domain.ps1` from `assets/run-template.ps1`, dropping the
CSV input and dry-run sections. For each area below, call the `Get-` function,
save full JSON to `exports/<domainId>-<timestamp>/<area>.json` with
`ConvertTo-Json -Depth 20`, and a flat CSV of the key columns for easy reading.
Wrap each area in its own check so one failure does not stop the export, and
print a summary table of area, item count, and status at the end.

| Area | Function(s) |
|---|---|
| Domain settings | `Get-Five9CloudDomainSettings`, `Get-Five9CloudInternalCallsSettings`, `Get-Five9CloudUtilizationSettings`, `Get-Five9CloudEmailNotificationSettings` |
| Users | `Get-Five9CloudUserDetails`, `Get-Five9CloudUserMigrationDetails`, `Get-Five9CloudUserProfiles` |
| Access | `Get-Five9CloudPermissionList`, `Get-Five9CloudPermissionSetDetails`, `Get-Five9CloudApplications`, `Get-Five9CloudCircleDetails`, `Get-Five9CloudDomainMFAPolicies`, `Get-Five9CloudIdpPolicyDetails` |
| Campaigns | `Get-Five9CloudCampaignList`, then `Get-Five9CloudInboundCampaignDetails` / `Get-Five9CloudOutboundCampaignDetails` per campaign by `type` |
| Campaign profiles | `Get-Five9CloudCampaignProfiles`, `Get-Five9CloudCampaignProfileDetails` per profile |
| Numbers and caller ID | `Get-Five9CloudDomainNumbers`, `Get-Five9CloudAniGroups`, `Get-Five9CloudAniGroupNumbers` per group, `Get-Five9CloudNumberCredits` |
| Routing objects | `Get-Five9CloudScripts`, `Get-Five9CloudPrompts`, `Get-Five9CloudSchedules`, `Get-Five9CloudConnectors`, `Get-Five9CloudDispositionList`, `Get-Five9CloudReasonCodeList`, `Get-Five9CloudReasonCodeSetList` |
| Tags | `Get-Five9CloudDomainTags` |
| Other | `Get-Five9CloudDigitalAssistance`, `Get-Five9CloudEmailConfigurations`, `Get-Five9CloudCannedReports`, `Get-Five9CloudDomainVerintPackages`, `Get-Five9CloudServiceAccounts` |

Per-campaign and per-group loops make many calls; the module's built-in pause
keeps this within rate limits, so a large domain can take several minutes. Show a
`Write-Progress` bar.

**Comparing snapshots:** offer a second script that loads two export folders and
reports added, removed, and changed objects per area by ID, with changed fields.
Run it locally; Claude can also read two exports in the shared folder directly to
summarize differences, since they are files, not live calls.

**Who changed what:** `Get-Five9CloudConfigEvents -StartDate -EndDate
-TimeZoneOffset` reads the domain's configuration audit log (defaults: last 24
hours, offset `-04:00`). Ask the user's timezone offset rather than assuming.
This is also the best place to look when a write "failed" without detail.

The export is a reference, not a restorable backup: the module has no import or
restore, and some objects may be only partly covered by their `Get-` function
(check the JSON before relying on it).

## Part B: Change domain settings

| Goal | Use | Notes |
|---|---|---|
| Tags | `Get-Five9CloudDomainTags`, `Add-Five9CloudTagScope -Scope user\|campaign\|skill\|data-table\|agent-group\|speed-dial\|phone-number\|permission -TagName/-TagId` plus the scope's own name/ID parameter | Scope-specific parameters appear only after `-Scope` is set (dynamic parameters). |
| Remove tags | `Remove-Five9CloudUserTag`, `Remove-Five9CloudCampaignTag`, `Remove-Five9CloudCampaignProfileTag` | |
| Schedules | `Get-Five9CloudSchedules`, `New-`/`Set-`/`Remove-Five9CloudSchedule` | Actions route to an IVR script (`-ActionScriptId`, `-ScriptParameterNames/Values`), a destination, or reject. Wrong schedules misroute live calls; trial with a test campaign. |
| Email configurations | `Get-Five9CloudEmailConfigurations`, `Set-Five9CloudEmailConfiguration` | Server host, port, protocol, service account, auto-pushback. Never put mailbox passwords in scripts. |
| Notification emails | `Set-Five9CloudEmailNotificationSettings` (`-LineUtilizationNotificationEmails`, `-MaintenanceNotificationEmails`, `-PstnLoginNotificationEmails`) | |
| Internal calls | `Set-Five9CloudInternalCallsSettings -InternalCallTimeout -TransferTimedOutInternalCalls` | |
| Digital assistance | `Get-`/`Add-`/`Set-`/`Remove-Five9CloudDigitalAssistance` | |
| Campaign prioritization (domain-wide) | `Set-Five9CloudCampaignPrioritization -EnablePriority -EnableDialingRatio` | Both mandatory `[bool]`s; read current values first so the one not being changed is preserved. |

Full parameter list: `references/functions.md`.

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

### Domain-specific cautions
- Domain-level settings affect every campaign and agent at once. The plan shows
  current and new values side by side, and the user confirms the domain is the
  intended one before any live run.
- Before changing a setting, save its current `Get-` output to `backups/` so it
  can be re-entered by hand if needed.
- Deleting a schedule or digital assistance entry follows `OBJECT_DEPENDENCIES.md`.

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

## Style

Short, concrete replies. For documentation requests, get the export running
first, then offer analysis of the files. Show commands in code blocks.
