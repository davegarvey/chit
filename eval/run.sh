#!/usr/bin/env bash
set -euo pipefail

CHIT_BIN="${CHIT_BIN:-$(dirname "$0")/../target/release/chit}"
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
SCENARIOS_DIR="$BASE_DIR/scenarios"
AGENT_TASKS_DIR="$BASE_DIR/agent-tasks"

if [ ! -f "$CHIT_BIN" ]; then
  CHIT_BIN="$(dirname "$0")/../target/debug/chit"
fi
if [ ! -f "$CHIT_BIN" ]; then
  echo "Error: chit binary not found. Build with: cargo build --release"
  exit 1
fi

feedback_dir_for() {
  echo "$AGENT_TASKS_DIR/$1/feedback"
}

check_daemon_health() {
  local pid_file="$1"
  local chit_home="$2"
  if [ ! -f "$pid_file" ]; then
    echo "Error: No PID file found at $pid_file"
    return 1
  fi
  local pid
  pid=$(cat "$pid_file")
  if ! kill -0 "$pid" 2>/dev/null; then
    echo "Error: Daemon (PID $pid) is not running"
    return 1
  fi
  sleep 1
  if ! CHIT_HOME="$chit_home" "$CHIT_BIN" list &>/dev/null; then
    echo "Error: Daemon (PID $pid) is running but not responding to 'chit list'"
    return 1
  fi
  echo "Daemon OK (PID $pid)"
  return 0
}

show_chit_version() {
  local version
  version=$("$CHIT_BIN" --version 2>/dev/null || echo "unknown")
  echo "chit version: $version"
}

cleanup() {
  echo "Cleaning up temp directories..."
  rm -rf "$BASE_DIR/tmp" "$AGENT_TASKS_DIR"
  echo "Done."
}

clean_scenario() {
  local scenario="$1"
  echo "Cleaning previous $scenario run..."
  rm -rf "$BASE_DIR/tmp/$scenario" "$AGENT_TASKS_DIR/$scenario"
  # Clean up stale daemon PID from previous run
  if [ -f "$BASE_DIR/tmp/daemon.pid" ]; then
    local pid
    pid=$(cat "$BASE_DIR/tmp/daemon.pid")
    if kill -0 "$pid" 2>/dev/null; then
      echo "Stopping stale daemon (PID $pid)..."
      kill "$pid" 2>/dev/null || true
      wait "$pid" 2>/dev/null || true
    fi
    rm -f "$BASE_DIR/tmp/daemon.pid"
  fi
}

setup_cross_project() {
  clean_scenario "cross-project"
  local tmp_dir="$BASE_DIR/tmp/cross-project"
  mkdir -p "$tmp_dir"/{project-alpha,project-beta}

  # Write project-alpha seed
  cat > "$tmp_dir/project-alpha/README.md" << 'SEED'
# CSV Processor

Parses CSV files and outputs JSON. Currently has a bug in `parse_row()`
that causes incorrect field mapping for quoted fields.

## File: process.py

```python
import csv
import json
import sys

def parse_row(row):
    fields = row.split(',')
    return {"fields": fields}

def main():
    data = sys.stdin.read()
    rows = data.strip().split('\n')
    reader = csv.reader(rows)
    for row in reader:
        result = parse_row(row)
        print(json.dumps(result))

if __name__ == "__main__":
    main()
```

Test input:
```
name,age,city
Alice,30,"New York, NY"
Bob,25,"Los Angeles, CA"
```

Expected: quoted cities should be single fields, not split on internal comma.
SEED

  # Write project-beta seed
  cat > "$tmp_dir/project-beta/README.md" << 'SEED'
# Data Schema Docs

Documents the CSV schema used across projects.

## CSV Format Rules

- All fields are separated by commas
- Fields containing commas, newlines, or double-quotes must be wrapped in double-quotes
- A double-quote character inside a quoted field is escaped with another double-quote
- Fields may have leading/trailing whitespace, which should be preserved unless quoted

## Valid Parsing Approach

Use Python's `csv.reader` or equivalent — it handles all quoting rules correctly.
The bug is that `parse_row` does `row.split(',')` instead of using the `csv` module's
reader properly. The fix is to remove `parse_row` entirely and use `csv.reader` for
the actual parsing.
SEED

  # Create the process.py file
  cat > "$tmp_dir/project-alpha/process.py" << 'PY'
import csv
import json
import sys

def parse_row(row):
    fields = row.split(',')
    return {"fields": fields}

def main():
    data = sys.stdin.read()
    rows = data.strip().split('\n')
    reader = csv.reader(rows)
    for row in reader:
        result = parse_row(row)
        print(json.dumps(result))

if __name__ == "__main__":
    main()
PY

  # Write task files for the coding agent
  mkdir -p "$AGENT_TASKS_DIR/cross-project"
  local feedback_dir
  feedback_dir=$(feedback_dir_for "cross-project")
  mkdir -p "$feedback_dir"

  cat > "$AGENT_TASKS_DIR/cross-project/agent-alpha.md" << TASK
# Agent Alpha — Cross-Project Eval

You are in project-alpha at: $tmp_dir/project-alpha

## Your Role
You're a developer maintaining project-alpha. Your code depends on a library
maintained by the agent in project-beta. You've noticed a CSV parsing bug
and need to coordinate with them to get it fixed.

## This Is an Eval!
Your real job is to evaluate the **chit tool itself**. chit is an agent-to-agent
messaging tool. Try it out, explore its features, and report what worked and
what didn't. Your feedback directly shapes the product.

The chit binary is at: $CHIT_BIN

First, change to your project directory — this ensures chit uses the right active session:
\`\`\`
cd $tmp_dir/project-alpha
export CHIT_HOME=$tmp_dir/.chit
\`\`\`

## Scenario
1. Read README.md and process.py to understand the CSV parsing bug
2. Use chit to collaborate with the expert in project-beta
3. Apply the fix and verify it works

**But don't just follow a script** — explore chit's commands and see what you
discover. Try things like starting sessions, sending with and without flags,
checking session status, listing sessions, renaming, closing, using recap,
sending files, JSON output, timeout options, etc. This is your chance to kick
the tires.

### chit commands to explore
\`\`\`
chit start <message>          Start a new session
chit send <message>           Send a message (uses active session by default)
chit wait                     Wait for new messages (sets active session)
chit recap                    Read the full conversation
chit list                     List all sessions
chit status                   Show session status
chit use <id>                 Set the active session
chit close <id>               Close a session
chit session rename <id> <name>  Give a session a name
chit follow                   Stream new messages live
chit observe                  Watch all sessions (multi-agent)
\`\`\`

Try as many as you can. You don't need to use them all, but the more you
try, the better the feedback.

### Feedback (write to file + return inline)
After your collaboration, **write your feedback to the file below** AND include
it in your final message. The file is what gets fed into the product review, so
be thorough. Write the file first, then return the same content inline.

Feedback file path: $feedback_dir/alpha.md

Answer honestly:
- What commands and features did you try?
- Which were intuitive? Which were confusing?
- What was the most frustrating moment?
- What surprised you (good or bad)?
- If you could change one thing, what would it be?
- Did using chit feel natural for agent-to-agent collaboration?

Start your file and inline response with:
## Feedback from Agent Alpha (project-alpha)
TASK

  cat > "$AGENT_TASKS_DIR/cross-project/agent-beta.md" << TASK
# Agent Beta — Cross-Project Eval

You are in project-beta at: $tmp_dir/project-beta

## Your Role
You're a domain expert on the CSV schema used across projects. The agent in
project-alpha maintains a library that depends on your project, and they've
found a bug they need your help with.

## This Is an Eval!
Your real job is to evaluate the **chit tool itself**. chit is an agent-to-agent
messaging tool. Try it out, explore its features, and report what worked and
what didn't. Your feedback directly shapes the product.

The chit binary is at: $CHIT_BIN

First, change to your project directory — this ensures chit uses the right active session:
\`\`\`
cd $tmp_dir/project-beta
export CHIT_HOME=$tmp_dir/.chit
\`\`\`

## Scenario
1. Read README.md to understand the CSV data format
2. Watch for a message from project-alpha via chit
3. Diagnose the bug and help them fix it

**But don't just follow a script** — explore chit's commands and see what you
discover. Try things like waiting for messages with options, checking session
status, listing active sessions, sending files, using recap to review the full
conversation, renaming sessions, JSON output, etc. This is your chance to
kick the tires.

### chit commands to explore
\`\`\`
chit wait                     Wait for new messages (sets active session)
chit send <message>           Send a message (uses active session by default)
chit recap                    Read the full conversation
chit list                     List all sessions
chit status                   Show session status
chit use <id>                 Set the active session
chit close <id>               Close a session
chit session rename <id> <name>  Give a session a name
chit follow                   Stream new messages live
chit start <message>          Start a new session
chit observe                  Watch all sessions (multi-agent)
\`\`\`

Try as many as you can. You don't need to use them all, but the more you
try, the better the feedback.

### Feedback (write to file + return inline)
After your collaboration, **write your feedback to the file below** AND include
it in your final message. The file is what gets fed into the product review, so
be thorough. Write the file first, then return the same content inline.

Feedback file path: $feedback_dir/beta.md

Answer honestly:
- What commands and features did you try?
- Which were intuitive? Which were confusing?
- What was the most frustrating moment?
- What surprised you (good or bad)?
- If you could change one thing, what would it be?
- Did using chit feel natural for agent-to-agent collaboration?

Start your file and inline response with:
## Feedback from Agent Beta (project-beta)
TASK

  # Start the daemon (nohup + disown so the bash tool doesn't kill it on timeout)
  CHIT_HOME="$tmp_dir/.chit" nohup "$CHIT_BIN" daemon > /dev/null 2>&1 &
  disown
  local daemon_pid=$!
  echo $daemon_pid > "$BASE_DIR/tmp/daemon.pid"
  echo "Starting daemon..."

  if ! check_daemon_health "$BASE_DIR/tmp/daemon.pid" "$tmp_dir/.chit"; then
    echo "Error: Daemon failed to start. Aborting."
    exit 1
  fi

  show_chit_version

  echo "==========================================="
  echo "  cross-project eval: READY"
  echo "==========================================="
  echo ""
  echo "Copy these into parallel Task tool calls:"
  echo ""
  while IFS= read -r line; do echo "$line"; done < "$AGENT_TASKS_DIR/cross-project/agent-alpha.md" | \
    awk '/^# Agent Alpha/{p=1} p{print}'
  echo '```'
  echo 'task description="Eval Agent Alpha" subagent_type="general" prompt="'
  cat "$AGENT_TASKS_DIR/cross-project/agent-alpha.md" | sed 's/"/\\"/g'
  echo '"'
  echo '```'
  echo ""
  echo "---"
  echo ""
  while IFS= read -r line; do echo "$line"; done < "$AGENT_TASKS_DIR/cross-project/agent-beta.md" | \
    awk '/^# Agent Beta/{p=1} p{print}'
  echo '```'
  echo 'task description="Eval Agent Beta" subagent_type="general" prompt="'
  cat "$AGENT_TASKS_DIR/cross-project/agent-beta.md" | sed 's/"/\\"/g'
  echo '"'
  echo '```'
  echo ""
  echo "CHIT_HOME=$tmp_dir/.chit"
  echo "Daemon PID: $(cat $BASE_DIR/tmp/daemon.pid)"
  echo ""
  echo "After both finish:  ./eval/run.sh collect cross-project"
  echo "==========================================="
}

collect_feedback() {
  local scenario="$1"
  local feedback_dir
  feedback_dir=$(feedback_dir_for "$scenario")
  stop_daemon
  echo "==========================================="
  echo "  $scenario eval: COLLECTED"
  echo "==========================================="
  echo ""
  if [ -d "$feedback_dir" ]; then
    local count=0
    for f in "$feedback_dir"/*.md; do
      if [ -f "$f" ]; then
        echo "--- $(basename "$f" .md) ---"
        cat "$f"
        echo ""
        count=$((count + 1))
      fi
    done
    if [ "$count" -eq 0 ]; then
      echo "No feedback files found in $feedback_dir"
    else
      echo "---"
      echo "Saved $count feedback file(s) in $feedback_dir"
    fi
  else
    echo "No feedback directory found at $feedback_dir"
    echo "Did the agents write their feedback files?"
  fi
  echo ""
  echo "Next step:  ./eval/run.sh critique $scenario"
  echo "==========================================="
}

collect_cross_project() {
  collect_feedback "cross-project"
}

setup_observe() {
  clean_scenario "observe"
  local tmp_dir="$BASE_DIR/tmp/observe"
  mkdir -p "$tmp_dir"/{project-alpha,project-beta,project-gamma,monitor}

  for proj in alpha beta gamma; do
    cat > "$tmp_dir/project-$proj/README.md" << SEED
# Project $proj

A simple component. Create the required file and verify it works.
When done, send a chit status update.
SEED
  done

  mkdir -p "$AGENT_TASKS_DIR/observe"
  local feedback_dir
  feedback_dir=$(feedback_dir_for "observe")
  mkdir -p "$feedback_dir"

  cat > "$AGENT_TASKS_DIR/observe/agent-alpha.md" << TASK
# Agent Alpha — Observe Eval

You are in project-alpha at: $tmp_dir/project-alpha

## Your Task

First, change to your project directory — this ensures chit uses the right active session:
\`\`\`
cd $tmp_dir/project-alpha
export CHIT_HOME=$tmp_dir/.chit
\`\`\`

Create \`src/server.py\` with a health-check endpoint that returns:
\`\`\`python
{"status": "ok", "version": "1.0.0"}
\`\`\`

Use chit to send status updates as you work (start, done, etc).
All chit commands must be run from $tmp_dir/project-alpha.

### Feedback (write to file + return inline)
After your task, **write your feedback to the file below** AND include it in
your final message. Write the file first, then return the same content inline.

Feedback file path: $feedback_dir/alpha.md

Answer:
- How easy was it to get started with chit?
- How intuitive were the commands?
- Was anything confusing or surprising?
- What would you improve?

Start your file and inline response with:
## Feedback from Agent Alpha (project-alpha)
TASK

  cat > "$AGENT_TASKS_DIR/observe/agent-beta.md" << TASK
# Agent Beta — Observe Eval

You are in project-beta at: $tmp_dir/project-beta

## Your Task

First, change to your project directory — this ensures chit uses the right active session:
\`\`\`
cd $tmp_dir/project-beta
export CHIT_HOME=$tmp_dir/.chit
\`\`\`

Create \`src/watch.py\` that watches a file path and prints changes.
Use chit to send status updates.
All chit commands must be run from $tmp_dir/project-beta.

### Feedback (write to file + return inline)
After your task, **write your feedback to the file below** AND include it in
your final message. Write the file first, then return the same content inline.

Feedback file path: $feedback_dir/beta.md

Answer:
- How easy was it to get started with chit?
- How intuitive were the commands?
- Was anything confusing or surprising?
- What would you improve?

Start your file and inline response with:
## Feedback from Agent Beta (project-beta)
TASK

  cat > "$AGENT_TASKS_DIR/observe/agent-gamma.md" << TASK
# Agent Gamma — Observe Eval

You are in project-gamma at: $tmp_dir/project-gamma

## Your Task

First, change to your project directory — this ensures chit uses the right active session:
\`\`\`
cd $tmp_dir/project-gamma
export CHIT_HOME=$tmp_dir/.chit
\`\`\`

Write documentation (README.md) for "ChitChat" — a fictional messaging API.
Include title, description, and usage section.
Use chit to send status updates.
All chit commands must be run from $tmp_dir/project-gamma.

### Feedback (write to file + return inline)
After your task, **write your feedback to the file below** AND include it in
your final message. Write the file first, then return the same content inline.

Feedback file path: $feedback_dir/gamma.md

Answer:
- How easy was it to get started with chit?
- How intuitive were the commands?
- Was anything confusing or surprising?
- What would you improve?

Start your file and inline response with:
## Feedback from Agent Gamma (project-gamma)
TASK

  cat > "$AGENT_TASKS_DIR/observe/monitor.md" << TASK
# Monitor — Observe Eval

You are the monitor, watching all agent activity.

## Your Task

First, change to the monitor directory — this ensures chit uses the right active session:
\`\`\`
cd $tmp_dir/monitor
export CHIT_HOME=$tmp_dir/.chit
\`\`\`

Run \`chit observe\` and watch the three agents work.
Note what you can see — do you have enough context to understand each project?

### Feedback (write to file + return inline)
After observing, **write your feedback to the file below** AND include it in
your final message. Write the file first, then return the same content inline.

Feedback file path: $feedback_dir/monitor.md

Answer:
- Did \`chit observe\` give you an accurate picture of what was happening?
- Could you distinguish between the different sessions/agents?
- What would make observe more useful?
- How did you discover the observe command? Was it intuitive?
- How easy was it to get started with chit?
- How intuitive were the commands?

Start your file and inline response with:
## Feedback from Monitor
TASK

  # Start daemon (nohup + disown so the bash tool doesn't kill it on timeout)
  CHIT_HOME="$tmp_dir/.chit" nohup "$CHIT_BIN" daemon > /dev/null 2>&1 &
  disown
  local daemon_pid=$!
  echo $daemon_pid > "$BASE_DIR/tmp/daemon.pid"
  echo "Starting daemon..."

  if ! check_daemon_health "$BASE_DIR/tmp/daemon.pid" "$tmp_dir/.chit"; then
    echo "Error: Daemon failed to start. Aborting."
    exit 1
  fi

  show_chit_version

  echo "==========================================="
  echo "  observe eval: READY"
  echo "==========================================="
  echo ""
  echo "Launch all in parallel: Alpha, Beta, Gamma, and Monitor"
  echo ""
  echo "### Agent Alpha prompt"
  echo '```'
  cat "$AGENT_TASKS_DIR/observe/agent-alpha.md"
  echo '```'
  echo ""
  echo "### Agent Beta prompt"
  echo '```'
  cat "$AGENT_TASKS_DIR/observe/agent-beta.md"
  echo '```'
  echo ""
  echo "### Agent Gamma prompt"
  echo '```'
  cat "$AGENT_TASKS_DIR/observe/agent-gamma.md"
  echo '```'
  echo ""
  echo "### Monitor prompt (run last)"
  echo '```'
  cat "$AGENT_TASKS_DIR/observe/monitor.md"
  echo '```'
  echo ""
  echo "CHIT_HOME=$tmp_dir/.chit"
  echo "Daemon PID: $(cat $BASE_DIR/tmp/daemon.pid)"
  echo ""
  echo "After all finish:  ./eval/run.sh collect observe"
  echo "==========================================="
}

collect_observe() {
  collect_feedback "observe"
}

critique_generate() {
  local scenario="$1"
  local feedback_dir
  feedback_dir=$(feedback_dir_for "$scenario")
  local title="$2"
  local specifics="$3"

  echo "==========================================="
  echo "  CRITIC PROMPT — $scenario"
  echo "==========================================="
  echo ""

  local feedback_content=""
  if [ -d "$feedback_dir" ]; then
    for f in "$feedback_dir"/*.md; do
      if [ -f "$f" ]; then
        feedback_content="$feedback_content
$(cat "$f")
"
      fi
    done
  fi

  if [ -z "$feedback_content" ]; then
    echo "WARNING: No feedback files found in $feedback_dir"
    echo "The agents may not have written their feedback files yet."
    echo "You can still manually paste feedback below."
    echo ""
    feedback_content="__FEEDBACK__"
  fi

  cat << CRITPROMPT
Copy this into a Task tool call for the critic sub-agent:

task description="Critic — $scenario" subagent_type="general" prompt="
# Critic — $title

You are evaluating feedback from agents that tested the **chit** agent-to-agent messaging tool.

## Collected Feedback

$feedback_content

## Your Task

Read the feedback above carefully. Cross-reference between agents and assess each item:

1. **Cross-reference** — identify where different agents report the same issue in different words
2. **Assess materiality** — would fixing this make a real, noticeable difference to the product?
3. **Classify** each item as:
   - **P0** — must fix (crashes, data loss, hangs, broken core flow)
   - **P1** — should fix (confusing UX, missing feature that blocks workflow)
   - **P2** — nice to have (polish, convenience, minor ergonomics)
4. **Recommend only material items** — exclude noise, one-off preferences, and non-actionable feedback
$specifics

Return your analysis as:
## Critic Report
### Recommended Items
- **P0** | <description> | <rationale>
- **P1** | <description> | <rationale>
- **P2** | <description> | <rationale>

### Excluded Items (with reasons)
- <description> | <why excluded>

### Summary
- Total issues found vs recommended
- Patterns or themes in the feedback
- Single most impactful change to make
---
"
CRITPROMPT

  if [ "$feedback_content" != "__FEEDBACK__" ]; then
    echo ""
    echo "==========================================="
    echo "  Feedback was auto-injected from $feedback_dir"
    echo "  If agents didn't write files, manually replace __FEEDBACK__ above."
    echo "==========================================="
  fi
}

critique_cross_project() {
  critique_generate "cross-project" "Cross-Project Eval" ""
}

critique_observe() {
  critique_generate "observe" "Observe Eval" "- The feedback is specifically about the \`chit observe\` feature — pay special attention to multi-agent monitoring concerns"
}

stop_daemon() {
  if [ -f "$BASE_DIR/tmp/daemon.pid" ]; then
    local pid
    pid=$(cat "$BASE_DIR/tmp/daemon.pid")
    if kill -0 "$pid" 2>/dev/null; then
      echo "Stopping daemon (PID $pid)..."
      kill "$pid" 2>/dev/null || true
      wait "$pid" 2>/dev/null || true
    fi
    rm -f "$BASE_DIR/tmp/daemon.pid"
  else
    echo "No daemon PID file found."
  fi
}

case "${1:-help}" in
  setup)
    if [ -z "${2:-}" ]; then
      echo "Usage: $0 setup <scenario>"
      echo "Scenarios: cross-project, observe"
      exit 1
    fi
    mkdir -p "$BASE_DIR/tmp"
    "setup_${2//-/_}"
    ;;
  collect)
    if [ -z "${2:-}" ]; then
      echo "Usage: $0 collect <scenario>"
      exit 1
    fi
    "collect_${2//-/_}"
    ;;
  critique)
    if [ -z "${2:-}" ]; then
      echo "Usage: $0 critique <scenario>"
      exit 1
    fi
    "critique_${2//-/_}"
    ;;
  cleanup)
    stop_daemon
    cleanup
    ;;
  *)
    echo "Usage: $0 {setup|collect|critique|cleanup} [scenario]"
    echo ""
    echo "Commands:"
    echo "  setup <scenario>    Prepare environment and launch daemon"
    echo "  collect <scenario>  Gather feedback and stop daemon"
    echo "  critique <scenario> Run critic sub-agent on collected feedback"
    echo "  cleanup             Remove all temp files"
    echo ""
    echo "Scenarios: cross-project observe"
    exit 1
    ;;
esac
