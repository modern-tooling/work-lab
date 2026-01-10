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
  - Middle number increments for each release (0.1.0 → 0.2.0 → 0.3.0 → 0.4.0)
  - Patch releases (x.y.1) are VERY RARE - only for critical hotfixes
  - First number reserved for major/stable releases
- Keep `CHANGELOG.md` up to date with each release

## Release Notes

Focus on **user impact**, not implementation details:

**Good:**
- `wl up` renamed to `wl start`
- `wl doctor` works inside container
- Works on stock macOS without coreutils

**Bad (too technical):**
- Added `_timeout()` portable wrapper function
- Fixed `((errors++))` under `set -e` with `|| true`
- Added `C_ACTION` semantic color variable

Rule: If a user wouldn't notice the change while using the tool, don't mention it.

## Releases

**IMPORTANT: Agents MUST get explicit human confirmation BEFORE:**
1. Deciding what version number to use (always ask!)
2. Creating tags or pushing releases
3. Updating the Homebrew tap

**Version decision rule:** When in doubt, bump the middle number (0.3.0 → 0.4.0). Patch releases are discouraged.

When releasing a new version (after human approval):

1. [ ] Update `VERSION` in `bin/work-lab`
2. [ ] Update `CHANGELOG.md` with release notes
3. [ ] Commit and push to main
4. [ ] Create git tag: `git tag -a v0.8.0 -m "Release v0.8.0"`
5. [ ] Push tag: `git push origin v0.8.0`
6. [ ] **Create GitHub release** (required for `wl release-notes` to work):
   ```bash
   gh release create v0.8.0 -R modern-tooling/work-lab \
     --title "v0.8.0" --latest \
     --notes "$(cat <<'EOF'
   ## Added
   - **Feature**: Description

   ## Changed
   - **Change**: Description

   ## Fixed
   - **Fix**: Description
   EOF
   )"
   ```
7. [ ] **Update Homebrew tap**:
   ```bash
   # Get SHA256 of the new release tarball
   curl -sL https://github.com/modern-tooling/work-lab/archive/refs/tags/v0.8.0.tar.gz | shasum -a 256

   # Update Formula/work-lab.rb in modern-tooling/homebrew-tap:
   # - Change url to new tag
   # - Change sha256 to new hash
   ```

**CRITICAL**: Steps 6 and 7 are NOT automated. `wl release-notes` fetches from GitHub Releases API.

**Release frequency:** One version per day maximum. If multiple features land same day, combine into single release.

## Docker Image

The Docker image is versioned independently from the CLI:

- Image rebuilds **only** when `.devcontainer/` files change (not on every release)
- `devcontainer.json` uses `:latest` tag
- CLI releases do NOT trigger Docker rebuilds

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
