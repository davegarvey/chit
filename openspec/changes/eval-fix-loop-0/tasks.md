## 1. Better Daemon Connectivity Errors

- [ ] 1.1 Add path and TALA_HOME details to `ensure_daemon_running()` error messages in `cli.rs`
- [ ] 1.2 Improve "no daemon running" text output in `cmd_status` to include path checked
- [ ] 1.3 Add daemon unreachable diagnostic (stale daemon.json) to all commands via shared helper

## 2. Unread Indicators in List and Status

- [ ] 2.1 Add `tala_home_path()` helper to `store.rs` for consistent path display
- [ ] 2.2 Add `.tala/cursor` read/write functions in `store.rs`
- [ ] 2.3 Add `unread_count` to `SessionSummary` model and compute from cursor
- [ ] 2.4 Add `active_session_id` to session list fetching for active session marker
- [ ] 2.5 Update `cmd_list` text output to show unread count and active marker
- [ ] 2.6 Update `cmd_status` to show total unread count

## 3. Non-blocking `tala whatsup` Command

- [ ] 3.1 Add `WhatsUp` variant to `Commands` enum with clap args
- [ ] 3.2 Add dispatch case in `run()` for `WhatsUp`
- [ ] 3.3 Implement `cmd_whatsup()`: read cursor, query observe endpoint, display messages, write cursor
- [ ] 3.4 Wire cursor I/O into `cmd_list` for unread computation
- [ ] 3.5 Verify JSON output format for scripting use

## 4. Verification

- [ ] 4.1 Build and check for compilation errors
- [ ] 4.2 Run existing test suite
- [ ] 4.3 Manual review of error message quality
