#!/bin/bash
SOCK="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/ssh-agent.socket"
if [ -S "$SOCK" ] && [ -n "$CLAUDE_ENV_FILE" ]; then
    echo "export SSH_AUTH_SOCK=\"$SOCK\"" >> "$CLAUDE_ENV_FILE"
fi
exit 0
