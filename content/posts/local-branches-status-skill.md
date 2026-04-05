---
title: "Local Branches Status Skill: A Branch Overview That Actually Helps You Act"
date: 2026-04-06T10:00:00+02:00
draft: true
summary: "The local-branches-status skill gives AI assistants a structured process for reporting every local branch with sync state, main diff, worktree path, last activity, and a content description."
featureimage: /img/posts/local-branches-status-skill/featured.svg
tags:
- opensource
- github
- git
- ai
categories:
- Technical posts
- Open Source
series: ["AI Skills"]
series_order: 6
---

Local branches accumulate. Nobody cleans them up.

You come back to a project after a few days away and `git branch` shows twelve branches. Which are merged? Which are stale? Which were never pushed? You run `git branch -vv`, then `git log` on each one, then check worktree paths — and by the time you have the full picture, you have forgotten what you came here to do.

The information exists. It is spread across six different git commands and requires mental assembly every time.

The [**local-branches-status**](https://github.com/rlespinasse/agent-skills) skill collapses that into a single structured report — one table, every branch, all six dimensions at once.

## What the skill does

The skill produces a six-column report for every local branch:

1. **Gather data** — collect all per-branch information in a single shell loop (not N separate commands)
2. **Determine the main branch** — detect it automatically from `origin/HEAD`, fall back to `main` or `master`
3. **Compute each column** — remote sync state, divergence from main, worktree path, last activity date, content description
4. **Present the table** — one row per branch, sorted with main first, active branches next, stale and deletable branches last
5. **Add actionable notes** — flag candidates for deletion, stale branches, unpushed branches, and diverged branches

The assistant reads the actual commits to describe each branch.
It does not guess from the branch name.

## The table

Every report follows the same structure:

```markdown
| Branch | Remote | Main diff | Worktree | Last activity | Description |
| --- | --- | --- | --- | --- | --- |
| **main** * | synced | — | …/rlespinasse/agent-skills | 22 hours ago | Current working branch |
| **feature/auth** | synced with `origin/feature/auth` | +3 ahead, -1 behind | …/wt/auth | 2 days ago | Add OAuth2 authentication flow |
| **old/legacy** | no upstream | 0 ahead, -15 behind | no worktree | 3 months ago | Fully merged into main, can be deleted |
```

The current branch is marked with `*`.
The worktree column shows the actual path, truncated to the last two segments, so you can navigate directly.
The last activity column shows relative time — `2 days ago`, `3 weeks ago` — so you can prioritize by recency rather than just by commit count.

## Stale branch detection

The skill applies a concrete threshold rather than a vague heuristic.
A branch is flagged as stale when it meets two conditions simultaneously:

- **10 or more commits behind main** — the gap is large enough that a rebase is non-trivial
- **No unique commits in the last 30 days** — no recent work, so the branch is not actively being developed

Both conditions must be true.
A branch 15 commits behind main but updated yesterday is still active — it just needs a rebase.
A branch with no recent activity but only 3 commits behind main is nearly caught up — not worth flagging.

## Batch data collection

The skill collects all branch data in a single shell loop.

```bash
for branch in $(git for-each-ref --format='%(refname:short)' refs/heads/); do
  # remote sync, main diff, last activity, worktree path, unique commits
  # — all in one pass
done
```

This matters for AI assistants because the alternative — one tool call per branch per column — is slow and scales poorly.
A repository with ten branches and six columns would otherwise mean sixty separate commands.
The batch pattern brings that down to one.

## What I observed in practice

The biggest win is not the table itself — it is what happens after the table. Before the skill, I would run a few git commands, get a rough sense of the situation, and move on. Stale branches survived for weeks because the cost of investigating them was higher than the cost of ignoring them.

With a structured report, the cost drops to zero. The table tells me "this branch is fully merged and 3 months old" — I delete it. "This branch has unpushed commits from 2 days ago" — I push it. The information was always available; the skill makes it actionable.

One pattern I did not expect: the content description column turns out to be the most useful. Branch names like `feature/auth` or `fix/issue-42` give you a hint. But the skill reads the actual commits and produces a one-line summary — "Add OAuth2 flow with refresh token rotation" is more useful than `feature/auth` when deciding what to keep.

The skill also explicitly avoids running `git fetch` without approval. This matters — a fetch can be slow on large repos and may pull changes you are not ready to deal with. The skill reports what it sees locally and lets you decide when to sync.

## Installing the skill

```bash
npx skills add https://github.com/rlespinasse/agent-skills --skill local-branches-status
```

Once installed, the skill activates on phrases like "branch status", "branch overview", "local branches", or "branch report".
You can also trigger it explicitly with `/local-branches-status`.

If you already have skills from the collection installed — [conventional-commit](/posts/conventional-commit-skill/), [diataxis](/posts/diataxis-documentation-skill/), or [pin-github-actions](/posts/pin-github-actions-skill/) — the installation process is the same.

## From ad-hoc commands to a reliable overview

The individual git commands for this information already exist.
The skill combines them into a repeatable process with a consistent output format, a concrete staleness definition, and a single-pass data collection pattern that keeps the assistant efficient.

The result is an overview you can act on: branches to delete, branches to rebase, branches to push.

```bash
npx skills add https://github.com/rlespinasse/agent-skills --skill local-branches-status
```

Explore the full collection at [github.com/rlespinasse/agent-skills](https://github.com/rlespinasse/agent-skills).
