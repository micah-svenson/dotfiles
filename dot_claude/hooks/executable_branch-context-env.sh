#!/bin/bash
# SessionStart hook: detect repo + branch and export context directory path
CWD="${CLAUDE_PROJECT_DIR:-.}"
REPO=$(git -C "$CWD" remote get-url origin 2>/dev/null | sed 's|.*/||;s|\.git$||')
BRANCH=$(git -C "$CWD" branch --show-current 2>/dev/null | sed 's|/|--|g')

if [ -n "$REPO" ] && [ -n "$BRANCH" ] && \
   [ "$BRANCH" != "main" ] && [ "$BRANCH" != "master" ] && [ "$BRANCH" != "develop" ]; then
    CONTEXT_DIR="$HOME/.claude/context/$REPO/$BRANCH"
    echo "export BRANCH_CONTEXT_DIR=\"$CONTEXT_DIR\"" >> "$CLAUDE_ENV_FILE"
    echo "export BRANCH_CONTEXT_REPO=\"$REPO\"" >> "$CLAUDE_ENV_FILE"
    echo "export BRANCH_CONTEXT_BRANCH=\"$BRANCH\"" >> "$CLAUDE_ENV_FILE"
fi
exit 0
