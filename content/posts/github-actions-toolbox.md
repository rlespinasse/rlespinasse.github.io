---
title: "GitHub Actions Toolbox: A CLI Companion for Your Workflows"
date: 2026-03-11T10:00:00+01:00
draft: false
summary: "Introducing ghat, a Go-based CLI toolbox that brings useful GitHub Actions utilities to your terminal. Learn how to install it via Homebrew and use it to query repository dependents."
tags:
- opensource
- github
- ci/cd
- homebrew
categories:
- Technical posts
- Open Source
---

Over the years I have published and maintained a handful of GitHub Actions —
[github-slug-action](https://github.com/rlespinasse/github-slug-action),
[drawio-export-action](https://github.com/rlespinasse/drawio-export-action),
[release-that](https://github.com/rlespinasse/release-that), and a few others.
Once an action gets some traction, a recurring question pops up:
**how many repositories actually depend on it?**
GitHub surfaces that number on each repository page,
but clicking through every project one by one gets old fast when you have half a dozen actions to keep an eye on.

That itch led me to build [**github-actions-toolbox**](https://github.com/rlespinasse/github-actions-toolbox) — a small Go CLI called **`ghat`** designed to gather the kind of information an action maintainer regularly needs, without leaving the terminal.

## The problem ghat solves

GitHub's dependency graph is a fantastic feature. It tells you which repositories reference yours in their workflows. The catch is that there is no convenient API to pull those numbers in bulk. You either scrape the web UI or write throwaway scripts every time you want a snapshot.

`ghat` wraps that scraping into a single, repeatable command so you can fold it into your own dashboards, CI jobs, or just run it from your laptop on a quiet Monday morning to see how things are going.

## Using the dependents command

The first — and currently the main — subcommand is `dependents`. At its simplest, you point it at one repository and it returns the dependent count:

```bash
ghat dependents rlespinasse/github-slug-action
```

When you maintain more than one action, you can pass several repositories in a single invocation. This saves time and avoids rate-limit headaches compared to scripting individual calls:

```bash
ghat dependents rlespinasse/github-slug-action rlespinasse/drawio-export-action
```

For larger inventories, piping from a file or another command keeps things clean. Imagine a `repos.txt` that lists every action you own — one `owner/repo` per line — and you get a full report in seconds:

```bash
cat repos.txt | ghat dependents
```

This composability is intentional. Unix pipes are still the best glue between tools, and `ghat` is designed to play nicely with the rest of your toolkit.

## Getting ghat on your machine

The quickest route on macOS or Linux is through my custom [Homebrew tap](https://github.com/rlespinasse/homebrew-tap). A single command gets you the latest release, and `brew upgrade` keeps it current from there:

```bash
brew install rlespinasse/tap/ghat
```

You can browse everything the tap offers with `brew search rlespinasse/tap`.

If you already have a Go toolchain, installing from source works just as well — and it is handy when you want to pin a specific version or hack on the code yourself:

```bash
go install github.com/rlespinasse/github-actions-toolbox@latest
```

For environments where neither Homebrew nor Go are available — CI runners, Docker images, Windows workstations — pre-built archives are published for **Linux**, **macOS**, and **Windows** across **amd64** and **arm64**. Grab the one that matches your platform from the [releases page](https://github.com/rlespinasse/github-actions-toolbox/releases) and drop the binary somewhere on your `PATH`.

## The Homebrew tap behind the scenes

The [**homebrew-tap**](https://github.com/rlespinasse/homebrew-tap) repository deserves a quick mention of its own. It is a standard custom Homebrew tap — a Git repository that Homebrew clones locally so it can discover cask and formula definitions beyond the core taps.

Right now it hosts the cask for `ghat`, but the structure is ready to accommodate any future command-line tools I release.
The whole release pipeline leans on [goreleaser](https://goreleaser.com/):
when I tag a new version of `github-actions-toolbox`, goreleaser cross-compiles the binary,
packages the archives, computes checksums, and pushes an updated cask definition to the tap repository.
This means the Homebrew formula is always in sync with the latest release, with zero manual intervention on my side.

If you maintain your own Go-based CLI and want a frictionless distribution story, I highly recommend pairing goreleaser with a personal Homebrew tap. The setup cost is low and the convenience for your users is significant.

## What comes next

The `dependents` command addresses the most immediate pain point I had, but a toolbox with a single tool is not much of a toolbox yet. There are other pieces of information that are tedious to gather as a GitHub Actions maintainer — marketplace listing details, workflow usage patterns, version adoption curves — and some of those may find their way into `ghat` over time.

The architecture is intentionally subcommand-based, so adding new capabilities does not break existing workflows. If you have ideas for commands that would make your life easier as an action maintainer, issues and pull requests are very welcome on the [GitHub repository](https://github.com/rlespinasse/github-actions-toolbox).

In the meantime, if you want to give it a spin:

```bash
brew install rlespinasse/tap/ghat
ghat dependents your-org/your-action
```

It takes about ten seconds to install and even less to get your first result.
