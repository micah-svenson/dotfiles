#!/usr/bin/env bash
# Push one file to ${EDITOR:-vim} in the tmux window named "review", then focus it.
# The review window is dedicated to this flow: a new file overrides the old one.
set -u

file="${1:-}"
[ -n "$file" ] || { echo "usage: open.sh <path>" >&2; exit 1; }
[ -n "${TMUX:-}" ] || { echo "Not inside tmux - no review window to send to." >&2; exit 1; }

# The review window's cwd may differ from ours.
file=$(realpath -e "$file" 2>/dev/null || readlink -f "$file" 2>/dev/null || printf '%s' "$file")

session=$(tmux display-message -p '#{session_name}') || exit 1
# Braces required: zsh reads $session:review as the :r modifier.
tgt="${session}:review"

if ! tmux list-windows -t "$session" -F '#{window_name}' | grep -qx review; then
  tmux new-window -d -t "$session" -n review
  tmux send-keys -t "$tgt" "${EDITOR:-vim} $(printf %q "$file")" Enter
  tmux select-window -t "$tgt"
  echo "opened $file (new review window)"
  exit 0
fi

case "$(tmux display-message -t "$tgt" -p '#{pane_current_command}')" in
  vim|nvim|vi|view|nview)
    # :edit does not accept quoting, so escape vim's specials inline.
    vp=$(printf '%s' "$file" | sed -e 's/\\/\\\\/g' -e 's/ /\\ /g' -e 's/%/\\%/g' -e 's/#/\\#/g')
    tmux send-keys -t "$tgt" Escape Escape          # clear pending modal state
    tmux send-keys -t "$tgt" -l ":edit! ${vp}"      # ! discards the prior artifact
    tmux send-keys -t "$tgt" Enter
    ;;
  bash|zsh|fish|sh|dash|ksh|tcsh|csh)
    tmux send-keys -t "$tgt" "${EDITOR:-vim} $(printf %q "$file")" Enter
    ;;
  *)
    cur=$(tmux display-message -t "$tgt" -p '#{pane_current_command}')
    echo "review pane runs '$cur' (not a shell or editor) - nothing sent." >&2
    echo "Free the pane (Ctrl-C / :q) and ask again." >&2
    exit 1
    ;;
esac

tmux select-window -t "$tgt"
echo "opened $file"
