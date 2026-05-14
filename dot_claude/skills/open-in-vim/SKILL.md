---
name: open-in-vim
description: |
  Use when the user says "open", "open in vim", "open this", "open <path>",
  "send to review", "review in vim", "let me review that", or otherwise asks
  to open a file in their editor for review. Also use to offer a neutral
  "Say `open` if you want to review this in vim" nudge whenever Claude has
  just produced a review-style artifact (design doc, planning doc, DRP, ADR,
  spec, requirements doc, plan, report, long-form prose writeup) the user is
  likely to want to read and annotate before continuing. Skip the nudge for
  code edits, config files, and routine prose tweaks.
---

# Open in Vim

Pushes a file to the user's `${EDITOR:-vim}` inside the tmux window named
`review` and switches focus there. The user has `prefix + r` bound to toggle
the review window — this skill is the programmatic counterpart that lands
the artifact in that window.

The review window is dedicated to this workflow, so it's safe to *override*
whatever is currently being reviewed: opening a new file replaces the one
already on screen. Future code-diff reviews (e.g. `:DiffviewOpen` in nvim)
will live in the same window.

## When to use

**Explicit request.** Any of these trigger the skill:

- "open", "open it", "open this", "open <path>"
- "open in vim", "review in vim"
- "send to review", "let me review that"

If the user supplies a path, use that. Otherwise use the most recently
written or referenced file from the conversation.

**Opt-in nudge after a review-style artifact.** When you've just written or
substantially edited a file the user is likely to read before the
conversation moves on, end your turn with one neutral line:

> Say `open` if you want to review this in vim.

No yes/no question, no follow-up — just an opt-in line they can ignore. If
they want it, they'll say "open"; if not, the conversation continues with
whatever was next.

Artifacts that warrant the nudge include:

- `design.md`, `designing.md`, `design-options/.../*.md`
- `planning.md`, ACs, requirements docs, spec docs
- DRP packages, ADR drafts
- Plans (briskly's `design.md`, plan files from writing-plans skills)
- Reports, long-form writeups, decision memos

**Don't** nudge after:

- Code edits (`.py`, `.ts`, `.java`, `.go`, `.rs`, etc.) — not reviewed in vim.
- Config files (yaml/json/toml/lockfiles).
- Memory files, skills, settings.json.
- Small/routine prose tweaks (typo fixes, one-line edits).

The nudge should mean "this is a doc worth a focused read," not be a default
footer on every turn.

## How to open

One file per invocation. Pass an absolute path.

```bash
open_in_vim() {
  if [ -z "$TMUX" ]; then
    echo "Not inside tmux — can't push to the review window." >&2
    return 1
  fi
  local file="$1"
  if [ -z "$file" ]; then
    echo "open_in_vim: need a file path" >&2
    return 1
  fi
  # Absolutize defensively — the review window's cwd may differ from here.
  file=$(realpath -e "$file" 2>/dev/null || readlink -f "$file" || printf '%s' "$file")

  local session tgt
  session=$(tmux display-message -p '#{session_name}') || return 1
  tgt="${session}:review"

  # Fresh review window: create it, run vim from the shell.
  if ! tmux list-windows -t "$session" -F '#{window_name}' | grep -qx review; then
    tmux new-window -d -t "$session" -n review
    tmux send-keys -t "$tgt" "${EDITOR:-vim} $(printf %q "$file")" Enter
    tmux select-window -t "$tgt"
    return 0
  fi

  # Review window exists — branch on what's running in its pane.
  local cur
  cur=$(tmux display-message -t "$tgt" -p '#{pane_current_command}')
  case "$cur" in
    vim|nvim|vi|view|nview)
      # Editor open — escape any pending modal/operator state, then :edit! to
      # force-load the new file (discards unsaved changes in current buffer;
      # that's the "override the previous review artifact" semantic).
      local vp
      vp=$(printf '%s' "$file" | sed -e 's/\\/\\\\/g' -e 's/ /\\ /g' -e 's/%/\\%/g' -e 's/#/\\#/g')
      tmux send-keys -t "$tgt" Escape Escape
      tmux send-keys -t "$tgt" -l ":edit! ${vp}"
      tmux send-keys -t "$tgt" Enter
      ;;
    bash|zsh|fish|sh|dash|ksh|tcsh|csh)
      tmux send-keys -t "$tgt" "${EDITOR:-vim} $(printf %q "$file")" Enter
      ;;
    *)
      echo "review pane is running '$cur' (not a shell or editor) — nothing sent." >&2
      echo "Free up the pane (Ctrl-C / :q / etc.) and ask again." >&2
      return 1
      ;;
  esac

  tmux select-window -t "$tgt"
}

open_in_vim /absolute/path/to/file.md
```

Why each piece matters:

- **`$TMUX` check** — outside tmux there's no review window to send to. Bail
  loudly rather than silently dropping the request.
- **Current session, not a fixed name** — the user runs many tmux sessions
  in parallel; the review window lives inside the *current* session, matching
  what `prefix + r` toggles to.
- **`realpath -e`** — absolutize the path so vim resolves it regardless of
  the review window's cwd.
- **`printf %q`** — shell-escapes spaces and metacharacters when sending to a
  shell prompt.
- **`${session}:review`, not `$session:review`** — zsh treats `:r` as a
  parameter modifier (root/strip-extension), which would silently mangle the
  target. Braces force plain concatenation. Same gotcha was caught the hard
  way with `:t` earlier.
- **Double `Escape`** before `:edit!` — clears any pending operator, count,
  or modal state in the running editor so the ex command lands cleanly.
- **`:edit!`** — the `!` discards unsaved changes in the current buffer. The
  user explicitly chose override-on-collision over preserve-prompt; the review
  window is for ephemeral review artifacts, not work-in-progress.
- **vim-style backslash escaping** for the `:edit` path — vim ex commands
  treat `%`, `#`, space, and `\` specially. Quoted forms aren't supported by
  `:edit`, so escape inline. Assumes no embedded single/double quotes in the
  path (true for all normal project paths).
- **`select-window` at the end** — focus lands on the review window,
  equivalent to the user hitting `prefix + r` after Claude finishes.

After running, tell the user in one short line what you opened — e.g.
"Opened `flowtasks/.../design.md` in the review window." Don't print the
Bash.

## When the user comes back

The user's workflow is: open the file, leave `TODO:` / `FIXME:` comments,
save, return to Claude, and ask you to address them. When they do, read the
file fresh — assume nothing about its contents from before they opened it.
