# badge-quest

Working repo for GitHub profile achievements, and an honest map of which ones
can actually be earned solo.

GitHub does not expose achievements through its API, so nothing here can *read*
your badge state. `scripts/status.sh` reports the underlying counters instead
(merged PRs, co-authored merges, accepted discussion answers, stars).

## The badges

| Badge | Requirement | Tiers | Solo? |
|---|---|---|---|
| **Pull Shark** | Merged pull requests | 2 / 16 / 128 / 1024 | yes |
| **YOLO** | Merge a PR without a review | one tier | yes |
| **Quickdraw** | Close an issue or PR within 5 minutes of opening it | one tier | yes |
| **Pair Extraordinaire** | Merged PR with a `Co-authored-by` trailer | 1 / 10 / 24 / 48 | needs a second real account |
| **Galaxy Brain** | Accepted answers in Discussions | 2 / 8 / 16 / 32 | yes, in your own repo |
| **Starstruck** | Stars on a repo you own | 16 / 128 / 512 / 4096 | **no** — needs 16 real people |
| **Public Sponsor** | Sponsor someone through GitHub Sponsors | one tier | **no** — costs real money |

Retired and no longer earnable by anyone: *Arctic Code Vault Contributor*,
*Mars 2020 Helicopter Contributor*, *Heart On Your Sleeve*, *Open Sourcerer*.

So the honest ceiling for a solo account is **five** badges: Pull Shark, YOLO,
Quickdraw, Galaxy Brain, and Pair Extraordinaire if a second account
co-authors. Starstruck needs an audience. Public Sponsor needs a payment.

## Requirements

- `gh` authenticated as the account that should receive the badges
  (`gh auth status`)
- The repo must be **public** — achievements are awarded on public activity
- A private *fork* cannot be made public; a badge repo has to be its own repo

## Caveats worth knowing before you start

- **Achievements are cosmetic.** They appear on your profile and carry no
  weight in code review, hiring pipelines, or repo permissions.
- **Commit authorship is what counts.** Work committed under another account's
  email credits that account, not yours. Check `git config user.email` matches
  the account you want credited.
- **GitHub can decline to award badges for obviously synthetic activity**, and
  has adjusted achievement rules before without notice. Nothing here can
  guarantee a badge lands.
- Achievements can be hidden entirely: Profile settings → *Show Achievements*.

## Layout

```
lib/common.sh       shared helpers (repo detection, counters, dry-run)
scripts/status.sh   read-only: report the counters behind each badge
scripts/*.sh        one script per badge
```

Every script honors `DRY_RUN=1` to print its plan without touching anything.
