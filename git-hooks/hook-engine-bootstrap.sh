#!/usr/bin/env bash
# ralph-machine-config-managed: true
# Commit-gate engine bootstrap (HO-13547). git-hooks/pre-commit hands it the
# engine path it would run ($1: this machine's checkout, or RALPH_HOOK_ENGINE).
# It prints the path of an engine that carries the managed marker — the
# candidate, else a cached copy pinned at ENGINE_REF — and exits 0; otherwise
# it prints nothing on stdout and exits 1 (the shim then skips the gate with
# one line). Every path is verified on every run, a cache hit included, so a
# planted file under ~/.cache or an ambient RALPH_HOOK_ENGINE never runs.
#
# The cache is content-addressed by the pinned sha, so a hit never touches the
# network. A miss fetches the engine and its siblings through `gh api` —
# AUTHENTICATED, never an anonymous curl — into a temp dir under the cache
# root, checks the managed marker, and renames the dir onto the sha dir in one
# step: a half-written engine is never visible. Rollout PRs bump ENGINE_REF.
set -euo pipefail

ENGINE_REF="f092e8081bb344d90a622e255540713b44d89cba"
ENGINE_REPO="TeamK2K/ralph-machine-config"
MARKER="ralph-machine-config-managed: true"

is_engine() {
  [ -f "$1" ] || return 1
  case "$(head -n 5 "$1")" in *"$MARKER"*) ;; *) return 1 ;; esac
  grep -q 'def run(' "$1"
}

if [ -n "${1:-}" ] && is_engine "$1"; then
  printf '%s\n' "$1"
  exit 0
fi

root="${XDG_CACHE_HOME:-$HOME/.cache}/ralph-hook-engine"
dest="$root/$ENGINE_REF"

if is_engine "$dest/commit_gate.py"; then
  printf '%s\n' "$dest/commit_gate.py"
  exit 0
fi
command -v gh >/dev/null 2>&1 || exit 1

fail() {
  echo "hook-engine-bootstrap: $1 (engine ${ENGINE_REF:0:12} not cached)" >&2
  exit 1
}

mkdir -p "$root"
tmp="$(mktemp -d "$root/.fetch.XXXXXX")"
trap 'rm -rf "$tmp"' EXIT

for name in commit_gate.py check_agent_file_growth.py check_supabase.py; do
  gh api -H 'Accept: application/vnd.github.raw' \
    "repos/$ENGINE_REPO/contents/hook-pack/scripts/$name?ref=$ENGINE_REF" \
    >"$tmp/$name" 2>/dev/null || fail "gh api could not fetch $name"
  head5="$(head -n 5 "$tmp/$name")"
  case "$head5" in
    *"$MARKER"*) ;;
    *) fail "$name has no managed marker" ;;
  esac
done
grep -q 'def run(' "$tmp/commit_gate.py" || fail "commit_gate.py is not the engine"

# rename(2): atomic, and it refuses a non-empty target — a concurrent winner
# keeps its dir and this run uses it.
python3 -c 'import os, sys; os.rename(sys.argv[1], sys.argv[2])' "$tmp" "$dest" 2>/dev/null || true
is_engine "$dest/commit_gate.py" || fail "could not place the cache at $dest"
printf '%s\n' "$dest/commit_gate.py"
