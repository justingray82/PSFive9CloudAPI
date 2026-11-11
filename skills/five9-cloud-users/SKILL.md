---
name: five9-cloud-users
description: For Cowork users. Manage Five9 users with the PSFive9CloudAPI PowerShell module through the Five9 Cloud REST API - create users, copy a template user (roles, skills, permissions, agent groups, circles, reason codes), bulk onboard from a CSV, update profile fields, activate or deactivate, assign applications, permission sets, canned reports, circles, user profiles, MFA and IdP/SSO policies, DIDs, voicemail email, and Verint/WFO settings. Always writes a paste-ready script with a dry run and confirmation before any change. Use this skill whenever the user mentions Five9 users or agents, onboarding or offboarding, bulk user creation, copying a user, permissions, SSO/IdP migration, MFA, Verint, or agent access in a Five9 domain, even if they never name the module.
---

# Five9 users with PSFive9CloudAPI

Helps a Five9 admin manage users safely. Claude writes a paste-ready PowerShell
script; the user runs it locally. Explain in plain language; many users are
admins, not developers.

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
| New user with the same access as an existing one | `Copy-Five9CloudUser` | **Preferred for onboarding.** Copies applications, permissions, roles, agent groups, media types, skills, circles, reason codes; `-Skip*` switches opt out of each. Ask which existing user to use as the template. |
| Bare user, access assigned separately | `New-Five9CloudUser` | `-FederationID` with `-IdPPolicy`/`-IdpPolicyId` creates an SSO user (auto-migration); otherwise a password user. |
| Change name, email, phone, timezone, locale, status, MFA, federation ID | `Set-Five9CloudUserDetails` | GET-then-PUT: only parameters you pass change. `-Mfa on/off` applies to migrated users only. |
| Activate / deactivate | `Set-Five9CloudUserStatus -Action Activate\|Deactivate` | Accepts arrays of usernames. Deactivation removes access immediately: treat as disruptive. |
| SSO / IdP policy | `Set-Five9CloudUserSecurity`, `Get-Five9CloudIdpPolicyDetails`, `Get-Five9CloudUserMigrationDetails` | `Resolve-Five9CloudIdpPolicyID` takes a policy **name** only. |
| Applications (admin console, agent, supervisor, reporting, etc.) | `Set-Five9CloudUserApplication`, `Remove-Five9CloudUserApplication`, `Get-Five9CloudApplications` | Application names are a fixed list; read the `ValidateSet` in the source. |
| Permissions | `Set-Five9CloudUserPermission` (`-Remove` to revoke), `Add-Five9CloudPermissionSetToUser`, `New-Five9CloudPermissionSet`, `Add-Five9CloudPermissionToSet`, `Get-Five9CloudPermissionList`, `Get-Five9CloudPermissionSetUsers` | |
| Reports, circles, reason codes, user profiles | `Add-Five9CloudCannedReportToUser`, `Add-Five9CloudCircleToUser`, `Add-Five9CloudReasonCodeSetToUser`, `Add-Five9CloudUserProfileToUser` | |
| MFA policy, voicemail email, Verint/WFO | `Set-Five9CloudUserMfaPolicy`, `Set-Five9CloudUserVMEmailSettings`, `Set-Five9CloudUserVerintSettings`, `Remove-Five9CloudUserVerintSettings` | |
| User DID | `Set-Five9CloudUserDID` | Number formatting rules are in the `five9-cloud-numbers` skill. |
| Who has a skill | `Get-Five9CloudSkillUsers` | Read-only. |

**Gap to state honestly:** the module has no function that adds or removes a
single skill on an existing user. Options: copy from a template user that has the
right skills, make the change in the Admin Console, or add a function (see
`five9-cloud-module-dev`). Skills on **campaigns** are in `five9-cloud-campaigns`.

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

### Users-specific cautions
- Usernames must be unique domain-wide; the dry run skips existing ones rather
  than updating them unless the user asks for updates.
- Deactivating or changing applications logs affected agents out of tools they
  are using. Confirm timing (for example, after shift end).
- `Copy-Five9CloudUser` prints a line per copied area. "Failed to copy ..." means
  the user was created but that area was not copied; the verify step reports it.
- For SSO users, confirm the IdP policy name exists with
  `Get-Five9CloudIdpPolicyDetails` during the dry run.

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

## Worked example

`assets/example-bulk-copy-users.ps1` is a complete bulk-onboarding script
(CSV → validate → plan → confirm → copy → verify → log). Use it as the model for
other bulk user tasks: keep its connect block, validation, plan table, domain
guard, and verify-by-re-read pattern, and swap the action. A typical CSV:

```csv
Username,FirstName,LastName,Email,TemplateUsername
jdoe@acme.com,Jane,Doe,jdoe@acme.com,agent.template@acme.com
```

For single-user changes, a short interactive block is fine instead of a full
script: connect (masked credentials), show the current values with
`Get-Five9CloudUserDetails -Filter "username=='<name>'"`, confirm, run the one
`Set-` call, then re-read.

## Style

Short, concrete replies. Ask for what is missing (template user, CSV, target
domain) one question at a time. Show commands in code blocks.
