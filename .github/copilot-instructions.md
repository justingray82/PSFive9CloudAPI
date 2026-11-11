# Copilot instructions

The canonical guidance for AI assistants in this repository is `AGENTS.md` at
the repository root. Read it before suggesting changes. Key points: target
PowerShell 5.1, one function per file, GET-then-PUT for updates, never handle
credentials in code or chat, and never write to a live Five9 domain without a
dry run and explicit confirmation.
