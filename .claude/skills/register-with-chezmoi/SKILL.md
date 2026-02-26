---
name: register-with-chezmoi
description: Use when user installs a new package, tool, or app and wants it tracked in dotfiles, or says something like "register this with chezmoi", "add this to dotfiles", or "I just installed X"
---

# Register with Chezmoi

## Overview

All machine config and package changes live in `~/Projects/dotfiles`. Use this skill to decide where and how to register a change.

## Decision: What Did You Install or Change?

| Type | Example | Action |
|------|---------|--------|
| Brew formula (CLI tool) | `tmux`, `gh`, `ripgrep` | Add to formula block in `bootstrap/macos.sh` |
| Brew cask (GUI app) | `iterm2`, `obsidian` | Add to cask block in `bootstrap/macos.sh` |
| New config file | `~/.tmux.conf`, `~/.gitconfig` | `chezmoi add <path>` |
| Change to tracked config | edits to `.zshrc`, etc. | Edit in chezmoi source dir, then `chezmoi apply` |

## Brew Formula — Where to Add

File: `~/Projects/dotfiles/bootstrap/macos.sh`

```bash
brew install --formula \
  ...existing tools... \
  new-tool       # ← add here, alphabetical preferred
```

For a cask:
```bash
brew install --cask \
  ...existing apps... \
  new-app        # ← add here
```

## New Config File — How to Add

```bash
chezmoi add ~/.some-config-file   # copies into source dir
chezmoi apply                     # verify no-op (already applied)
```

Chezmoi renames the file in the source dir (e.g. `~/.tmux.conf` → `dot_tmux.conf`).

## Manual Setup Notes

Some tools require extra steps after install (auth, post-install config, etc.). After registering a tool, ask the user: **"Are there any manual steps needed after installing this on a new machine?"** If yes, add a note to `~/Projects/dotfiles/mac-setup-steps.md` under the relevant section:

```markdown
### <tool-name>
- `brew install <tool>` (handled by bootstrap)
- <any manual step, e.g. "Run `gh auth login` to authenticate">
- <config files tracked via chezmoi: list them>
```

Always check `mac-setup-steps.md` first — the note may already exist.

## Always Finish With

```bash
cd ~/Projects/dotfiles
git add -p
# then commit and push
```

Use the `commit` skill for the commit message.

## Common Mistakes

- **Editing the live config file directly** — changes won't be in the repo. Edit via `chezmoi edit` or in the source dir.
- **Forgetting to push** — the whole point is reproducibility on a new machine.
- **Linux bootstrap** — if the tool should also be on Linux/WSL, also add it to `bootstrap/linux.sh`.
