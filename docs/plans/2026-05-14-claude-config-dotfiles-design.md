# Claude Code config → dotfiles migration: design

Date: 2026-05-14

## Goal

Move the reusable parts of `~/.claude/` into the chezmoi-managed `dotfiles` repo so a fresh machine can be brought up with `chezmoi apply`. Scope is "lift and shift" of personal config only: no work-org artifacts, no runtime data, no Bluemind tooling.

## Non-goals

- Migrating Claude runtime state (`projects/`, `sessions/`, `history.jsonl`, `cache/`, `telemetry/`, `tasks/`, `todos/`, `file-history/`, `shell-snapshots/`, etc.).
- Migrating credentials (`.credentials.json`, `mcp-needs-auth-cache.json`).
- Migrating org-specific tooling (Bluemind agents/commands/hooks, `team-standards@bluestaq` plugin, custom marketplaces).
- Sanitizing existing skills that contain Bluestaq/UDL references inside their content (out of scope; flagged below as follow-up).

## Layout in `dotfiles/`

```
dot_claude/
├── CLAUDE.md
├── private_settings.json.tmpl
├── settings.local.json
├── statusline-command.sh           # already in repo
├── hooks/
│   ├── branch-context-env.sh
│   └── ssh-agent-env.sh
├── scripts/
│   ├── statusline.sh
│   └── claude-notify/
│       ├── claude-notify.sh
│       └── README.txt
├── skills/
│   ├── fix-mr-comments-local/
│   ├── mr-queue/
│   ├── open-in-vim/
│   ├── review-tests/
│   ├── rich-copy/
│   ├── slickdoc/
│   ├── todo/
│   └── writing-requirements/
└── commands/
    └── grill-me.md
```

Chezmoi prefixes used:

- `dot_claude/`: renders to `~/.claude/`. **Plain**, not `exact_`, so chezmoi leaves Claude's runtime state alone.
- `private_settings.json.tmpl`: `private_` preserves mode 0600 (matches current). `.tmpl` enables Go template expansion.
- All subdirectories (`skills/`, `agents/`, `commands/`, `hooks/`, `scripts/`) are plain too. Selective tracking: adding a new skill on-machine requires an explicit `chezmoi add ~/.claude/skills/<name>` (or invoking the `register-with-chezmoi` skill). Skills that aren't in source stay on-machine; chezmoi doesn't touch them. No `agents/` directory exists in the seed because nothing non-Bluemind survives the cut.

## What gets dropped on the way in

### Bluemind (entirely excluded)

- `agents/bluemind-capture.md`, `bluemind-decompose.md`, `bluemind-retrieve.md`, `bluemind-review.md`
- `commands/bluemind-migrate.md`, `bluemind-review.md`, `bluemind-update.md`
- `rules/bluemind-signals.md`
- In `CLAUDE.md`: the `<!-- BLUEMIND:START -->` ... `<!-- BLUEMIND:END -->` block (lines 9-41)
- In `settings.json`:
  - The second `Stop` hook (`bluemind capture --event stop`)
  - The `SessionEnd` hook (`bluemind capture --event session_end`)
  - The `PostToolUse` hook on `Write|Edit|Bash` (`bluemind capture --event post_tool`)

### Custom marketplaces (entirely excluded)

- `extraKnownMarketplaces` block in `settings.json` (loom, jira-diode, like-micah, briskly)
- Their `enabledPlugins` entries: `loom@loom`, `like-micah@like-micah`, `jira-diode@jira-diode`, `briskly@briskly`
- The `team-standards@bluestaq` plugin entry (work-org marketplace)

### Work-specific skills (excluded)

- `skills/jira-writing/`: Bluestaq Jira standards
- `skills/psql-query/`: UDL Postgres
- `skills/writing-requirements-workspace/`: eval workspace with cerberus/Bluestaq content

### Other agents/commands (excluded)

- `agents/jira-writer.md`: user opted to drop after sweep

### Runtime data (always excluded)

- `backups/`, `cache/`, `debug/`, `downloads/`, `file-history/`, `history.jsonl`, `paste-cache/`, `plans/`, `plugins/`, `projects/`, `sessions/`, `session-env/`, `shell-snapshots/`, `stats-cache.json`, `tasks/`, `telemetry/`, `todos/`, `usage-data/`
- `.credentials.json`, `mcp-needs-auth-cache.json`, `policy-limits.json`, `.last-cleanup`, `config-changelog.md`, `settings.json.bak.*`

## Templating `private_settings.json.tmpl`

After dropping the Bluemind hooks and custom marketplaces, the surviving file uses chezmoi Go-template substitutions for absolute paths:

| Before | After |
|---|---|
| `"command": "CLAUDE_NOTIFY_SOUND=boing bash /home/micah/.claude/scripts/claude-notify/claude-notify.sh"` | `"command": "CLAUDE_NOTIFY_SOUND=boing bash {{ .chezmoi.homeDir }}/.claude/scripts/claude-notify/claude-notify.sh"` |
| `"command": "CLAUDE_NOTIFY_SOUND=laser bash /home/micah/.claude/scripts/claude-notify/claude-notify.sh"` | `"command": "CLAUDE_NOTIFY_SOUND=laser bash {{ .chezmoi.homeDir }}/.claude/scripts/claude-notify/claude-notify.sh"` |

The `statusLine.command` references `~/.claude/statusline-command.sh` already via chezmoi-managed `dot_claude/statusline-command.sh`, so it gets the same `{{ .chezmoi.homeDir }}` substitution.

Everything else (model, alwaysThinkingEnabled, effortLevel, spinnerVerbs, voiceEnabled, the surviving official-marketplace enabledPlugins) copies verbatim.

After cleanup, the final `enabledPlugins` reads:

```jsonc
{
  "enabledPlugins": {
    "superpowers@claude-plugins-official": true,
    "ralph-loop@claude-plugins-official": false,
    "playwright@claude-plugins-official": true,
    "frontend-design@claude-plugins-official": true,
    "skill-creator@claude-plugins-official": true
  }
}
```

## CLAUDE.md trim

Lines 9-41 (the `<!-- BLUEMIND:START -->` ... `<!-- BLUEMIND:END -->` block) are removed. Everything outside that block is generic WSL/tooling guidance and copies verbatim. Result: file shrinks from ~3.1 KB to ~1 KB.

## `settings.local.json`

Copied as-is. It contains only Bash permission allowlists (e.g. `git push:*`, `chmod:*`). No paths, no secrets, no work-specific tokens.

## Bootstrap on a new machine

The repo's existing `bootstrap/linux.sh` and `bootstrap/macos.sh` already run `chezmoi apply`. After this change, a fresh `chezmoi apply` produces a working `~/.claude/` with:

- Global CLAUDE.md guidance
- Notify toasts wired up (tmux-aware label per earlier work)
- 8 user-authored skills available
- 1 user-authored slash command available
- Official-marketplace plugins enabled and ready to install on first Claude run

No additional cloning, no marketplace setup, no manual `chezmoi add` needed for the seed.

## Future workflow

After migration, adding a new authored skill/agent/command on machine A:

1. Author the file under `~/.claude/<skills|agents|commands>/<name>/`.
2. `chezmoi add ~/.claude/<skills|agents|commands>/<name>`: or invoke the `register-with-chezmoi` skill, which performs the same operation.
3. Commit in the dotfiles repo.

Removing one from tracking: `chezmoi forget ~/.claude/skills/<name>` (leaves on-machine), then optionally delete from the source repo to stop syncing to other machines on next apply.

## Known caveats / follow-ups (not blocking)

1. **Bluestaq/UDL references inside kept skills.** `mr-queue`, `review-tests`, and `writing-requirements` each contain inline references to Bluestaq standards and conventions. User explicitly chose to keep them as-is. Sanitizing those into generic-language skills is a separate effort.
2. **`fix-mr-comments-local`** is in the skill listing inside `~/.claude/skills/` but is not surfaced in the active-skills listing in this Claude session, which suggests it may be experimental or unfinished. Included anyway since the user authored it; remove later if stale.
3. **Plugin enablement is not the same as plugin installation.** On a fresh machine, the `enabledPlugins` entries record the user's preference, but the actual plugin code is fetched by Claude Code from the official marketplace on first run. Expect a small first-launch delay while plugins install.
4. **`hooks/branch-context-env.sh` and `hooks/ssh-agent-env.sh`** are shell-env helpers that don't appear referenced by any current `settings.json` hook. They are included on the assumption they're sourced by some external mechanism (e.g., the user's zshrc or a tmux hook). If after migration they turn out to be unreferenced anywhere, they can be dropped from the seed in a follow-up.

## Approval gate

User reviews this spec; on approval, the next step is `writing-plans` to lay out the concrete file copy/transform sequence.
