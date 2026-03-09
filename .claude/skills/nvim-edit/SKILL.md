---
name: nvim-edit
description: Use when the user wants to open nvim to review or edit something, or when they say "open this in nvim", "let me edit this", "pop open an editor", "edit this plan", "open an editor for me", "I want to review this"
---

# Nvim Editor Popup

Opens nvim in a tmux popup overlay so the user can edit content interactively.
Blocks until the user closes nvim (`:wq` to save, `:q!` to discard), then reads back the result.

**Requirement:** Must be inside a tmux session (`$TMUX` set). Claude Code sessions running in tmux satisfy this.

## The Script

`~/.local/bin/claude-nvim-edit` — opens nvim via `tmux display-popup -E` and returns the final file content on stdout.

## Three Modes

### 1. Let the user write something from scratch (blank buffer)

```bash
~/.local/bin/claude-nvim-edit
```

Opens an empty nvim buffer. Whatever the user writes and saves comes back to you on stdout.

### 2. Let the user edit content you generated

Write the content to a temp file first (use the Write tool), then pass the path:

```bash
# Claude writes content to a temp file, e.g. /tmp/plan.md
~/.local/bin/claude-nvim-edit /tmp/plan.md
```

The user edits it in nvim. You receive the final version on stdout AND the file is updated in-place.

### 3. Let the user edit an existing repo file

```bash
~/.local/bin/claude-nvim-edit path/to/file.md
```

Opens the file directly. Changes are saved in-place, and content is echoed to stdout.

## Capturing the Result

Run via Bash tool and capture stdout:

```bash
# The script outputs the edited content — read it from the Bash tool result
~/.local/bin/claude-nvim-edit /tmp/my-artifact.md
```

The Bash tool result IS the edited content. Read it, summarize changes, and proceed.

## Typical Workflow

1. User says "let me edit this plan"
2. You write the current content to `/tmp/claude-plan.md` using the Write tool
3. You run `~/.local/bin/claude-nvim-edit /tmp/claude-plan.md` via Bash tool
4. A nvim popup appears over the terminal — user edits and does `:wq`
5. Bash tool returns the edited content
6. You acknowledge the changes and continue

## Tips

- Popup is 90% width/height — plenty of room for editing
- `:wq` saves and closes; `:q!` discards changes and closes
- Both exit codes return content (`:q!` returns original/empty — that's fine)
- For generated plans, use `.md` extension so nvim gets markdown syntax highlighting
- You don't need to diff the content — just read the returned version as the new ground truth
