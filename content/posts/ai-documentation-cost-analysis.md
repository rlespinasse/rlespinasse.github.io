---
title: "What Does AI-Maintained Documentation Actually Cost?"
date: 2026-04-04T14:00:00+02:00
draft: true
summary: "We measured every token spent maintaining documentation in a real project. 49 files, $2.36 per document at API rates."
featureimage: /img/posts/ai-documentation-cost-analysis/featured.svg
tags:
- ai
- documentation
- claude-code
categories:
- Technical posts
- Documentation
series: ["AI Documentation"]
series_order: 1
---

Nobody measures the cost of documentation.

Teams track CI minutes, cloud spend, test coverage — but documentation is either "we should write more" or "we don't have time."
Most developers do not write docs because the payoff feels distant and the cost feels immediate.

But the cost of *not* having documentation is real and compounding.
A missing how-to guide means every new team member asks the same questions.
An outdated architecture page means the next developer makes decisions based on a system that no longer exists.
An absent reference page means the AI coding assistant guesses instead of looking things up — and guesses wrong.

That last point matters more than it used to.
If you use an AI coding assistant, your documentation is not just for humans anymore.
It is the context your assistant reads before modifying your code.
Good docs mean better suggestions, fewer hallucinations, and less time spent correcting the assistant.
Bad docs — or no docs — mean the assistant works blind.

And there is a compounding effect.
Each coding session starts fresh — the assistant has no memory of previous conversations.
The only knowledge that persists between sessions is what is written down: the code itself, and the documentation around it.
A reference page explaining how callbacks work means the assistant does not reinvent the pattern in session 47 because it was not present in session 12.
An architecture explanation means a new session can make informed trade-offs instead of guessing from function signatures.

Documentation is not just a record of what was built.
It is the grounding layer that keeps every future session anchored to the actual system — instead of drifting into assumptions that diverge further with each conversation.

When an AI coding assistant handles part of the documentation work, the cost becomes measurable for the first time.
Every token is logged, every session is timestamped, every file change is committed.

I decided to look at the numbers.

## The project

The project is an internal AI assistant built on Python, with multiple AI agents and a cloud-based backend.
It has 433+ tests and a documentation set structured using the [Diataxis framework](/posts/diataxis-documentation-skill/).
All development happens with [Claude Code](https://docs.anthropic.com/en/docs/claude-code) on a Max 5x plan — powered by Claude Opus 4.6 — which means every interaction produces a token trail.
The costs shown below are **API-equivalent prices** for comparison, not what was actually billed (the Max plan is a flat subscription).

I analyzed 152 Claude Code sessions associated with the project across all worktrees, and filtered for those that wrote or modified files in the `docs/` folder or `README.md`.
Two skills were involved in the docs work: the [diataxis skill](/posts/diataxis-documentation-skill/) for structuring and classifying documentation, and the [verify-readme-features skill](/posts/verify-readme-features-skill/) for auditing documentation claims against code.

## The calculation method

Claude Code logs token usage per API call, not per file.
A single turn where the assistant reads `architecture.md`, edits `main.py`, and writes `deploy.md` produces one aggregated token count — there is no way to attribute tokens to individual files directly.

To get a fair estimate, I used **proportional attribution**: for each session, I counted how many files were written to docs/ or README.md versus how many files were written in total, then attributed that proportion of the session's tokens to documentation work.

A session that writes 3 docs pages and 7 Python files gets 30% of its tokens counted as docs.
A session that only runs the `/diataxis` skill and writes exclusively to `docs/` gets 100%.
A session that only touches code gets 0%.

## The numbers

Out of 152 sessions, 42 included documentation work.
After proportional attribution, documentation accounts for **20% of the project's total token usage**.

| Metric | Docs (proportional) | All sessions | Docs share |
| :----- | -----------: | -----------: | --------: |
| Input tokens | 35,618 | 227,072 | 16% |
| Output tokens | 356,292 | 2,002,448 | 18% |
| Cache write tokens | 7,483,183 | 33,879,999 | 22% |
| Cache read tokens | 119,744,936 | 627,540,407 | 19% |
| **Total tokens** | **127,620,029** | **663,649,926** | **19%** |

The API-equivalent cost, calculated at [Claude Opus 4.6 pricing](https://platform.claude.com/docs/en/about-claude/pricing) ($5/MTok input, $25/MTok output, $6.25/MTok cache write, $0.50/MTok cache read), comes to **$116 for documentation** out of $577 total.

## Cost per artifact

Those 42 sessions produced 49 markdown files in `docs/` and `README.md`, totaling 7,218 lines across 65 git commits.

| Metric | Value |
| :----- | ----: |
| Cost per documentation file | $2.36 |
| Cost per line of documentation | $0.016 |
| Cost per documentation commit | $1.78 |

Less than two cents per line of structured documentation.
That includes not just the text generation, but the exploration, analysis, classification, verification, and restructuring that goes with it.

To put this in perspective: a technical writer billing €500 per day would produce roughly the same volume in two to three weeks of full-time work — around €5,000 to €7,500.
The API-equivalent cost is $116. On a Max 5x plan at $100/month, it is zero marginal cost — the docs were produced alongside the code in the same subscription.

## One token in five

One in five tokens spent on this project went to documentation.
That sounds like a lot until you consider what those tokens bought.

The documentation set covers the four Diataxis categories:
- **3 tutorials** (in French) for onboarding new team members
- **8 how-to guides** for common tasks: deploying, adding agents, managing data, releasing
- **10 reference pages** covering API, access roles, environment config, data models, troubleshooting
- **6 explanations** of architecture, design decisions, and evaluation methodology

Plus 20 structured analyses exploring potential improvements in security, data quality, and architecture — each following a consistent template with problem statement, proposed approach, and trade-offs.

All structured using the Diataxis framework, with category badges on every page and reclassification decisions tracked in git history with reasoning.

This is not a pile of auto-generated markdown.
It is a maintained documentation system where files get reclassified when their content does not match their category — troubleshooting moved from how-to to reference because it is a lookup table, not a procedure.
Access management documentation was split into a reference page (role tables) and a how-to guide (the granting procedure) because mixing them made neither useful.
The [verify-readme-features skill](/posts/verify-readme-features-skill/) audits the README against the codebase to catch claims that have drifted from reality.

## Where the tokens go

![Token cost breakdown across documentation sessions](/img/posts/ai-documentation-cost-analysis/cost-breakdown.svg)

The cost breakdown reveals something worth understanding about AI-assisted documentation work.

Cache read tokens dominate — 94% of all docs tokens.
These are the cheapest tokens ($0.50 per million at Opus 4.6 rates), and they represent the assistant re-reading project context at the start of each session.
The actual generation work — output tokens — accounts for 356,292 tokens, costing about $9 at API rates.

The expensive sessions are the analytical ones — where the assistant reads the entire codebase to understand what exists before writing about it.
Pure writing sessions are cheap.
Understanding the system well enough to write accurate documentation about it is what costs tokens.

## The flat plan effect

This project runs on Claude Code Max 5x at $100/month.
All 152 sessions — the entire dataset analyzed here — span exactly one month.

At API rates, the same work would have cost $577.
That is a **5.8x return** on the $100 plan.

Documentation alone accounts for $116 at API rates — more than the full monthly subscription.
The docs pay for the plan by themselves, and the remaining $461 of code, tests, and refactoring work comes for free.

But the real value is not the discount.
It is what the flat plan enables.

On a per-token API plan, every documentation session has a visible cost.
A `/diataxis` restructuring that reads the entire codebase before moving a single file burns through cache tokens.
A [verify-readme-features](/posts/verify-readme-features-skill/) audit that searches every source file for evidence costs more than writing the feature itself.
When documentation has a per-token price tag, it is the first thing teams skip when the bill feels high.

On a flat plan, documentation has **zero marginal cost**.
The $100/month is already paid whether you write docs or not.
That changes behavior: you run the diataxis skill because it takes two minutes, not because you calculated whether the tokens are worth it.
You verify the README after every refactor instead of hoping it is still accurate.

The numbers make this concrete:

| | API rates | Max 5x plan |
| :- | --------: | ----------: |
| Total project cost (1 month) | $577 | $100 |
| Documentation share | $116 (20%) | $0 marginal |
| Cost per docs file | $2.36 | $0 marginal |
| Cost per docs line | $0.016 | $0 marginal |

At API rates, the documentation work costs $116 — cheap by any standard.
But "cheap" still creates friction.
A flat plan eliminates that friction entirely, which is why 20% of this project's tokens went to documentation without anyone ever asking "is this worth the cost?"

## Documentation as infrastructure

Teams that treat documentation as an afterthought pay for it in onboarding time, repeated questions, and tribal knowledge that walks out the door when someone leaves.
Teams that treat it as infrastructure invest upfront and recover the cost every time someone — human or AI — needs to understand the system.

The difference with AI-assisted documentation is that the investment is finally measurable.
$116 in API-equivalent tokens. 49 files. 7,218 lines on main. 65 commits with reclassification reasoning in the messages.
On a flat plan, the effective cost of all that documentation is zero — it comes bundled with the rest of the development work.

The cost of not having that documentation is harder to measure, but anyone who has onboarded onto an undocumented project knows what it feels like.

If you are using an AI coding assistant and not tracking how much of your token budget goes to documentation, you are missing the most actionable data point in your development workflow.
Measure it. Budget for it. Or better yet, put it on a flat plan and stop thinking about it — the documentation will happen on its own.
