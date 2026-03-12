---
title: "actions-able: A GitHub Organisation for GitHub Actions Tooling"
date: 2026-03-12T10:00:00+01:00
draft: false
summary: "Introducing actions-able, a GitHub organisation dedicated to building and curating GitHub Actions. Meet envsubst-action for environment variable substitution and awesome-actions, a maintained curated list of GitHub Actions resources."
tags:
  - opensource
  - github
  - ci/cd
categories:
  - Technical posts
---

Over the past few years I have built and maintained several GitHub Actions under my personal account —
[github-slug-action](https://github.com/rlespinasse/github-slug-action),
[drawio-export-action](https://github.com/rlespinasse/drawio-export-action),
and others.
As the collection grew, it became clear that some of these projects would benefit from shared ownership and a home that is not tied to a single person.
That reasoning led to the creation of [**actions-able**](https://github.com/actions-able), a GitHub organisation dedicated to GitHub Actions tooling.

The name is a small play on words — actions that are *able*, ready to use. The organisation is maintained together with [@fhgbaguidi](https://github.com/fhgbaguidi) and is open to contributions from anyone.

## envsubst-action

The first action published under the organisation is [**envsubst-action**](https://github.com/actions-able/envsubst-action). It wraps the `envsubst` utility from GNU gettext so you can substitute environment variables inside files directly in your workflow, without installing extra dependencies on the runner.

A typical use case is templating configuration files before deployment. Imagine a `config.template.json` that contains placeholders like `${API_URL}` and `${APP_VERSION}`. A single step turns it into a ready-to-deploy configuration:

```yaml
- uses: actions-able/envsubst-action@v1
  env:
    API_URL: https://api.example.com
    APP_VERSION: ${{ github.sha }}
  with:
    input: config.template.json
    output: config.json
```

The action supports processing multiple files at once using glob patterns, and it lets you configure a working directory and output suffix when you need more control. It runs on Alpine Linux, keeping the image lightweight and fast to pull.

The current release is **v1.2.0**. You can find full documentation and examples in the [repository README](https://github.com/actions-able/envsubst-action#readme).

## awesome-actions

The second project is [**awesome-actions**](https://github.com/actions-able/awesome-actions), a maintained fork of the well-known [sdras/awesome-actions](https://github.com/sdras/awesome-actions) list. The original repository was a go-to resource for discovering GitHub Actions across every category imaginable — from CI/CD and testing to deployment and security scanning. Over time, maintenance slowed down and many entries became outdated or pointed to archived repositories.

The fork under actions-able picks up where the original left off. It keeps the same comprehensive structure — official actions, community actions organised by language and purpose, deployment targets, and more — while actively reviewing and updating entries. Archived and deleted repositories are tracked transparently so you know exactly what is still alive.

If you maintain a GitHub Action and want it listed, or if you spot a broken link, pull requests are welcome. The list is licensed under CC0, so you can use and share it freely.

## Getting involved

The organisation participates in [Hacktoberfest](https://hacktoberfest.com/) each year, so October is a particularly good time to send your first contribution. But contributions are welcome year-round — whether that is a bug report, a documentation improvement, or a brand-new action idea.

You can find everything at [github.com/actions-able](https://github.com/actions-able).
