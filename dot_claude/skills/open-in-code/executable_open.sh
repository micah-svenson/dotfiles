#!/usr/bin/env bash
# Hand one file or folder to VS Code, landing it in the right window.
set -u

target="${1:-}"
[ -n "$target" ] || { echo "usage: open.sh <path>" >&2; exit 1; }

target=$(realpath -e "$target" 2>/dev/null || readlink -f "$target" 2>/dev/null || printf '%s' "$target")

# `code <folder>` already focuses an existing window for that folder, or opens
# a new one. Do not reimplement it.
if [ -d "$target" ]; then
  code "$target" && echo "opened $target"
  exit
fi

# A file alone lands in the last-active window, which may be the wrong project.
# Pass the git root too so the file lands in that project's window.
root=$(git -C "$(dirname "$target")" rev-parse --show-toplevel 2>/dev/null)
if [ -n "$root" ]; then
  code "$root" "$target" && echo "opened $target in the window for $root"
else
  code -r "$target" && echo "opened $target (no repo; reused last window)"
fi
