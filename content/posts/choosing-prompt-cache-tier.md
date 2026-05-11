---
title: "Choosing Between the 5-Minute and 1-Hour Prompt Cache Tiers"
date: 2026-05-14T03:00:00
draft: false
summary: "Anthropic's prompt cache offers two write tiers: 5-minute and 1-hour. The right choice depends on how often you reuse the same cached context — and getting it wrong can cost you more than skipping caching entirely."
featureimage: /img/posts/choosing-prompt-cache-tier/featured.svg
tags:
- ai
- api
- claude
categories:
- Technical posts
---

Prompt caching on the Anthropic API has two write tiers.
A default 5-minute tier, and a longer 1-hour tier.
Both read back at the same discounted price.

The decision is not whether to cache.
It is how long to keep the cache alive — and that decision is paid for upfront, on the write side.

"Longer is better" is the easy assumption — but it is not, and the break-even math is worth knowing before committing to either tier.

The official numbers from the [pricing page](https://platform.claude.com/docs/en/docs/about-claude/pricing) and the [prompt caching docs](https://platform.claude.com/docs/en/build-with-claude/prompt-caching):

| Cache operation | Multiplier | Duration |
| :-------------- | :--------- | :------- |
| 5-minute write | 1.25x base input | 5 minutes |
| 1-hour write | 2x base input | 1 hour |
| Cache read (hit) | 0.1x base input | Same window as the preceding write |

The read price is the same regardless of which tier wrote the cache.
Only the write side differs.

## The math behind the two tiers

Prices per million tokens for the latest models:

| Operation | Opus 4.7 | Sonnet 4.6 | Haiku 4.5 |
| :-------- | -------: | ---------: | --------: |
| Base input | $5.00 | $3.00 | $1.00 |
| 5m cache write | $6.25 | $3.75 | $1.25 |
| 1h cache write | $10.00 | $6.00 | $2.00 |
| Cache read | $0.50 | $0.30 | $0.10 |

Multipliers are identical across models — only the absolute numbers shift.

The 5-minute write costs 25% more than base input.
The 1-hour write costs 100% more.
A cache read costs 90% less than base input on either tier.

The only question is how many reads you get inside the window.

![Cumulative cost comparison between no caching, 5-minute cache, and 1-hour cache](/img/posts/choosing-prompt-cache-tier/break-even.svg)

## Break-even analysis

Every cache read saves you 90% of the base input price.
The write premium is what you pay upfront for those savings.

**5-minute tier.** A 25% write premium. One read saves 90% — already past break-even. **Break-even: 1 read.**

**1-hour tier.** A 100% write premium. Two reads recover the extra cost. **Break-even: 2 reads.**

After break-even, every additional read saves the same 90% on both tiers.
The 0.75x gap between them is fixed by the write premium and never closes — but it also stops growing.
The real question is how long you have to accumulate those reads.

| Reads within window | 5m total cost | 1h total cost | No caching |
| :------------------ | ------------: | ------------: | ---------: |
| 0 (write only) | 1.25x | 2.00x | 1.00x |
| 1 | 1.35x | 2.10x | 2.00x |
| 2 | 1.45x | 2.20x | 3.00x |
| 3 | 1.55x | 2.30x | 4.00x |
| 5 | 1.75x | 2.50x | 6.00x |
| 10 | 2.25x | 3.00x | 11.00x |

Costs expressed as multiples of the base input price for the cached token block. "No caching" means paying full input price on every call.

## When to use each tier

**Use the 5-minute tier when:**

- Requests come in quick bursts — multiple calls within seconds or minutes
- You are building conversational agents where each turn reuses the system prompt
- Your traffic is unpredictable — short windows mean less wasted cache if traffic stops

**Use the 1-hour tier when:**

- You have a large, stable system prompt that many requests share over time
- You are running a production API with steady traffic against the same context
- Your batch jobs process many items against the same few-shot prompt
- Agentic workflows where individual steps can exceed 5 minutes between cache hits

**Do not cache at all when:**

- Each request has a unique prompt with no reusable prefix
- You make a single call and never reuse the context
- The cacheable portion is small relative to the unique portion

## Combining tiers with the Batch API

Cache pricing stacks with the Batch API 50% discount. On Opus 4.7:

| Opus 4.7 scenario | Input cost per MTok |
| :----------------- | ------------------: |
| Standard input | $5.00 |
| Batch input (no cache) | $2.50 |
| Cache read (standard) | $0.50 |
| Cache read (batch) | $0.25 |
| 5m write (batch) | $3.125 |
| 1h write (batch) | $5.00 |

With batch processing, the 1-hour cache write costs the same as a standard input call without caching.
Any batch job with two or more reads on the same context comes out ahead.

## How to enable each tier

Caching is controlled by `cache_control` on content blocks.
The type is always `"ephemeral"` — the tier is set by the `ttl` field.

**5-minute cache** (default — omit `ttl`, or set it to `"5m"`):

```json
{
  "type": "text",
  "text": "Your system prompt here...",
  "cache_control": { "type": "ephemeral" }
}
```

**1-hour cache** — add `"ttl": "1h"`:

```json
{
  "type": "text",
  "text": "Your system prompt here...",
  "cache_control": { "type": "ephemeral", "ttl": "1h" }
}
```

You can mix tiers in the same request, with one constraint from the docs: **longer TTLs must appear before shorter ones**.
Cache the stable system prompt at 1 hour, the growing conversation history at 5 minutes:

```json
{
  "model": "claude-opus-4-7",
  "system": [
    {
      "type": "text",
      "text": "A large, stable system prompt...",
      "cache_control": { "type": "ephemeral", "ttl": "1h" }
    }
  ],
  "messages": [
    {
      "role": "user",
      "content": [
        {
          "type": "text",
          "text": "Previous conversation context...",
          "cache_control": { "type": "ephemeral" }
        },
        {
          "type": "text",
          "text": "What should we do next?"
        }
      ]
    }
  ]
}
```

A few practical limits worth knowing:

- Up to **4 explicit cache breakpoints** per request
- Minimum cacheable length of **1024–4096 tokens**, depending on model
- Cache hits require **100% identical** prompt prefixes — any drift, even whitespace, invalidates the entry

The response `usage` object breaks cache activity down per tier via `ephemeral_5m_input_tokens` and `ephemeral_1h_input_tokens` inside `cache_creation`.
Useful for confirming the cache is being hit, not just written.

## A practical decision framework

![Decision flowchart for choosing between cache tiers](/img/posts/choosing-prompt-cache-tier/decision-flow.svg)

Three questions, in order:

1. **What is the reuse window?**
   Any reuse within 5 minutes: the 5-minute tier wins.
   Reuse spread over more than 5 minutes but inside an hour: the 1-hour tier wins, provided you get at least two reads (its break-even).

2. **How stable is the context?**
   A system prompt that never changes is a 1-hour candidate.
   A conversation history that grows each turn works better at 5 minutes — new content invalidates the cache anyway.

3. **What happens if the cache expires unused?**
   A 5-minute write that expires wastes 25% of the base price.
   A 1-hour write that expires wastes 100%.
   Bursty or unpredictable traffic favors the smaller downside.

For most interactive use cases — chatbots, coding assistants, agent loops — the 5-minute tier is the right default.
The 1-hour tier earns its keep in production pipelines where the same context serves many requests over a sustained period, or in agentic workflows where individual steps run long.

The two tiers solve different problems.
Pick the one that matches your traffic shape, not the one that looks cheaper on the write line.
