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

Run the script. Do not reimplement it, and do not print it.

```bash
~/.claude/skills/open-in-vim/open.sh <absolute-path>
```

One file per call. If the user names a path, use that path. If not, use the
file you wrote or referenced last.

The script sends the file to `${EDITOR:-vim}` in the tmux window named
`review`, then focuses that window. A new file replaces the file on screen.
That override is deliberate: the window holds ephemeral review artifacts, not
work in progress. The script fails loudly outside tmux, and when the review
pane runs something other than a shell or an editor.

Report the result in one short line: "Opened `<file>` in the review window."

The user reviews the file, leaves `TODO:` or `FIXME:` comments, saves, and
comes back. Read the file fresh at that point. Assume nothing about the
contents from before.
