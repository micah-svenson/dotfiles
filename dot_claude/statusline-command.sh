#!/bin/sh
# Claude Code status line — styled after the robbyrussell Oh My Zsh theme

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Current directory basename (mirrors robbyrussell %c)
dir_name=$(basename "$cwd")

# Git branch and dirty status (skip optional locks)
git_branch=""
if git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
    branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
    if [ -n "$branch" ]; then
        if git -C "$cwd" status --porcelain 2>/dev/null | grep -q .; then
            git_info="git:(${branch}) ✗"
        else
            git_info="git:(${branch})"
        fi
        git_branch=" $git_info"
    fi
fi

# Context usage indicator
ctx_str=""
if [ -n "$used" ] && [ "$used" != "null" ]; then
    used_int=$(printf "%.0f" "$used")
    ctx_str=" [ctx: ${used_int}%]"
fi

# Model label
model_str=""
if [ -n "$model" ] && [ "$model" != "null" ]; then
    model_str=" ${model}"
fi

printf "\033[1;32m➜\033[0m \033[0;36m%s\033[0m\033[1;34m%s\033[0m\033[33m%s\033[0m\033[35m%s\033[0m\n" \
    "$dir_name" "$git_branch" "$ctx_str" "$model_str"
