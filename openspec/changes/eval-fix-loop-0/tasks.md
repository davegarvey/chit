## 1. Fix reopen race condition

- [ ] 1.1 In `store.rs`, modify `reopen_session` to hold the sessions write lock through the broadcast send, eliminating the TOCTOU window

## 2. Fix stream --timeout

- [ ] 2.1 In `cli.rs`, remove underscore prefix from `_timeout` parameter in `cmd_watch` and pass it to the API request
- [ ] 2.2 In `api.rs`, add timeout support to `stream_events` SSE handler using `tokio::time::timeout`

## 3. Add session targeting improvements

- [ ] 3.1 Add `--session` / `-s` flag to `send`, `wait`, and `recap` subcommands in CLI argument definitions
- [ ] 3.2 Implement auto-select of single open session when no active session is set
- [ ] 3.3 Update session resolution helper to use auto-select

## 4. Preserve session name on reply

- [ ] 4.1 In `store.rs` `add_message`, only set session name from sender if session currently has no name

## 5. Hide unread counts for closed sessions

- [ ] 5.1 In `cli.rs`, filter out or skip unread computation for closed sessions in `cmd_list`

## 6. Improve start output

- [ ] 6.1 Enhance `cmd_start` output to show message confirmation alongside session ID
- [ ] 6.2 Add inline message to `tala wait --json` output

## 7. Verify and test

- [ ] 7.1 Run `cargo build` to verify compilation
- [ ] 7.2 Run `cargo test` to verify existing tests pass
