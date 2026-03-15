---
title: "Consistent Link Titles at Scale: A Textlint Rule for Title Case"
date: 2026-03-13T10:00:00+01:00
draft: false
summary: "The awesome-actions curated list already required AP Style title case for links — but enforcing it was manual. The textlint-rule-link-title-case rule automates that existing convention, catching what human reviewers miss and fixing what they would rather not fix by hand."
tags:
- opensource
- github
- textlint
categories:
- Technical posts
- Open Source
---

Curated lists are deceptively hard to maintain.
The content itself is straightforward — a link, a short description, maybe a category header — but once dozens of contributors start opening pull requests, small inconsistencies pile up.

The original [awesome-actions](https://github.com/sdras/awesome-actions) repository already required AP Style title case for link text.
That convention kept things readable, but enforcing it relied entirely on human reviewers catching mistakes during pull request reviews.
One PR capitalizes every word, another lowercases prepositions that should stay capitalized, and a third uses sentence case where title case is expected.
Multiply that by hundreds of entries and the review burden becomes unsustainable.

When I forked the project into [**awesome-actions**](https://github.com/actions-able/awesome-actions) under the actions-able organization, I wanted to keep the same convention but remove the manual effort.
The goal was clear: automate the AP Style title case check that was already part of the contribution guidelines.

## The gap in existing tooling

[Textlint](https://textlint.github.io/) is a pluggable linting framework for natural language in Markdown and other text formats.
There are rules for spelling, terminology, sentence length, and even title case on headings.
But when I looked for a rule that checks title case on **link text** — the visible part inside `[brackets]` — I came up empty.

Heading title case and link title case follow the same capitalization logic, but they apply to completely different Markdown nodes.
A heading rule will never flag `[some link text](https://example.com)` no matter how badly it is capitalized.
The existing convention from sdras/awesome-actions was solid — it just needed a tool to enforce it automatically.

## Introducing textlint-rule-link-title-case

[**textlint-rule-link-title-case**](https://github.com/rlespinasse/textlint-rule-link-title-case) fills that gap.
It enforces AP Style title case on three kinds of Markdown links:

- **Inline links:** `[Link Text](url "Optional Title")`
- **Link references:** `[Link Text][reference-id]`
- **Link definitions:** `[reference-id]: url "Optional Title"`

Both the visible link text and the optional title attribute are checked by default.

## What the rule checks

The rule follows the AP Style capitalization conventions that were already expected in the original repository:

- Capitalize the first and last words, always.
- Capitalize all words of four letters or more.
- Capitalize nouns, pronouns, adjectives, verbs, adverbs, and subordinating conjunctions regardless of length.
- Lowercase articles (*a*, *an*, *the*), coordinating conjunctions (*and*, *but*, *or*, *for*, *nor*), and prepositions of three letters or fewer — unless they are the first or last word.

So `[a guide to writing github actions]` becomes `[A Guide to Writing GitHub Actions]`.

## Configuration and features

The rule works out of the box with sensible defaults, but it exposes a few options for projects that need them.

**Choosing what to check.** By default both link text and link titles are validated. You can turn either off independently:

```json
{
  "rules": {
    "link-title-case": {
      "checkLinkText": true,
      "checkLinkTitle": false
    }
  }
}
```

**Handling brand names.** Some terms have unconventional capitalization — *GitHub*, *Next.js*, *iOS*. The `specialTerms` option lets you define a mapping so the rule knows that `nextjs` should become `Next.js` rather than `Nextjs`:

```json
{
  "rules": {
    "link-title-case": {
      "specialTerms": {
        "nextjs": "Next.js",
        "github": "GitHub",
        "ios": "iOS"
      }
    }
  }
}
```

**Autofixing.** Run textlint with the `--fix` flag and the rule will correct every violation it finds. For a list with hundreds of links, this turns a tedious manual pass into a single command.

## How it fits into awesome-actions

The [awesome-actions](https://github.com/actions-able/awesome-actions) repository uses a `justfile` to orchestrate its quality checks.
Three dedicated linting tasks run in parallel, each targeting a different concern:

- `just textlint` — checks terminology and language.
- `just textlint-titlecase` — validates heading title case.
- `just textlint-linktitlecase` — validates link title case using this rule.

These same tasks run in the GitHub Actions workflow on every pull request.
When a contributor submits a new entry with inconsistent capitalization, the CI pipeline catches it immediately and the contributor can run `just fix` locally to apply corrections before pushing again.

This setup turns a convention that used to depend on reviewer discipline into a guarantee.
Maintainers no longer need to leave review comments about capitalization.
The linter handles the mechanical checks so that human reviewers can focus on whether the linked project is a good fit for the list and whether the description is accurate.

## Getting started

Install the rule alongside textlint:

```bash
npm install textlint textlint-rule-link-title-case --save-dev
```

Add it to your `.textlintrc`:

```json
{
  "rules": {
    "link-title-case": true
  }
}
```

Run it against your Markdown files:

```bash
npx textlint "**/*.md"
```

And when you are ready to fix everything in one go:

```bash
npx textlint --fix "**/*.md"
```

## What comes next

The rule covers the core use case — AP Style title case on links — and the autofix capability makes adoption painless even on large existing documents.
Future improvements could include support for additional title case styles or smarter handling of edge cases like acronyms and hyphenated compounds.

If you maintain a curated list, a documentation site, or any project where link text should look polished and consistent, give [textlint-rule-link-title-case](https://github.com/rlespinasse/textlint-rule-link-title-case) a try.
Issues and pull requests are welcome on the [GitHub repository](https://github.com/rlespinasse/textlint-rule-link-title-case).
