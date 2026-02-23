# Tmux Status Bar Design
**Date:** 2026-02-22
**Objective:** Improve tmux status bar usability and aesthetics for local software development workflow

## Problem Statement

Current tmux status bar (default styling) makes it difficult to:
- Quickly identify the active window
- Distinguish between active and inactive windows
- Get at-a-glance context about the development session

## Design Approach: Left-Center-Right Segments

### Overall Layout
```
[session-name] | window1  ◆active-window◆  window3 | branch | working-dir | time
```

### Section 1: Left (Session Identifier)
- **Content:** Session name in brackets
- **Styling:** Bold, Dracula cyan color
- **Purpose:** Quick visual anchor showing which tmux session you're in

### Section 2: Center (Window Navigation)
- **Content:** List of all open windows
- **Active window:** Highlighted with diamond symbols (◆) on each side, bold text, Dracula purple/pink background
- **Inactive windows:** Normal text, dim gray color
- **Separator:** Vertical bar (|) between left section and windows

### Section 3: Right (Development Context)
- **Git branch:** Shows current git branch (if in git repo), prefixed with branch icon (⎇)
- **Working directory:** Current pane's working directory, truncated to last 2-3 path segments
- **Time:** 24-hour format (HH:MM)
- **Separators:** Vertical bars (|) between each info item
- **Color scheme:**
  - Git branch: Dracula green
  - Directory: Dracula blue
  - Time: Dracula yellow

## Visual Styling (Dracula Theme)

| Element | Color | Style |
|---------|-------|-------|
| Session name | Cyan (#8be9fd) | Bold |
| Active window | Purple bg (#bd93f9) | Bold text, diamonds |
| Inactive windows | Gray (#6272a4) | Normal |
| Separators | Gray (#6272a4) | Normal |
| Git branch | Green (#50fa7b) | Normal |
| Directory | Blue (#8be9fd) | Normal |
| Time | Yellow (#f1fa8c) | Normal |

## Implementation Details

- Status bar will be configured in `dot_tmux.conf`
- Use `status-left`, `status-right`, and `window-status-format` settings
- Window-specific formatting using `#W` (window name) and `#I` (window index)
- Context info (git, directory, time) will use tmux command substitution and shell helpers
- Colors will map to Dracula palette via tmux color codes

## Success Criteria

- Active window is immediately visually distinct from inactive windows
- All required info (session, windows, git branch, directory, time) is visible at a glance
- Status bar remains readable and doesn't feel cluttered
- Colors follow Dracula theme for consistency with rest of development environment
