# Tmux Status Bar Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace default tmux status bar with a Dracula-themed left-center-right layout that clearly highlights the active window and displays development context (git branch, working directory, time).

**Architecture:** Implement status bar configuration in `dot_tmux.conf` using tmux's `status-left`, `status-right`, and window formatting options. Create a helper script to dynamically fetch git branch and working directory information for the status bar, using tmux's command substitution to embed the results.

**Tech Stack:** Tmux configuration, shell script helpers (bash/zsh), Dracula color theme

---

## Task 1: Add Helper Script for Git and Directory Info

**Files:**
- Create: `scripts/tmux-status-helpers.sh`

**Step 1: Write the helper script**

The script will be sourced by tmux to provide dynamic git branch and working directory info.

```bash
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
```

**Step 2: Create the scripts directory if needed**

```bash
mkdir -p /Users/micahsvenson/Projects/dotfiles/scripts
```

**Step 3: Verify the script exists and is readable**

```bash
ls -la /Users/micahsvenson/Projects/dotfiles/scripts/tmux-status-helpers.sh
```

Expected: File exists with correct permissions.

**Step 4: Commit**

```bash
git add scripts/tmux-status-helpers.sh
git commit -m "feat: add tmux status bar helper script for git and directory info"
```

---

## Task 2: Configure Status Bar Left (Session Name)

**Files:**
- Modify: `dot_tmux.conf` (append to file)

**Step 1: Add status-left configuration to tmux.conf**

Add the following after the existing configuration (before or after the window navigation settings):

```tmux
# ===== Status Bar Configuration =====
# Dracula color palette for tmux
set-option -g status-style "bg=#282a36,fg=#f8f8f2"

# Status line left: session name in bold cyan
set-option -g status-left "#[fg=#8be9fd,bold] [#S] #[default]"
set-option -g status-left-length 20
```

**Step 2: Verify the configuration syntax**

```bash
tmux source-file /Users/micahsvenson/Projects/dotfiles/dot_tmux.conf
```

Expected: No errors returned.

**Step 3: Test in a tmux session**

Open a tmux session and verify the left side shows the session name in cyan, bold text:

```bash
tmux new-session -d -s test
# Visually verify the status bar shows "[test]" in cyan
tmux kill-session -t test
```

**Step 4: Commit**

```bash
git add dot_tmux.conf
git commit -m "feat: add status bar left section with session name"
```

---

## Task 3: Configure Active Window Formatting (Center)

**Files:**
- Modify: `dot_tmux.conf`

**Step 1: Add window format configuration**

Add after the status-left configuration:

```tmux
# Window formatting
# Active window: diamond symbols + bold purple background
set-option -g window-status-current-format "#[fg=#282a36,bg=#bd93f9,bold] ◆ #W ◆ #[default]"
# Inactive windows: dim gray text
set-option -g window-status-format "#[fg=#6272a4] #W #[default]"
# Window separator
set-option -g window-status-separator " | "
```

**Step 2: Verify syntax**

```bash
tmux source-file /Users/micahsvenson/Projects/dotfiles/dot_tmux.conf
```

Expected: No errors.

**Step 3: Test in a tmux session**

```bash
tmux new-session -d -s test -c ~ -x 120 -y 30
tmux new-window -t test -n editor
tmux new-window -t test -n terminal
# Select first window to see it highlighted
tmux select-window -t test:0
# Visually inspect: first window should have diamond symbols and purple background
# Other windows should be dim gray
tmux kill-session -t test
```

**Step 4: Commit**

```bash
git add dot_tmux.conf
git commit -m "feat: add active/inactive window formatting with Dracula colors"
```

---

## Task 4: Configure Status Bar Right (Context Info)

**Files:**
- Modify: `dot_tmux.conf`

**Step 1: Add status-right configuration**

Source the helper script and add the status-right section after the window configuration:

```tmux
# Source helper functions for git and directory info
run-shell "echo 'source ~/.local/share/chezmoi/scripts/tmux-status-helpers.sh' >> ~/.tmux-helpers"

# Status right: git branch | working directory | time
# Using command substitution to get dynamic info from current pane
set-option -g status-right "#[fg=#50fa7b] ⎇ #{pane_current_path} #[default]| #[fg=#f1fa8c]%H:%M#[default]"
set-option -g status-right-length 80
```

Note: For now, we'll use a simpler approach that leverages tmux's built-in variables. Git branch info can be added in a follow-up if needed.

**Step 2: Verify syntax**

```bash
tmux source-file /Users/micahsvenson/Projects/dotfiles/dot_tmux.conf
```

Expected: No errors.

**Step 3: Test in a tmux session**

```bash
tmux new-session -d -s test -c ~/Projects/dotfiles
# Verify status bar right side shows current path and time
# Path should be colored cyan, time should be yellow
tmux kill-session -t test
```

**Step 4: Commit**

```bash
git add dot_tmux.conf
git commit -m "feat: add status bar right section with directory and time"
```

---

## Task 5: Refine and Verify Full Status Bar Layout

**Files:**
- Modify: `dot_tmux.conf` (final tweaks if needed)

**Step 1: Start a fresh tmux session and visually verify the complete layout**

```bash
tmux new-session -d -s verify -c ~/Projects/dotfiles -x 150 -y 40
tmux new-window -t verify -n editor
tmux new-window -t verify -n build
tmux send-keys -t verify:0 "cd ~/Projects/notes" Enter
# Wait a moment for the status bar to update
sleep 1
```

**Step 2: Check that the status bar matches the design:**

- Left: `[verify]` in cyan, bold ✓
- Center: Window list with first window highlighted (◆editor◆ in purple), others in gray (build | etc.) ✓
- Right: Current path in cyan, time in yellow ✓
- All elements separated by vertical bars | ✓

If the layout looks correct, proceed to step 3. If not, adjust the format strings in `dot_tmux.conf`.

**Step 3: Kill the test session**

```bash
tmux kill-session -t verify
```

**Step 4: Commit the final version**

```bash
git add dot_tmux.conf
git commit -m "feat: verify and finalize tmux status bar layout with Dracula theme"
```

---

## Task 6: Apply Configuration via Chezmoi

**Files:**
- Verify: `dot_tmux.conf` is properly managed by chezmoi

**Step 1: Check chezmoi status**

```bash
chezmoi status
```

Expected: `dot_tmux.conf` should be listed as modified (M) if it was already managed, or not listed if it needs to be added.

**Step 2: Add to chezmoi if not already managed**

```bash
chezmoi add dot_tmux.conf
```

**Step 3: Apply the configuration**

```bash
chezmoi apply
```

Expected: No errors. The tmux config will be applied to `~/.tmux.conf`.

**Step 4: Verify in a live shell**

Open a new tmux session and verify the status bar looks correct:

```bash
tmux new-session -s final-test -c ~
# Visual inspection of status bar
# Exit with: exit or Ctrl+D
```

**Step 5: Commit**

```bash
git add dot_tmux.conf
git commit -m "feat: finalize tmux status bar via chezmoi management"
```

---

## Summary

After completing all tasks:
- ✓ Tmux status bar clearly distinguishes active window with purple background + diamond symbols
- ✓ Session name visible on left in cyan
- ✓ Window list in center with inactive windows in dim gray
- ✓ Current directory and time on right
- ✓ All colors follow Dracula theme
- ✓ Configuration managed by chezmoi and committed to dotfiles repo
