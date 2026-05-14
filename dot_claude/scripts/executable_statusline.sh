#!/bin/bash
input=$(cat)
cwd=$(echo "$input" | jq -r '.workspace.current_dir')

# Strip $HOME prefix for relative path
rel=${cwd#$HOME/}

# Show last 3 path components, prefix with … if truncated
short=$(echo "$rel" | awk -F/ '
  NF<=3 { print; next }
  NF>3 {
    printf "…/"
    for(i=NF-2; i<=NF; i++) {
      if(i > NF-2) printf "/"
      printf "%s", $i
    }
    print ""
  }
')

if git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
  branch=$(git -C "$cwd" branch --show-current 2>/dev/null || echo 'detached')
  staged=$(git -C "$cwd" diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
  unstaged=$(git -C "$cwd" diff --numstat 2>/dev/null | wc -l | tr -d ' ')
  echo "$short | $branch | staged: $staged unstaged: $unstaged"
else
  echo "$short | no git"
fi
