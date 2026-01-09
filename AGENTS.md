<!-- doc-audience: ai -->
# Agent Instructions for work-lab

Instructions for AI coding agents working on this repository.

## Documentation

Before editing docs, check line 1 for `<!-- doc-audience: ... -->`.

| Tag | Action |
|-----|--------|
| `human` or `preserve-voice` | DO NOT edit |
| `human, ai-editable` | Edit while preserving concise voice |
| `ai` | Edit freely |

References:
- [AGENTS-GUIDANCE.md](https://raw.githubusercontent.com/modern-tooling/ai-human-docs/main/AGENTS-GUIDANCE.md) (behavior)
- [SPEC.md](https://raw.githubusercontent.com/modern-tooling/ai-human-docs/main/SPEC.md) (parsing)

## Versioning

- Version is defined in `bin/work-lab` as `VERSION="x.y.z"`
- Follow [Semantic Versioning](https://semver.org/)
- Keep `CHANGELOG.md` up to date with each release

## Releases

When releasing a new version:

1. Update `VERSION` in `bin/work-lab`
2. Update `CHANGELOG.md` with release notes
3. Create git tag: `git tag -a v0.1.0 -m "Release v0.1.0"`
4. Push tag: `git push origin v0.1.0`
5. GitHub Actions will build and push Docker image to GHCR

**Release frequency:** One version per day maximum. If multiple features land same day, combine into single release.

## Code Style

- Shell scripts: Use `shellcheck` conventions
- Naming: kebab-case for files (e.g., `post-create.sh`)
- Comments: Lowercase unless proper noun
- Follow XDG Base Directory Specification for paths

## Testing

Before committing:

```bash
work-lab doctor   # Verify environment
shellcheck bin/work-lab  # Lint shell scripts
```

## Demo Recording

To re-record the demo gif:

```bash
brew install vhs
vhs docs/demo.tape
```
