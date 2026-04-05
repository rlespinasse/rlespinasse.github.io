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

Returning to a project after a few days away means answering a set of questions that should be simple but rarely are.
Which branches are still relevant?
Which are already merged?
Which are so far behind main that rebasing them is more work than starting over?
Which ones were never pushed?

Running `git branch -vv` gives you names and upstream references.
Running `git log` for each branch gives you commits.
But piecing together a full picture — sync state, divergence from main, worktree usage, recency, purpose — requires several commands and mental assembly.

The [**local-branches-status**](https://github.com/rlespinasse/agent-skills) skill is part of the [agent-skills](https://github.com/rlespinasse/agent-skills) collection.
It gives AI coding assistants a structured process for collecting and presenting that full picture in one table.

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

## Evaluation with 7 scenarios

The skill includes seven evaluation scenarios:

- Full branch report with all six columns
- Identifying cleanup candidates using the stale threshold
- Detecting unpushed branches with no upstream
- Worktree overview showing actual paths
- Branch summary after returning to a project
- Confirming the skill does not run `git fetch` without approval
- Handling an ambiguous "what branches do I have?" request

These scenarios define expected behavior so the skill produces consistent results regardless of which AI assistant runs it.

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
