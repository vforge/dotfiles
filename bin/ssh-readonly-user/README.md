# ssh-readonly-user

Create a restricted readonly user on a remote server via SSH. Designed for **agents**
(or humans) that need to inspect system state, check services, and read logs —
without the ability to modify anything meaningful.

## Quick Start

```bash
# Create readonly user (username derived from key filename: id_ed25519_agent.pub → agent)
ssh-readonly-user/create root@192.168.1.10 ~/.ssh/id_ed25519_agent.pub

# List all readonly users on a server
ssh-readonly-user/list root@192.168.1.10

# Remove it later
ssh-readonly-user/remove root@192.168.1.10 agent
```

## Usage

### `create`

```bash
ssh-readonly-user/create user@host /path/to/id_rsa.pub [options]
```

| Option | Description | Default |
|---|---|---|
| `--user <name>` | Override username (default: derived from key filename) | key filename without `.pub` and `id_*` prefix |
| `--commands "cmd1,cmd2,..."` | Custom whitelist of allowed commands | 30+ read-only tools (see below) |
| `--lock-home` | Make home directory fully read-only (`chattr +i`, `chmod 555`) | `false` |
| `--unlock-home` | Explicitly unlock home directory (revert `--lock-home`) | — |

**Examples:**

```bash
# Basic — creates user 'agent' with default command set
ssh-readonly-user/create root@server ~/.ssh/id_ed25519_agent.pub

# Custom username
ssh-readonly-user/create admin@server ~/.ssh/monitor.pub --user monitor-bot

# Minimal commands only
ssh-readonly-user/create root@server ~/.ssh/agent.pub \
  --commands "ls,cat,tail,grep,systemctl,journalctl"

# Locked home (max security)
ssh-readonly-user/create root@server ~/.ssh/agent.pub --lock-home
```

### Re-running `create` (idempotent updates)

The script is **fully idempotent** — safe to re-run at any time to modify an
existing user. It detects what changed and updates only what's needed.

| What you change | What happens on re-run |
|---|---|
| Different `--commands` list | New commands symlinked, **old (removed) symlinks cleaned up** |
| Different key file (`*.pub`) | Old SSH key **replaced** with new one (key rotation) |
| Add `--lock-home` | Home directory locked (`chattr +i`, `chmod 555`) |
| Remove `--lock-home` (or pass `--unlock-home`) | Home directory **auto-unlocked** back to `chmod 755` |
| Same everything | All phases report "unchanged", no modifications made |

```bash
# Initial setup with default commands
ssh-readonly-user/create root@server ~/.ssh/id_ed25519_agent.pub

# Later: add more commands (old ones kept, new ones added)
ssh-readonly-user/create root@server ~/.ssh/id_ed25519_agent.pub \
  --user agent --commands "ls,cat,tail,grep,strace,tmux,htop"

# Rotate the SSH key (old key removed, new key installed)
ssh-readonly-user/create root@server ~/.ssh/id_ed25519_agent_new.pub \
  --user agent

# Lock home for max security
ssh-readonly-user/create root@server ~/.ssh/id_ed25519_agent_new.pub \
  --user agent --lock-home

# Unlock again (auto-detected, or use --unlock-home explicitly)
ssh-readonly-user/create root@server ~/.ssh/id_ed25519_agent_new.pub \
  --user agent --unlock-home
```

### `remove`

```bash
ssh-readonly-user/remove user@host <readonly-username> [options]
```

| Option | Description | Default |
|---|---|---|
| `--keep-home` | Don't delete the user's home directory | `false` (home is deleted) |

### `list`

```bash
ssh-readonly-user/list user@host [options]
```

Audits all readonly users on a server. Detects them by finding any user with
`/bin/rbash` as their login shell.

| Option | Description | Default |
|---|---|---|
| `--json` | Output in JSON format (for scripting/parsing) | table |
| `--brief` | One line per user, no details | table |

**Table output (default):**
```
=== Readonly Users on myserver ===

── agent ──
  Home:    /home/agent
  Shell:   /bin/rbash
  UID/GID: agent(1001)/agent(1001)
  Commands (35): cat curl df du env file find grep head less ls more ...
  SSH keys: 1 total (1 with hardening flags)
    → flags=no-port-forwarding,no-X11-forwarding,no-agent-forwarding key=AAAAC3NzaC1l...
  Sudo:    YES (18 rules in /etc/sudoers.d/readonly-agent)
    /usr/bin/systemctl status *
    /usr/bin/journalctl -u * --no-pager
    ...
  Lock:    NO (home permissions: 755)

=== Total: 1 readonly user(s) ===
```

**Brief output:**
```
$ ssh-readonly-user/list root@server --brief
agent  home=/home/agent  cmds=35  keys=1  sudo=yes
```

**JSON output:**
```json
[
  {
    "user": "agent",
    "home": "/home/agent",
    "shell": "/bin/rbash",
    "commands": ["cat", "curl", "df", "du", ...],
    "ssh_keys": [{"flags": "no-port-forwarding,...", "key": "AAAAC3..."}],
    "sudo_rules": ["/usr/bin/systemctl status *", ...],
    "home_locked": false
  }
]
```

## Prerequisites

- You have SSH access to the remote server as a user with **sudo** privileges
- `ssh-copy-id` already done for your admin key
- Target OS: **Debian/Ubuntu** or **Arch/CatchyOS** (auto-detected)

---

## What Exactly Happens

When you run `create`, the script connects to the remote server via SSH and
performs these 6 phases in order. All output is streamed back to your terminal.

### Phase 1 — User Account Creation

**OS detection:** Checks for `/etc/debian_version`, `/etc/arch-release`, or runs
`lsb_release -si` to determine the distro.

**User creation (idempotent):**
- If user doesn't exist: creates it with `adduser` (Debian) or `useradd` (Arch)
- If user exists: skips creation, proceeds to update
- No password is set — login is SSH-key-only

**Shell:** Sets login shell to `/bin/rbash` via `chsh`. On Debian, if
`/bin/rbash` doesn't exist as a file, creates a symlink: `/bin/rbash → /bin/bash`.

**Files changed:**
- `/etc/passwd` — new user entry with shell set to `/bin/rbash`
- `/bin/rbash` — created as symlink to `/bin/bash` if missing

### Phase 2 — Private Bin Directory with Symlinks

Creates `~/.readonly-bin/` and populates it with **symlinks** to only the
whitelisted commands. Each symlink points to the real binary (resolved via
`readlink -f`).

```
/home/agent/.readonly-bin/
├── cat → /usr/bin/coreutils/cat
├── df  → /usr/bin/df
├── grep → /usr/bin/grep
├── ls  → /usr/bin/coreutils/ls
├── ps  → /usr/bin/ps
├── tail → /usr/bin/tail
└── ... (all whitelisted commands)
```

If a requested command isn't found on the system, it's skipped with a warning.

**Default whitelist (35 commands):**

| Category | Commands |
|---|---|
| File browsing | `ls`, `cat`, `less`, `more`, `tail`, `head`, `find`, `file`, `tree` |
| Text processing | `grep`, `wc`, `sort`, `uniq`, `cut`, `awk`, `sed` |
| System info | `df`, `du`, `free`, `uptime`, `whoami`, `date`, `hostname`, `env` |
| Process/network | `ps`, `top`, `ss`, `netstat`, `lsof`, `ping` |
| Network tools | `curl`, `wget` |
| Misc | `ssh-keygen`, `tmux` |

**Files changed:**
- `~/.readonly-bin/` — new directory with symlinks

### Phase 3 — Shell Hardening (`.profile` + `.bashrc`)

Writes a hardened `~/.profile` and `~/.bashrc` that lock down the shell environment.

**What `.profile` does:**

```bash
# 1. Lock PATH to private bin only — user can't access /usr/bin, /bin, etc.
readonly HOME
export PATH="$HOME/.readonly-bin"

# 2. Block environment variable hijacks
#    BASH_ENV and ENV can source arbitrary scripts before the shell starts
unset BASH_ENV ENV CDPATH 2>/dev/null || true

# 3. Enable restricted mode (redundant with rbash, but defense in depth)
set -o restricted 2>/dev/null || true

# 4. Clear history — no command persistence across sessions
history -c 2>/dev/null || true

# 5. Block editor escapes (vi/vim can spawn shells with :!sh)
alias vi='echo "vi is not allowed"'
alias vim='echo "vim is not allowed"'
alias nano='echo "nano is not allowed"'
alias emacs='echo "emacs is not allowed"'

# 6. Block interpreter escapes (python/perl/ruby can run arbitrary code)
alias python='echo "python is not allowed"'
alias python3='echo "python3 is not allowed"'
alias perl='echo "perl is not allowed"'
alias ruby='echo "ruby is not allowed"'
alias lua='echo "lua is not allowed"'

# 7. Block shell escapes
alias bash='echo "bash is not allowed — you are already in rbash"'
alias sh='echo "sh is not allowed"'

# 8. Greeting message
echo "--- readonly shell: type 'ls' or 'exit' ---"
```

**What `.bashrc` does:**
Same PATH lock and environment unsets, for non-login shells (e.g., `sudo -u agent bash`).

**Files changed:**
- `~/.profile` — overwritten with hardened profile
- `~/.bashrc` — created/overwritten with minimal hardening

### Phase 4 — SSH Key Installation with Hardening Flags

Installs the provided public key into `~/.ssh/authorized_keys` with restrictive
prefix flags.

**The key line looks like:**
```
no-port-forwarding,no-X11-forwarding,no-agent-forwarding,ssh-ed25519 AAAAC3... user@host
```

| Flag | What it blocks |
|---|---|
| `no-port-forwarding` | TCP tunneling (`-L`, `-R`, `-D`) — prevents lateral movement via SSH tunnels |
| `no-X11-forwarding` | X11 display forwarding — prevents graphical app execution |
| `no-agent-forwarding` | SSH agent forwarding (`-A`) — prevents use of your local SSH keys from the server |

**Idempotency:** If the same key already exists, it's skipped. If a different readonly
key exists, it's replaced. Other users' keys are untouched.

**Files changed:**
- `~/.ssh/` — created with `chmod 700`
- `~/.ssh/authorized_keys` — created/appended with key + hardening flags, `chmod 600`

### Phase 5 — Limited Sudo Access (for Agents)

Creates a sudoers drop-in file that grants **passwordless** sudo for specific
service management and log inspection commands.

**File:** `/etc/sudoers.d/readonly-<username>` (permissions: `440`, owner: `root:root`)

**Granted sudo commands:**

| Command | What the agent can do |
|---|---|
| `systemctl status *` | Check if any service is running |
| `systemctl start *` | Start a stopped service |
| `systemctl stop *` | Stop a running service |
| `systemctl restart *` | Restart a service |
| `systemctl reload *` | Reload service config |
| `journalctl -u * --no-pager` | Read logs for any service (forced no-pager) |
| `journalctl -u * --no-pager -n N` | Read last N log lines |
| `journalctl -u * --no-pager -f` | Follow logs in real-time |
| `service * status` | Legacy SysV service status |
| `cat /var/log/*` | Read any system log file |
| `tail /var/log/*` | Read end of any log file |
| `tail -f /var/log/*` | Follow any log file in real-time |
| `ss *` | Check network sockets/connections |
| `netstat *` | Legacy network stats |
| `lsof *` | List open files and processes |

**Conditional additions:**
- If `docker` is installed: adds `docker ps`, `docker logs *`, `docker stats --no-stream`, `docker inspect *`
- If `kubectl` is installed: adds `kubectl get *`, `kubectl describe *`, `kubectl logs *`

**Files changed:**
- `/etc/sudoers.d/readonly-<username>` — new file with NOPASSWD rules

### Phase 6 — Ownership & Optional Lock

Sets correct ownership on all created files and optionally locks the home directory.

**Ownership (always):**
```bash
chown -R agent:agent /home/agent/.readonly-bin/
chown -R agent:agent /home/agent/.ssh/
chown agent:agent /home/agent/.profile /home/agent/.bashrc
```

**Lock mode (`--lock-home`):**
```bash
chattr +i /home/agent/.readonly-bin/*   # symlinks become immutable
chmod 555 /home/agent/                  # home is read+execute only, no writes
```

---

## Defense in Depth — 6 Layers of Hardening

| # | Layer | What it blocks | Config |
|---|---|---|---|
| 1 | **rbash** (restricted bash) | `cd` outside home, PATH modification, redirections (`>`, `\|`), `export`, `unset` | `/etc/passwd` shell field |
| 2 | **Private bin** | Access to any command not in whitelist — no editors, no interpreters, no shells | `~/.readonly-bin/` symlinks |
| 3 | **Profile hardening** | Environment hijack (`BASH_ENV`), editor escapes (`vi :!sh`), interpreter escapes (`python -c`) | `~/.profile`, `~/.bashrc` |
| 4 | **SSH key flags** | Port tunneling, X11 forwarding, agent forwarding (lateral movement) | `authorized_keys` prefix |
| 5 | **Limited sudo** | Only specific service management commands, no arbitrary root access | `/etc/sudoers.d/readonly-*` |
| 6 | **Home lock** (optional) | Can't write any files in home, can't modify symlinks | `chattr +i`, `chmod 555` |

### Common rbash Escape Hatches & How They're Blocked

| Escape attempt | Why it works normally | How we block it |
|---|---|---|
| `vi` → `:!bash` | vi can spawn subshells | Not in PATH + aliased to echo |
| `python -c 'import os; os.system("/bin/bash")'` | Python runs arbitrary code | Not in PATH + aliased to echo |
| `export PATH=/usr/bin` → get full bash | rbash allows export by default | `readonly HOME` + PATH locked in profile |
| `BASH_ENV=~/.evil` → sources evil script on startup | Bash sources `$BASH_ENV` before running | `unset BASH_ENV` in profile |
| `cd /tmp && echo "hack" > /tmp/script.sh` | Redirection works in rbash without locked PATH | No write tools in private bin, no editors |
| `ssh -L 8080:localhost:80 other-server` | SSH tunneling from inside the session | `no-port-forwarding` on key |
| `ssh -A other-server` → use admin's keys | Agent forwarding passes credentials | `no-agent-forwarding` on key |

---

## Summary of All Changes Made

| Path/Setting | Action | Purpose |
|---|---|---|
| `/etc/passwd` | New user entry, shell = `/bin/rbash` | Restricted login shell |
| `/bin/rbash` | Symlink to `/bin/bash` (if missing) | Required for rbash on Debian |
| `~/.readonly-bin/` | New directory with symlinks | Whitelisted commands only |
| `~/.profile` | Overwritten with hardened profile | PATH lock, alias blocks, env cleanup |
| `~/.bashrc` | Created with minimal hardening | Same protections for non-login shells |
| `~/.ssh/` | Created, `chmod 700` | SSH directory |
| `~/.ssh/authorized_keys` | Key installed with hardening flags, `chmod 600` | Restricted SSH access |
| `/etc/sudoers.d/readonly-<user>` | New file, `chmod 440`, owner `root:root` | Passwordless sudo for agents |
| Home directory | `chown -R user:user` on all files | Correct ownership |

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     ATTACK SURFACE                           │
│                                                             │
│  SSH Login ──→ Layer 4 (key flags) ──→ rbash shell          │
│                      │                        │              │
│              no-port-fwd                Layer 1 (rbash)      │
│              no-X11-fwd                  no cd, export       │
│              no-agent-fwd               no redirections      │
│                                             │                │
│                                    Layer 2 (private bin)     │
│                                       PATH = ~/.readonly-bin │
│                                       only whitelisted cmds  │
│                                             │                │
│                                    Layer 3 (.profile)        │
│                                     unset BASH_ENV, ENV      │
│                                     alias vi='', python=''   │
│                                             │                │
│                              needs service mgmt?             │
│                                    /          \              │
│                                   YES          NO            │
│                                    │            │            │
│                           Layer 5 (sudo)    Layer 6 (lock)   │
│                           systemctl,        chattr +i        │
│                           journalctl         chmod 555       │
│                           cat /var/log/*                     │
└─────────────────────────────────────────────────────────────┘
```

---

## Troubleshooting

### "rbash: command not found" after login
The PATH isn't loading. Check that `~/.profile` exists and contains:
```bash
export PATH="$HOME/.readonly-bin"
```

### User can still run editors
Check for escape hatches:
```bash
# Verify .readonly-bin has no editors
ls ~/.readonly-bin/ | grep -E 'vi|vim|nano|emacs|python|perl|ruby'

# Verify aliases are loaded
ssh agent@server "alias vi"
# Should output: alias vi='echo "vi is not allowed"'
```

### Sudo doesn't work for the agent
Check the sudoers file:
```bash
sudo cat /etc/sudoers.d/readonly-agent
sudo visudo -c  # validate syntax
```

### Need to add more commands after creation
Re-run `create` with the extended command list — it's idempotent:
```bash
ssh-readonly-user/create root@server ~/.ssh/agent.pub \
  --user agent --commands "ls,cat,tail,grep,strace,tmux"
```

---

## See Also

- [PLAN.md](./PLAN.md) — Full design document with security analysis
- [../README.md](../README.md) — Main dotfiles documentation
