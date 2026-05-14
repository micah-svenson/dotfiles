#!/usr/bin/env bash

# Claude Code Notification Sound + Windows Toast
# Plays a sound and shows a toast when Claude needs your attention.
# Works on Windows (Git Bash/MINGW), Mac, Linux, and WSL.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOUND_NAME="${CLAUDE_NOTIFY_SOUND:-soft-chime}"
SOUND="$SCRIPT_DIR/sounds/$SOUND_NAME.wav"

# Read stdin (hooks pipe JSON context via stdin)
INPUT="$(cat)"

# Parse hook context
EVENT="$(echo "$INPUT" | jq -r '.hook_event_name // empty' 2>/dev/null)"
SESSION="$(echo "$INPUT" | jq -r '.session_id // empty' 2>/dev/null)"
CWD="$(echo "$INPUT" | jq -r '.cwd // empty' 2>/dev/null)"

# Prefer tmux session name over project dir so multiple sessions in the same
# repo are distinguishable in toasts.
LABEL=""
if [ -n "$TMUX" ] && command -v tmux >/dev/null 2>&1; then
  LABEL="$(tmux display-message -p '#S' 2>/dev/null)"
fi
[ -z "$LABEL" ] && LABEL="$(basename "$CWD" 2>/dev/null)"

# Build toast title and message based on event type
case "$EVENT" in
Notification)
  NOTIF_TYPE="$(echo "$INPUT" | jq -r '.notification_type // empty' 2>/dev/null)"
  NOTIF_MSG="$(echo "$INPUT" | jq -r '.message // empty' 2>/dev/null)"
  case "$NOTIF_TYPE" in
    permission_prompt) TITLE="Claude - Permission Needed" ;;
    idle_prompt)       TITLE="Claude - Waiting for Input" ;;
    *)                 TITLE="Claude - Notification" ;;
  esac
  MSG="${NOTIF_MSG:-Claude needs your attention}"
  [ -n "$LABEL" ] && MSG="[$LABEL] $MSG"
  ;;
Stop)
  TITLE="Claude - Done"
  MSG="Claude has finished responding"
  [ -n "$LABEL" ] && MSG="[$LABEL] $MSG"
  ;;
*)
  TITLE="Claude Code"
  MSG="Claude needs your attention"
  ;;
esac

# Check sound file exists
if [ ! -f "$SOUND" ]; then
  PLAY_SOUND=false
else
  PLAY_SOUND=true
fi

# Play sound and show toast by platform
case "$(uname -s)" in
MINGW* | MSYS*)
  [ "$PLAY_SOUND" = true ] && powershell -c "(New-Object Media.SoundPlayer '$SOUND').PlaySync()" 2>/dev/null &
  ;;
Darwin)
  [ "$PLAY_SOUND" = true ] && afplay "$SOUND" 2>/dev/null &
  osascript -e "display notification \"$MSG\" with title \"$TITLE\"" 2>/dev/null &
  ;;
Linux)
  if grep -qi microsoft /proc/version 2>/dev/null; then
    # WSL: use powershell for sound and toast
    if [ "$PLAY_SOUND" = true ]; then
      WIN_SOUND="$(wslpath -w "$SOUND")"
      powershell.exe -c "(New-Object Media.SoundPlayer '$WIN_SOUND').PlaySync()" 2>/dev/null &
    fi
    # Windows toast notification
    TOAST_TITLE="${TITLE//\'/\'\'}"
    TOAST_MSG="${MSG//\'/\'\'}"
    powershell.exe -c "
      [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > \$null
      [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom, ContentType = WindowsRuntime] > \$null
      \$xml = [Windows.Data.Xml.Dom.XmlDocument]::new()
      \$xml.LoadXml('<toast launch=\"app\" duration=\"short\"><audio silent=\"true\"/><visual><binding template=\"ToastGeneric\"><text>$TOAST_TITLE</text><text>$TOAST_MSG</text></binding></visual></toast>')
      \$toast = [Windows.UI.Notifications.ToastNotification]::new(\$xml)
      [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier('com.squirrel.AnthropicClaude.claude').Show(\$toast)
    " 2>/dev/null &
  else
    [ "$PLAY_SOUND" = true ] && paplay "$SOUND" 2>/dev/null &
    notify-send "$TITLE" "$MSG" 2>/dev/null &
  fi
  disown 2>/dev/null
  ;;
esac

exit 0
