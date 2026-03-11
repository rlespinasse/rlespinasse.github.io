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
---

When you maintain several GitHub Actions, keeping track of how they are used across the ecosystem becomes important. That is why I built [**github-actions-toolbox**](https://github.com/rlespinasse/github-actions-toolbox), a Go-based CLI called **`ghat`** that brings handy GitHub Actions utilities straight to your terminal.

## What is ghat?

`ghat` is a command-line tool that currently ships with a `dependents` command. It fetches the number of repository dependents from GitHub's dependency graph, giving you a quick overview of how widely your actions or libraries are adopted.

### Querying a single repository

```bash
ghat dependents rlespinasse/github-slug-action
```

### Querying multiple repositories at once

```bash
ghat dependents rlespinasse/github-slug-action rlespinasse/drawio-export-action
```

### Piping from stdin

You can also feed a list of repositories from a file or another command:

```bash
cat repos.txt | ghat dependents
```

This is particularly useful when you want to monitor adoption across all your actions in a single pass.

## Installation

### Homebrew (recommended)

The easiest way to install `ghat` is through my custom [Homebrew tap](https://github.com/rlespinasse/homebrew-tap):

```bash
brew install rlespinasse/tap/ghat
```

You can also browse all available packages in the tap with:

```bash
brew search rlespinasse/tap
```

### From source

If you have Go installed, you can grab it directly:

```bash
go install github.com/rlespinasse/github-actions-toolbox@latest
```

### Binary releases

Pre-built binaries are available for **Linux**, **macOS**, and **Windows** on both **amd64** and **arm64** architectures. Head over to the [releases page](https://github.com/rlespinasse/github-actions-toolbox/releases) to download the right archive for your platform.

## About the Homebrew Tap

The [**homebrew-tap**](https://github.com/rlespinasse/homebrew-tap) repository is a custom Homebrew tap that hosts casks for my CLI tools. Right now it distributes `ghat`, but it is designed to grow as new tools are added. Release management is handled through [goreleaser](https://goreleaser.com/), which automatically generates the cask definitions and platform-specific archives on each release.

## What is next?

The `dependents` command is just the starting point. The toolbox is built to accommodate more subcommands over time as new needs arise from maintaining GitHub Actions in the wild.

If you maintain GitHub Actions and want a quick way to check their adoption, give `ghat` a try:

```bash
brew install rlespinasse/tap/ghat
ghat dependents your-org/your-action
```

Feedback and contributions are welcome on [GitHub](https://github.com/rlespinasse/github-actions-toolbox).
