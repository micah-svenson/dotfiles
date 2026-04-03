You're in a Windows Subsystem for Linux (WSL) environment.

- NEVER use emdashes or double dashes in writing.
- Always use glab cli when presented with gitlab urls or tasks.
- Use `pbcopy` for copying to clipboard (shell function wrapping `clip.exe` on WSL)
- **Open URLs in Edge**: Use `xdg-open '<url>'` for http/https URLs (configured via `~/.local/share/applications/wsl-browser.desktop`).
- **Open WSL files in Windows browser**: Use `explorer.exe "$(wslpath -w /path/to/file)"` to open local files (e.g., HTML) in the default Windows application.
