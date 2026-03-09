---
name: nvim-edit
description: Use when the user wants to open a file in nvim to review or edit it, or when they say "open this in nvim", "let me edit this", "pop open an editor", "edit this plan", "open this skill", "let me review this file", "open that for me". Also invoke proactively after writing any significant artifact (plan, skill, config file, doc) by offering to open it for review before proceeding.
---

# Nvim Editor Popup

Opens nvim in a tmux popup overlay so the user can edit a file interactively.
Blocks until the user closes nvim (`:wq` to save, `:q!` to discard), then reads back the result.

**Requirement:** Must be inside a tmux session (`$TMUX` set). Claude Code sessions running in tmux satisfy this.

## Proactive Offering

After writing any significant artifact, **always offer** to open it in nvim before proceeding:

> "Want to review or tweak this in nvim before I continue? (`; + e` or just say yes)"

Trigger this after writing any of the following:
- A plan, proposal, or multi-step outline
- A new SKILL.md or updates to an existing one
- A shell script or config file (`.tmux.conf`, `.zshrc`, etc.)
- A markdown doc or notes file
- Any file the user is likely to have opinions about

**Do not offer** for trivial edits, single-line changes, or files the user just dictated line-by-line.

If the user says "yes" or "open it", immediately invoke `claude-nvim-edit` on the file you just wrote. After they close nvim, read back the content and treat it as the new ground truth — update your understanding before continuing.

## The Script

`~/.local/bin/claude-nvim-edit <filepath>` — opens the file in a 90% popup via `tmux display-popup -E`.
Returns the final file content on stdout after nvim exits.

## Primary Use Case: Open a Specific File

Always pass an absolute path so the file opens correctly regardless of the current working directory:

```bash
~/.local/bin/claude-nvim-edit /absolute/path/to/file.md
```

**Common locations the user might want to reach:**

| What | Path |
|------|------|
| Claude skills | `~/.claude/skills/<name>/SKILL.md` |
| Dotfiles tmux config | `~/Projects/dotfiles/dot_tmux.conf` |
| Dotfiles zshrc | `~/Projects/dotfiles/dot_zshrc.tmpl` |
| Plans / docs | `~/Projects/dotfiles/docs/plans/<file>.md` |
| Any chezmoi source file | `~/Projects/dotfiles/<chezmoi-name>` |

If the user refers to a file vaguely ("that skill", "the tmux config"), resolve the path first, then open it.

## Capturing the Result

The Bash tool result IS the edited content — read it directly:

```bash
~/.local/bin/claude-nvim-edit ~/.claude/skills/nvim-edit/SKILL.md
```

After the user closes nvim, the returned content reflects their edits. Acknowledge the changes and continue.

## For Claude-Generated Content

Write the content to a temp file first (use the Write tool), then open it:

```bash
~/.local/bin/claude-nvim-edit /tmp/claude-plan.md
```

## Blank Buffer (rare)

```bash
~/.local/bin/claude-nvim-edit
# or: echo "" | ~/.local/bin/claude-nvim-edit
```
