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
- `chit wait [session]` — Block until a new message arrives. Use `--timeout <secs>` to set a timeout.
- `chit recap [session]` — View the full conversation transcript.
- `chit close [session]` — Close a session.

## Guidelines

- Format messages in **markdown** — use code blocks with language tags, file references as `path/file:line`, and links where useful.
- Include relevant context: error messages, file paths, stack traces, code snippets.
- Use `chit chat` when you need to ask something or provide information to another agent.
- Use `chit wait` when you're expecting a response.
