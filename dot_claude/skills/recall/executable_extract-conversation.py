#!/usr/bin/env python3
"""Extract readable text from Claude Code conversation JSONL files.

Outputs grep-friendly plaintext with role/timestamp markers.
Strips thinking blocks, tool_use internals, and progress events.

Usage:
    extract-conversation.py <file.jsonl>                    # full conversation
    extract-conversation.py <file.jsonl> --role user        # user messages only
    extract-conversation.py <file.jsonl> --role assistant   # assistant messages only
    extract-conversation.py <file.jsonl> --grep "keyword"   # filter lines containing keyword
    extract-conversation.py <file.jsonl> --after 2026-03-28 # messages after date
    extract-conversation.py <file.jsonl> --before 2026-03-29
    extract-conversation.py <file.jsonl> --summary          # just first 200 chars per message

Output format:
    === USER [2026-03-28T16:23:35Z] ===
    The user's message text here...

    === ASSISTANT [2026-03-28T16:23:40Z] ===
    The assistant's response text here...
"""

import argparse
import json
import sys
from datetime import datetime


def extract_text_from_content(content):
    """Extract readable text from message content (string or array)."""
    if isinstance(content, str):
        return content.strip()

    if isinstance(content, list):
        parts = []
        for block in content:
            if isinstance(block, dict):
                if block.get("type") == "text":
                    parts.append(block["text"].strip())
                elif block.get("type") == "tool_result":
                    # Include tool results briefly
                    result_content = block.get("content", "")
                    if isinstance(result_content, str) and result_content:
                        # Truncate long tool results
                        if len(result_content) > 500:
                            parts.append(f"[tool_result: {result_content[:500]}...]")
                        else:
                            parts.append(f"[tool_result: {result_content}]")
                # Skip thinking, tool_use blocks
        return "\n".join(parts)

    return ""


def parse_timestamp(ts):
    """Parse timestamp from either ISO string or epoch millis."""
    if isinstance(ts, str):
        try:
            return datetime.fromisoformat(ts.replace("Z", "+00:00"))
        except (ValueError, TypeError):
            return None
    elif isinstance(ts, (int, float)):
        try:
            return datetime.fromtimestamp(ts / 1000)
        except (ValueError, OSError):
            return None
    return None


def main():
    parser = argparse.ArgumentParser(description="Extract text from Claude Code conversation JSONL")
    parser.add_argument("file", help="Path to .jsonl conversation file")
    parser.add_argument("--role", choices=["user", "assistant"], help="Filter by role")
    parser.add_argument("--grep", help="Filter output lines containing this text (case-insensitive)")
    parser.add_argument("--after", help="Only messages after this date (YYYY-MM-DD)")
    parser.add_argument("--before", help="Only messages before this date (YYYY-MM-DD)")
    parser.add_argument("--summary", action="store_true", help="Truncate messages to first 200 chars")
    parser.add_argument("--no-tool-results", action="store_true", help="Exclude tool result content")
    args = parser.parse_args()

    after_dt = datetime.fromisoformat(args.after) if args.after else None
    before_dt = datetime.fromisoformat(args.before) if args.before else None

    with open(args.file) as f:
        for line in f:
            line = line.strip()
            if not line:
                continue

            try:
                obj = json.loads(line)
            except json.JSONDecodeError:
                continue

            msg_type = obj.get("type")
            if msg_type not in ("user", "assistant"):
                continue

            message = obj.get("message", {})
            role = message.get("role", msg_type)

            # Role filter
            if args.role and role != args.role:
                continue

            # Timestamp
            ts_raw = obj.get("timestamp", "")
            ts = parse_timestamp(ts_raw)

            # Date filters
            if ts:
                ts_naive = ts.replace(tzinfo=None) if ts.tzinfo else ts
                if after_dt and ts_naive < after_dt:
                    continue
                if before_dt and ts_naive > before_dt:
                    continue

            # Extract text
            content = message.get("content", "")
            text = extract_text_from_content(content)

            if not text:
                continue

            # Skip pure tool results if requested
            if args.no_tool_results and text.startswith("[tool_result:"):
                continue

            # Summary mode
            if args.summary and len(text) > 200:
                text = text[:200] + "..."

            # Format timestamp
            ts_str = ts.strftime("%Y-%m-%dT%H:%M:%SZ") if ts else "unknown"

            # Build output block
            header = f"=== {role.upper()} [{ts_str}] ==="
            block = f"{header}\n{text}\n"

            # Grep filter
            if args.grep:
                if args.grep.lower() not in block.lower():
                    continue

            print(block)


if __name__ == "__main__":
    main()
