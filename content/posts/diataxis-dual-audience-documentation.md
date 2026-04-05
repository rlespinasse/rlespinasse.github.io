---
title: "Diataxis Was Designed for Humans — It Works Even Better for AI"
date: 2026-04-20T10:00:00+02:00
draft: true
summary: "91% of our Diataxis-structured documentation serves both human readers and AI coding assistants. That was not the plan — it is a property of the framework."
featureimage: /img/posts/diataxis-dual-audience-documentation/featured.svg
tags:
- ai
- documentation
- diataxis
categories:
- Technical posts
- Documentation
series: ["AI Documentation"]
series_order: 2
---

I audited our documentation to find out who actually reads it.

The project — an internal AI assistant built on Python — uses [Claude Code](https://docs.anthropic.com/en/docs/claude-code) for all development.
The docs are structured with the [Diataxis framework](/posts/diataxis-documentation-skill/).
I wanted to know: for each document, is the primary audience a human, an AI agent, or both?

The answer surprised me.

## The finding

I classified every file in the `docs/` folder and the project READMEs by who uses them in practice — not who they were written for, but who actually reads and acts on them.

| Audience | Files | Lines | Share |
| :------- | ----: | ----: | ----: |
| Both human and AI | 46 | 6,806 | 91% |
| Human only | 4 | 689 | 9% |
| AI only | 0 | 0 | 0% |

91% of the documentation in `docs/` serves both audiences.
The remaining 9% is human-only: three tutorials written in French for onboarding, and the CONTRIBUTING guide.
No documentation in `docs/` exists solely for AI consumption.

This was not designed.
We did not write docs "for the AI."
We structured them for humans using Diataxis, and the AI turned out to be a natural consumer of the same material.

## Why Diataxis is machine-readable

Each Diataxis category maps to a distinct information need.
It turns out AI coding assistants have the same needs as human readers — they just process the information differently.

**Reference pages** are the strongest dual-audience category.
A table of access roles, a list of environment variables, an API endpoint specification — these are structured data that humans scan visually and AI agents parse for decision-making.
When Claude Code needs to determine which role a new service account requires, it reads the roles reference page the same way a human operator would.
The tabular format that makes reference pages easy for humans to scan also makes them easy for AI to extract facts from.

**How-to guides** are sequential and goal-oriented.
A deployment procedure or a release checklist is a series of numbered steps with preconditions and verification commands.
When Claude Code executes the `/release` workflow, it follows `release-process.md` step by step — the same document a human would follow to do a manual release.
The structure that keeps humans from missing steps also keeps AI agents on track.

**Explanations** provide architectural context.
When Claude Code modifies code that touches the clarification strategy or the context enrichment pipeline, it reads the corresponding explanation pages to understand why the system was designed that way.
Humans read the same pages when they need to understand trade-offs before proposing changes.
The "why" is equally valuable to both audiences.

**Tutorials** are the exception.
Learning-oriented guides assume a human who needs to build confidence through guided practice.
An AI agent does not need confidence — it needs facts and procedures.
Our three tutorials (in French, for team onboarding) are the only category that serves humans exclusively.

## Reclassification as proof

The strongest evidence that Diataxis categories serve both audiences came from reclassification decisions — moments where we moved a document from one category to another because its content did not match.

**Troubleshooting: how-to → reference.**
The troubleshooting page was originally in `how-to/` because it felt like guidance.
But its actual structure was a symptom-fix lookup table — given an error message, find the solution.
That is reference material: structured, factual, lookup-oriented.
After the move, humans find answers faster (they scan the table instead of reading a narrative), and AI agents extract symptom-fix pairs more reliably (structured rows instead of prose paragraphs).
Both audiences benefited from the correct classification.

**Access management: split reference and how-to.**
The roles page originally mixed two things: a table of which roles exist (reference) and a procedure for granting access (how-to).
Splitting them gave humans a clean lookup table and a focused task guide.
It also gave Claude Code two distinct resources: the role table for access decisions during infrastructure changes, and the procedure for when a user asks how to grant access.
One page serving two purposes poorly became two pages each serving both audiences well.

## The feedback loop

In this project, Claude Code is not just a consumer of documentation — it is also an author.

The [diataxis skill](/posts/diataxis-documentation-skill/) classifies and restructures documentation.
The [verify-readme-features skill](/posts/verify-readme-features-skill/) audits documentation claims against the codebase.
The `/redteam-analysis` skill produces security analysis pages from evaluation results.

This creates a loop:

![The documentation feedback loop](/img/posts/diataxis-dual-audience-documentation/feedback-loop.svg)

1. **AI writes docs** — structured pages following Diataxis categories, analysis pages, verified README content
2. **AI reads docs** — when modifying code, the assistant reads reference pages, explanations, and how-to guides for context
3. **Better code changes** — informed by accurate documentation, the changes are more aligned with the system's design
4. **Docs stay current** — because the AI that writes code also maintains docs, they update together

The loop only works if the documentation is structured in a way that both writing and reading benefit from.
Diataxis provides that structure.
A flat folder of markdown files would not — the AI would not know which file to consult for a role lookup versus a deployment procedure.

## The compass works for AI too

Diataxis classifies documentation along two axes:

- **Action vs. Cognition** — does the reader do something or understand something?
- **Acquisition vs. Application** — is the reader studying or working?

AI coding assistants operate on the same axes.
When Claude Code is deploying a service, it needs action-oriented, application-focused content — a how-to guide.
When it is deciding which access role to assign, it needs information-oriented, application-focused content — a reference page.
When it is modifying the clarification strategy, it needs cognition-oriented, acquisition-focused content — an explanation.

The compass was designed by observing how humans use documentation.
It turns out AI agents use documentation the same way — they just do it faster and more literally.
A human might skim a how-to guide and skip to step 4.
An AI agent reads every step and executes them in order.
Both benefit from the same structure, but the AI benefits more from the consistency that Diataxis enforces.

## What this means in practice

If you are already using Diataxis, you have AI-readable documentation for free.
You did not need to do anything special — the framework's insistence on separating concerns by information need produces documents that are naturally parseable by AI agents.

If you are not using Diataxis but you use AI coding assistants, consider what your docs look like from the assistant's perspective.
A single README with installation instructions, API reference, design rationale, and a getting-started guide in one file is hard for humans to navigate and hard for AI to extract specific information from.
Splitting it into four focused documents — following the Diataxis categories — makes it better for both audiences simultaneously.

The 91% dual-audience finding is not unique to this project.
It is a property of the framework.
Any documentation set structured around the four Diataxis categories will naturally serve both human readers and AI agents, because the categories reflect fundamental information needs that are audience-independent.

Diataxis was designed for humans.
It turns out that was enough.
