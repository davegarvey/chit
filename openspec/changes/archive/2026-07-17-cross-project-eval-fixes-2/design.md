## Context

The cross-project eval revealed four issues in chit's session lifecycle and message input:

1. **`chit send` errors with no active session** — When zero sessions exist, `cmd_send` (cli.rs:727-748) exits with `"No active sessions. Start one with \`chit start\`"`. This breaks the core flow for agents who expect `send` to be self-contained. Branch B (cli.rs:697-726) already auto-creates when the active session is stale — the same pattern should apply when no sessions exist at all.

2. **No safe way to send arbitrary text** — Shell escaping (backticks, braces) causes `zsh: parse error` when agents generate shell commands. Chit already supports piped stdin implicitly (cli.rs:669-685) via `!is_terminal()` detection, but there's no explicit `--stdin` flag. Agents need a clear opt-in mechanism.

3. **Daemon idle timeout kills sessions** — The daemon (daemon.rs:22-59) shuts down after 600s of inactivity (all sessions closed or idle). Since sessions are in-memory, this destroys all state. Agents collaborating slowly or waiting for human input hit this.

4. **Session rename silently overwrites** — `rename_session` (store.rs:201-209) unconditionally overwrites the name. Two agents renaming the same session leads to last-write-wins with no warning.

## Goals / Non-Goals

**Goals:**
- `chit send` auto-creates a session when none exists and no active session is set
- Add explicit `--stdin` flag to `chit send` for safe message input
- Daemon idle timeout does not destroy sessions mid-collaboration (increase default, or add per-session keepalive)
- `chit session rename` warns or rejects when the session already has a name

**Non-Goals:**
- Persisting sessions to disk (out of scope)
- Per-session TTL or expiry (out of scope)
- Full daemon lifecycle rewrite (minimal change)

## Decisions

### 1. `chit send` auto-create on no sessions
- **Approach**: In Branch C (cli.rs:727-748), when `active.is_empty()`, instead of failing, call `POST /api/sessions` to auto-create, write the new session ID to `.chit/active-session`, then send the message.
- **Rationale**: Matches existing behavior in Branch B (stale active session → auto-create). Consistent UX. Minimal code change.
- **Alternatives considered**: Requiring `chit start` first (current behavior — rejected because it's friction for agents).

### 2. `chit send --stdin` flag
- **Approach**: Add a `--stdin` flag that, when set, reads message content from stdin (ignoring the positional message arg if also provided). Reuses the existing blocking-read pattern (cli.rs:670-679) but without the 500ms timeout — block until EOF.
- **Rationale**: Explicit flag avoids ambiguity and shell escaping. Agents can pipe content without worrying about shell interpretation. The existing implicit stdin detection is left in place as a fallback.
- **Alternatives considered**: Only implicit stdin (current — agents can't opt in explicitly). `--raw` flag (same concept, `--stdin` is more descriptive).

### 3. Daemon idle timeout
- **Approach**: Increase default idle timeout from 600s to 3600s (1 hour). Add a per-session "last active message" timestamp check — if any session has received messages recently, consider the daemon "active" regardless of session count.
- **Rationale**: 10 minutes is too short for agent collaboration (agents may be thinking, generating, or waiting for human input). 1 hour is more forgiving. The per-session check prevents the daemon from shutting down while sessions have recent activity.
- **Alternatives considered**: Removing idle timeout entirely (risks daemon bloat on forgotten setups). Per-session TTL (complex, over-engineered).

### 4. Session rename conflict detection
- **Approach**: `rename_session` checks if the session already has a `name` set. If so, return a `409 Conflict` with the existing name and the requested name. The CLI then prints a warning and rejects the rename. Add a `--force` flag to override.
- **Rationale**: Prevents silent overwrite. `--force` allows intentional renames.
- **Alternatives considered**: First-write-wins only (too restrictive — user should be able to rename). No change (current — silent overwrite, rejected).

## Risks / Trade-offs

- **Auto-create on send may surprise users** who prefer explicit session creation → Mitigation: print "→ Created session <id>" (same pattern as existing auto-create notification).
- **Stdin with no pipe may hang** → Mitigation: `--stdin` still falls back to the error path if stdin is a terminal (detect with `is_terminal()`).
- **Increasing idle timeout** keeps daemon running longer → Mitigation: still configurable via `idle_timeout` in config. Default is just more generous.
- **Rename conflict breaks scripts** that blindly rename → Mitigation: `--force` flag preserves backward compatibility for automation.
