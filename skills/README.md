# Claude skills for PSFive9CloudAPI

These skills teach Claude (in Cowork or Claude Code) how to help with the
PSFive9CloudAPI module safely: Claude writes paste-ready PowerShell scripts with a
built-in dry run, and you run them on your own computer, where your Five9 login
stays. Claude never connects to your Five9 domain itself.

| Skill | Use it for |
|---|---|
| `five9-cloud-scripting` | **Writing your own scripts** with the module's built-in functions: which function to use, parameters, what each returns, safe patterns, debugging. Start here if you script. |
| `five9-cloud-setup` | Installing the module, PowerShell and execution policy, region, first read-only connection. Start here. |
| `five9-cloud-users` | Creating, copying, updating, activating/deactivating users; permissions, applications, SSO/MFA, Verint, DIDs. |
| `five9-cloud-campaigns` | Campaign settings, profiles, dialing modes, skills, scripts, prompts, start/stop/reset. |
| `five9-cloud-numbers` | Credits, inventory, claiming and releasing numbers, campaign DNIS, ANI groups, caller ID on profiles. |
| `five9-cloud-domain` | Read-only domain documentation exports, config audit log, tags, schedules, email, notifications, digital assistance. |
| `five9-cloud-module-dev` | Contributors: adding or fixing module functions from HAR captures. |

All skills defer to `AGENTS.md` in the repository root for policy, and to
`OBJECT_DEPENDENCIES.md` before anything is deleted or released.

## Installing in Claude

Each folder is one skill. Zip a skill folder (the zip should contain the folder,
with `SKILL.md` inside it) and add it through the Skills section of Claude's
settings. Install `five9-cloud-setup` plus whichever task skills you need.
Your organization's admin may need to allow custom skills.

For Claude Code, copy the folders into `.claude/skills/` in your clone (or
`~/.claude/skills/` for all projects).

## How a typical session goes

1. Share a working folder (for example `Documents\Five9-Admin`) with Claude.
2. Describe the task ("onboard these 40 agents like Jane's account").
3. Claude writes a script to `scripts\` and tells you what input it needs.
4. Run it with `$DryRun = $true`. It logs in (masked password prompt), shows the
   domain ID, and prints what it would change. Nothing changes.
5. Confirm the domain and the plan with Claude, set `$ExpectedDomainId` and
   `$DryRun = $false`, run again.
6. The script verifies each change and writes a log to `logs\`.

## Maintaining the skills

Function references are generated from the module source. After adding or
changing functions, regenerate from the repository root:

```
python skills/tools/generate_function_reference.py   # five9-cloud-scripting
python skills/tools/generate_function_catalogs.py    # the task skills
```

Edit `SKILL.md` files by hand when a function's purpose or risk changes. The
shared `assets/run-template.ps1` is duplicated in each task skill so each skill
works when installed alone; keep the copies identical.

This is sample code, not officially supported by Five9. For production
deployments, contact Five9 Professional Services or your Technical Account
Manager.
