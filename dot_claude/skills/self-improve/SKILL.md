---
name: self-improve
description: Use when the user says "self-improve", "what went wrong", "analyze last session", or wants to review a previous Claude Code conversation for improvement opportunities. Analyzes conversation logs to find mistakes, wasted effort, user corrections, and suggests concrete improvements.
---

# Self-Improve

Analyze a previous Claude Code conversation to identify what went wrong and propose concrete improvements.

## How to Run

1. **Identify the target conversation.** Default: the most recent conversation in this project. The user may specify a different project or session.

2. **Find the conversation log.** Logs live at:
   ```
   ~/.claude/projects/{encoded-project-path}/{uuid}.jsonl
   ```
   - Project paths are URL-encoded: `/Users/foo/Projects/bar` becomes `-Users-foo-Projects-bar`
   - Sort by modification time to find the most recent: `ls -lt ~/.claude/projects/{path}/*.jsonl | head -5`
   - If the user says "last session" or "previous chat", pick the second-most-recent file (the current conversation is the most recent)

3. **Extract and analyze.** Dispatch a subagent to read the JSONL and produce a structured analysis. The JSONL format:
   - Each line is a JSON object with `type` field: `user`, `assistant`, `progress`, `file-history-snapshot`
   - User messages: `message.content` contains the user's text (string or content array)
   - Assistant messages: `message.content` is an array of `thinking`, `text`, and `tool_use` blocks
   - Tool results: nested under `toolUseResult` or in `message.content` as `tool_result` objects
   - Chain messages via `uuid` / `parentUuid` fields

   **What to look for:**
   - **User corrections** — messages where the user says "no", "not that", "wrong", "stop", "undo", "revert", or redirects the approach
   - **Repeated attempts** — the same tool called multiple times with similar inputs (spinning wheels)
   - **Errors and failures** — tool results containing error messages, failed commands, test failures
   - **Wasted effort** — large blocks of work that got discarded or replaced
   - **Missing context** — times the agent asked questions that could have been answered by memory, CLAUDE.md, or codebase exploration
   - **Scope creep** — agent doing more than asked, adding unrequested features or refactors

4. **Categorize findings** into these improvement types:

   | Category | Fix Location |
   |----------|-------------|
   | Missing knowledge about user preferences | Memory file (feedback type) |
   | Missing project context | Memory file (project type) or CLAUDE.md |
   | Repeated pattern that should be automated | Hook in settings.json |
   | Reusable workflow that was done manually | New skill |
   | Wrong default behavior | CLAUDE.md instruction |
   | Tool/API misunderstanding | Memory file (reference type) |

5. **Present findings** as a structured report:

   ```
   ## Session Analysis: {project} — {date}

   ### Issues Found
   1. [Issue description] — [category] — [severity: high/medium/low]
      Evidence: [quote or summary from log]
      Proposed fix: [specific action]

   ### Proposed Improvements
   - [ ] [Specific actionable item with exact file and content to add/change]
   ```

6. **Ask before applying.** Present the report and let the user choose which improvements to apply. Then implement the approved changes (update memory files, CLAUDE.md, settings.json, or create new skills as appropriate).

## Important

- NEVER include raw JSONL or full conversation dumps in the output — summarize and quote selectively
- Focus on **patterns**, not one-off mistakes — a single typo isn't worth a memory entry
- Be honest about failures but constructive — the goal is improvement, not blame
- If the conversation was mostly successful, say so — don't invent problems
- Large JSONL files (>1MB) should be searched with grep first, then targeted reads on relevant sections
