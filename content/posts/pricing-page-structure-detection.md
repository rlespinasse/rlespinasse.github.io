---
title: "Anthropic Now Has Two Cache Write Tiers: Choosing Between 5-Minute and 1-Hour"
date: 2026-04-22T10:00:00+02:00
draft: true
summary: "Anthropic split prompt cache writes into a 5-minute tier and a 1-hour tier. The right choice depends on how often you reuse the same cached context — and getting it wrong can cost you more than skipping caching entirely."
featureimage: /img/posts/pricing-page-structure-detection/featured.svg
tags:
- ai
- api
- claude
categories:
- Technical posts
---

Prompt caching on the Anthropic API used to have a single write price. You paid a 1.25x premium on input tokens to store them in the cache, then read them back at 0.1x. One price, one duration, one decision: cache or do not cache.

That changed. The [pricing page](https://docs.anthropic.com/en/docs/about-claude/pricing) now lists two cache write tiers.

| Cache operation | Multiplier | Duration |
| :-------------- | :--------- | :------- |
| 5-minute write | 1.25x base input | Cache valid for 5 minutes |
| 1-hour write | 2x base input | Cache valid for 1 hour |
| Cache read (hit) | 0.1x base input | Same duration as preceding write |

The read price did not change. Only the write side split. You now choose how long your cached context survives — and you pay accordingly.

## The math behind the two tiers

Take Opus at $5/MTok base input. Here is what each operation costs:

| Operation | Opus | Sonnet | Haiku |
| :-------- | ---: | -----: | ----: |
| Base input | $5.00 | $3.00 | $1.00 |
| 5m cache write | $6.25 | $3.75 | $1.25 |
| 1h cache write | $10.00 | $6.00 | $2.00 |
| Cache read | $0.50 | $0.30 | $0.10 |

The 5-minute write costs 25% more than base input. The 1-hour write costs 100% more — double the base price. But a cache read costs 90% less than base input regardless of which tier wrote the cache.

The question is not which tier is cheaper to write. It is how many reads you get before the cache expires.

![Cumulative cost comparison between no caching, 5-minute cache, and 1-hour cache](/img/posts/pricing-page-structure-detection/break-even.svg)

## Break-even analysis

Every cache read saves you 90% of the base input price. The write premium is what you pay upfront for those savings.

**5-minute tier.** You pay a 25% premium on the write. A single cache read saves 90%. One read pays back the write premium and then some. Break-even: **1 read**.

**1-hour tier.** You pay a 100% premium on the write. Each read still saves 90%. You need two reads to recover the extra write cost. Break-even: **2 reads**.

After break-even, every additional read saves 90% of the base input price. The tiers converge quickly — by the third read, the total cost is nearly identical. The difference is only in how long you have to accumulate those reads.

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
- You are running Claude Code, which rebuilds context frequently as conversations grow
- Your traffic is unpredictable — short windows mean less wasted cache if traffic stops

**Use the 1-hour tier when:**

- You have a large, stable system prompt that many requests share over time
- You are running a production API that receives steady traffic against the same context
- Your batch jobs process many items against the same few-shot prompt
- The cached context is expensive to recompute (large documents, long conversation histories)

**Do not cache at all when:**

- Each request has a unique prompt with no reusable prefix
- You make a single call and never reuse the context
- The cacheable portion is small relative to the unique portion

## Combining tiers with other discounts

Cache pricing stacks with the Batch API 50% discount. If you use batch processing with 1-hour caching, a cache read on Opus costs $0.25/MTok — 95% less than the standard input price.

| Opus scenario | Input cost per MTok |
| :------------ | ------------------: |
| Standard input | $5.00 |
| Batch input (no cache) | $2.50 |
| Cache read (standard) | $0.50 |
| Cache read (batch) | $0.25 |
| 5m write (batch) | $3.125 |
| 1h write (batch) | $5.00 |

With batch processing, the 1-hour cache write costs the same as a standard input call. If your batch job makes three or more calls against the same context, the 1-hour tier with batch discount is cheaper than standard input without caching.

## What about Claude Code?

If you use Claude Code rather than the API directly, you do not choose between tiers. Claude Code manages prompt caching automatically — it uses the 5-minute tier, and you cannot switch to 1-hour.

What you can do is disable caching entirely, per model family:

```bash
DISABLE_PROMPT_CACHING=1          # disable for all models
DISABLE_PROMPT_CACHING_OPUS=1     # disable for Opus only
DISABLE_PROMPT_CACHING_SONNET=1   # disable for Sonnet only
DISABLE_PROMPT_CACHING_HAIKU=1    # disable for Haiku only
```

In practice, there is no reason to disable it. The 5-minute tier breaks even after a single cache read, and Claude Code rebuilds context on every turn — exactly the pattern where short-lived caching pays off. The 1-hour tier would not help much here because the conversation context changes with each message, invalidating the cache anyway.

The two-tier choice matters when you build on the API directly.

## How to enable each tier via the API

Prompt caching is controlled by the `cache_control` field on content blocks in your API request. The type is always `"ephemeral"` — the difference between tiers is the `ttl` parameter.

**5-minute cache** (the default) — omit `ttl` or do not set it:

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

One parameter. That is the entire difference.

You can mix tiers within the same request. Cache the stable system prompt with `"ttl": "1h"` and the growing conversation history with the default 5-minute tier:

```json
{
  "model": "claude-opus-4-6",
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

The system prompt stays cached for an hour. The conversation context gets 5 minutes. The final message is not cached at all.

## A practical decision framework

![Decision flowchart for choosing between cache tiers](/img/posts/pricing-page-structure-detection/decision-flow.svg)

When deciding between tiers, I ask three questions:

1. **How often will this context be reused?** If more than twice within an hour, the 1-hour tier is cheaper. If once or twice within 5 minutes, the 5-minute tier wins.

2. **How stable is the context?** A system prompt that never changes is a good candidate for 1-hour caching. A conversation history that grows with each turn works better with 5-minute caching — the cache gets invalidated by new content anyway.

3. **What happens if the cache expires unused?** A 5-minute write that expires without a read wastes 25% of the base input price. A 1-hour write that expires unused wastes 100%. If your traffic is bursty or unpredictable, the 5-minute tier has a lower downside.

For most interactive use cases — chatbots, coding assistants, agent loops — the 5-minute tier is the default choice. The 1-hour tier shines in production pipelines where the same context serves many requests over a sustained period.

The split gives you a lever that did not exist before. Use it.
