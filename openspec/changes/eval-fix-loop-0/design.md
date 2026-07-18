## Context

tala is a Rust CLI with a local Axum daemon for multi-agent messaging. Sessions are in-memory with broadcast channels for SSE streaming. The reopen race and stream timeout are bugs; the session targeting and name persistence are ergonomic gaps discovered in eval.

## Goals / Non-Goals

**Goals:**
- Fix reopen race by keeping sessions write lock through broadcast
- Fix stream --timeout by passing it through to the SSE endpoint
- Add --session flag to send/wait/recap; auto-select single open session
- Preserve session name when agents reply to named sessions
- Hide unread counts for closed sessions in list output
- Improve start output; add inline message to wait --json

**Non-Goals:**
- Persisting session state to disk (daemon restart loses state)
- Overhauling the broadcast channel architecture
- Rewriting CLI help text beyond targeted clarifications

## Decisions

- **Reopen race fix**: Hold `sessions` write lock through the broadcast send, avoiding the TOCTOU window. Use a clone of the session ID to avoid holding lock during broadcast send. This is simpler than an event log or two-phase approach.
- **Stream timeout**: Pass `timeout_secs` from CLI handler to API, reuse the same `tokio::time::timeout` pattern `listen` already uses. Avoids a new mechanism.
- **Name preservation**: In `add_message`, only set `session.name = Some(sender)` if `session.name` is `None`. This prevents overwriting user-set names.
- **Auto-select**: When no active session and no `--session` flag, if exactly one open session exists, use it. Otherwise error with guidance. Logic in the session resolution helper shared by send/wait/recap.

## Risks / Trade-offs

- [Minor] Auto-select hides a potential multi-session mistake — user might think they're targeting session A when session B is the auto-selected one. Mitigated by always printing the targeted session ID.
- [Minor] Holding write lock during broadcast send increases lock contention. Broadcast send is near-instant so impact is negligible.
