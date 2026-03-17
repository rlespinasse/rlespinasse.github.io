---
title: "Conventional Commits Skill: Teaching AI Assistants to Write Better Commit Messages"
date: 2026-03-12T17:57:51+01:00
draft: false
summary: "AI coding assistants write code well but often produce vague commit messages. The conventional-commit skill for agent-skills brings the Conventional Commits specification into your coding sessions, guiding assistants through structured, meaningful commit messages."
coverImg: /img/posts/conventional-commit-skill/featured.svg
tags:
- opensource
- github
- ai
categories:
- Technical posts
- Open Source
---

AI coding assistants are remarkably good at writing code.
They refactor functions, fix bugs, and implement features with impressive speed.
But when it comes time to commit that code, the quality often drops.
Generic messages like "update files" or "fix bug" tell you nothing about what changed or why.

Commit messages are documentation.
They are the first thing a reviewer reads in a pull request, the first thing you check when bisecting a bug, and the primary record of why a change was made.
When an AI assistant writes a vague commit message, it creates the same maintenance burden as a vague message from a human — except the AI does it at much higher volume.

## The Conventional Commits specification

[Conventional Commits](https://www.conventionalcommits.org/) is a lightweight convention for structuring commit messages.
Every message follows a predictable format:

```text
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

The type (`feat`, `fix`, `refactor`, `docs`, `ci`, etc.) tells you what kind of change this is.
The optional scope narrows the context.
The description explains what happened.
The body provides additional detail when needed.

This structure is not just for humans — it enables tooling.
Semantic-release can automatically determine version bumps from commit types.
Changelog generators can group changes by category.
CI pipelines can trigger different workflows based on the type of change.

## A skill for AI assistants

The [**conventional-commit**](https://github.com/rlespinasse/agent-skills) skill is part of the [agent-skills](https://github.com/rlespinasse/agent-skills) collection, built on the [agentskills.io](https://agentskills.io) specification.
It works with Claude Code, GitHub Copilot, Cursor, and any assistant that supports the spec.

When activated, the skill guides the assistant through writing a Conventional Commits-compliant message.
Rather than generating a message from a template, the skill teaches the assistant the principles behind good commit messages:

- Choose the right type based on the nature of the change
- Scope the message to the affected area of the codebase
- Write a subject line that is concise but specific
- Include a body when the "why" is not obvious from the "what"
- Use footers for breaking changes, issue references, and co-authorship

The skill was introduced in agent-skills **v1.2.0** and enhanced for complex scenarios in **v1.3.0**.

## Evaluation with 7 scenarios

How do you verify that a skill actually works?
The conventional-commit skill includes seven evaluation scenarios that test the assistant's behavior across different situations:

- Simple single-file changes
- Multi-file changes that span different areas
- Breaking changes that need a footer
- Changes that affect documentation alongside code
- Refactoring where no external behavior changes
- Bugfixes with issue references
- Complex scenarios mixing multiple concerns

Each scenario provides a set of staged changes and checks whether the resulting commit message follows the specification correctly.
This evaluation approach gives confidence that the skill produces consistent results across different assistants and contexts.

## Installing the skill

Adding the conventional-commit skill to your project takes one command:

```bash
npx skills add https://github.com/rlespinasse/agent-skills --skill conventional-commit
```

Once installed, the skill activates when the assistant is about to create a commit.
You can also invoke it explicitly during a session — for example, by asking the assistant to commit the current changes using the Conventional Commits format.

If you are already using the [diataxis skill](/posts/diataxis-documentation-skill/) from the same collection, the installation process is identical.
Both skills coexist and activate independently based on the task at hand.

## What comes next

The agent-skills collection is growing, and the conventional-commit skill continues to be refined based on real-world usage.
The evaluation scenarios provide a foundation for catching regressions as the skill evolves.

If commit message quality matters to your project — and it should — give the skill a try.
It brings the same discipline to AI-assisted commits that Conventional Commits brings to human ones.

```bash
npx skills add https://github.com/rlespinasse/agent-skills --skill conventional-commit
```

Explore the full collection at [github.com/rlespinasse/agent-skills](https://github.com/rlespinasse/agent-skills).
