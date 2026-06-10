# Agent instructions

Rules for AI agents (Claude Code, Copilot, etc.) working in this repository.

## Privacy — never commit personal details

This is a public dotfiles repo. Before staging or committing any file, verify it contains none of the following:

### Hardcoded paths
- No `/Users/<name>/...` or `/home/<name>/...` — use `$HOME` or `~` instead
- No machine-specific absolute paths outside of `$HOME`-relative forms

### Credentials & secrets
- No auth tokens, API keys, passwords, or session cookies
- No private registry URLs that include credentials (e.g. `_authToken=...` in `.npmrc`)
- No OAuth tokens or refresh tokens
- Files like `.npmrc`, `.yarnrc.yml`, `.netrc` often contain secrets — do not add them without stripping credentials first

### Personal identifiers
- No real names in file content (comments, configs, scripts)
- No personal email addresses
- No machine hostnames or internal network names (e.g. SSH `Host` entries with real hostnames)
- No account IDs, UIDs, or usernames embedded in config values

### What's allowed
- `$HOME`, `$USER`, `$DOTFILES` environment variables
- Generic placeholder values like `<name>`, `<token>`, `<host>`
- Public URLs and open-source tool references

## Before every commit

1. Scan staged diffs for the patterns above
2. If any violation is found, fix it before proceeding — do not ask the user to decide, just replace with the safe form (e.g. swap a hardcoded path for `$HOME/...`)
3. If a file cannot be safely included without credentials (e.g. a registry `.npmrc`), exclude it entirely and note why

## SSH config

`settings/ssh_config.symlink` is a **template** — it contains only the `Host *` global block. Machine-specific host entries live in `~/.ssh/config` locally and must never be committed here.

## Sensitive files to never track

Even if present in the working directory, never `git add` these:

- `*.npmrc` containing `_authToken`
- `.yarnrc.yml` containing `npmAuthToken`
- `.env`, `.env.*`
- `*.pem`, `*.key`, `id_rsa`, `id_ed25519` (SSH private keys)
- `.netrc`
- `~/.aws/credentials`
- Any file under `.ssh/` except the template in `settings/`
