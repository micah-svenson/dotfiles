#!/bin/bash

# Get the git branch for a given pane
# Usage: tmux_git_branch <pane_id>
tmux_git_branch() {
    local pane_id="${1:-.}"
    local pane_dir=$(tmux display-message -p -t "$pane_id" '#{pane_current_path}')

    if [ -d "$pane_dir/.git" ]; then
        cd "$pane_dir" || return
        git branch --show-current 2>/dev/null || echo "unknown"
    fi
}

# Get the working directory for a pane, truncated to last 2 segments
# Usage: tmux_working_dir <pane_id>
tmux_working_dir() {
    local pane_id="${1:-.}"
    local pane_dir=$(tmux display-message -p -t "$pane_id" '#{pane_current_path}')

    # Truncate to last 2 path segments, expand ~ for home
    echo "$pane_dir" | sed "s|^$HOME|~|" | awk -F/ '{
        if (NF > 2) {
            printf "%s/%s\n", $(NF-1), $NF
        } else {
            print $0
        }
    }'
}
