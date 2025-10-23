#!/bin/bash

# Common functions for bootstrap scripts

log_info() {
    echo "ℹ️  $1"
}

log_success() {
    echo "✅ $1"
}

log_error() {
    echo "❌ $1" >&2
}

log_warning() {
    echo "⚠️  $1"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Create directory if it doesn't exist
ensure_dir() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
        log_info "Created directory: $1"
    fi
}

# Backup existing file/directory
backup_if_exists() {
    if [ -e "$1" ]; then
        mv "$1" "${1}.backup.$(date +%Y%m%d_%H%M%S)"
        log_info "Backed up existing: $1"
    fi
}

# Clone or update git repository
clone_or_update_repo() {
    local repo_url="$1"
    local target_dir="$2"
    
    if [ -d "$target_dir/.git" ]; then
        log_info "Updating repository: $target_dir"
        cd "$target_dir" && git pull
    else
        log_info "Cloning repository: $repo_url"
        git clone "$repo_url" "$target_dir"
    fi
}