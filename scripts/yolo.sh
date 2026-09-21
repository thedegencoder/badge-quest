#!/usr/bin/env bash
# YOLO: merge a pull request with no review.
#
# Opens a trivial PR against main in this repo and merges it without requesting
# review. Single tier, so this only needs to succeed once. The same merge also
# counts toward Pull Shark.
#
#   bash scripts/yolo.sh
#   DRY_RUN=1 bash scripts/yolo.sh

set -euo pipefail
cd "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

DRY_RUN="${DRY_RUN:-0}"
REPO="$(gh repo view --json nameWithOwner -q .nameWithOwner)"
VIS="$(gh repo view --json visibility -q .visibility)"
STAMP="$(date +%Y%m%d-%H%M%S)"
BRANCH="yolo/$STAMP"

[ "$VIS" = "PUBLIC" ] || printf '! %s is %s — achievements need public activity.\n' "$REPO" "$VIS" >&2

if [ "$DRY_RUN" = "1" ]; then
  printf '[dry-run] branch %s, commit a log line, open PR, merge with no review\n' "$BRANCH"
  exit 0
fi

git checkout -q main
git pull -q --ff-only origin main 2>/dev/null || true
git checkout -q -b "$BRANCH"

mkdir -p log
printf -- '- %s YOLO run\n' "$STAMP" >> log/merges.md
git add log/merges.md
git commit -q -m "chore: log merge $STAMP"
git push -q -u origin "$BRANCH"

num="$(gh pr create --base main --head "$BRANCH" \
  --title "YOLO: merge without review ($STAMP)" \
  --body "Merged without a review to satisfy the YOLO achievement." \
  | sed 's#.*/##')"
printf 'opened  PR #%s\n' "$num"

gh pr merge "$num" --squash --delete-branch >/dev/null
printf 'merged  PR #%s with no review\n' "$num"

git checkout -q main
git pull -q --ff-only origin main 2>/dev/null || true
printf '\nYOLO condition met. Also +1 toward Pull Shark.\n'
