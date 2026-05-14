---
name: rich-copy
description: |
  Use when the user says "/rich-copy" or asks to copy a message for Teams,
  format something for Teams, prepare a rich text message, or copy formatted
  content to clipboard. Converts drafted messages into rich HTML and copies
  to the Windows clipboard so it pastes with formatting into Teams, Outlook, etc.
---

# Rich Copy to Clipboard

Converts a drafted message into rich HTML and copies it to the
Windows clipboard using `html-to-clipboard`. Works with Teams, Outlook, and
any application that accepts rich text paste.

## When to Use

When the user has drafted or finalized a message in the conversation and wants to
paste it into Microsoft Teams with proper formatting (bold, bullets, numbered lists,
spacing).

## How It Works

1. Take the most recently drafted message from the conversation
2. Convert it to simple HTML that Teams renders well
3. Pipe it through `~/.local/bin/html-to-clipboard`

## HTML Formatting Rules for Teams

Teams has limited HTML support. Follow these rules:

- Use `<p>` for paragraphs
- Use `<br>` between sections for visual spacing (Teams collapses margin between `<p>` tags)
- Use `<b>` for bold (not `<strong>`)
- Use `<i>` for italic (not `<em>`)
- Use `<ul><li>` for bullet lists
- Use `<ol><li>` for numbered lists
- Do NOT use `<h1>`-`<h6>` (Teams ignores them). Use `<b>` on a `<p>` for headings.
- Do NOT use markdown syntax. Convert everything to HTML tags.
- Do NOT use `<table>` (Teams renders them poorly in chat)
- Do NOT include `<html>`, `<body>`, or `<head>` tags (the clipboard tool adds these)
- Keep it simple. If in doubt, use `<p>`, `<b>`, `<ul>`, `<ol>`, `<li>`, `<br>`.

## Execution

Pipe the HTML directly to html-to-clipboard via Bash:

```bash
cat <<'EOF' | html-to-clipboard
<p>First paragraph</p>
<br>
<p><b>Section heading</b></p>
<br>
<ul>
<li>Bullet one</li>
<li>Bullet two</li>
</ul>
EOF
```

After running, tell the user: "Copied to clipboard. Paste into Teams with Ctrl+V."

## Common Patterns

**Paragraph spacing**: Always put `<br>` between paragraphs and before/after lists
for visual breathing room.

**Bold headings**: Use `<p><b>Heading text</b></p>` instead of `<h2>`.

**Nested content**: Teams handles one level of nesting at most. Avoid deeply nested lists.
