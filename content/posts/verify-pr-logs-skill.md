---
title: "Verify PR Logs Skill: Diagnosing CI Failures Without Leaving Your Terminal"
date: 2026-04-10T10:00:00+02:00
draft: true
featureimage: /img/posts/verify-pr-logs-skill/featured.svg
summary: "The verify-pr-logs skill fetches GitHub Actions logs, triages failure types, diagnoses root causes, and guides fixes — all through the gh CLI."
tags:
- ai
- opensource
- github
- ci/cd
categories:
- Technical posts
- Open Source
series: ["AI Skills"]
series_order: 8
---

A CI failure on a pull request triggers a predictable loop: open GitHub, find the failed check, click through to the logs, scroll past setup and dependency installation, find the actual error, copy it, switch back to the editor, figure out the fix, push, wait, repeat.

The context switching is the expensive part. Not the fix itself — most CI failures are lint errors, test failures, or type mismatches that take minutes to resolve. But the time spent navigating between GitHub's UI and your editor adds up, especially when multiple checks fail or the logs are long.

The [**verify-pr-logs**](https://github.com/rlespinasse/agent-skills) skill keeps the entire diagnosis-and-fix loop in the terminal. It uses the `gh` CLI to fetch logs, triage failures, identify root causes, and guide the assistant to implement fixes — without opening a browser.

## The seven-step process

The skill defines a structured workflow that mirrors how an experienced developer debugs CI failures, but faster.

**Step 1 — Identify the PR.** If the user provides a PR number, use it. Otherwise, detect it from the current branch with `gh pr view`. Confirm before proceeding.

**Step 2 — List check runs.** Fetch all checks with `gh pr checks` and present a summary table. If everything passes, stop. Only proceed with failed checks.

**Step 3 — Fetch failed logs.** This is where the skill earns its keep. It always uses `--log-failed` first — never full logs. Full CI logs can be thousands of lines of setup boilerplate, dependency installation, and framework banners. The failed-only filter cuts straight to the error.

```bash
gh run view <run-id> --log-failed
```

If `--log-failed` produces no useful output, it falls back to the tail of the full logs. But the default is always the filtered view.

**Step 4 — Triage the failure type.** The skill categorizes failures by their log signals:

| Failure type | Log signals | Typical fix location |
| :--- | :--- | :--- |
| Lint / format | `eslint`, `prettier`, `flake8` | Source files flagged in output |
| Test failure | `FAIL`, `AssertionError` | Test file or implementation |
| Build / compile | `error TS`, `cannot find module` | Source files referenced |
| Timeout | `exceeded`, `timed out` | CI config or slow test |
| Permission / auth | `403`, `401`, `permission denied` | Workflow config or secrets |
| Dependency | `not found`, `resolve failed` | Lock file or package manifest |
| Workflow config | `Invalid workflow`, `syntax error` | `.github/workflows/*.yml` |

This categorization determines where to look for the fix — a critical distinction that saves time.

**Step 5 — Diagnose the root cause.** Skip the boilerplate, find the first error (not cascading errors that follow), trace it to a specific file and line number.

**Step 6 — Implement the fix.** Fix in the correct location. Code errors go in source files. CI configuration errors go in workflow files. Dependency errors go in lock files. The skill explicitly prevents the anti-pattern of fixing CI issues in source code or vice versa.

**Step 7 — Re-verify.** Run the failing command locally, push, and watch the CI run with `gh run watch`.

## Code issues versus CI issues

The most common misdiagnosis in CI debugging is confusing code issues with CI issues. A test that passes locally but fails in CI might be a code problem (OS-specific behavior) or a CI problem (environment differences, missing secrets, path issues).

The skill provides a decision table:

| Symptom | Likely CI issue | Likely code issue |
| :--- | :--- | :--- |
| Works locally, fails in CI | Environment, secrets, or paths | Rare — check OS-specific code |
| Failed on unrelated step | Workflow config | Not a code issue |
| Same test fails intermittently | Flaky test or resource contention | Test isolation problem |
| Failure matches code changes | Unlikely | Check the diff |

This saves the round-trip of pushing a "fix" to source code when the problem is in the workflow configuration.

## What I have observed in practice

The biggest time saver is the `--log-failed` default. Before using the skill, I would fetch full logs and manually search for the error. Full CI logs for a Node.js project with linting, testing, and building can easily be 2,000+ lines. The failed-only filter typically reduces that to 10-30 lines of actual error output.

The triage step also prevents a common mistake: jumping to fix the first error you see without understanding the failure type. A `cannot find module` error after a dependency update is a lock file issue, not a source code issue. The skill's categorization guides the assistant to the right fix location on the first try.

I use the skill alongside [conventional-commit](/posts/conventional-commit-skill/) in a tight loop: diagnose the failure, fix it, commit with a well-structured message, push, verify. The two skills complement each other without overlap.

## Anti-patterns the skill prevents

| Anti-pattern | Why it fails | What the skill does instead |
| :--- | :--- | :--- |
| Fetching full logs first | Floods context with thousands of lines | Always uses `--log-failed` first |
| Blindly re-running failed jobs | Masks issues, wastes CI minutes | Diagnoses root cause before re-running |
| Fixing CI issues in source code | Wrong location | Distinguishes code vs CI issues |
| Skipping local reproduction | Fix may not work | Runs failing command locally first |
| Fixing without explaining | User cannot review the diagnosis | Always explains before implementing |

## Installing the skill

```bash
npx skills add https://github.com/rlespinasse/agent-skills --skill verify-pr-logs
```

Once installed, the skill activates when you mention CI failures, PR logs, pipeline errors, or broken builds. You can also invoke it explicitly with `/verify-pr-logs` and optionally pass a PR number.

## CI debugging belongs in the terminal

The browser-based CI debugging loop — click, scroll, copy, switch, fix, push, wait — is a workflow that tolerates interruption at every step. The verify-pr-logs skill collapses that loop into a single terminal session where the assistant handles the log fetching and triage while you focus on reviewing the diagnosis and approving the fix.

```bash
npx skills add https://github.com/rlespinasse/agent-skills --skill verify-pr-logs
```

The skill is part of the [agent-skills](https://github.com/rlespinasse/agent-skills) collection.
