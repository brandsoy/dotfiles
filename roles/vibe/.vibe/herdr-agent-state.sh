#!/bin/sh
# herdr agent-state bridge for Mistral Vibe
# Reports Vibe lifecycle hook events to the herdr server over its socket API
# (methods: pane.report_agent, pane.report_agent_session).
# Called from ~/.vibe/hooks.toml; receives the Vibe hook JSON on stdin.
set -eu

hook_input_file="$(mktemp "${TMPDIR:-/tmp}/herdr-vibe-hook.XXXXXX")" || exit 0
trap 'rm -f "$hook_input_file"' EXIT HUP INT TERM
cat >"$hook_input_file" 2>/dev/null || true

# Only report when Vibe runs inside a herdr-managed pane.
[ "${HERDR_ENV:-}" = "1" ] || exit 0
[ -n "${HERDR_SOCKET_PATH:-}" ] || exit 0
[ -n "${HERDR_PANE_ID:-}" ] || exit 0
command -v python3 >/dev/null 2>&1 || exit 0

HERDR_HOOK_INPUT_FILE="$hook_input_file" python3 - <<'PY'
import json
import os
import random
import socket
import time

source = "herdr:vibe"
agent = "vibe"
pane_id = os.environ.get("HERDR_PANE_ID")
socket_path = os.environ.get("HERDR_SOCKET_PATH")
hook_input_file = os.environ.get("HERDR_HOOK_INPUT_FILE")


def exit_ok():
    raise SystemExit(0)


if not pane_id or not socket_path:
    exit_ok()

hook_input = {}
try:
    if hook_input_file:
        with open(hook_input_file, encoding="utf-8") as handle:
            content = handle.read()
        if content.strip():
            hook_input = json.loads(content)
except Exception:
    hook_input = {}

# Subagent hook events must not clobber the pane's root session state.
if hook_input.get("parent_session_id"):
    exit_ok()

event = str(hook_input.get("hook_event_name") or "")
tool_name = str(hook_input.get("tool_name") or "")

if event == "post_agent":
    state = "idle"
elif event == "post_tool":
    state = "working"
elif event == "pre_tool":
    state = "blocked" if tool_name == "ask_user_question" else "working"
else:
    exit_ok()

session_id = hook_input.get("session_id")
session_id = session_id if isinstance(session_id, str) and session_id else None
transcript_path = hook_input.get("transcript_path")
transcript_path = (
    transcript_path if isinstance(transcript_path, str) and transcript_path.strip() else None
)


def send_request(method, params):
    request = {
        "id": f"{source}:{int(time.time() * 1000)}:{random.randrange(1_000_000):06d}",
        "method": method,
        "params": params,
    }
    try:
        client = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        client.settimeout(0.5)
        client.connect(socket_path)
        client.sendall((json.dumps(request) + "\n").encode())
        try:
            client.recv(4096)
        except Exception:
            pass
        client.close()
    except Exception:
        pass


# State first: reporting state grants the pane authority, which
# pane.report_agent_session (with resume_argv) requires.
params = {
    "pane_id": pane_id,
    "source": source,
    "agent": agent,
    "seq": time.time_ns(),
    "state": state,
}
if session_id:
    params["agent_session_id"] = session_id
send_request("pane.report_agent", params)

if session_id:
    session_params = {
        "pane_id": pane_id,
        "source": source,
        "agent": agent,
        "seq": time.time_ns(),
        "agent_session_id": session_id,
    }
    if transcript_path:
        session_params["agent_session_path"] = transcript_path
    session_params["resume_argv"] = ["vibe", "--resume", session_id]
    send_request("pane.report_agent_session", session_params)

exit_ok()
PY
