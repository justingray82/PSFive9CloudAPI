---
name: five9-cloud-numbers
description: For Cowork users. Manage Five9 phone numbers with the PSFive9CloudAPI PowerShell module through the Five9 Cloud REST API - check number credits and area-code inventory, claim DIDs or toll-free numbers, open number orders, release numbers, assign numbers to campaigns (DNIS) and users (DIDs), manage ANI groups and their numbers, and set ANI group, default ANI, and caller-ID rules on campaign profiles. Always writes a paste-ready script with a dry run and confirmation, with separate confirmation for anything that consumes credits or releases numbers. Use this skill whenever the user mentions Five9 phone numbers, DIDs, toll-free numbers, DNIS, ANI or caller ID, ANI groups, local presence, number credits, number orders, or releasing numbers, even if they never name the module.
---

# Five9 phone numbers and ANI groups with PSFive9CloudAPI

Helps a Five9 admin manage numbers and caller ID safely. Claude writes a
paste-ready PowerShell script; the user runs it locally. Number changes can cost
money (credits) or be irreversible (releases), so this skill is deliberately
cautious.

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
| Numbers on the domain | `Get-Five9CloudDomainNumbers` | Read-only. |
| Credits left | `Get-Five9CloudNumberCredits` | Claims decrement `<TYPE>_AVAILABLE` (for example `DID_AVAILABLE`). |
| Availability by area code | `Get-Five9CloudNumberInventory -AreaCode -NumberType DID\|TFN -Country` | Read-only. |
| Claim numbers now | `Add-Five9CloudPhoneNumber -AreaCode 216,330 -Quantity 2` or `-Random` | **Consumes credits.** Pre-checks inventory and credits, submits a bulk claim, polls up to `-TimeoutSeconds`; `-NoWait` returns the claim ID. Quantity is **per area code**. |
| Area code has no inventory | `New-Five9CloudNumberOrder -AreaCode -Quantity` | **Opens an order Five9 fulfils later**; returns an order ID; does not claim immediately. |
| Release numbers | `Remove-Five9CloudPhoneNumbers -PhoneNumbers` or `-CsvPath -ColumnName` | **Irreversible in practice.** Released numbers return to the carrier pool. |
| Campaign DNIS | `Add-`/`Remove-Five9CloudCampaignNumber`, `Get-Five9CloudCampaignNumbers` | |
| User DID | `Set-Five9CloudUserDID` | |
| ANI groups | `Get-Five9CloudAniGroups`, `Get-Five9CloudAniGroupNumbers`, `Add-`/`Remove-Five9CloudAniGroupNumber` (`-Ani`, `-AreaCode`, `-NoNormalize`) | |
| Caller ID on a campaign profile | `Set-Five9CloudCampaignProfileAniGroup` | ANI group, contact-field-to-ANI mapping, default ANI, transfer and conference ANIs, queue-callback ANI selection, manual-call behaviour. GET-then-PUT. |
| Tag a number | `Add-Five9CloudTagScope -Scope phone-number` | See `five9-cloud-domain`. |

Full parameter list: `references/functions.md`.

## Number formatting

Module functions normalize numbers by stripping everything but digits, adding a
leading `1`, collapsing repeated leading `1`s, and prefixing `+`. So
`(330) 555-0100`, `3305550100`, and `+1 330 555 0100` all become `+13305550100`.

**This assumes North American (+1) numbers.** A UK number such as
`+44 20 7946 0000` would be turned into `+144...`. For non-+1 numbers:
`Add-`/`Remove-Five9CloudAniGroupNumber` accept `-NoNormalize` (pass E.164 as-is);
the other number functions always add `1`, so do not use them for non-+1 numbers,
and say so plainly. In the dry run, show each input number next to its
normalized form so the user can catch surprises.

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

### Number-specific cautions
- **Claims and orders cost credits.** The plan shows: credits available, numbers
  requested (quantity × area codes), inventory per area code, and what is left
  afterwards. Confirm separately with the total stated, for example "Claim 6 DIDs
  (2 each in 216, 330, 440), leaving 14 DID credits. Yes?"
- **Releases need a dependency report** (see `OBJECT_DEPENDENCIES.md`). For every
  number, the dry run checks campaign DNIS assignments
  (`Get-Five9CloudCampaignNumbers` per campaign), ANI group membership
  (`Get-Five9CloudAniGroupNumbers` per group), and user DIDs where the user
  record exposes them (read `Get-Five9CloudUserDetails` output to confirm; if it
  does not, list user DIDs as a manual check), and saves the
  findings to `backups/`. It lists what the module cannot check: IVR scripts that
  dial the number, and porting plans. Detach first, then release. Ask for a
  separate confirmation that lists every number being released.
- **Removing a number from an ANI group or campaign profile** changes the caller
  ID that customers see on outbound calls. Name the affected profiles.
- **Do not loop claims.** One `Add-Five9CloudPhoneNumber` call with several area
  codes is one bulk claim; repeating it in a loop multiplies the spend.

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

- **"Get us 10 local numbers in 330"** — inventory and credit check (read-only),
  plan, separate spend confirmation, `Add-Five9CloudPhoneNumber`, verify with
  `Get-Five9CloudDomainNumbers`. If inventory is short, offer
  `New-Five9CloudNumberOrder` and explain it is fulfilled later.
- **"Build a local-presence ANI group from this CSV"** — validate and normalize;
  plan shows numbers already in the group as Skip; add with
  `Add-Five9CloudAniGroupNumber` (`-AreaCode` per row when the user maps numbers
  to area codes); verify with `Get-Five9CloudAniGroupNumbers`; then optionally
  attach the group to campaign profiles with
  `Set-Five9CloudCampaignProfileAniGroup`.
- **"Release these unused numbers"** — dependency report first; never in the same
  run as other changes.

## Style

Short, concrete replies. State costs and irreversibility plainly, once. Show
commands in code blocks.
