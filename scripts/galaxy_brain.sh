#!/usr/bin/env bash
# Galaxy Brain: get answers accepted in GitHub Discussions.
#
# Tiers: 2 / 8 / 16 / 32 accepted answers. In a repo you own you can open a
# Q&A discussion, answer it, and mark your own answer as accepted.
#
#   bash scripts/galaxy_brain.sh [count]     # default 2
#   DRY_RUN=1 bash scripts/galaxy_brain.sh
#
# Requires Discussions enabled on the repo (this script enables it) and a Q&A
# category, which is created by default with Discussions.

set -euo pipefail
cd "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

COUNT="${1:-2}"
DRY_RUN="${DRY_RUN:-0}"
REPO="$(gh repo view --json nameWithOwner -q .nameWithOwner)"
OWNER="${REPO%%/*}"
NAME="${REPO##*/}"

if [ "$DRY_RUN" = "1" ]; then
  printf '[dry-run] enable Discussions on %s, then open/answer/accept %s Q&A threads\n' "$REPO" "$COUNT"
  exit 0
fi

printf '▸ enabling Discussions on %s\n' "$REPO"
gh api -X PATCH "repos/$REPO" -F has_discussions=true --jq '.has_discussions' >/dev/null 2>&1 \
  || printf '  (already enabled, or needs admin)\n'

repo_id="$(gh api graphql -f query="{repository(owner:\"$OWNER\",name:\"$NAME\"){id}}" --jq .data.repository.id)"

cat_id="$(gh api graphql -f query="{repository(owner:\"$OWNER\",name:\"$NAME\"){
  discussionCategories(first:20){nodes{id name isAnswerable}}}}" \
  --jq '.data.repository.discussionCategories.nodes[] | select(.isAnswerable==true) | .id' | head -1)"

if [ -z "$cat_id" ]; then
  printf '! no answerable (Q&A) discussion category found.\n' >&2
  printf '  Create one: https://github.com/%s/discussions/categories\n' "$REPO" >&2
  exit 1
fi

for i in $(seq 1 "$COUNT"); do
  printf '\n▸ discussion %s/%s\n' "$i" "$COUNT"

  d="$(gh api graphql -f query="
    mutation(\$r:ID!,\$c:ID!,\$t:String!,\$b:String!){
      createDiscussion(input:{repositoryId:\$r,categoryId:\$c,title:\$t,body:\$b}){
        discussion{id number}}}" \
    -f r="$repo_id" -f c="$cat_id" \
    -f t="Q&A $i: how does this repo track achievement progress?" \
    -f b="Asking so the answer is recorded in Discussions rather than only in the README." \
    --jq '.data.createDiscussion.discussion | "\(.id) \(.number)"')"
  d_id="${d%% *}"; d_num="${d##* }"
  printf '  opened #%s\n' "$d_num"

  c_id="$(gh api graphql -f query="
    mutation(\$d:ID!,\$b:String!){
      addDiscussionComment(input:{discussionId:\$d,body:\$b}){comment{id}}}" \
    -f d="$d_id" \
    -f b="\`scripts/status.sh\` reports the counters behind each badge: merged PR count with its Pull Shark tier, PRs and issues opened, and stars across owned repos. GitHub exposes no achievements API, so the badge state itself has to be read off the profile page." \
    --jq .data.addDiscussionComment.comment.id)"

  gh api graphql -f query="
    mutation(\$c:ID!){markDiscussionCommentAsAnswer(input:{id:\$c}){clientMutationId}}" \
    -f c="$c_id" >/dev/null
  printf '  answered and marked as accepted\n'
done

printf '\nDone. %s accepted answers this run.\n' "$COUNT"
printf 'Galaxy Brain tiers: 2 / 8 / 16 / 32 — check https://github.com/%s\n' "$(gh api user --jq .login)"
