## 1. `chit send` auto-create on no sessions

- [x] 1.1 Modify `cmd_send` Branch C (cli.rs:727-748): when `active.is_empty()`, call `POST /api/sessions` to create a new session, write active session, and send message
- [x] 1.2 Print "→ Created session <id>" on auto-create (non-JSON output); include session_id in JSON output
- [x] 1.3 Ensure auto-create does NOT fire when `--session <id>` is explicitly provided (error as before)
- [x] 1.4 Add tests: auto-create with no sessions, auto-create with `--json`, auto-create with `--wait`, explicit `--session` error, sessions-exist-but-no-active list

## 2. `chit send --stdin` flag

- [x] 2.1 Add `--stdin` bool flag to `cmd_send` clap argument definition
- [x] 2.2 If `--stdin` is set, read message content from stdin (blocking read, no timeout, fallback to error if terminal)
- [x] 2.3 If both `--stdin` and positional message are provided, print warning and prefer stdin; if both `--stdin` and `--file`, prefer `--file`
- [x] 2.4 Verify implicit pipe (no `--stdin`) still works with existing 500ms timeout fallback
- [x] 2.5 Add tests: `--stdin` flag with piped input (test_stdin_flag_piped)

## 3. Daemon idle timeout improvements

- [x] 3.1 Change default `idle_timeout` from 600s to 3600s in daemon.rs
- [x] 3.2 Replace `has_active_sessions()` check with per-session `last_activity` check: daemon stays alive if any session has `last_activity` within `idle_timeout`
- [x] 3.3 Update tests: relies on existing daemon lifecycle tests (idle timeout is 3600s, not testable in automated suite without long waits)

## 4. Session rename conflict detection

- [x] 4.1 Add `--force` flag to `chit session rename` clap argument definition
- [x] 4.2 In `rename_session` (store.rs:201), check if session already has a name set; if so, return 409 Conflict unless `--force`
- [x] 4.3 In `cmd_session_rename` (cli.rs:1357), handle 409 response with warning message; pass `--force` through API
- [x] 4.4 Handle no-op rename (same name) as silent success
- [x] 4.5 Add tests: rename overwrite rejection (test_rename_rejects_overwrite_without_force), no-op rename (test_rename_noop_same_name)
