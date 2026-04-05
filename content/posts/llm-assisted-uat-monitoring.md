---
title: "Practical Guide to LLM-Assisted UAT Log Monitoring"
date: 2026-04-24T10:00:00+02:00
draft: true
summary: "A 5-step method for monitoring Cloud Run UAT sessions with an LLM coding assistant — fetch logs, classify incidents by severity, read the code, fix the bug, and track everything in a single conversation."
tags:
- ai
- cloud-run
- monitoring
categories:
- Technical posts
---

# Practical Guide to LLM-Assisted UAT (User Acceptance Testing) Log Monitoring

You're running UAT on a Cloud Run service. Real users are testing. You have no Datadog, no PagerDuty, no custom dashboards — just `gcloud logs` and a terminal. Logs are noisy: container startup messages, health checks, IAP authentication noise, transient retries, all mixed in with the actual errors that matter.

You need to catch issues in real-time, understand their severity, and fix them before the next test session. But manually parsing raw logs is slow, error-prone, and context-free — you see the symptom but not the cause, because the cause lives in the code, not the logs.

This is the reality of the 0-to-1 phase. You don't have enough traffic to justify a full observability stack. You don't have structured logging or SLI/SLO targets. What you have is a CLI, a codebase, and an LLM coding assistant with shell access.

During UAT testing sessions of an AI agent service running on Cloud Run, we developed a method that turns this minimal setup into an effective monitoring loop: fetch logs, classify incidents, read the code, fix the bug, commit, and track everything — all within a single conversation. This post describes that method.

## The Setup

You need three things:

1. **A CLI LLM assistant with shell access** — an agent that can run shell commands, read and write files, and maintain conversation context (e.g., Claude Code, Cursor, Aider).
2. **Authenticated `gcloud` CLI** — configured to access your Cloud Run service and its logs.
3. **An incident tracking file** — a markdown file in your repo that accumulates findings across sessions.

The core idea: the LLM reads the logs AND reads/writes the code in the same session. There's no context switch between "the person monitoring" and "the person debugging."

### Severity Classification Table

This table is the filter. It tells the LLM (and you) what matters and what doesn't.

| Pattern | Severity | Action |
|---------|----------|--------|
| SIGABRT, SIGKILL, OOM, container crash | **CRITICAL** | Investigate immediately |
| ValidationError at startup, ImportError | **CRITICAL** | Investigate immediately |
| HTTP 5xx, unhandled exceptions | **HIGH** | Investigate immediately |
| Truncated response body | **HIGH** | Investigate immediately |
| HTTP 4xx (except auth), deprecation warnings | **MEDIUM** | Log and investigate when possible |
| Session/resource not found (404) | **MEDIUM** | Log and investigate when possible |
| Permission Denied (IAP/auth) | **LOW** | Log, usually config-level |
| Cosmetic warnings (tracing libs, missing .env) | **LOW** | Log, non-actionable |

Keep this table in your incident file or in the LLM's instructions. It becomes pattern memory — the assistant learns what to escalate and what to ignore.

## The Method: 5 Steps

### Step 1 — Load Context

Before looking at any logs, the LLM needs to know what happened before. Start every monitoring session by loading context:

- **Read the incident file** from previous sessions. Know what's open, what was fixed, what to watch for.
- **Check `git log`** for recent deploys. Understand what changed since the last session.
- **Review open incidents** to see if any fixes have been deployed.

This takes 30 seconds and prevents duplicate work. If the incident file says "OOM crash fixed by increasing memory to 1Gi" and the latest deploy includes that change, you know to verify the fix rather than re-investigate if a crash occurs.

Example starting point: *"3 open incidents from last session. New deploy includes a fix for the ValidationError on agent re-import (commit `f3afbcc`). Session persistence is still in-memory — expect 404s on instance changes."*

The LLM now has a mental model of the service's current state before reading a single log line.

### Step 2 — Start Monitoring

Two modes, used together:

**Historical fetch** — pull logs for the session window:

```bash
gcloud beta run services logs read SERVICE_NAME \
  --project PROJECT_ID \
  --region REGION \
  --limit 500
```

Use `--limit` to control volume. For a typical 2-hour UAT session, 300-500 lines covers it. Add time filters if needed.

**Live tail** — stream logs in real-time:

```bash
gcloud beta run services logs tail SERVICE_NAME \
  --project PROJECT_ID \
  --region REGION
```

Run this in the background (the LLM assistant can manage background processes) and check its output periodically — every 2-5 minutes during active testing, or when the tester reports an issue.

The historical fetch gives you the full picture. The live tail catches things as they happen. Together, they cover both "what did we miss" and "what's happening now."

### Step 3 — Classify and Report

This is where the LLM earns its keep. For each log line or cluster of related log lines:

1. **Match against the severity table.** A `SIGABRT` with signal 6 is CRITICAL. An IAP `Permission Denied` on `/favicon.ico` is LOW.
2. **Filter known noise.** If the incident file already tracks "ddtrace `/proc/vmstat` warning — cosmetic, non-actionable," don't re-report it. Acknowledge it as a known pattern and move on.
3. **For MEDIUM and above**, report: timestamp, severity, log message, and a root cause hypothesis.
4. **For HIGH and CRITICAL**, stop classifying and investigate immediately (Step 4).

Example classification output:

```
10:29:17 | CRITICAL | POST /run_sse → HTTP 500
  ValidationError: Agent 'hr_domain_subagent' already has parent 'hr_data_agent'
  Hypothesis: module re-import creates duplicate agent parent assignment

10:34:17 | MEDIUM | GET artifacts/hr_chart_0_*.png → 404
  Artifacts stored in-memory, lost on instance change
  Known issue — same root cause as incident #2 (in-memory storage)

10:34:28 | LOW | SIGTERM → graceful shutdown
  Normal autoscaling behavior, not an error

14:08:55 | LOW | 5x IAP Permission Denied on /favicon.ico
  Browser requests without IAP cookie — config-level, not a bug
```

The key insight: classification is fast because the LLM has the severity table and incident history in context. It doesn't waste time on known non-issues. A human doing this manually would need to remember (or re-read) all prior context every time.

### Step 4 — Investigate and Fix

When a HIGH or CRITICAL incident is found, the investigation follows a direct path:

1. **Log error → stack trace → source file → root cause.** The LLM reads the error, identifies the file and line number from the stack trace, then reads the actual source code.

2. **Understand the context.** Why does this code path exist? What was the original intent? The LLM can read surrounding code, imports, and related modules to understand the full picture.

3. **Propose a minimal fix.** Not a refactor, not an improvement — the smallest change that resolves the issue.

4. **Run tests.** Execute the test suite to verify the fix doesn't break anything.

5. **Commit.** The fix is tracked in git with a descriptive conventional commit message.

Here's what this looks like in practice:

> HTTP 500 from `/run_sse` → stack trace points to `ValidationError` in agent initialization → reading the source reveals that re-importing a module re-creates agents that already have a parent → fix: filter the problematic agent from the app list so it's never loaded independently → run 348 tests, all pass → commit with `fix: hide hr_domain from app list to prevent ValidationError`.

The entire flow — from spotting the log error to committing the fix — happens in a single conversation. No copy-pasting between terminals, no switching between a log viewer and an IDE, no filing a ticket for someone else to investigate later.

This is the core advantage: **logs and code live in the same context.** The LLM doesn't just tell you something is broken — it reads the code, understands why, and fixes it.

### Step 5 — Track and Report

After the monitoring session, update the incident file:

1. **Add new entries to the summary table** — one row per incident with date, severity, description, root cause, resolution, and status.
2. **Write detailed analysis for HIGH+ incidents** — symptoms, analysis, affected files, and the fix applied.
3. **Reconstruct the user's testing journey** — correlate session IDs and timestamps to understand what the tester was doing when things broke.
4. **Generate a session report** — timeline, key metrics (requests, sessions, errors), service health status.

The session report isn't just for you. Share it with the testing team so they know which issues they hit, which were fixed, and which are still open.

## The Incident File Format

The incident file is a single markdown file in your repo. It has two sections:

### Summary Table

```markdown
| # | Date | Severity | Description | Root Cause | Resolution | Status |
|---|------|----------|-------------|------------|------------|--------|
| 1 | 2026-03-16 09:27 | CRITICAL | Container crash SIGABRT | OOM — 512Mi insufficient | Increased memory to 1Gi | Fixed |
| 2 | 2026-03-16 09:28 | HIGH | Sessions lost after crash | In-memory session storage | Migrated to persistent backend | Fixed |
| 3 | 2026-03-16 09:28 | MEDIUM | Debug trace endpoint 404 | Framework route not supported | Framework behavior, not a bug | Non-actionable |
```

### Detailed Sections

For each HIGH+ incident, a dedicated section with:

- **Symptoms**: exact log lines, timestamps, HTTP status codes
- **Analysis**: what happened and why, traced to the source code
- **Fix**: what was changed, commit reference
- **Impact**: what the user experienced

### Status Values

| Status | Meaning |
|--------|---------|
| Open | Identified, not yet resolved |
| Fixed (not deployed) | Fix committed, awaiting deployment |
| Fixed | Fix deployed and verified |
| Non-actionable | Expected behavior or external config issue |
| Resolved | Resolved itself (e.g., transient infrastructure issue) |

The key principle: **incidents accumulate across sessions.** The file is the persistent memory. Session 3 starts with full knowledge of sessions 1 and 2. The LLM reads this file at the start of every monitoring session (Step 1) and updates it at the end (Step 5).

## What Makes This Work

**Single flow.** Logs → code → fix → commit in one conversation. No context switching between tools, no handoffs between people. The person who spots the error is the same "person" who reads the code, writes the fix, and runs the tests.

**Pattern memory.** The severity table plus the incident history give the LLM a growing knowledge base. By session 3, it knows that IAP errors on static assets are noise, that `ddtrace` warnings are cosmetic, and that 404s on session endpoints likely mean an instance change — not a bug. It classifies faster and with fewer false positives.

**User journey tracing.** By correlating session IDs, timestamps, and request paths, the LLM reconstructs what the tester was doing when things broke. This turns raw logs into a narrative: "The user asked a data question at 10:31, the agent queried BigQuery successfully, but by the time the UI requested the chart artifact at 10:34, the instance had changed and the artifact was lost." This context is invaluable for prioritizing fixes.

**Incremental knowledge.** Each session enriches the incident file. Open incidents get resolved. New patterns get classified. The next session starts with more context and less noise. The monitoring gets better over time without building any tooling.

## Limitations & When to Graduate

This method has real limits:

- **Not real-time.** You poll logs manually or on a timer. There are no push alerts — if something breaks at 3 AM, nobody knows until someone checks.
- **No quantitative metrics.** You can count errors by hand, but there's no p50/p95 latency tracking, no error rate graphs, no trend analysis over weeks.
- **Raw text parsing.** There's no structured log query language. The LLM parses text, which works but is fragile if log formats change.
- **Single operator.** This works for one person monitoring one service. It doesn't scale to a team watching ten services.

**When to move on:** when you have enough traffic that manual monitoring doesn't scale, when you need SLI/SLO tracking with alerting, or when multiple team members need concurrent visibility into service health. At that point, invest in structured logging, a metrics pipeline, and a proper observability stack.

This method is for the **0-to-1 phase** — when you're validating that your service works at all. Proper observability is for the **1-to-N phase** — when you're ensuring it works reliably at scale.

---

*This guide was developed during UAT sessions of an AI agent service running on Cloud Run, where the entire monitoring-debugging-fixing loop was executed within CLI conversations with an LLM coding assistant. The method described here is a generalization of that experience.*
