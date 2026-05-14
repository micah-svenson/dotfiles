# Claude Code config → dotfiles migration: implementation plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Move the personal, reusable parts of `~/.claude/` into the chezmoi-managed `dotfiles` repo so a fresh machine can be bootstrapped with `chezmoi apply`.

**Architecture:** Write cleaned file content directly into `~/projects/dotfiles/dot_claude/` (the chezmoi source). Use chezmoi's `private_`, `executable_`, and `.tmpl` prefixes to encode permissions and template substitution. Then run `chezmoi diff` to confirm the only deltas against live `~/.claude/` are the intentional ones (Bluemind hooks removed from settings.json), then `chezmoi apply`. Finally clean up the live filesystem (dropped Bluemind agents/commands, dropped/broken symlinks).

**Tech Stack:** chezmoi (dev build, source = `~/projects/dotfiles`), bash, jq, python3 (for JSON edits where jq would be awkward), git.

---

## File Structure

Source files created or modified in `~/projects/dotfiles/dot_claude/`:

| Path | Responsibility |
|---|---|
| `CLAUDE.md` | Global user instructions (Bluemind block trimmed) |
| `private_settings.json.tmpl` | User settings, mode 0600, with `{{ .chezmoi.homeDir }}` substitutions and Bluemind/marketplace cruft stripped |
| `settings.local.json` | Per-project permission allowlist, mode 0644 |
| `executable_hooks/executable_branch-context-env.sh` | Shell hook helper, mode 0755 |
| `executable_hooks/executable_ssh-agent-env.sh` | Shell hook helper, mode 0755 |
| `executable_scripts/executable_statusline.sh` | Statusline helper, mode 0755 |
| `executable_scripts/claude-notify/executable_claude-notify.sh` | Notify hook script, mode 0755 |
| `executable_scripts/claude-notify/README.txt` | Notify README, mode 0644 |
| `executable_scripts/claude-notify/sounds/*.wav` | Notify sound files (7 files), mode 0644 |
| `skills/{mr-queue,open-in-vim,review-tests,rich-copy,slickdoc,writing-requirements}/...` | 6 user-authored skills, recursive copy |
| `commands/grill-me.md` | User-authored slash command |

Files modified in the live `~/.claude/`:

| Path | Change |
|---|---|
| `~/.claude/agents/bluemind-*.md` (4) | Delete |
| `~/.claude/commands/bluemind-*.md` (3) | Delete |
| `~/.claude/agents/jira-writer.md` | Delete |
| `~/.claude/rules/bluemind-signals.md` | Delete |
| `~/.claude/skills/fix-mr-comments-local` | Delete (broken symlink) |
| `~/.claude/skills/todo` | Delete (symlink to deprecated mi-todos skill) |
| `~/.claude/skills/{jira-writing,psql-query,writing-requirements-workspace}` | Leave on this machine (work skills); not in dotfiles |
| `~/.claude/CLAUDE.md` | Overwritten by `chezmoi apply` with trimmed version |
| `~/.claude/settings.json` | Overwritten by `chezmoi apply` with trimmed/templated version |

Note: directories under `executable_hooks/` / `executable_scripts/` only need a single `executable_` prefix on the directory name to apply 0755 mode to that dir's contained scripts. Chezmoi inherits modes per-file; the per-script `executable_` prefix is what marks the script itself as 0755. The directory-name `executable_` prefix here is convention to make intent visible; chezmoi accepts it without effect on directories. If unsure, follow the per-file rule: only files actually needing 0755 get the prefix.

---

## Task 1: Stage clean CLAUDE.md

**Files:**
- Create: `~/projects/dotfiles/dot_claude/CLAUDE.md`
- Source: `~/.claude/CLAUDE.md` (lines 1-8 and 42-end; drop the Bluemind block on lines 9-41)

- [ ] **Step 1.1: Read current CLAUDE.md to confirm line numbers of Bluemind block**

Run:
```bash
grep -n 'BLUEMIND:' ~/.claude/CLAUDE.md
```
Expected: prints two lines, e.g. `9:<!-- BLUEMIND:START -->` and `41:<!-- BLUEMIND:END -->`. If the line numbers differ, use the actual numbers in step 1.2.

- [ ] **Step 1.2: Write trimmed CLAUDE.md into dotfiles source**

Run (substitute START/END line numbers from step 1.1 if different):
```bash
awk 'NR<9 || NR>41' ~/.claude/CLAUDE.md > ~/projects/dotfiles/dot_claude/CLAUDE.md
```
Expected: file is created. Verify length shrunk:
```bash
wc -l ~/.claude/CLAUDE.md ~/projects/dotfiles/dot_claude/CLAUDE.md
```
Expected: the dotfiles copy has ~33 fewer lines than the live file.

- [ ] **Step 1.3: Verify no Bluemind references remain**

Run:
```bash
grep -in -E '\b(bluemind|bluestaq|udl)\b' ~/projects/dotfiles/dot_claude/CLAUDE.md && echo "FAIL: hits found" || echo "OK"
```
Expected: prints `OK`. Any output before `OK` is a failure.

---

## Task 2: Stage settings.local.json (verbatim copy)

**Files:**
- Create: `~/projects/dotfiles/dot_claude/settings.local.json`
- Source: `~/.claude/settings.local.json`

- [ ] **Step 2.1: Copy file as-is**

Run:
```bash
cp ~/.claude/settings.local.json ~/projects/dotfiles/dot_claude/settings.local.json
```
Expected: silent success.

- [ ] **Step 2.2: Verify content matches**

Run:
```bash
diff ~/.claude/settings.local.json ~/projects/dotfiles/dot_claude/settings.local.json && echo "OK"
```
Expected: prints `OK` with no diff output.

---

## Task 3: Build templated settings.json

**Files:**
- Create: `~/projects/dotfiles/dot_claude/private_settings.json.tmpl`
- Source: `~/.claude/settings.json`

The transform: drop Bluemind hooks, drop `extraKnownMarketplaces`, drop non-official `enabledPlugins`, substitute `/home/micah` with `{{ .chezmoi.homeDir }}`.

- [ ] **Step 3.1: Build cleaned JSON with python3**

Run (heredoc preserves quoting cleanly):
```bash
python3 - <<'PY'
import json, pathlib, re

src = pathlib.Path.home() / '.claude' / 'settings.json'
dst = pathlib.Path.home() / 'projects' / 'dotfiles' / 'dot_claude' / 'private_settings.json.tmpl'

data = json.loads(src.read_text())

# Strip Bluemind hooks. Bluemind hooks have a "command" whose string contains
# "bluemind/bin/bluemind", match on substring.
def is_bluemind(h):
    return any('bluemind/bin/bluemind' in step.get('command', '') for step in h.get('hooks', []))

for event in ('Stop', 'SessionEnd', 'PostToolUse'):
    if event in data.get('hooks', {}):
        data['hooks'][event] = [h for h in data['hooks'][event] if not is_bluemind(h)]
        if not data['hooks'][event]:
            del data['hooks'][event]

# Drop extraKnownMarketplaces entirely.
data.pop('extraKnownMarketplaces', None)

# Drop non-claude-plugins-official enabledPlugins.
if 'enabledPlugins' in data:
    data['enabledPlugins'] = {
        k: v for k, v in data['enabledPlugins'].items()
        if k.endswith('@claude-plugins-official')
    }

# Serialize. Use indent=2 to match Claude's own settings.json style.
text = json.dumps(data, indent=2)

# Substitute /home/micah with {{ .chezmoi.homeDir }} ONLY in path-like positions
# (i.e., when followed by '/'). This avoids false hits in any random string.
text = text.replace('/home/micah/', '{{ .chezmoi.homeDir }}/')

dst.write_text(text + '\n')
print(f'wrote {dst} ({len(text)} chars)')
PY
```
Expected: prints a `wrote ...` line. No exceptions.

- [ ] **Step 3.2: Verify no Bluemind / marketplace / hardcoded path leakage**

Run:
```bash
f=~/projects/dotfiles/dot_claude/private_settings.json.tmpl
echo "=== bluemind/bluestaq hits ==="
grep -nE '\b(bluemind|bluestaq)\b' "$f" && echo "FAIL" || echo "OK"
echo "=== /home/micah hits (raw) ==="
grep -n '/home/micah' "$f" && echo "FAIL" || echo "OK"
echo "=== extraKnownMarketplaces ==="
grep -n 'extraKnownMarketplaces' "$f" && echo "FAIL" || echo "OK"
echo "=== templated paths ==="
grep -c 'chezmoi.homeDir' "$f"
```
Expected: three `OK`s and a `templated paths` count of 3 or more (one for each surviving hook command + statusLine.command).

- [ ] **Step 3.3: Verify template renders to valid JSON**

Run:
```bash
chezmoi cat ~/.claude/settings.json | jq -e . > /dev/null && echo "OK"
```
Expected: prints `OK`. If jq errors, the template is malformed (e.g. a stray `}` near a substitution).

- [ ] **Step 3.4: Inspect the rendered output for sanity**

Run:
```bash
chezmoi cat ~/.claude/settings.json | jq '{hookEvents: (.hooks | keys), plugins: .enabledPlugins, hasMarketplaces: (has("extraKnownMarketplaces"))}'
```
Expected output approximately:
```json
{
  "hookEvents": ["Notification", "Stop"],
  "plugins": {
    "superpowers@claude-plugins-official": true,
    "ralph-loop@claude-plugins-official": false,
    "playwright@claude-plugins-official": true,
    "frontend-design@claude-plugins-official": true,
    "skill-creator@claude-plugins-official": true
  },
  "hasMarketplaces": false
}
```
The `PostToolUse` and `SessionEnd` events should be gone. `Stop` and `Notification` should still each contain a single hook running `claude-notify.sh`.

---

## Task 4: Stage hooks/ directory

**Files:**
- Create: `~/projects/dotfiles/dot_claude/executable_hooks/executable_branch-context-env.sh`
- Create: `~/projects/dotfiles/dot_claude/executable_hooks/executable_ssh-agent-env.sh`

- [ ] **Step 4.1: Create directory and copy files**

Run:
```bash
mkdir -p ~/projects/dotfiles/dot_claude/executable_hooks
cp ~/.claude/hooks/branch-context-env.sh ~/projects/dotfiles/dot_claude/executable_hooks/executable_branch-context-env.sh
cp ~/.claude/hooks/ssh-agent-env.sh ~/projects/dotfiles/dot_claude/executable_hooks/executable_ssh-agent-env.sh
```
Expected: silent success.

- [ ] **Step 4.2: Verify chezmoi resolves correct target paths**

Run:
```bash
chezmoi target-path ~/projects/dotfiles/dot_claude/executable_hooks/executable_branch-context-env.sh
chezmoi target-path ~/projects/dotfiles/dot_claude/executable_hooks/executable_ssh-agent-env.sh
```
Expected: each prints `/home/micah/.claude/hooks/<basename>.sh`.

---

## Task 5: Stage scripts/ directory (statusline + claude-notify + sounds)

**Files:**
- Create: `~/projects/dotfiles/dot_claude/executable_scripts/executable_statusline.sh`
- Create: `~/projects/dotfiles/dot_claude/executable_scripts/claude-notify/executable_claude-notify.sh`
- Create: `~/projects/dotfiles/dot_claude/executable_scripts/claude-notify/README.txt`
- Create: `~/projects/dotfiles/dot_claude/executable_scripts/claude-notify/sounds/*.wav` (7 files)

- [ ] **Step 5.1: Stage scripts/statusline.sh**

Run:
```bash
mkdir -p ~/projects/dotfiles/dot_claude/executable_scripts
cp ~/.claude/scripts/statusline.sh ~/projects/dotfiles/dot_claude/executable_scripts/executable_statusline.sh
```

- [ ] **Step 5.2: Stage scripts/claude-notify/ contents**

Run:
```bash
mkdir -p ~/projects/dotfiles/dot_claude/executable_scripts/claude-notify
cp ~/.claude/scripts/claude-notify/claude-notify.sh ~/projects/dotfiles/dot_claude/executable_scripts/claude-notify/executable_claude-notify.sh
cp ~/.claude/scripts/claude-notify/README.txt ~/projects/dotfiles/dot_claude/executable_scripts/claude-notify/README.txt
```

- [ ] **Step 5.3: Stage sounds/ (exclude WSL Zone.Identifier cruft)**

Run:
```bash
mkdir -p ~/projects/dotfiles/dot_claude/executable_scripts/claude-notify/sounds
for f in ~/.claude/scripts/claude-notify/sounds/*.wav; do
  case "$f" in
    *:Zone.Identifier) ;;
    *) cp "$f" ~/projects/dotfiles/dot_claude/executable_scripts/claude-notify/sounds/ ;;
  esac
done
ls ~/projects/dotfiles/dot_claude/executable_scripts/claude-notify/sounds/
```
Expected: lists 7 .wav files (alert-tone, bell, boing, coin, laser, ping, quack, soft-chime), no `:Zone.Identifier` entries. (8 wavs total in some counts.)

- [ ] **Step 5.4: Verify chezmoi-resolved paths**

Run:
```bash
chezmoi target-path ~/projects/dotfiles/dot_claude/executable_scripts/claude-notify/executable_claude-notify.sh
```
Expected: prints `/home/micah/.claude/scripts/claude-notify/claude-notify.sh`.

---

## Task 6: Stage 6 user skills

**Files:**
- Create: `~/projects/dotfiles/dot_claude/skills/{mr-queue,open-in-vim,review-tests,rich-copy,slickdoc,writing-requirements}/...`

- [ ] **Step 6.1: Copy each skill directory recursively**

Run:
```bash
mkdir -p ~/projects/dotfiles/dot_claude/skills
for s in mr-queue open-in-vim review-tests rich-copy slickdoc writing-requirements; do
  if [ -L ~/.claude/skills/"$s" ]; then
    echo "ERROR: $s is a symlink, manual review needed"
    exit 1
  fi
  cp -r ~/.claude/skills/"$s" ~/projects/dotfiles/dot_claude/skills/"$s"
done
ls ~/projects/dotfiles/dot_claude/skills/
```
Expected: lists 6 directory names. No `ERROR`. (None of these six are symlinks per pre-plan investigation, but the guard catches future drift.)

- [ ] **Step 6.2: Verify total size is reasonable**

Run:
```bash
du -sh ~/projects/dotfiles/dot_claude/skills/
```
Expected: roughly 160-200 KB.

---

## Task 7: Stage commands/grill-me.md

- [ ] **Step 7.1: Copy command**

Run:
```bash
mkdir -p ~/projects/dotfiles/dot_claude/commands
cp ~/.claude/commands/grill-me.md ~/projects/dotfiles/dot_claude/commands/grill-me.md
```

- [ ] **Step 7.2: Verify**

Run:
```bash
diff ~/.claude/commands/grill-me.md ~/projects/dotfiles/dot_claude/commands/grill-me.md && echo "OK"
```
Expected: `OK`.

---

## Task 8: Inspect chezmoi diff before any apply

This is the critical safety checkpoint. `chezmoi diff` shows what `chezmoi apply` would change. The only changes to the live system should be:
- `~/.claude/settings.json`: Bluemind hooks removed, `extraKnownMarketplaces` removed, non-official plugins removed.
- `~/.claude/CLAUDE.md`: Bluemind block removed.
- Everything else (hooks/scripts/skills/commands): zero diff because the source is byte-identical to live.

- [ ] **Step 8.1: Run chezmoi diff**

Run:
```bash
chezmoi diff | tee /tmp/chezmoi-diff-claude-migration.patch
```
Expected: diff is contained to:
- `.claude/CLAUDE.md`: lines 9-41 removed
- `.claude/settings.json`: Bluemind Stop hook, SessionEnd hook, PostToolUse hook, `extraKnownMarketplaces` block, and non-official entries inside `enabledPlugins` all removed
- Possibly mode changes on a few files (the `executable_` prefix making them 0755 if they weren't already)

- [ ] **Step 8.2: Hand-review the diff**

Read `/tmp/chezmoi-diff-claude-migration.patch`. Look for:
1. **Unexpected file additions or deletions outside `.claude/`.** STOP and investigate.
2. **`.claude/skills/<name>` showing a content change.** Means the source copy diverged from live unexpectedly. Re-run the copy step for that skill.
3. **Any mode change other than 0644→0755 on a script.** Investigate.

If anything in this review is unclear, STOP. Do not proceed to Task 9.

---

## Task 9: Apply chezmoi (destructive step)

This overwrites the live `~/.claude/CLAUDE.md` and `~/.claude/settings.json` with the cleaned versions. Bluemind hooks stop firing after this. Notify hooks continue working.

- [ ] **Step 9.1: Apply**

Run:
```bash
chezmoi apply -v
```
Expected: prints actions for each managed file. No errors.

- [ ] **Step 9.2: Verify live settings.json is valid JSON and contains expected events**

Run:
```bash
jq '{hookEvents: (.hooks | keys), pluginCount: (.enabledPlugins | length), hasMarketplaces: has("extraKnownMarketplaces")}' ~/.claude/settings.json
```
Expected:
```json
{
  "hookEvents": ["Notification", "Stop"],
  "pluginCount": 5,
  "hasMarketplaces": false
}
```

- [ ] **Step 9.3: Confirm CLAUDE.md is trimmed**

Run:
```bash
grep -c 'BLUEMIND' ~/.claude/CLAUDE.md
```
Expected: prints `0`.

---

## Task 10: Smoke-test the notify hook end-to-end

This validates the templated path actually resolved correctly and the toast still fires.

- [ ] **Step 10.1: Pipe a synthesized Notification payload to the (now-managed) notify script**

Run (from inside tmux):
```bash
echo '{"hook_event_name":"Notification","notification_type":"permission_prompt","message":"Smoke test","cwd":"/home/micah/projects/dotfiles","session_id":"x"}' | CLAUDE_NOTIFY_SOUND=ping bash ~/.claude/scripts/claude-notify/claude-notify.sh
echo "exit=$?"
```
Expected: `exit=0`. A toast appears in Windows with title `Claude - Permission Needed` and body `[<your-tmux-session-name>] Smoke test`. A `ping` sound plays.

If the toast does not appear or path lookup fails, the chezmoi apply did not produce the expected file at `~/.claude/scripts/claude-notify/claude-notify.sh`. Run:
```bash
ls -la ~/.claude/scripts/claude-notify/claude-notify.sh
```
and confirm the file exists with mode 0755.

---

## Task 11: Clean up live ~/.claude (drop Bluemind agents/commands/rules and broken/dropped symlinks)

These items are dropped from the user's working setup, not just from dotfiles. After this task, opening Claude no longer surfaces Bluemind agents/commands or the dead skills.

- [ ] **Step 11.1: Delete Bluemind agents**

Run:
```bash
rm -v ~/.claude/agents/bluemind-capture.md ~/.claude/agents/bluemind-decompose.md ~/.claude/agents/bluemind-retrieve.md ~/.claude/agents/bluemind-review.md
```
Expected: prints 4 `removed` lines.

- [ ] **Step 11.2: Delete the non-Bluemind agent the user opted to drop**

Run:
```bash
rm -v ~/.claude/agents/jira-writer.md
```
Expected: prints 1 `removed` line.

- [ ] **Step 11.3: Delete Bluemind commands**

Run:
```bash
rm -v ~/.claude/commands/bluemind-migrate.md ~/.claude/commands/bluemind-review.md ~/.claude/commands/bluemind-update.md
```
Expected: prints 3 `removed` lines.

- [ ] **Step 11.4: Delete Bluemind rules**

Run:
```bash
rm -v ~/.claude/rules/bluemind-signals.md
rmdir ~/.claude/rules 2>/dev/null || true
```
Expected: prints 1 `removed` line. The `rmdir` succeeds silently if rules/ is now empty, fails silently otherwise.

- [ ] **Step 11.5: Delete dropped/broken skill symlinks**

Run:
```bash
rm -v ~/.claude/skills/fix-mr-comments-local ~/.claude/skills/todo
```
Expected: prints 2 `removed` lines. (These are symlinks, so the rm targets the link itself, not the upstream `mi-todos` repo.)

- [ ] **Step 11.6: Confirm ~/.claude/agents is now empty**

Run:
```bash
ls -la ~/.claude/agents
```
Expected: only `.` and `..`. Directory exists but is empty. No need to delete it; Claude is fine with an empty agents dir.

---

## Task 12: Update .gitignore in dotfiles repo if needed

`dot_claude/` already exists in the dotfiles repo with one file (`statusline-command.sh`). The repo has a small `.gitignore`. Confirm nothing in the new tree is ignored.

- [ ] **Step 12.1: Check git status sees all new files**

Run:
```bash
cd ~/projects/dotfiles && git status --short
```
Expected: lists all the new files under `dot_claude/` as untracked (`??`). If any are missing, check `.gitignore` for an over-broad rule.

- [ ] **Step 12.2: Confirm no ignored files in dot_claude/**

Run:
```bash
cd ~/projects/dotfiles && git check-ignore -v dot_claude/**/* 2>/dev/null
```
Expected: no output. (Output here means some file is excluded; investigate.)

---

## Task 13: Commit the migration

Two logical commits keep history clean: the additions to the dotfiles repo, then a no-op marker if any post-apply state needs recording. In practice one commit is fine since the live cleanup is on a different machine resource (no commit needed for the rm operations on `~/.claude/`).

- [ ] **Step 13.1: Stage and commit**

Run:
```bash
cd ~/projects/dotfiles
git add dot_claude/
git status
```
Expected: shows the new files staged.

```bash
git commit -m "$(cat <<'EOF'
feat(claude): migrate ~/.claude config into chezmoi-managed dot_claude

- CLAUDE.md (Bluemind section trimmed)
- private_settings.json.tmpl (Bluemind hooks + custom marketplaces stripped, paths templated via {{ .chezmoi.homeDir }})
- settings.local.json (verbatim)
- hooks/, scripts/, scripts/claude-notify/ (with sounds, no WSL Zone.Identifier files)
- 6 user-authored skills: mr-queue, open-in-vim, review-tests, rich-copy, slickdoc, writing-requirements
- commands/grill-me.md

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
git log --oneline -3
```
Expected: new commit at the top of the log.

---

## Self-review checklist (run after writing this plan)

- Every task that produces source files has a verify step before the commit step.
- The destructive task (9) is gated behind an explicit diff inspection (8).
- All file paths are absolute or anchored at `~`.
- No "TODO" or "TBD" markers.
- Types: the JSON-transform python script uses substring match (`'bluemind/bin/bluemind' in step.get('command', '')`) so renames to the Bluemind binary won't break it; verify still matches against the current settings.json.
- Spec coverage: every drop/keep item in the design doc has a corresponding task or step (Bluemind agents → 11.1; Bluemind commands → 11.3; Bluemind rules → 11.4; jira-writer → 11.2; broken/dead symlinks → 11.5; templated paths → 3.1; CLAUDE.md trim → 1.2; settings.json trim → 3.1; 6 skills → 6.1; grill-me → 7.1).

---

## Caveats for the executing agent

1. **Stop if `chezmoi diff` shows unexpected changes in Task 8.2.** Do not run `chezmoi apply` until any unexpected entry is investigated and either explained or fixed in the source.
2. **The python heredoc in Step 3.1 imports `pathlib` and `re` but doesn't use `re`.** That's harmless. Don't trim the import; leave it.
3. **WAV file count:** if `~/.claude/scripts/claude-notify/sounds/` ends up with 7 vs 8 sound files, both are fine. The exact set varies; the verification in Step 5.3 lists whatever is present.
4. **`fix-mr-comments-local` is a broken symlink.** `rm` on a broken symlink succeeds; the verify in Step 11.5 should still print "removed".
