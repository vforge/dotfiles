# Pi setup

Notes for setting up [Pi](https://pi.dev) on a new machine together with these dotfiles.

## 1. Install Pi

Pi is a Node.js CLI. Install Node first using your normal machine setup (`mise`, `nvm`, Homebrew, etc.), then install Pi:

```bash
npm install -g --ignore-scripts @earendil-works/pi-coding-agent
```

Alternative installer:

```bash
curl -fsSL https://pi.dev/install.sh | sh
```

Verify:

```bash
pi --version
```

## 2. Install personal Pi package

My reusable Pi extensions live in a separate Pi package repo:

```text
git@github.com:vforge/pi-config.git
```

Install it globally for the user:

```bash
pi install git:git@github.com:vforge/pi-config.git
```

Verify:

```bash
pi list
```

Update later with:

```bash
pi update --extensions
```

## 3. Configure secrets/env locally

Do not commit Pi secrets into dotfiles.

Machine-local files live under:

```text
~/.pi/agent/
```

Useful files:

```text
~/.pi/agent/settings.json   # local Pi preferences
~/.pi/agent/models.json     # local/custom providers
~/.pi/agent/.env            # local env vars for extensions/models
~/.pi/agent/auth.json       # Pi auth; do not copy/commit
~/.pi/agent/sessions/       # session history; do not copy/commit
~/.pi/agent/trust.json      # project trust; machine-local
```

The `vforge/pi-config` repo includes templates:

```text
settings.example.json
models.example.json
.env.example
```

Use them as references when creating local files in `~/.pi/agent/`.

Example `~/.pi/agent/.env`:

```env
SEARXNG_URL=http://localhost:8080
LLAMACPP_BASE_URL=http://localhost:1234/v1
LLAMACPP_API_KEY=dummy
```

## 4. Authenticate providers

Either use API keys/env vars or Pi login:

```bash
pi
/login
```

For GitHub Copilot/ChatGPT/Claude subscription auth, use `/login` inside Pi.

## 5. `pissh` wrapper

This dotfiles repo provides:

```text
~/.dotfiles/bin/pissh
```

It is a thin wrapper around `pi --ssh`:

```bash
pissh user@host
pissh user@host:/remote/path
pissh user@host:/remote/path -p "/skills"
```

The actual `--ssh` behavior is provided by the `vforge/pi-config` package. When enabled, Pi runs locally but built-in tools operate on the remote host:

```text
read, write, edit, bash, grep, find, ls
```

Remote requirements:

- SSH key auth; no interactive password prompts
- `bash`
- `rg` for remote `grep`

## 6. New machine checklist

```bash
# dotfiles
mkdir -p ~/.dotfiles
# or clone normally if not already present
git clone git@github.com:vforge/dotfiles.git ~/.dotfiles
cd ~/.dotfiles && bash install.sh work   # macOS workstation
# or: bash install.sh simple             # Linux/server

# Pi
npm install -g --ignore-scripts @earendil-works/pi-coding-agent
pi install git:git@github.com:vforge/pi-config.git

# local config
mkdir -p ~/.pi/agent
$EDITOR ~/.pi/agent/.env
$EDITOR ~/.pi/agent/settings.json
$EDITOR ~/.pi/agent/models.json

# auth
pi
# then run /login if needed
```

## 7. Things intentionally not managed by dotfiles

Do not symlink or commit these:

```text
~/.pi/agent/auth.json
~/.pi/agent/sessions/
~/.pi/agent/trust.json
~/.pi/agent/.env
```

Keep them per-machine.
