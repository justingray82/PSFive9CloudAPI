# PSFive9CloudAPI — AI Agent Guide

> **Canonical guidance doc.** This is the tool- and model-agnostic source of truth
> for AI assistants working in this repo. `CLAUDE.md` imports it for Claude Code;
> `.github/copilot-instructions.md` points to it for Copilot; the Cowork skills in
> `skills/` defer to it for policy. Keep shared rules here and tool-specific
> instructions in their respective entry points.

## Who this is for

This repo is used by **Five9 Developer Program members**, Five9 customers, and
Five9 Technical Account Managers. Many users are contact-center administrators,
not professional developers. They can paste and run a PowerShell script but may
not know what a module, a hashtable, or an access token is.

When assisting in this repo, an AI agent should:
- Prefer clear, step-by-step explanations over terse engineering jargon.
- Briefly explain unfamiliar concepts when they come up. For example: the Five9
  Cloud API is a REST API, meaning each action is a web request (GET to read,
  POST to create, PUT to update, DELETE to remove) that sends and receives JSON.
  This module wraps those requests in PowerShell functions so most users never
  build a request by hand.
- Favor paste-ready scripts that call existing module functions over writing raw
  `Invoke-RestMethod` calls or new abstractions.
- Assume the user may be unfamiliar with git, execution policy, or modules, and
  explain the "why" briefly when asking them to run a command.

## Project overview

PSFive9CloudAPI is a PowerShell module wrapping the Five9 Cloud REST API
(`https://api.<environment>.<region>.five9.net`) for administration of Five9
domains: users, permissions, campaigns, campaign profiles, phone numbers, ANI
groups, tags, schedules, digital assistance, email configuration, Verint/WFO
settings, and domain settings.

**Disclaimer:** This is sample code, **not officially supported by Five9**. For
production deployments, direct users to Five9 Professional Services or their
Technical Account Manager (TAM). See "Safety guardrails" below.

## Architecture

### Layout
- **One public function per `.ps1` file**, named after the function.
- Module manifest `PSFive9CloudAPI.psd1` and installer `Install-PSFive9CloudAPI.ps1`.
- `skills/` holds Claude Cowork skills (see `skills/README.md`).

### Naming
- Public verbs: `Get-`, `Set-`, `Add-`, `Remove-`, `New-`, `Copy-`, `Reset-`,
  `Start-`, `Stop-`. All nouns start with `Five9Cloud`.
- `Resolve-*` helpers turn a friendly name (or a raw ID, passed through
  unchanged) into the internal ID an endpoint needs.
- `Invoke-*` and `Set-Five9CloudToken`, `Get-Five9CloudAuthHeader`,
  `Set-Five9CloudQueryUri` are internal plumbing.

### Shared infrastructure
- **`Connect-Five9Cloud`** — authenticates and initialises `$global:Five9`.
  - `-Region us|uk|eu|ca` (default `us`), `-Environment prod|alpha` (default `prod`).
  - Admin login: `-Username` / `-Password` (prompts with `Read-Host` if omitted).
  - Service account: `-ClientId` / `-ClientSecret` (OAuth client credentials).
  - Checks GitHub for a newer module version on every connect and overwrites the
    installed files if one exists; `-SkipUpdateCheck` disables this.
- **`$global:Five9`** — connection state: `AccessToken`, `ExpiresAt`, `DomainId`,
  `ApiBaseUrl`, `AuthType`, `AuthParams`. **`AuthParams` holds the plaintext
  password or client secret** so the module can reconnect automatically.
- **`Invoke-Five9CloudApi`** — every request goes through here. Checks the token
  (auto-reconnects when expired), sends JSON, prints `API call failed [...]` and
  returns `$false` on error, and sleeps 250 ms after each successful call.
- **`Invoke-Five9CloudPagedApi`** — follows `paging.next` cursors and returns
  every page's response envelope; callers read `.items`.
- **`Test-Five9CloudConnection`** — returns `$true`/`$false`; `-AutoReconnect`.

## Code conventions

- **PowerShell 5.1 compatibility** is the target. No `??`, `?.`, ternary, or other
  PS 7-only syntax.
- **GET-then-PUT** for updates: Five9 PUT endpoints require the full object. GET →
  convert to a hashtable via `.PSObject.Properties` → apply only parameters the
  caller passed (`$PSBoundParameters.ContainsKey()`) → strip read-only fields →
  PUT.
- **Resolvers** accept a name or an ID; when an ID is supplied, skip the lookup.
- **Errors**: `Write-Error; return` (not `throw`). Check API results with
  `$result -ne $false`.
- **Status messages**: `Write-Host` for user-visible success/failure; `-Quiet`
  where a function is called internally.
- **Booleans**: use `[bool]` (not `[switch]`) when callers must be able to pass
  `$false` explicitly.
- **Value-dependent parameters**: use `DynamicParam` (see `Add-Five9CloudTagScope`).
- **Phone numbers**: strip non-digits → prepend `1` → collapse `^1{2,}` → prefix `+`.
- **Customer-facing scripts** are self-contained and paste-ready: a plain
  `CONFIG` block at the top instead of `param()`, runnable with F5 in ISE, and
  `return` instead of `exit` (which closes the ISE session).

## Known behaviours to design around

1. **No `-WhatIf`.** No function implements `SupportsShouldProcess`. Dry runs
   must be built in the calling script by reading current state with `Get-` /
   `Resolve-` functions and printing the plan.
2. **Many writes return nothing on success.** Functions like
   `New-Five9CloudUser` only `Write-Host` the outcome. Verify writes by re-reading
   with a `Get-`/`Resolve-` call instead of trusting the return value.
3. **Error detail is swallowed.** `Invoke-Five9CloudApi` prints the method and
   URI but not the response body. For diagnosis, check `Get-Five9CloudConfigEvents`
   (the domain's config audit log) or the Admin Console.
4. **`-Suppress` failures return `$null`, not `$false`**, so they pass the
   `-ne $false` check. Do not rely on `-Suppress` results to detect failure.
5. **Resolvers print "not found" in red** for missing objects. In dry runs that
   check existence, query `Get-` functions directly to avoid alarming output.
6. **Auto-update overwrites module files** on connect. Pass `-SkipUpdateCheck`
   when the user wants a run to use exactly the version they reviewed, and on
   macOS/Linux, where the update block uses Windows-style temp paths.
7. **Paged results** are usually lists of page envelopes: use `.items` (member
   enumeration flattens across pages). Functions that pass `-ResultProperty` to
   `Invoke-Five9CloudPagedApi` already return the items. Read the function to
   know which shape you get.

## Authentication & credentials

- Never hardcode credentials in scripts or commit them.
- In generated scripts, prompt with `Get-Credential` (masked input) and pass
  `$cred.UserName` / `$cred.GetNetworkCredential().Password` to
  `Connect-Five9Cloud`. Do not call `Connect-Five9Cloud` without `-Password`
  in examples you give users: its fallback `Read-Host` shows the password on screen.
- For service accounts, use `Get-Credential` with the client ID as the user name
  and the secret as the password, then pass them to `-ClientId` / `-ClientSecret`.
- Never print, log, or transcript `$global:Five9`, `$global:Five9.AuthParams`,
  `$global:Five9.AccessToken`, or `Get-Five9CloudAuthHeader` output.
- Start any `Start-Transcript` **after** connecting, and end scripts with
  `Remove-Variable Five9 -Scope Global -ErrorAction SilentlyContinue` so the
  password does not linger in the session.

### Regions
| `-Region` | Base URL (prod) |
|---|---|
| `us` (default) | `https://api.prod.us.five9.net` |
| `uk` | `https://api.prod.uk.five9.net` |
| `eu` | `https://api.prod.eu.five9.net` |
| `ca` | `https://api.prod.ca.five9.net` |

A login failure on a domain the user says is valid is most often the wrong region.

## Development workflow (contributors)

- **HAR-driven development.** New endpoints come from Chrome DevTools HAR exports
  of the Admin Console. Treat the HAR as ground truth for method, URL, request
  body, response shape, and field names. Postman collections are an alternative.
- Read two or three existing functions that hit the same service before writing a
  new one, and match their structure.
- Keep each function in its own file and add it to the manifest's
  `FunctionsToExport` if the manifest lists functions explicitly.
- Never commit HAR files: they contain bearer tokens, cookies, and customer data.
  Redact before sharing.

## Safety guardrails for AI agents

These rules apply regardless of AI tool. This module talks to **real Five9
contact-center domains**; mistakes can affect live agents, callers, campaigns,
phone numbers, and billing.

1. **Never handle secrets in chat or tracked files.**
   - Never ask users to paste passwords, client secrets, access tokens, HAR files
     with auth headers, or `$global:Five9` contents into chat.
   - Generated scripts prompt locally with `Get-Credential`.
   - Before sharing output, redact tokens, authorization headers, and customer
     data (names, phone numbers, emails) unless the user needs them discussed.

2. **Treat every domain as potentially production.**
   - There is no reliable way to tell sandbox from production through the API.
   - Before an agent runs, or asks the user to run, anything against a live
     domain, confirm which domain (show `$global:Five9.DomainId`) and whether it is
     production.
   - Before anything that writes, modifies, or deletes (`New-`, `Set-`, `Add-`,
     `Copy-`, `Remove-`, `Reset-`, `Start-`, `Stop-`), get explicit confirmation
     after a dry run. A vague reply is not confirmation.
   - Extra care, each with its own confirmation:
     - `Add-Five9CloudPhoneNumber` and `New-Five9CloudNumberOrder` consume number
       credits.
     - `Remove-Five9CloudPhoneNumbers` releases numbers back to the carrier; they
       may not be recoverable.
     - `Start-`/`Stop-`/`Reset-Five9CloudCampaign*` affect live traffic and dialing
       lists immediately.
     - `Set-Five9CloudUserStatus -Action Deactivate` logs agents out of work.
   - Before any deletion, follow `OBJECT_DEPENDENCIES.md`.
   - Recommend a non-production domain whenever one is available.

3. **Respect pacing.** Route calls through module functions so the built-in
   250 ms pause applies. Do not bypass `Invoke-Five9CloudApi` with direct
   `Invoke-RestMethod` loops or parallel jobs to go faster.

4. **Escalate production deployment requests.** If a request implies running this
   sample code as part of a production integration, say it is unsupported sample
   code and recommend Five9 Professional Services or the TAM team.

5. **When in doubt, ask before acting.**

## Checking for module updates

`Connect-Five9Cloud` updates itself unless `-SkipUpdateCheck` is passed. When a
user works from a git clone, never run `git pull` or change their checkout
without approval; check for local modifications first, and use
`git pull --ff-only` on a verified tracking branch.

## Contact & support
- Disclaimer: sample code, NOT officially supported by Five9.
- Production use: Five9 Professional Services or the TAM team.
- Issues/PRs welcome.
- Author: Justin Gray (justingray82).
