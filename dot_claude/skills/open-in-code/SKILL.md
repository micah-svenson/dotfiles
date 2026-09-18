---
name: open-in-code
description: |
  Use when the user asks to open a file or project in VS Code specifically:
  "open in code", "open in vscode", "open in vs code", "open <path> in code",
  "code this", "open the project in vscode", "pull this up in vscode". The
  request must name VS Code / code — bare "open" (with no editor named) belongs
  to the open-in-vim skill, which owns the vim review flow. This skill focuses
  the already-open VS Code window for the file's project when there is one, and
  opens a fresh window otherwise.
---

# Open in Code

Run the script. Do not reimplement it, and do not print it.

```bash
~/.claude/skills/open-in-code/open.sh <absolute-path>
```

One target per call, either a file or a directory. If the user names a path,
use that path. If not, use the file or directory you wrote or referenced last.

The script hands a directory straight to `code`, which focuses an existing
window for that folder or opens a new one. For a file, the script finds the
git root and passes both, so the file lands in that project's window instead
of the last-active one.

Report the result in one short line: "Opened `foo/bar.ts` in the VS Code
window for `foo`."
