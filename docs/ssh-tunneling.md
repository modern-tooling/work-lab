<!-- doc-audience: ai -->
# SSH Tunneling to Project Devcontainer

SSH into your project's devcontainer from within work-lab.

## Zero Configuration Required

work-lab automatically sets up SSH tunneling when you run `wl mux` or `wl shell`. **No changes to your devcontainer needed** - just enable sshd.

## Quick Start

### Step 1: Enable sshd in your devcontainer

Add to your project's `.devcontainer/devcontainer.json`:

```json
"features": {
    "ghcr.io/devcontainers/features/sshd:1": {}
}
```

### Step 2: Use it

```bash
wl up                    # start work-lab
wl mux                   # enter tmux (auto-configures SSH tunnel)
# press prefix + S       # SSH into devcontainer
```

That's it!

## How It Works

```
┌─────────────────────────────────────────────────────────────────────┐
│  HOST (wl mux / wl shell)                              [has Docker] │
│  1. Generate SSH keys → project/.work-lab/                          │
│  2. docker inspect → get devcontainer IP                            │
│  3. docker exec → inject public key into devcontainer               │
│  4. Update .gitignore                                               │
└─────────────────────────────────────────────────────────────────────┘
                              ▼
              (credentials written to shared project mount)
                              ▼
┌─────────────────────────────────────────────────────────────────────┐
│  WORK-LAB (dc-ssh)                                   [NO Docker]    │
│  Read .work-lab/ssh-key and .work-lab/dc-ip → SSH connect           │
└─────────────────────────────────────────────────────────────────────┘
```

**Key design:**
- HOST orchestrates setup (has Docker access)
- work-lab stays isolated (no Docker socket)
- Zero devcontainer modifications required

## Usage

### From work-lab tmux

- `prefix + S` - SSH tunnel to devcontainer
- `prefix + D` - Docker exec fallback (requires Docker on host)

### Command line

```bash
dc-ssh              # interactive shell
dc-ssh npm test     # run command
dc-ssh make build   # run command
dc-ssh --check      # check if tunnel is available (exit 0/1)
```

## Checking Tunnel Availability

### wl ps (from host)

```
project-name/
  ├─ work-lab      abc123def456  ●    work-lab-container
  └─ devcontainer  def789abc012  ● ⚡  project-devcontainer
```

Indicators:
- `⚡` = tunnel ready (use `prefix + S` in tmux)
- `~` = can tunnel (run `wl mux` to configure)

### wl doctor (from host)

```
Mode
  ℹ Sidecar mode
  ✓ project devcontainer: running
  ✓ SSH tunnel: configured
```

## Security Model

| Property | Description |
|----------|-------------|
| **No Docker socket in work-lab** | work-lab maintains full isolation |
| **Ephemeral keys** | Generated on first `wl mux`/`wl shell` |
| **Host orchestrates** | Docker access only needed on host |
| **User controls .gitignore** | Add `.work-lab/` to .gitignore if desired |

### Security flow

1. User runs `wl mux` on HOST (which has Docker)
2. Host generates SSH keypair in `project/.work-lab/`
3. Host uses `docker exec` to inject public key into devcontainer
4. Host writes devcontainer IP to `project/.work-lab/dc-ip`
5. work-lab's `dc-ssh` reads credentials and connects via SSH

**work-lab never needs Docker access** - all orchestration happens on the host.

## Troubleshooting

### "SSH tunnel not configured"

The devcontainer may not have sshd enabled.

1. Add the sshd feature to your devcontainer.json
2. Rebuild the devcontainer
3. Run `wl mux` again (triggers setup)

### "Cannot reach devcontainer"

1. Check devcontainer is running: `wl ps`
2. Verify sshd feature is enabled
3. Restart devcontainer and run `wl mux` again

### Keys not being generated

Run `wl mux` or `wl shell` from the host - this triggers lazy initialization of SSH tunnel credentials.

## Files Created

work-lab creates these files in your project (auto-gitignored):

```
project/
└── .work-lab/
    ├── ssh-key       # private key (mode 600)
    ├── ssh-key.pub   # public key
    ├── dc-ip         # devcontainer IP
    └── dc-user       # SSH user
```

## Comparison: dc-ssh vs dc-attach

| Feature | dc-ssh | dc-attach |
|---------|--------|-----------|
| Connection | SSH over network | docker exec |
| Works from work-lab | Yes | No (host only) |
| Port forwarding | Supported | Not supported |
| Devcontainer setup | sshd feature only | None |
| tmux keybinding | prefix + S | prefix + D |

**Recommendation:** Use `dc-ssh` from work-lab tmux. Use `wl dc` from the host when Docker access is available.
