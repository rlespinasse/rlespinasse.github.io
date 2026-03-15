---
title: "Pin GitHub Actions Skill: Automating SHA Pinning with AI Assistants"
date: 2026-03-15T13:00:00+01:00
draft: false
summary: "Migrating GitHub Actions from tags to commit SHAs is tedious: look up releases, resolve SHAs, dereference annotated tags, update every workflow file. The pin-github-actions skill for agent-skills automates the entire process — including major version detection and Dependabot configuration."
tags:
- opensource
- github
- ci/cd
- security
- ai
categories:
- Technical posts
- Open Source
---

SHA pinning GitHub Actions is a [well-understood security practice](/posts/github-actions-commit-sha-pinning/).
Replacing `actions/checkout@v4` with a full commit SHA prevents a compromised tag from silently changing the code your CI runs.

The problem is not understanding why to do it.
The problem is doing it.

A typical migration means: enumerate every `uses:` reference across all workflow files, look up the latest release for each action, resolve the commit SHA (handling annotated tags that need dereferencing), replace every reference, add version comments, and then configure Dependabot so the SHAs stay current.
For a repository with three workflows and six different actions, this is already tedious.
For an organisation with dozens of repositories, it does not scale without automation.

## What the skill does

The [**pin-github-actions**](https://github.com/rlespinasse/agent-skills) skill is part of the [agent-skills](https://github.com/rlespinasse/agent-skills) collection.
It guides AI coding assistants through the full migration, step by step:

1. **Discover** — scan `.github/workflows/` for all `uses:` references and report which are already pinned
2. **Resolve** — look up the latest release for each action, resolve the commit SHA via the GitHub API, and dereference annotated tags
3. **Pin** — replace tag references with `SHA # vX.Y.Z` format using exact release versions
4. **Configure Dependabot** — set up or update `.github/dependabot.yml` with grouped updates for all discovered ecosystems
5. **Confirm** — present every change for review before applying

The assistant handles the API calls, the tag-versus-commit disambiguation, and the file edits.
You review the result.

## Major version detection

Not every upgrade is safe.
If your workflow uses `actions/checkout@v3` and the latest release is `v4.2.2`, that is a major version jump with potential breaking changes.

The skill instructs the assistant to flag these jumps explicitly, link to the changelog, and ask whether to upgrade or stay on the latest patch of the current major version.
No silent upgrades across major boundaries.

This matters because a migration tool that blindly pins to the latest version can break workflows in ways that are harder to debug than the security issue it was trying to solve.

## Dependabot with grouped updates

Pinning to SHAs without Dependabot creates a maintenance burden — you lose the automatic update notifications that tag-based references provide.
The skill addresses this by configuring Dependabot as part of the migration.

Two design choices are built into the skill:

**Grouped updates.**
By default, Dependabot opens one PR per dependency update.
For a repository with six actions, that means six PRs every time updates are available.
The skill configures grouped updates so all action updates land in a single PR:

```yaml
version: 2
updates:
  - package-ecosystem: 'github-actions'
    directory: '/'
    schedule:
      interval: 'weekly'
    groups:
      dependencies:
        patterns:
          - '*'
```

**Multi-ecosystem discovery.**
The skill does not stop at `github-actions`.
It scans the repository for other dependency sources — `.gitmodules`, `package.json`, `go.mod`, `Gemfile`, `Cargo.toml`, `Dockerfile`, Terraform files — and adds each discovered ecosystem to the Dependabot configuration with the same grouped update pattern.

If a `dependabot.yml` already exists, the skill merges with it rather than overwriting it, preserving any existing labels, reviewers, or ignore rules.

## Evaluation with 7 scenarios

The skill includes seven evaluation scenarios that cover the main decision paths:

- Pinning all actions in a repository from scratch
- Detecting and handling major version jumps
- Setting up Dependabot for a new repository
- Merging with an existing Dependabot configuration
- Auditing already-pinned actions for correctness
- Enforcing exact version comments (never major tags)
- End-to-end migration combining all steps

These scenarios define the expected behavior so the skill produces consistent results regardless of which AI assistant runs it.

## Installing the skill

```bash
npx skills add https://github.com/rlespinasse/agent-skills --skill pin-github-actions
```

Once installed, ask the assistant to pin your GitHub Actions or migrate your workflows to SHA-pinned versions.
The skill activates on keywords like "pin actions", "SHA pinning", "pinned versions", or "supply-chain security".

If you have already installed other skills from the collection — like [conventional-commit](/posts/conventional-commit-skill/) or [diataxis](/posts/diataxis-documentation-skill/) — the process is the same.

## From blog post to automation

The [earlier post on SHA pinning](/posts/github-actions-commit-sha-pinning/) explained why pinning matters and how to do it manually.
This skill turns that knowledge into something an AI assistant can execute on your behalf.

The tedious parts — API lookups, tag dereferencing, file editing, Dependabot configuration — are handled by the assistant.
The important parts — reviewing changes, deciding on major version upgrades, approving the final result — stay with you.

```bash
npx skills add https://github.com/rlespinasse/agent-skills --skill pin-github-actions
```

Explore the full collection at [github.com/rlespinasse/agent-skills](https://github.com/rlespinasse/agent-skills).
