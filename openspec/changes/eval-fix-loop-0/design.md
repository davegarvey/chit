## Context

Tala uses a file-based cursor system via `.tala/active-session` for tracking the active session per project directory. The `daemon.json` file stores the daemon's host/port. Currently, connection failures produce raw `reqwest` errors (e.g., "connection refused") without indicating which path or `TALA_HOME` value was used. Session listings show total message counts but no new/unread differentiation. There is no lightweight non-blocking command for polling new messages — agents must use `tala wait` (blocking long-poll) or `tala recap` (full transcript).

## Goals / Non-Goals

**Goals:**
- Add diagnostic information (path, TALA_HOME) to daemon connection errors
- Add unread counts to `tala list` and `tala status`
- Add active session marker (`*`) to `tala list`
- Add `tala whatsup` command for non-blocking incremental message poll
- Per-project cursor persistence at `.tala/cursor`, shared across `whatsup` and unread tracking

**Non-Goals:**
- Server-side per-agent cursor tracking (keeping it client-side avoids state complexity)
- Push notifications or real-time unread updates
- UI-level changes beyond CLI text/JSON output

## Decisions

1. **Client-side cursor, not server-side**: The cursor file (`.tala/cursor`) is stored per project directory, matching the existing pattern of `.tala/active-session`. Server-side per-agent cursors would require agent identity tracking and more complex state management. The client-side approach is simpler and sufficient for the eval use case. The trade-off is that cursor is per-project, not per-agent-identity.

2. **`tala whatsup` as a new top-level command**: Fits the existing command structure pattern. Alternative considered: adding `--since` to `tala list`. Rejected because `list` shows session metadata, not message content. The `whatsup` name fills the gap between `tala wait` (blocking) and `tala recap` (full history).

3. **Reusing the observe endpoint for `whatsup`**: The existing `/api/observe?since=N` endpoint already returns all messages across all sessions since a cursor. With `timeout_secs=0` the daemon can return immediately. Alternative: creating a dedicated `/api/whats-new` endpoint. Rejected to keep API surface minimal — the observe endpoint is a superset.

4. **Unread counts computed from cursor**: Rather than adding new daemon state, unread counts are computed client-side: total messages per session minus messages up to cursor. The daemon returns `message_count` in `SessionSummary` — the CLI computes `unread_count = message_count - messages_seen_count`. Alternative: daemon computes unread per session using per-project cursors. Rejected for simplicity — client-side computation matches the cursor approach.

## Risks / Trade-offs

- [Cursor staleness] If the cursor file is deleted, all messages become "unread" again → Acceptable; same as first-time behavior
- [Performance for many sessions] `tala whatsup` fetches all messages since cursor across all sessions → Acceptable for typical eval scenarios; if performance becomes an issue, pagination can be added later
- [Cursor shared between whatsup and list] `tala list` updating the cursor could interfere with whatsup expectations → Mitigation: only `tala whatsup` updates the cursor; `tala list` reads it but does not advance it
