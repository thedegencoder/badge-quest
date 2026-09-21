#!/usr/bin/env bash
# Read-only. Reports the counters behind each achievement for the authenticated
# account. GitHub exposes no achievements API, so these are the inputs, not the
# badge state itself.

set -euo pipefail

ME="$(gh api user --jq .login)"
printf '\nGitHub achievement counters for %s\n' "$ME"
printf -- '----------------------------------------\n'

count() { gh api -X GET search/issues -f q="$1" -f per_page=1 --jq .total_count; }

merged=$(count "is:pr is:merged author:$ME")
opened=$(count "is:pr author:$ME")
issues=$(count "is:issue author:$ME")

tier() {  # tier <count> <t1> <t2> <t3> <t4>
  local n=$1
  if   [ "$n" -ge "$5" ]; then echo "gold"
  elif [ "$n" -ge "$4" ]; then echo "silver"
  elif [ "$n" -ge "$3" ]; then echo "bronze"
  elif [ "$n" -ge "$2" ]; then echo "earned"
  else echo "not yet"; fi
}

printf 'Pull Shark    merged PRs: %-6s %s\n' "$merged" "$(tier "$merged" 2 16 128 1024)"
printf 'PRs opened    %s\n' "$opened"
printf 'Issues opened %s\n' "$issues"

printf '\nStars across owned repos:\n'
gh repo list "$ME" --limit 100 --json nameWithOwner,stargazerCount,visibility \
  --jq '.[] | select(.stargazerCount > 0) | "  \(.stargazerCount)\t\(.nameWithOwner) (\(.visibility))"' \
  || printf '  none\n'

printf '\nNot derivable from the API (check your profile page):\n'
printf '  YOLO, Quickdraw, Pair Extraordinaire, Galaxy Brain\n'
printf '  Profile: https://github.com/%s\n\n' "$ME"
