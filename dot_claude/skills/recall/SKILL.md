---
name: recall
description: Use when the user wants to find information from a past Claude Code conversation — "remember when we discussed X", "go back to that session where", "find the conversation about", "what did we decide about", "recall", "look up what we talked about". Searches conversation logs across projects and sessions.
---

# Recall

Search past Claude Code conversations to find and extract specific information.

## How to Run

1. **Clarify the search target.** Ask if not obvious:
   - Which project? (or search all)
   - Rough timeframe?
   - What kind of information? (decision, code pattern, discussion, error fix)

2. **Search strategy — narrow to broad:**

   **Step 1: History index (fast).** Search `~/.claude/history.jsonl` for matching keywords. Each line has:
   ```json
   {"display": "user prompt text", "timestamp": 1761102703073, "project": "/path/to/project", "sessionId": "uuid"}
   ```
   Use grep on this file to find candidate sessions by keyword. Extract the `sessionId` values.

   **Step 2: Find conversation files.** Map sessions to JSONL files:
   ```
   ~/.claude/projects/{encoded-project-path}/{uuid}.jsonl
   ```
   - Project paths are URL-encoded: `/Users/foo/Projects/bar` → `-Users-foo-Projects-bar`
   - If you have a `sessionId` from history, grep for it in the JSONL filenames or content
   - If searching by project only, list files sorted by date: `ls -lt ~/.claude/projects/{path}/*.jsonl`

   **Step 3: Extract readable text.** Use the extraction tool to convert JSONL to grep-friendly plaintext:
   ```bash
   # Full conversation, user messages only
   python3 ~/.claude/skills/recall/extract-conversation.py <file.jsonl> --role user

   # Filter by keyword
   python3 ~/.claude/skills/recall/extract-conversation.py <file.jsonl> --grep "keyword"

   # Summary mode (first 200 chars per message)
   python3 ~/.claude/skills/recall/extract-conversation.py <file.jsonl> --role user --summary

   # Date range
   python3 ~/.claude/skills/recall/extract-conversation.py <file.jsonl> --after 2026-03-28

   # Then pipe to ripgrep for multi-keyword search
   python3 ~/.claude/skills/recall/extract-conversation.py <file.jsonl> --role user | rg -i "vision|scope|expand"
   ```
   The tool strips thinking blocks, tool_use internals, and progress events. Output is clean plaintext with `=== ROLE [timestamp] ===` headers.

3. **Extract and synthesize.** Read the extracted text directly or dispatch a subagent for large conversations. Focus on:
   - Synthesizing decisions, conclusions, and context
   - Noting dates and session IDs for re-reference
   - Quoting key passages directly

4. **Present findings:**
   ```
   ## Found: {topic}
   **Project:** {project name}
   **Date:** {date}
   **Session:** {uuid} (for re-reference)

   ### Summary
   {Synthesized findings — decisions made, context discussed, conclusions reached}

   ### Key Quotes
   > {Direct quotes from the conversation where relevant}

   ### Suggested Actions
   - {What to do with this information, if applicable}
   ```

5. **Follow up.** Ask the user if they want to:
   - Save key findings to memory for future reference
   - Apply the information to current work
   - Search for additional related conversations

## Tips for Efficient Search

- **Large files (>1MB):** Grep first, then read targeted line ranges. Don't read whole files.
- **Multiple candidate sessions:** Present the top 3-5 matches from history and let the user pick before deep-diving.
- **Subagent messages:** Conversation dirs may have `subagents/` subdirs with `agent-*.jsonl` files — these contain subagent work from that session. Search these too if the main conversation doesn't have what you need.
- **Cross-project search:** If project is unknown, grep across all project dirs: `grep -l "keyword" ~/.claude/projects/*/*.jsonl`
