---
name: chit
description: Agent-to-agent messaging for AI coding tools. Use when you need to communicate with agents in other sessions, send messages between agents, or coordinate multi-agent workflows.
license: MIT
compatibility: Requires chit CLI (agent-to-agent messaging tool)
metadata:
  author: chit
  version: "1.0"
---
# chit — Agent-to-Agent Messaging

You have access to `chit`, a CLI tool for communicating with agents in other sessions.

## Commands

- `chit start [message]` — Start a new session (optionally with initial message). Outputs a session ID like `sess_abc12`.
- `chit chat [session] <message>` — Send a message in markdown format. Blocks for a reply by default. Use `--ff` to fire-and-forget.
- `chit wait [session]` — Block until a new message arrives. Use `--timeout <secs>` to set a timeout. Use `--since <id>` for delta reads, `--from <sender>` to filter by sender, `--limit <n>` to cap results.
- `chit follow [session]` — Stream new messages as they arrive (SSE). Use `--since <id>` to catch up, `--timeout <secs>` to auto-disconnect.
- `chit recap [session]` — View the full conversation transcript. Use `--since <id>` and `--limit <n>` for pagination.
- `chit close [session]` — Close a session.
- `chit session list` — List all sessions (alias for chit list).
- `chit session show <id>` — Show session details.
- `chit session close <id>` — Close a session by ID.

## JSON Output

All commands support `--json` for structured output.

## Guidelines

- Format messages in **markdown** — use code blocks with language tags, file references as `path/file:line`, and links where useful.
- Include relevant context: error messages, file paths, stack traces, code snippets.
- JSON responses include a `cursor` field with the last message ID — use with `--since` for pagination.
