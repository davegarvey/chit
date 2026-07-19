## 1. Rename `Chat` to `Send`, swap primary/alias

- [ ] 1.1 Rename enum variant `Chat` → `Send`, set `#[command(name = "send")]`, remove `alias = "send"`
- [ ] 1.2 Update help text on `Send` variant

## 2. Remove `Start` command, fold into `Send`

- [ ] 2.1 Remove `Start` enum variant and its after_help
- [ ] 2.2 Remove `Commands::Start` dispatch branch from `run()`
- [ ] 2.3 Add `--name` / `-n` flag to `Send` variant
- [ ] 2.4 Update `cmd_send` to accept `--name` parameter and pass it through to auto-create
- [ ] 2.5 Add auto-create logic to `cmd_send` when no message and no active session (replaces bare `start`)
- [ ] 2.6 Add error in `cmd_send` when no message supplied and active session exists
- [ ] 2.7 Delete `cmd_start` function

## 3. Rename `Recap` to `History`

- [ ] 3.1 Rename enum variant `Recap` → `History`, update help text
- [ ] 3.2 Update `Commands::Recap` → `Commands::History` in dispatch

## 4. Rename `WhatsUp` to `Check`

- [ ] 4.1 Rename enum variant `WhatsUp` → `Check`, update help text
- [ ] 4.2 Update `Commands::WhatsUp` → `Commands::Check` in dispatch

## 5. Remove deprecated `Follow`, `Watch`, `Observe`

- [ ] 5.1 Remove `Follow` enum variant
- [ ] 5.2 Remove `Watch` enum variant
- [ ] 5.3 Remove `Observe` enum variant
- [ ] 5.4 Remove their dispatch branches from `run()`
- [ ] 5.5 Remove `deprecation_warning()` function

## 6. Remove deprecated `--file` flag

- [ ] 6.1 Remove the hidden `--file` arg from `Send` variant
- [ ] 6.2 Clean up `--file` handling in `cmd_send` function body

## 7. Remove `--cursor` and `--new` flag aliases

- [ ] 7.1 Remove `alias = "cursor"` from `--since` arg on `Wait` variant
- [ ] 7.2 Remove `alias = "cursor"` from `--since` arg on `History` (`Recap`) variant
- [ ] 7.3 Remove `alias = "new"` from `--new-session` arg on `Wait` variant

## 8. Rename `chit_dir` to `tala_dir`

- [ ] 8.1 Rename variable `chit_dir` → `tala_dir` in `cmd_init`

## 9. Remove deprecated tests

- [ ] 9.1 Remove `test_follow_alias_still_works` test
- [ ] 9.2 Remove `test_file_deprecation_warning` test
- [ ] 9.3 Update any tests referencing `start`

## 10. Update generated skill/docs

- [ ] 10.1 Update embedded SKILL.md in `install_opencode_skills()` with new command names
- [ ] 10.2 Update embedded command.md in `install_opencode_skills()`

## 11. Update README.md

- [ ] 11.1 Update command table: `send` as primary, `recap`→`history`, `whatsup`→`check`, remove `start`
- [ ] 11.2 Update examples to use `send` instead of `chat`/`send`

## 12. Update eval scenario

- [ ] 12.1 Update `eval/scenarios/observe.md`: `tala observe` → `tala listen`

## 13. Verify

- [ ] 13.1 Run `cargo build` to verify compilation
- [ ] 13.2 Run `cargo test` to verify tests pass
