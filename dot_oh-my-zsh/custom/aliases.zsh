alias wslip="ip addr show eth0 | grep 'inet\b' | awk '{print $2}' | cut -d/ -f1"

alias java-17="/usr/lib/jvm/java-17-amazon-corretto/bin/java"
alias java-21="/usr/lib/jvm/java-21-amazon-corretto/bin/java"

alias edot="explorer.exe ."

alias m="mvn"
alias mcl="mvn clean"
alias mi="mvn install"
alias mcli="mvn clean install"
alias mco="mvn compile"
alias spa="mvn spotless:apply"
alias spc="mvn spotless:check"
alias cm="chezmoi"
alias cme="chezmoi edit"

alias proj="cd ~/projects/"

alias hosts="vim /mnt/c/Windows/System32/drivers/etc/hosts"

alias msa="mvn spotless:apply"

# https://lloydrochester.com/post/unix/wsl-pbcopy-pbpaste/
pbcopy() {
    tee <&0 | clip.exe
}

pbpaste() {
    powershell.exe Get-Clipboard | sed 's/\r$//' | sed -z '$ s/\n$//'
}

# Navigate to a directory using fzf.
# Depth defaults to 1.
# Add numeric arg after cdf to specify depth other than 1
fcd() {
    local depth=${1:-1}  # Default depth to 1 if no argument is passed
    local dir=$(find . -maxdepth "$depth" -type d | fzf)
    if [ -n "$dir" ]; then
        cd "$dir"
    fi
}

# Navigate to a project with default depth of 1
p() {
    local depth=${1:-1}  # Default depth to 1 if no argument is passed
    local projects_dir=~/projects

    # Make sure the projects directory exists
    if [ ! -d "$projects_dir" ]; then
        echo "Error: ~/projects directory does not exist."
        return 1
    fi

    # Remember current directory to return if cancelled
    local current_dir=$(pwd)

    # Navigate to projects directory temporarily
    cd "$projects_dir"

    # Use cdf with the specified or default depth
    fcd "$depth"

    # If cdf was cancelled (still in projects dir), return to original directory
    if [ "$(pwd)" = "$projects_dir" ]; then
        cd "$current_dir"
        echo "Navigation cancelled."
    fi
}

# Jump to recently visited directories
cdjump() {
    local dir=$(dirs -p | fzf)
    cd "$dir"
}


# Quickly switch git branches
fgc() {
    local branch=$(git branch | grep -v '^*' | sed 's/^  //' | fzf)
    if [ -n "$branch" ]; then
        git checkout "$branch"
    fi
}

# Search command history
fh() {
    local cmd=$(history | fzf | sed 's/ *[0-9]* *//')
    echo "$cmd"
    eval "$cmd"
}

# Find files and preview content
ff() {
    find . -type f | fzf --preview 'bat --color=always {} 2>/dev/null || cat {}'
}

# Fuzzy search aliases and functions; Enter inserts the name at the prompt
fa() {
  local tmp selection
  tmp=$(mktemp)
  { alias; printf '\n'; typeset -f; } > "$tmp"

  selection=$(
    {
      alias | while IFS='=' read -r name val; do
        val="${val#\'}"
        val="${val%\'}"
        printf "%-22s  \033[33malias\033[0m  %s\n" "$name" "$val"
      done

      typeset +f | grep -v '^_' | sort | while read -r fn; do
        first=$(typeset -f "$fn" | awk 'NR==3{gsub(/^[[:space:]]*/,""); if(length>55) $0=substr($0,1,52)"..."; print; exit}')
        printf "%-22s  \033[36mfn\033[0m     %s\n" "$fn" "$first"
      done
    } | fzf \
        --ansi \
        --reverse \
        --height 60% \
        --header 'fa: aliases & functions — Enter to insert at prompt' \
        --preview "name=\$(echo {} | awk '{print \$1}'); grep -A 30 \"^\$name ()\" \"$tmp\" | head -30 || grep \"^\$name=\" \"$tmp\"" \
        --preview-window 'right:50%:wrap'
  )

  rm -f "$tmp"
  [[ -n "$selection" ]] && print -z -- "${selection%% *}"
}

# Save and jump to bookmarked directories
bookmark() {
    # Save current directory to bookmarks file
    pwd >> ~/.bookmarks
}

jumpmark() {
    # Jump to a bookmarked location
    local dir=$(cat ~/.bookmarks | sort | uniq | fzf)
    if [ -n "$dir" ]; then
        cd "$dir"
    fi
}

# Quick tmux session picker/creator (works outside tmux)
tm() {
    ~/.local/bin/tmux-sessionizer
}

alias lg="lazygit"

alias omz_aliases="vim ~/.oh-my-zsh/custom/aliases.zsh"
alias c="clear"

alias pyvenv-localstack="source ~/.venv-localstack/bin/activate"
alias dev="cd ~/projects/"
alias bootstaq="cd ~/projects/bootstaq/"
alias udl="cd ~/projects/udl"
alias udl-dev="mvn quarkus:dev -DuseLocalConfiguration=true -DconfigFilePath=config/ -DpropertyFile=udl-properties.yaml -Ddebug=true -Dsuspend=false -Dawt.toolkit=  -DdwProvider=mongo"
alias cl="cd ~/projects/component-library"
alias pepstaq="cd ~/projects/pepstack"
alias udlnifi="cd ~/projects/udlnifi"
alias storefront="cd ~/projects/storefront"
alias acctmgt-front="cd ~/projects/acctmgt-front"
alias udladmin="cd ~/projects/udladmin"
alias ui-components="cd ~/projects/ui-components"

alias restest="cd ~/projects/rest_test/"
alias pp="code ~/projects/python-playground/"

alias vim="nvim"
alias vimconf=" cd ~/.config/nvim && nvim ."

alias duh='sudo du -h --threshold=1000000 ./*'
alias pyenv='source env/bin/activate'
alias pyvenv='source .venv/bin/activate'

function sync-ssh-configs {
  user_ssh=$HOME/.ssh
  root_ssh=/root/.ssh
  windows_ssh=/mnt/c/Users/MicahSvenson/.ssh

  # make sure the .ssh directory exists.
  sudo mkdir -p $root_ssh

  echo "copying ${user_ssh} to ${root_ssh}"
  sudo cp "$user_ssh/config" "$root_ssh/config"
  echo "copying ${user_ssh}/config to ${windows_ssh}"
  cp "$user_ssh/config" "$windows_ssh/config"
}

alias d="docker"
alias dc="docker-compose"
alias dils="docker image ls"
alias dcls="docker container ls"
alias dr="docker run -it --rm"

alias edge="/mnt/c/Program\ Files\ \(x86\)/Microsoft/Edge/Application/msedge.exe"

# Open a specific gitlab issue number in webtools
function gl-issue {
  edge "https://gitlab.com/<group>/<project>/-/issues/${1}"
}


# ── OpenCode ────────────────────────────────────────────────────────
alias oc="opencode"
alias oco="opencode -m amazon-bedrock/micah-opus-4-6"
alias ocs="opencode -m amazon-bedrock/micah-sonnet-4-6"
alias och="opencode -m amazon-bedrock/micah-haiku-4-5"
alias ocg="opencode -m openai/gpt-5.4"
alias ocgm="opencode -m openai/gpt-5.4-mini"

# ── Claude Code ─────────────────────────────────────────────────────
alias cld="claude --remote"
alias cldp="claude -p --remote"
alias cldo="claude --remote --model opus"
alias clds="claude --remote --model sonnet"
alias cldh="claude --remote --model haiku"
alias cldr="claude --resume"
alias cldy="claude --dangerously-skip-permissions --remote"
alias cldyo="claude --dangerously-skip-permissions --remote --model opus"
alias cldys="claude --dangerously-skip-permissions --remote --model sonnet"
alias cldyh="claude --dangerously-skip-permissions --remote --model haiku"
alias cldyr="claude --dangerously-skip-permissions --resume"
alias cldpy="claude -p --dangerously-skip-permissions --remote"
alias cldpyo="claude -p --dangerously-skip-permissions --remote --model opus"
alias cldpys="claude -p --dangerously-skip-permissions --remote --model sonnet"
alias lfg="claude --dangerously-skip-permissions --remote --model opus"

# ── Claude Code (local) ───────────────────────────────────────────
alias cldl="claude"
alias cldlo="claude --model opus"
alias cldls="claude --model sonnet"
alias cldlh="claude --model haiku"
alias cldly="claude --dangerously-skip-permissions"
alias cldlyo="claude --dangerously-skip-permissions --model opus"

# Edit global Claude config
alias cldcfg="vim ~/.claude/CLAUDE.md"

# ── Claude Plugin Dev ────────────────────────────────────────────────
CLAUDE_PLUGIN_DEV=~/Projects/claude-plugin-dev

# List available plugins in the dev marketplace
cldplugins() {
  ls "$CLAUDE_PLUGIN_DEV/plugins/"
}

# Launch Claude with one or more dev plugins loaded via --plugin-dir
# Usage: clddev <plugin-name> [<plugin-name>...]
# Example: clddev example
# Example: clddev formatter linter
clddev() {
  local plugin_args=()
  for plugin in "$@"; do
    plugin_args+=(--plugin-dir "$CLAUDE_PLUGIN_DEV/plugins/$plugin")
  done
  claude "${plugin_args[@]}"
}

# ── Task Workspace: auto-rename tmux session on cd ──────────────────
chpwd() {
    [ -z "$TMUX" ] && return

    local dir="$PWD"
    if [[ "$dir" == */.tasks/* ]]; then
        local tasks_parent="${dir%%/.tasks/*}"
        local workspace="$(basename "$tasks_parent")"
        local after_tasks="${dir#*/.tasks/}"
        local task_name="${after_tasks%%/*}"
        local session_name="$(echo "$workspace/$task_name" | tr './:' '___')"
        tmux rename-session "$session_name" 2>/dev/null
    fi
}
