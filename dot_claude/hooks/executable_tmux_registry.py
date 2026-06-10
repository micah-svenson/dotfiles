#!/usr/bin/env python3
"""Maintain a registry mapping tmux sessions to their active Claude session IDs.

Modes (argv[1]):
  register      SessionStart hook: upsert this pane's Claude session id.
  unregister    SessionEnd hook: delete this Claude session id's row.
  rename NAME   tmux session-renamed hook: refresh tmux_name for that session.

Registry: ~/.claude/tmux-session-registry.json, keyed by Claude session id (UUID).
"""
from __future__ import annotations

import fcntl
import json
import os
from datetime import datetime, timezone

HOME = os.path.expanduser("~")
REGISTRY_PATH = os.path.join(HOME, ".claude", "tmux-session-registry.json")


def now_iso() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def load(path: str) -> dict:
    try:
        with open(path) as f:
            data = json.load(f)
        return data if isinstance(data, dict) else {}
    except (FileNotFoundError, json.JSONDecodeError, ValueError):
        return {}


def atomic_write(path: str, data: dict) -> None:
    tmp = f"{path}.tmp.{os.getpid()}"
    with open(tmp, "w") as f:
        json.dump(data, f, indent=2, sort_keys=True)
        f.write("\n")
    os.replace(tmp, path)


class locked:
    """Exclusive cross-process lock held on a sidecar lockfile."""

    def __init__(self, path: str):
        self._lockpath = f"{path}.lock"
        self._fh = None

    def __enter__(self):
        self._fh = open(self._lockpath, "w")
        fcntl.flock(self._fh, fcntl.LOCK_EX)
        return self

    def __exit__(self, *exc):
        fcntl.flock(self._fh, fcntl.LOCK_UN)
        self._fh.close()


def upsert(reg: dict, *, session_id: str, tmux_name: str, tmux_session_id: str,
           window_index: int, cwd: str, now: str) -> dict:
    out = dict(reg)
    out[session_id] = {
        "tmux_name": tmux_name,
        "tmux_session_id": tmux_session_id,
        "window_index": window_index,
        "cwd": cwd,
        "updated_at": now,
    }
    return out


def remove(reg: dict, session_id: str) -> dict:
    out = dict(reg)
    out.pop(session_id, None)
    return out


def rename(reg: dict, tmux_session_id: str, new_name: str) -> dict:
    out = {}
    for sid, row in reg.items():
        row = dict(row)
        if row.get("tmux_session_id") == tmux_session_id:
            row["tmux_name"] = new_name
        out[sid] = row
    return out


import subprocess  # noqa: E402  (kept with the I/O layer below)
import sys  # noqa: E402


def _tmux(args: list[str]) -> str:
    return subprocess.run(["tmux", *args], capture_output=True, text=True,
                          check=True).stdout


def resolve_pane(pane: str) -> dict:
    fmt = "#{session_name}\t#{session_id}\t#{window_index}\t#{pane_current_path}"
    out = _tmux(["display-message", "-p", "-t", pane, fmt]).rstrip("\n")
    name, sid, widx, cwd = out.split("\t")
    return {"tmux_name": name, "tmux_session_id": sid,
            "window_index": int(widx), "cwd": cwd}


def session_id_for_name(name: str) -> str | None:
    try:
        return _tmux(["display-message", "-p", "-t", name, "#{session_id}"]).strip()
    except subprocess.CalledProcessError:
        return None


def _read_stdin_session_id() -> str | None:
    try:
        payload = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        return None
    sid = payload.get("session_id")
    return sid if isinstance(sid, str) and sid else None


def main(argv: list[str]) -> int:
    if len(argv) < 2:
        return 0
    mode = argv[1]

    if mode == "rename":
        if len(argv) < 3:
            return 0
        new_name = argv[2]
        sid = session_id_for_name(new_name)
        if not sid:
            return 0
        with locked(REGISTRY_PATH):
            atomic_write(REGISTRY_PATH, rename(load(REGISTRY_PATH), sid, new_name))
        return 0

    session_id = _read_stdin_session_id()
    if not session_id:
        return 0

    if mode == "unregister":
        with locked(REGISTRY_PATH):
            atomic_write(REGISTRY_PATH, remove(load(REGISTRY_PATH), session_id))
        return 0

    if mode == "register":
        pane = os.environ.get("TMUX_PANE")
        if not os.environ.get("TMUX") or not pane:
            return 0  # not inside tmux; nothing to track
        try:
            info = resolve_pane(pane)
        except (subprocess.CalledProcessError, ValueError):
            return 0
        with locked(REGISTRY_PATH):
            atomic_write(REGISTRY_PATH,
                         upsert(load(REGISTRY_PATH), session_id=session_id,
                                now=now_iso(), **info))
        return 0

    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
