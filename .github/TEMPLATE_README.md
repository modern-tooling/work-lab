# Using work-lab as a Template

This repository is configured as a GitHub template. You can create your own
customized version with one click.

## How to use

1. Click the green **"Use this template"** button at the top of the repository
2. Choose a name for your new repository
3. Clone your new repository
4. Customize to your needs

## What to customize

After creating from template:

- **`.devcontainer/Dockerfile`** — Add your preferred tools
- **`~/.config/work-lab/post-create.sh`** — Personal tool installation
- **`~/.config/work-lab/post-start.sh`** — Startup scripts

## Keep or remove

| File | Purpose | Keep? |
|------|---------|-------|
| `install.sh` | One-liner installer | Remove if private |
| `.github/workflows/` | CI/CD | Customize or remove |
| `examples/` | Reference configs | Remove after copying |

## Staying updated

To pull updates from upstream:

```bash
git remote add upstream https://github.com/modern-tooling/work-lab.git
git fetch upstream
git merge upstream/main --allow-unrelated-histories
```
