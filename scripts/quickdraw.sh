#!/usr/bin/env bash
# Quickdraw: close an issue within 5 minutes of opening it.
#
# Opens one issue in this repo and closes it immediately. Single tier, so this
# only ever needs to succeed once.
#
#   bash scripts/quickdraw.sh
#   DRY_RUN=1 bash scripts/quickdraw.sh

set -euo pipefail
cd "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

DRY_RUN="${DRY_RUN:-0}"
REPO="$(gh repo view --json nameWithOwner -q .nameWithOwner)"
VIS="$(gh repo view --json visibility -q .visibility)"

if [ "$VIS" != "PUBLIC" ]; then
  printf '! %s is %s — achievements are awarded on public activity.\n' "$REPO" "$VIS" >&2
fi

if [ "$DRY_RUN" = "1" ]; then
  printf '[dry-run] open an issue in %s, then close it immediately\n' "$REPO"
  exit 0
fi

started=$(date +%s)
url="$(gh issue create --repo "$REPO" \
  --title "Quickdraw: tracking issue" \
  --body "Opened and closed in the same minute to satisfy the Quickdraw achievement.")"
num="${url##*/}"
printf 'opened  #%s\n' "$num"

gh issue close "$num" --repo "$REPO" --comment "Closing immediately." >/dev/null
elapsed=$(( $(date +%s) - started ))
printf 'closed  #%s after %ss (needs to be under 300s)\n' "$num" "$elapsed"

if [ "$elapsed" -lt 300 ]; then
  printf 'Quickdraw condition met. Check https://github.com/%s\n' "$(gh api user --jq .login)"
else
  printf '! took too long — re-run\n' >&2
fi
