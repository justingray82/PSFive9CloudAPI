---
name: five9-cloud-setup
description: For Cowork users. Set up the PSFive9CloudAPI PowerShell module (Five9DeveloperProgram/PSFive9CloudAPI) and make a first safe connection to a Five9 domain through the Five9 Cloud REST API. Walks the user through sharing a working folder, checking their PowerShell version, installing or updating the module, handling execution policy, choosing the right region, and running a read-only smoke test with masked credentials. Use this skill whenever the user wants to install, update, or troubleshoot PSFive9CloudAPI, mentions Connect-Five9Cloud, login or region errors, the Five9 Cloud API from PowerShell, or is starting any Five9 admin automation and has not connected before, even if they never name the module.
---

# PSFive9CloudAPI setup

This skill gets a user from a bare Windows machine (or a Mac with PowerShell 7)
to a verified, read-only connection to their Five9 domain using the
PSFive9CloudAPI module. Many users are contact-center admins, not developers, so
explain each step in plain language and confirm each step worked before moving on.

The module is sample code, unsupported by Five9, provided as-is under the
repository's license. Say so once, briefly, during setup, and recommend a
non-production domain when one is available.

Repo: https://github.com/Five9DeveloperProgram/PSFive9CloudAPI

## Where things run (Cowork)

- **Claude's shell is a sandbox, not the user's computer.** It cannot reach the
  user's PowerShell session, installed module, or Five9 login, and may not be able
  to reach Five9 at all. Never run Five9 calls from the sandbox.
- **Claude can only see folders the user shares.**

So the working model is: Claude guides and writes, the user runs locally. Claude
writes scripts into the shared folder; the user runs them in their own PowerShell,
where the module and credentials live, and pastes back output with secrets
removed. Credentials never leave the user's machine.

### Step 0: Get a folder into the chat

Before anything else, if no folder is connected, request one with the folder
access tool (`mcp__cowork__request_cowork_directory`, load via ToolSearch if
needed). Suggest a folder such as `Five9-Admin` in Documents with this layout:

```
Five9-Admin/
  scripts/   generated scripts
  input/     CSV files the user prepares
  logs/      results written by scripts
  backups/   JSON snapshots taken before risky changes
```

Then offer, once, a project that points at this folder so future chats start
with it attached:

1. In the navigation panel, click "+" next to Projects.
2. Name it "Five9 Cloud API (PowerShell)".
3. Click "Use a folder" and choose `Five9-Admin` (or the folder holding a clone
   of the repo).
4. Leave "What are you trying to achieve?" blank.
5. Leave Visibility on "Private".
6. Click "Create project" and start new chats from inside it.

If the user clones the repo into this folder (optional; contributors and
curious users), Claude can read `AGENTS.md` and every function's source directly.
On conflicts, `AGENTS.md` wins for policy and the current `.ps1` files win for
parameter names and behaviour.

## Part 1: PowerShell

Every command below is for the user to run in their own terminal, one at a time.
Ask them to paste the result before continuing.

1. **Check the version and host.**
   ```powershell
   $PSVersionTable.PSVersion
   $Host.Name
   ```
   - Windows PowerShell **5.1** is the module's compatibility target. Its console
     and **PowerShell ISE both work**; generated scripts are paste-ready for ISE
     (F5 to run).
   - PowerShell **7** also works on Windows.
   - **macOS/Linux** need PowerShell 7 (`pwsh`). Always pass `-SkipUpdateCheck`
     to `Connect-Five9Cloud` there: its self-update step uses Windows temp paths.
2. **Execution policy.** If later steps say "running scripts is disabled", run
   `Get-ExecutionPolicy -List` and explain what the policy does (it controls
   whether downloaded scripts may run). Suggest
   `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` only if their
   organization allows it; otherwise send them to IT. Never suggest `Bypass` at
   machine scope.

## Part 2: Install or update the module

1. **Check whether it is already installed.**
   ```powershell
   Get-Module PSFive9CloudAPI -ListAvailable | Select-Object Name, Version, ModuleBase
   ```
2. **Install** (if missing) with the installer from the repository:
   ```powershell
   irm 'https://raw.githubusercontent.com/Five9DeveloperProgram/PSFive9CloudAPI/main/Install-PSFive9CloudAPI.ps1' | iex
   ```
   Explain briefly: this downloads the installer script and runs it. If they
   prefer to read it first, have them open the URL in a browser. If the repo is
   cloned, read `README.md` for the current install steps instead; it wins over
   this skill if they differ.
3. **Import and confirm.**
   ```powershell
   Import-Module PSFive9CloudAPI -Force
   (Get-Command -Module PSFive9CloudAPI).Count
   ```
   A count well above 100 means the functions loaded.
4. **Updates.** `Connect-Five9Cloud` checks GitHub and updates the module
   automatically each time it connects, unless `-SkipUpdateCheck` is passed.
   Generated scripts pass `-SkipUpdateCheck` so a live run uses the same code as
   its dry run; tell users to connect once interactively (without the switch)
   when they want to pick up updates.

## Part 3: Region and login account

Ask once: "Is your Five9 domain in the US, UK, EU, or Canada?" Skip if already
known. Map to `-Region us|uk|eu|ca`. `-Environment alpha` is only for Five9
internal test environments; default is `prod`.

The login must be a user **in the target domain** with access to the Admin
Console application. The username they type decides which domain they reach;
never assume it is a sandbox.

For unattended automation, a service account uses `-ClientId`/`-ClientSecret`
instead of a username. Store neither in a script.

## Part 4: Smoke test (read-only)

Give the user this block. The password is typed into a masked dialog, not shown
on screen. Do not suggest `Connect-Five9Cloud` without `-Password`: its fallback
prompt displays the password as it is typed.

```powershell
Import-Module PSFive9CloudAPI
$cred = Get-Credential -Message 'Five9 admin login'
Connect-Five9Cloud -Region us -Username $cred.UserName -Password $cred.GetNetworkCredential().Password
$cred = $null
Test-Five9CloudConnection
"Domain ID: $($global:Five9.DomainId)"
"API base:  $($global:Five9.ApiBaseUrl)"
(Get-Five9CloudCampaignList).items.Count
```

Replace `us` with their region. Ask them to paste the output. `True`, a domain
ID, and a campaign count mean it works. Ask the user to confirm the domain ID is
the domain they intend (they can match it to the domain shown in the Admin
Console) and whether it is production. Remember the answer for this chat.

**Never** ask for, or accept, output of `$global:Five9`, `$global:Five9.AuthParams`
(it holds their password in plain text), `$global:Five9.AccessToken`, or
`Get-Five9CloudAuthHeader`. If the user pastes any of these, tell them to treat
the password or token as exposed and change or revoke it.

When finished, they can clear the stored login from the session:
```powershell
Remove-Variable Five9 -Scope Global
```

## Troubleshooting

| Symptom | Likely cause and fix |
|---|---|
| `Authentication failed` with a checklist | Wrong region first, then wrong password, locked account, or no Admin Console access. |
| `The term 'Connect-Five9Cloud' is not recognized` | Module not imported: `Import-Module PSFive9CloudAPI`. If not found, reinstall. |
| `running scripts is disabled` | Execution policy; see Part 1. |
| `Not connected. Run Connect-Five9Cloud first.` | Login failed earlier or the session was closed; reconnect. |
| `API call failed [GET ...]` | The call reached Five9 but was refused: missing permission, wrong ID, or wrong region. The module does not show the response body; check the Admin Console or `Get-Five9CloudConfigEvents`. |
| Odd file errors on macOS during connect | Self-update path issue; add `-SkipUpdateCheck`. |

## Next steps

Once connected, hand off to the task skills:
- `five9-cloud-users` — create, copy, update, deactivate users; permissions, roles, reason codes, Verint.
- `five9-cloud-campaigns` — campaigns, profiles, dialing settings, skills, scripts.
- `five9-cloud-numbers` — phone number inventory, claims, releases, ANI groups, DIDs.
- `five9-cloud-domain` — domain settings, tags, schedules, email, digital assistance, and read-only domain documentation exports.
- `five9-cloud-module-dev` — contributing new functions to the module.

## Style

Short, concrete replies. One step at a time during setup; wait for the result.
Exact commands in code blocks for the user's OS.
