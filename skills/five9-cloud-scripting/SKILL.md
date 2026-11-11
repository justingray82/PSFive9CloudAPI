---
name: five9-cloud-scripting
description: Help end users write, fix, and understand their own PowerShell scripts that use the PSFive9CloudAPI module (Five9DeveloperProgram/PSFive9CloudAPI) to work with the Five9 Cloud REST API. Knows every built-in function, its parameters, what it returns, and its quirks, so Claude can pick the right functions, chain them correctly (names vs IDs, paged results, success checks, filters), and debug scripts that fail. Use this skill whenever the user is writing or editing a script that calls Five9Cloud functions such as Connect-Five9Cloud, Get-Five9CloudUserDetails, Copy-Five9CloudUser, Set-Five9CloudCampaignDialingSettings, or Add-Five9CloudAniGroupNumber; asks which Five9Cloud function does something; pastes a PowerShell error from one; or wants to automate a Five9 admin task in PowerShell, even if they never name the module.
---

# Scripting with PSFive9CloudAPI

The user is writing their own PowerShell scripts with the functions already in
the module. Claude's job is to help them use those functions correctly: pick the
right ones, call them with the right parameters, handle what they return, and
keep the script safe to run against a live contact center. Many users are Five9
admins rather than developers, so explain briefly in plain language as you go.

The module is sample code, unsupported by Five9. Mention that once if the user
seems to be building something for production, and suggest Five9 Professional
Services or their TAM for that.

## Ground rules

1. **Use only functions that exist.** Look them up in `references/functions.md`
   (162 public functions, grouped by area). If the repo or module source is in a
   shared folder, read the function's `.ps1` before relying on details. Never
   invent a function or parameter. If nothing does what the user needs, say so
   plainly and offer the closest built-in route.
2. **Work with the user's script, not around it.** If they have a script, edit it
   in their style. Offer `assets/script-template.ps1` only for new scripts or when
   they want structure.
3. **Claude does not run Five9 calls.** Claude writes and reviews; the user runs
   the script on their own machine, where the module and their login live.
   Ask for the output, with tokens and customer data removed.
4. **Never handle secrets.** No passwords or client secrets in scripts or chat.
   Never print `$global:Five9` (its `AuthParams` holds the password in plain text),
   the access token, or `Get-Five9CloudAuthHeader`.
5. **Target Windows PowerShell 5.1.** No `??`, `?.`, ternaries, or
   `ForEach-Object -Parallel`. Use `return`, not `exit`, in scripts run from ISE.

## How the functions behave (read before writing any call)

**Connecting.** Call `Connect-Five9Cloud` once per session with
`-Region us|uk|eu|ca`. Prompt with `Get-Credential` and pass
`-Username $cred.UserName -Password $cred.GetNetworkCredential().Password`. Leaving
out `-Password` falls back to a prompt that shows the password on screen. After
connecting, `$global:Five9.DomainId` is the domain; tokens refresh automatically,
so long scripts need no reconnect logic. Add `-SkipUpdateCheck` in scripts so
the module does not update itself mid-project. On failure `$global:Five9` is
empty, so check `$global:Five9.AccessToken` before continuing.

**Name or ID.** Most functions accept either a friendly name or an ID for their
target (`-CampaignName` or `-CampaignId`, `-Username` or `-UserUID`). Pass one.
With a name, the function looks up the ID first, which is one extra API call. In
loops over many objects, look IDs up once (with a `Resolve-` function or from a
list) and pass `-...Id` to save time. A name that matches nothing prints
"not found" and the function returns without doing anything.

**What comes back.** This is the most common source of script bugs. The
reference's Output column says what each function returns:
- **Page envelopes** (most list functions, for example `Get-Five9CloudUserDetails`,
  `Get-Five9CloudCampaignList`): the records are in `.items`. Write
  `$users = (Get-Five9CloudUserDetails).items`, not `$users = Get-Five9CloudUserDetails`.
  All pages are already fetched.
- **List of items**: use the result directly.
- **`Resolve-` functions**: an ID string, or `$null`.
- **Writes**: many return **nothing** on success and `$false` on failure; a few
  return nothing either way (`New-Five9CloudUser`, `Set-Five9CloudUserStatus`).
  They also print a success or failure line with `Write-Host`.

**Checking success.** Because writes often return nothing, do not test success
with `if ($result)`. Use `if ($result -ne $false)` to catch outright failures, and
when it matters, **re-read** the object with a `Get-` function to confirm the
change landed. That is the only reliable check for the functions that return
nothing either way.

**Errors.** The module does not throw on API errors. A failed call prints
`API call failed [METHOD URI]` and returns `$false`, without the API's reason.
`try/catch` will not catch these. For the reason, check the Admin Console or
`Get-Five9CloudConfigEvents` (the domain's change log).

**Filters and fields.** List functions take `-Filter` and `-Fields`. Filters
use the syntax the module itself uses: `name=='Sales'`,
`username=='jdoe@acme.com'`, nested fields such as
`campaignProfile.campaignProfileId=='123'`, lists with `tagId=in=(1,2,3)`, and
`;` for AND (`timestamp>=...;timestamp<=...`). `-Fields 'useruid,name'` trims
the response. Filtering on the server is much faster than pulling everything and
using `Where-Object`.

**Updates only change what you pass.** Most `Set-` functions read the current
object, change only the parameters you supplied, and write it back. A few send
only the fields you pass (for example `Set-Five9CloudCampaignProfile`); if a
field matters, check the function source or re-read afterwards. Leave out anything
you don't want changed. To clear a value, pass an empty string or `$false`
explicitly (`[bool]` parameters accept `$false`).

**Pacing.** Every call waits about 250 ms, which keeps bulk scripts within Five9
rate limits. A loop over 1,000 users takes several minutes; that is expected.
Do not speed it up with jobs, runspaces, or direct `Invoke-RestMethod`.

**Phone numbers** are normalized to `+1XXXXXXXXXX`: any format works for
North American numbers. Non-+1 numbers get mangled except in the ANI group
functions with `-NoNormalize`.

More detail and copy-ready snippets for each of these: `references/patterns.md`.

## Keeping scripts safe

Scripts that only read are low risk. For scripts that change the domain:

- **Show the target.** Print `$global:Five9.DomainId` right after connecting, and
  for bulk changes compare it with an expected ID before writing. Ask the user to
  confirm it is the domain they intend and whether it is production.
- **Add a dry-run switch.** No function supports `-WhatIf`, so put
  `$DryRun = $true` in the script's config and print what would change instead of
  changing it. The user flips it after reviewing the output.
- **Try one first.** For bulk changes, suggest running against one object, then
  checking it in the Admin Console, before the full list.
- **Log results.** Record each item's outcome to a CSV with `Export-Csv`.
- **Flag the risky functions** (marked in the reference's Effect column) and ask
  for explicit confirmation before the user runs them:
  - `Add-Five9CloudPhoneNumber`, `New-Five9CloudNumberOrder` use number credits.
  - `Remove-Five9CloudPhoneNumbers` releases numbers; they may not be recoverable.
  - `Start-`, `Stop-`, and `Reset-Five9CloudCampaign*` act on live calls immediately.
  - `Set-Five9CloudUserStatus -Action Deactivate` removes agents' access at once.
  - Any `Remove-` function: first check what still uses the object (see
    `OBJECT_DEPENDENCIES.md` in the repo) and save the current definition with
    `ConvertTo-Json -Depth 20`.
- End scripts with `Remove-Variable Five9 -Scope Global` so the stored login
  does not stay in the session.

## Debugging a user's script

| Symptom | Usual cause |
|---|---|
| A variable holds one object with `items` and `paging`, or `.name` is empty | Forgot `.items` on a list function |
| `Not connected. Run Connect-Five9Cloud first.` | Login failed earlier, or the script runs in a new session |
| `Authentication failed` | Wrong `-Region` first; then credentials, locked account, or no Admin Console access |
| `API call failed [PUT ...]` | API refused the change: permissions, invalid value, or an object in use. Check `Get-Five9CloudConfigEvents` |
| `... not found` in red | Name doesn't match exactly, or wrong domain |
| `Parameter set cannot be resolved` | Mixed parameters from different modes (for example two dialing modes, or `-AreaCode` with `-Random`) |
| `$false` passed as a switch is ignored | The parameter is `[switch]`; use `-Name:$false` |
| Script "succeeded" but nothing changed | Tested `if ($result)` on a function that returns nothing; re-read to check |
| `The term '...' is not recognized` | Typo or a function that doesn't exist; check the reference (names come from the source, for example `Get-Five9CloudServiceAccounts` is plural) |
| Garbled `$.` or `$(.` in a pasted script | Underscores in `$_` were eaten when copied through a chat or email; retype them |

## Style

Answer the question asked; don't rebuild a user's script unless they want that.
Show code in PowerShell code blocks, explain each new function briefly the first
time it appears, and point out the risky calls before the user runs them.
