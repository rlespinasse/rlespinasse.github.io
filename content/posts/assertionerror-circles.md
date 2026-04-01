---
title: "AssertionError Circles: Watching an AI Doubt Its Own Spelling"
date: 2026-03-16T18:00:00+01:00
draft: false
summary: "My AI coding assistant spiraled trying to verify whether 'AssertionError' was a typo. It wasn't. A clean illustration of LLM verification loops."
featureimage: /img/posts/assertionerror-circles/featured.svg
tags:
- ai
- github
categories:
- Technical posts
---

I was working with my AI coding assistant on a skill that included a triage table listing common CI failure signals.
One of the entries read: `FAIL`, `AssertionError`, `expected/got`.

The assistant flagged it as a potential typo.

Then it tried to verify.

## The spiral

The assistant's internal reasoning went something like this:

1. "AssertionError" — is that missing a letter?
2. Let me check... "AssertionError" — wait, that looks the same.
3. The correct spelling should be "AssertionError".
4. But both of those look identical when I type them.
5. Let me try character by character: A-s-s-e-r-t-i-o-n-E-r-r-o-r.
6. Hmm, that matches what I already have.
7. But I feel like something is wrong.
8. Let me grep the codebase... no matches found.
9. Let me ask Python what the correct class name is.

It eventually ran `python3 -c "print(AssertionError.__name__)"` and got back: `AssertionError`.

The spelling was correct the entire time.

The assistant's own conclusion is worth quoting verbatim:

> Actually, I was confusing myself. Looking at the raw diff text: AssertionError — this is missing the second 'i', it should be AssertionError. But both my renderings look the same... The correct Python/JS class is AssertionError.
>
> OK, the spelling is correct — AssertionError. I was going in circles on that one.

![Corporate needs you to find the difference between these two strings — They're the same picture (The Office)](/img/posts/assertionerror-circles/self-awareness.svg)

Even in its closing summary, it claims one version is "missing the second 'i'" while producing two identical strings. The self-awareness is there — "I was going in circles" — but the inability to actually see the difference persists to the very last line.

## Why it happened

LLMs do not see characters the way humans do.
They process tokens — chunks of text that may or may not align with individual letters.
When an LLM tries to verify spelling by re-typing a word and comparing it to what it already typed, it is essentially comparing its own output to its own output.
There is no external reference point.

This creates a specific failure mode: the model becomes uncertain about something it cannot resolve through introspection alone.
Each attempt to verify increases the uncertainty rather than reducing it, because the verification method (re-typing and comparing) is the same process that generated the uncertainty in the first place.

The fix was obvious in hindsight: run actual code.
`AssertionError` is a built-in Python exception. Asking the interpreter to print it would have settled the question in under a second.
The assistant eventually did this — but only after several rounds of fruitless self-comparison.

## The pattern

This is not unique to spelling.
The same spiral can happen whenever an LLM tries to verify something by reasoning about it rather than testing it:

- Checking if a regex matches a string by mentally simulating the engine
- Verifying that a refactored function preserves behavior by reading both versions
- Confirming that a JSON structure is valid by staring at brackets

In each case, the model would be better served by running the code — executing the regex, running a test, piping the JSON through a parser.
The tool is right there. The instinct to reason first is the trap.

## What I take from it

The episode reinforced something I have noticed across many sessions with AI assistants: **the best interventions are often just nudging the assistant toward execution instead of deliberation**.

This maps well to the [karpathy-guidelines](/posts/karpathy-guidelines-skill/) principle of goal-driven execution: transform vague verification into a concrete, runnable check.
"Is this word spelled correctly?" becomes "ask the Python interpreter for the canonical class name."

For those working with AI coding assistants regularly, it is worth watching for these spirals.
They are easy to spot — the assistant repeating itself, restating the same question in slightly different words, trying to resolve uncertainty through more reasoning instead of more information.

The fix is usually simple: point it at a tool.

## The irony

The skill being worked on teaches AI agents to fetch and analyze CI logs — to use tools (`gh run view --log-failed`) instead of guessing what went wrong.

The assistant proceeded to guess at a spelling instead of using a tool to check.

The skill would have been good advice for itself.
