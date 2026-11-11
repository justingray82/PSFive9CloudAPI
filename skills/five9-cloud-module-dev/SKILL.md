---
name: five9-cloud-module-dev
description: For contributors to PSFive9CloudAPI (Five9DeveloperProgram/PSFive9CloudAPI). Add or fix functions in the Five9 Cloud REST API PowerShell module following its conventions - HAR-driven endpoint discovery from Chrome DevTools captures of the Five9 Admin Console, one function per file, Resolve- helpers that accept a name or an ID, the GET-then-PUT update pattern, Windows PowerShell 5.1 compatibility, and paste-ready customer scripts. Use this skill whenever the user shares a HAR file or Postman collection from Five9, asks to write, debug, refactor, or review a PSFive9CloudAPI function, wants a new Five9 Cloud API endpoint wrapped, hits a PowerShell 5.1 quirk in the module, or is preparing a pull request to the repo, even if they never name the module.
---

# Contributing to PSFive9CloudAPI

Helps a contributor add or fix module functions so they match the rest of the
module. The user may be an experienced PowerShell developer or a TAM learning as
they go; match the explanation to them.

## Where things run (Cowork)

The repo must be cloned into the shared folder so Claude can read existing
functions and write new ones. If it is not, use the folder access tool and ask
the user to clone `https://github.com/Five9DeveloperProgram/PSFive9CloudAPI`
there (see `five9-cloud-setup`). Claude edits files in the clone; the user tests
them in their own PowerShell against a domain they choose. Claude never calls
Five9 from the sandbox.

Read `AGENTS.md` at the start of each chat. It is the canonical source for
conventions and safety rules; this skill adds the working method.

## Workflow

1. **Get ground truth.** Ask for a HAR export of the Admin Console action (Chrome
   DevTools → Network → perform the action → right-click → "Save all as HAR with
   content"), or a Postman request. Before reading it, remind the user once that
   HARs contain bearer tokens, cookies, and customer data: share it only in this
   private folder, never commit it, and delete it when done.
2. **Analyze before coding.** From the HAR, write down for the user: method, URL
   template (which segments are domain ID, object IDs), query parameters, request
   body, response shape (paged envelope with `items`/`paging`, or a flat object),
   and any read/write mismatch (fields the GET returns that the PUT rejects, or
   different names between them). Treat the HAR as ground truth over docs or
   memory. Do not guess fields the capture does not show; mark them as unverified.
3. **Find siblings.** Read two or three existing functions on the same service
   (`users/v1`, `campaigns/v1`, `routes/v1`, `numbers-svc/v1`, `acl/v1`, ...) and
   mirror their shape. `references/functions.md` lists every function with its
   parameters.
4. **Write the function** from `assets/function-templates.ps1`.
5. **Give the user a test plan**: a read-only call first; for writes, a
   non-production domain, one object, then re-read to confirm the change landed
   and nothing else changed (compare the GET before and after).
6. **Update docs**: the manifest's `FunctionsToExport` if functions are listed
   explicitly, the README, and `AGENTS.md` if a new convention or quirk emerged.
   Regenerate the skills' `references/functions.md` (see `skills/README.md`).

## Conventions (summary; `AGENTS.md` is authoritative)

- One function per file, file named after the function; verbs `Get-`, `Set-`,
  `Add-`, `Remove-`, `New-`, `Copy-`, `Reset-`, `Start-`, `Stop-`; private
  lookups `Resolve-`.
- All HTTP through `Invoke-Five9CloudApi` / `Invoke-Five9CloudPagedApi`; URIs via
  `$global:Five9.ApiBaseUrl` and `$global:Five9.DomainId` or
  `Set-Five9CloudQueryUri`.
- Accept both `-<Noun>Name` and `-<Noun>Id`; resolve with
  `if (-not $Id) { $Id = Resolve-... } ; if (-not $Id) { return }`.
- Updates: GET → hashtable via `.PSObject.Properties` → apply only
  `$PSBoundParameters.ContainsKey()` parameters → strip read-only fields → PUT.
- Errors: `Write-Error; return`. API results: `$result -ne $false`. User-visible
  status: `Write-Host`; `-Quiet` when called internally.
- `[bool]` for parameters callers must be able to set to `$false`; `DynamicParam`
  when parameters depend on another parameter's value.
- Phone numbers: digits only → prepend `1` → collapse `^1{2,}` → prefix `+`.

## PowerShell 5.1 gotchas

- No `??`, `?.`, ternary, `ForEach-Object -Parallel`, or `-AsHashtable` on
  `ConvertFrom-Json`.
- Assigning to a null property of a deserialized `PSCustomObject` throws; convert
  to a hashtable first.
- Single-record GETs can still return a paged envelope; drill into `.items[0]`.
- Parameter sets bind on which parameters are present, not their values.
- `Mandatory` silently ignores a default value.
- `$PSBoundParameters` is not inherited by nested functions; check it where the
  parameters are declared.
- `[switch]` parameters swallow a positional `$false`; use `[bool]`.
- Customer scripts use `return`, not `exit` (exit closes ISE).
- Code copied through chat or email can lose `$_` when markdown treats
  underscores as formatting. Prefer named `foreach` loops in code that is likely
  to be pasted, and check pasted code for `$(.` or `$.` fragments.

## Known module behaviours to keep in mind

From `AGENTS.md`: no `-WhatIf`; many writes return nothing on success;
`Invoke-Five9CloudApi` does not surface error bodies; `-Suppress` failures return
`$null`; resolvers print "not found"; `$global:Five9.AuthParams` holds the
plaintext password; `Connect-Five9Cloud` self-updates from GitHub. When a change
touches one of these, raise it with the user rather than silently working around
it, and keep backward compatibility for existing callers (customer scripts depend
on current names and parameters).

## Reviewing a pull request

Check: matches sibling functions; PS 5.1 syntax; name-or-ID parameters; GET-then-
PUT for updates (a partial-body PUT without a GET is a red flag unless the HAR
shows the endpoint accepts partial bodies); no secrets, HARs, or customer data in
the diff; success message and `$false` on failure; test evidence from a
non-production domain.

## Safety

Contributors still follow `AGENTS.md` guardrails: test writes against a
non-production domain, confirm before running anything that writes to a live
domain, and never paste tokens, passwords, or unredacted HARs into chat or
commits.
