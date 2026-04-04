---
title: "Automating AI Skills: From Manual Invocation to Always-On Guardrails"
date: 2026-03-19T19:00:00+01:00
draft: false
summary: "How to classify your installed skills as proactive or reactive, and use Claude Code hooks and CLAUDE.md to enforce the right ones automatically."
tags:
- ai
- opensource
- github
categories:
- Technical posts
- Open Source
series: ["AI Skills"]
series_order: 9
---

Skills are useful. Remembering to invoke them is the problem.

After building and installing a collection of skills — [conventional-commit](/posts/conventional-commit-skill/), [diataxis](/posts/diataxis-documentation-skill/), [pin-github-actions](/posts/pin-github-actions-skill/), [french-language](/posts/french-language-skill/), [verify-readme-features](/posts/verify-readme-features-skill/), [verify-pr-logs](/posts/verify-pr-logs-skill/) — I noticed a pattern: the skills that matter most are the ones I forget to invoke. French accents slip through because I did not type `/french-language` before generating an SVG. A commit goes out without conventional format because I forgot `/conventional-commit`. A workflow edit ships with tag-based action references because `/pin-github-actions` was not on my mind.

The skills work. The human loop does not.

Claude Code provides two mechanisms to close this gap: **hooks** (event-driven automation in `settings.json`) and **CLAUDE.md** (persistent instructions loaded at session start). The question is which skills deserve which mechanism.

## Classifying skills: proactive versus reactive

Not every skill should run automatically. The first step is classifying each skill along two axes.

**Proactive versus reactive.** A proactive skill should fire on every relevant action — every commit, every file write, every workflow edit. A reactive skill is useful only when explicitly needed — auditing a README before a release, debugging a CI failure.

**Global versus project-scoped.** Some rules apply everywhere (commit format, supply-chain security). Others apply only to specific projects (French language enforcement, Diataxis documentation structure).

Here is how my eleven installed skills break down:

| Skill | Proactive/Reactive | Scope | Automation |
| :--- | :--- | :--- | :--- |
| conventional-commit | Proactive | Global | Hook + CLAUDE.md |
| french-language | Proactive | Project | Hook + CLAUDE.md |
| pin-github-actions | Semi-proactive | Global | Hook + CLAUDE.md |
| karpathy-guidelines | Proactive | Global | CLAUDE.md only |
| diataxis | Semi-proactive | Project | CLAUDE.md only |
| verify-readme-features | Reactive | — | Manual |
| verify-pr-logs | Reactive | — | Manual |
| drawio-export-tools | Reactive | — | Manual |
| find-skills | Reactive | — | Manual |
| local-branches-status | Reactive | — | Manual |
| open-in-chrome | Reactive | — | Manual |

Five of eleven skills should remain manual. They are either too expensive to run automatically (verify-readme-features scans the entire codebase) or only relevant in specific situations (verify-pr-logs requires a failing CI run). Their skill descriptions already trigger auto-invocation when the user mentions relevant keywords — that is enough.

The interesting work is in the other six.

## CLAUDE.md: persistent behavioral rules

Some skills are best expressed as persistent instructions rather than hooks. The [karpathy-guidelines](/posts/karpathy-guidelines-skill/) skill is a good example — it shapes how the assistant approaches any task, not what it does at a specific lifecycle event. A hook that fires on every tool use would add overhead without adding value. An instruction in CLAUDE.md loads once and stays in context for the entire session.

The global `~/.claude/CLAUDE.md` is the right place for rules that apply to all projects:

```markdown
## Conventions

### Commits
Use the Conventional Commits specification for all commits.
Use the `conventional-commit` skill for every git commit.
Always run `git diff --cached` before writing the message.

### GitHub Actions
When editing `.github/workflows/*.yml`, verify that all action
references are pinned to commit SHAs using `pin-github-actions`.

### Code quality
Apply karpathy-guidelines principles: clarify ambiguity,
surgical changes, no over-engineering.
```

A project-level CLAUDE.md adds project-specific rules. For a French-language project using Diataxis:

```markdown
## Langue

All content must be in French with correct accents.
Use the `french-language` skill when generating or editing files.

## Documentation

Follow the Diataxis framework for all documentation pages.
Use the `diataxis` skill when creating or restructuring docs.
```

CLAUDE.md is lightweight, zero-overhead, and reliable. Its limitation is that it relies on the assistant reading and following the instructions — there is no enforcement mechanism. For rules that must not be skipped, hooks add a safety net.

## Hooks: event-driven enforcement

Claude Code hooks fire on specific lifecycle events. Three hook types are relevant for skill automation:

- **`command`** — runs a shell script, near-instant for simple checks
- **`prompt`** — runs a single-turn LLM evaluation (Haiku), takes 2-5 seconds
- **`agent`** — runs a subagent with tool access, takes 10-30 seconds

The trade-off is speed versus thoroughness. For most skill automation, `command` hooks with fast path checks are sufficient.

### Hook 1: conventional commit guard

**Event:** `PreToolUse` on `Bash`
**Type:** `command`
**Scope:** Global (`~/.claude/settings.json`)

This hook checks if the assistant is about to run a `git commit` command and whether the message follows the conventional format. If not, it injects a warning — non-blocking, just a reminder.

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash -c '..check if git commit follows conventional format..'",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```

**Cost:** <10ms per Bash call. The script exits immediately for non-commit commands. You do not notice it.

### Hook 2: French accent verification

**Event:** `PostToolUse` on `Write|Edit`
**Type:** `prompt`
**Scope:** Project (`.claude/settings.json` in the French-language project)

This is the most valuable automation. Every time the assistant writes or edits a file, a prompt hook checks if the content has French text with missing accents. If it finds issues, it injects a system message telling the assistant to fix them before continuing.

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "prompt",
            "prompt": "Check if the written file contains French text with missing accents...",
            "timeout": 15
          }
        ]
      }
    ]
  }
}
```

**Cost:** ~2-5 seconds per Write/Edit in this project. This is a real cost, but it eliminates the "generate SVG, find missing accents, fix, regenerate" loop that was eating more time than the hook ever will.

### Hook 3: workflow SHA pinning reminder

**Event:** `PostToolUse` on `Write|Edit`
**Type:** `command`
**Scope:** Global (`~/.claude/settings.json`)

Checks if the edited file is a GitHub Actions workflow. If yes, reminds the assistant to verify SHA pinning. If not, exits silently.

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "bash -c '..check if file is .github/workflows/*.yml..'",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```

**Cost:** <10ms. A single path check.

## What I chose not to automate

**Diataxis** — validating documentation structure requires reading multiple files and analyzing their content. Too expensive for a PostToolUse hook. The CLAUDE.md instruction to place files in the right subdirectory is the pragmatic choice. Invoke `/diataxis` for a full audit when needed.

**verify-readme-features** — an audit that scans the entire codebase against README claims. Can take minutes. Running it on every session would be absurd. Invoke before releases.

**verify-pr-logs** — only useful when CI fails. The skill's description triggers it when the user mentions "CI failing" or "check PR logs". No automation needed.

**karpathy-guidelines** — behavioral, not procedural. Its value is in shaping the session, not in firing at specific events. CLAUDE.md is the right mechanism.

## The layered model

The result is a three-layer automation model:

| Layer | Mechanism | When it fires | Skills served |
| :--- | :--- | :--- | :--- |
| **Always-on context** | CLAUDE.md | Session start | karpathy-guidelines, diataxis, conventional-commit, pin-github-actions, french-language |
| **Event-driven checks** | Hooks | Per tool use | conventional-commit (PreToolUse), french-language (PostToolUse), pin-github-actions (PostToolUse) |
| **On-demand audits** | Manual `/skill` | When invoked | verify-readme-features, verify-pr-logs, drawio-export-tools, local-branches-status |

CLAUDE.md provides the baseline — persistent instructions that shape behavior. Hooks add enforcement for the rules that must not be skipped. Manual invocation remains for expensive or situational skills.

The key insight is that not every skill benefits from automation. The five reactive skills work perfectly as manual invocations. Forcing them into hooks would add latency without adding value. Automation should target the skills where forgetting to invoke them has a cost — and for those, even a small overhead per tool use is worth the consistency.

## Getting started

If you have skills installed and want to automate them:

1. **Classify** each skill as proactive or reactive
2. **Add CLAUDE.md instructions** for all proactive skills — this is free and always works
3. **Add hooks** only for the proactive skills where CLAUDE.md instructions alone are not sufficient — where you need enforcement, not just guidance
4. **Leave reactive skills manual** — their descriptions handle auto-invocation when the context matches

The automation should be invisible when it works and obvious when it catches something. If you notice the hooks slowing you down, they are too aggressive. If you still find missing accents or non-conventional commits, they are not aggressive enough. Tune until they disappear into the workflow.
