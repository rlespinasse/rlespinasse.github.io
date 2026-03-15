---
title: "Karpathy Guidelines: Keeping AI Assistants from Overthinking Your Code"
date: 2026-03-15T18:00:00+01:00
draft: false
summary: "LLM coding assistants are fast, but they tend to over-engineer, refactor things nobody asked for, and hide assumptions. The karpathy-guidelines skill — based on Andrej Karpathy's observations — installs four behavioral guardrails that make sessions noticeably more disciplined."
tags:
- ai
- opensource
- github
categories:
- Technical posts
- Open Source
---

AI coding assistants are fast and capable.
But they have a persistent set of bad habits: adding abstractions nobody asked for, refactoring adjacent code that was working fine, hiding assumptions instead of stating them, and building in "flexibility" for scenarios that will never happen.

These are not capability problems.
The model can write correct, minimal code — it just defaults to doing too much.
Left unchecked, you end up reviewing diffs that are three times larger than they need to be.

Andrej Karpathy catalogued these patterns in a [post on X](https://x.com/karpathy/status/2015883857489522876), and they resonated because every developer who has used an LLM assistant has seen them.

The [**karpathy-guidelines**](https://github.com/forrestchang/andrej-karpathy-skills) skill, created by [forrestchang](https://github.com/forrestchang), translates Karpathy's observations into behavioral guardrails that activate during coding sessions.

## The four guidelines

The skill is built around four principles, each targeting a specific failure mode.

**Think Before Coding.**
Surface assumptions explicitly. If multiple interpretations exist, present them instead of picking silently. If something is unclear, stop and ask.

**Simplicity First.**
No features beyond what was asked. No abstractions for single-use code. No error handling for impossible scenarios.
The skill's own formulation is direct: "If you write 200 lines and it could be 50, rewrite it."

**Surgical Changes.**
Touch only what the request requires. Do not improve adjacent code, comments, or formatting. Match the existing style even if you would do it differently.

**Goal-Driven Execution.**
Transform vague requests into verifiable goals. "Fix the bug" becomes "write a test that reproduces it, then make it pass." For multi-step tasks, state a plan with verification checks at each step.

## Why behavioral guidelines matter

Most skills are task-oriented.
The [conventional-commit](/posts/conventional-commit-skill/) skill structures commit messages.
The [pin-github-actions](/posts/pin-github-actions-skill/) skill migrates workflows to SHA-pinned versions.
The [diataxis](/posts/diataxis-documentation-skill/) skill organizes documentation.

The karpathy-guidelines skill is different — it is a meta-skill.
It does not perform a specific task. It constrains *how* the assistant approaches any task.
This means it complements task-specific skills without conflict.

The skill is honest about its tradeoff: these guidelines bias toward caution over speed.
For trivial tasks, you may want the assistant to just act. For anything non-trivial, the added discipline pays for itself in smaller diffs and fewer surprises.

## What I have observed in practice

I invoke the skill explicitly with `/karpathy-guidelines`.
I do not autoload it — I activate it deliberately when the work is non-trivial: debugging production issues, refactoring shared modules, or implementing features across multiple files.
For quick one-off edits, I skip it and let the assistant move fast.

I also use the skill after a session is done, as a review lens.
I invoke `/karpathy-guidelines` and ask the assistant to look back at the work — the code that was written, the changes that were made — and identify any surface for improvement against the four guidelines.
Did an implementation introduce unnecessary abstractions? Did a fix skip stating its assumptions? Could a multi-file change have been more surgical?
This turns the skill into a lightweight retrospective tool, catching patterns that slipped through during the session itself.

The most visible change is in how the assistant handles ambiguity.
In one session, I asked it to fix a 404 error on a cached agent reference.
Without the skill, this kind of request typically gets a single proposed fix.
With it, the assistant surfaced the root cause first — the cached reference pointed to a deleted resource — then presented three distinct approaches: checking agent state after lookup, catching the error and recreating, or deleting the stale reference and retrying.
It asked which approach I preferred before writing any code.

That pattern repeats across sessions.
The assistant stops to clarify assumptions before implementing rather than picking a path silently.
When I ask for a fix, it frames success as a verifiable goal — "write a test that reproduces the issue, then make it pass" — rather than just changing code until it looks right.

The effect is not absolute.
The assistant will still occasionally over-engineer or make assumptions.
But the frequency drops noticeably, and when it does happen, the scope of the unwanted changes is smaller.
Diffs stay closer to what the request actually required.

The skill coexists well with other installed skills.
I regularly run it alongside [conventional-commit](/posts/conventional-commit-skill/) and [diataxis](/posts/diataxis-documentation-skill/) in the same session.
There is no interference — the behavioral guidelines shape how the assistant works, while the task skills shape what it works on.
Having both karpathy-guidelines and conventional-commit active means I get surgical code changes followed by well-structured commit messages.

## Installing the skill

```bash
npx skills add https://github.com/forrestchang/andrej-karpathy-skills --skill karpathy-guidelines
```

Once installed, invoke it at the start of a session with `/karpathy-guidelines`.
The guidelines then apply for the rest of the session — during coding, reviewing, or refactoring.

## A useful default

If you use an AI coding assistant regularly, the karpathy-guidelines skill is a sensible default for non-trivial work.
It addresses the most common friction points — over-engineering, unsolicited refactoring, hidden assumptions — without limiting what the assistant can do.

Credit to [forrestchang](https://github.com/forrestchang) for packaging Karpathy's observations into an installable skill, and to [Andrej Karpathy](https://x.com/karpathy/status/2015883857489522876) for articulating the patterns in the first place.

```bash
npx skills add https://github.com/forrestchang/andrej-karpathy-skills --skill karpathy-guidelines
```

The skill repository is at [github.com/forrestchang/andrej-karpathy-skills](https://github.com/forrestchang/andrej-karpathy-skills).
