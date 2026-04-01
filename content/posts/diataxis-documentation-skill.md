---
title: "Diataxis Meets AI: A Documentation Skill for Coding Sessions"
date: 2026-03-11T14:00:00+01:00
draft: false
summary: "The diataxis skill for agent-skills brings the Diataxis documentation framework into AI coding sessions, keeping docs well-structured."
featureimage: /img/posts/diataxis-documentation-skill/featured.svg
tags:
- opensource
- github
- documentation
- ai
categories:
- Technical posts
- Open Source
- Documentation
series: ["AI Skills"]
series_order: 1
---

Good documentation does not happen by accident.
When the focus is on shipping features, docs tend to drift —
a readme grows a few paragraphs here, a guide appears there,
and before long nobody is quite sure where things belong.
AI coding assistants like Claude, GitHub Copilot, or Cursor are brilliant at writing code,
but they do not inherently know how a project's documentation should be organized.
Without a shared framework, every contributor — human or AI — adds pages in whatever spot feels right at the moment.

That is why I built the **diataxis** skill inside [agent-skills](https://github.com/rlespinasse/agent-skills):
a way to bring a proven documentation methodology directly into a coding session.

## What is Diataxis?

[Diataxis](https://diataxis.fr/) is a documentation framework created by Daniele Procida.
Its core idea is simple: documentation serves four distinct needs, and each one calls for a different style of writing.

- **Tutorials** — learning-oriented. They walk a newcomer through a complete experience step by step, building confidence along the way.
- **How-to guides** — task-oriented. They give a practitioner the sequence of actions needed to solve a specific problem.
- **Explanations** — understanding-oriented. They provide context, background, and the reasoning behind design decisions.
- **Reference** — information-oriented. They offer precise, complete, and trustworthy technical descriptions.

The insight that makes Diataxis powerful is that mixing these categories in a single page makes documentation harder to use.
A tutorial that detours into exhaustive API reference loses the learner.
A reference page that tries to teach concepts becomes noisy for the practitioner who just needs a function signature.
Keeping the four types separate lets every reader find exactly what they need, when they need it.

## Bringing Diataxis into your coding sessions

[Agent-skills](https://github.com/rlespinasse/agent-skills) is a collection of installable skills for AI coding assistants,
built on the [agentskills.io](https://agentskills.io) specification.
Once installed, skills activate contextually and give the AI assistant specialized guidance for specific tasks.
If you are interested in documentation tooling beyond AI skills, you might also enjoy [how Antora handles multi-repo documentation](/posts/antora-en/).

The **diataxis** skill teaches the assistant to apply the Diataxis framework whenever it touches project documentation.
It works with Claude Code, GitHub Copilot, Cursor, and any tool that supports the agentskills.io spec —
which means the same documentation discipline is available regardless of which AI assistant a contributor prefers.

## How the diataxis skill works

The skill follows a four-step process designed to be thorough without being disruptive:

![The four-step diataxis skill workflow](/img/posts/diataxis-documentation-skill/workflow.svg)

1. **Discover** — The skill scans the project for existing documentation files: Markdown pages, readmes, wiki entries, and anything else that looks like prose meant for humans.
2. **Classify** — Each document is assigned to one of the four Diataxis categories. Pages that blend multiple categories are flagged so they can be split or refocused.
3. **Propose** — Based on the classification, the skill suggests a restructured documentation layout. It identifies gaps — maybe there are plenty of how-to guides but no tutorials — and recommends new pages to fill them.
4. **Execute** — With the contributor's explicit approval, the skill carries out the restructuring: creating, moving, or rewriting pages as needed.

The approval step is intentional.
Documentation restructuring touches the entire project, and no automated process should reorganize your docs without you signing off.
The skill respects your existing structure and proposes incremental improvements rather than forcing a complete overhaul.
All content is preserved — nothing gets deleted, only reorganized or expanded.

## Getting started

Installing the diataxis skill takes a single command:

```bash
npx skills add https://github.com/rlespinasse/agent-skills --skill diataxis
```

Once installed, the diataxis skill is available in your next coding session.
You can ask the AI assistant explicitly — for example, _"review this project's documentation using the diataxis framework"_ —
or it will activate on its own when it detects documentation-related work in the session.

The skill becomes part of the assistant's toolbox and is ready to use immediately.

## Why this matters for contributors

Whether a contributor is a human opening a pull request or an AI assistant generating changes during a coding session,
the diataxis skill provides the same guardrails.

During a typical session, documentation changes happen alongside code changes.
A new feature needs a how-to guide, a refactor invalidates part of the reference, a bugfix reveals a gap in the tutorials.
Without a framework, these changes are ad hoc — the contributor writes something, hopes it lands in the right place, and moves on.
With the diataxis skill active, the assistant knows where each piece of documentation belongs and can suggest the right location and format before the change is even committed.

This reduces the review burden on maintainers.
Instead of manually checking whether a documentation PR follows the project's structure,
the framework is already baked into the workflow.
Reviews can focus on accuracy and clarity rather than organization.

## What comes next

The agent-skills project is actively growing.
The [conventional-commit](https://github.com/rlespinasse/agent-skills) skill was recently added to help with well-structured commit messages,
and more skills are in the pipeline.

If you maintain a project where documentation quality matters — and it always does —
give the diataxis skill a try.
Explore the repository, open an issue if something does not fit your workflow,
or contribute a skill of your own.

```bash
npx skills add https://github.com/rlespinasse/agent-skills --skill diataxis
```

The goal is straightforward: make AI coding assistants not just code-aware, but documentation-aware.
