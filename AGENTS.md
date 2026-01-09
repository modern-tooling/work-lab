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
- Uses beads-style versioning: `0.<release>.0`
  - Middle number increments for each release (0.1.0 → 0.2.0 → 0.3.0)
  - Last number reserved for patches on a released version (0.2.0 → 0.2.1)
  - First number reserved for major/stable releases
- Keep `CHANGELOG.md` up to date with each release

## Releases

**IMPORTANT: Agents MUST NOT release without explicit human confirmation.** Always ask the user before creating tags, pushing releases, or updating the Homebrew tap.

When releasing a new version (after human approval):

1. Update `VERSION` in `bin/work-lab`
2. Update `CHANGELOG.md` with release notes
3. Commit and push to main
4. Create git tag: `git tag -a v0.3.0 -m "Release v0.3.0"`
5. Push tag: `git push origin v0.3.0`
6. GitHub Actions will build and push Docker image to GHCR
7. **MUST** update Homebrew tap (this is NOT automated):
   ```bash
   # Get SHA256 of the new release tarball
   curl -sL https://github.com/modern-tooling/work-lab/archive/refs/tags/v0.3.0.tar.gz | shasum -a 256

   # Update Formula/work-lab.rb in modern-tooling/homebrew-tap:
   # - Change url to new tag
   # - Change sha256 to new hash
   ```

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
