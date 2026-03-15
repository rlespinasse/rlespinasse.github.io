---
title: "Hacktoberfest 2020: Insights from a github-slug-action Maintainer"
date: 2020-11-01T11:42:00+02:00
draft: false
showToC: false
summary: Report on the Hacktoberfest 2020 for github-slug-action project.
tags:
- hacktoberfest
- opensource
- maintainer
categories:
- Technical posts
- Open Source
---

> This post have been published first on [dev.to](https://dev.to/rlespinasse/hacktoberfest-2020-maintainer-of-github-slug-action-49bi).

Some projects ideas can start from a [colleague tweet](https://twitter.com/ameausoone/status/1191827751751299074).
This idea behind `github-slug-action` is one of them (tweet in French).

From this `SLUG` variable need, I start to develop my first GitHub Action. Using docker-based container and some bash script with `sed` or `cut`, I create the first version of this action quickly.

## master end-of-life

After sometimes, `github-slug-action` start to be used by multiples projects and some enhancements have been asked.

This lead to a version bump to `2.x` due to a breaking change in April 2020.
Due to that breaking change, I take the decision to change my branching strategy to adopt a `vX.Y` branch naming to better manage this type of change.

The `master` branch have been depreciated ([rlespinasse/github-slug-action#15](https://github.com/rlespinasse/github-slug-action/issues/15))

A removal of the `master` branch have been plan 6-months later.
This work is complete.
Some repositories still used the `master` branch and a pull-request to migrate have been created of each of them during October before the `master` branch deletion.

**TIP**: Use [`Dependabot`](https://dependabot.com/github-actions/) to manage versions of used GitHub Actions in your workflows

## Docker-based GitHub Action limitation

Currently, a docker-based GitHub Action can only run on Linux-based workflows ([rlespinasse/github-slug-action#16](https://github.com/rlespinasse/github-slug-action/issues/16)).

In order to manage Windows-based and Macos-based workflows, the action need to be rewrite as Javascript-based action.
In September 2020, [@Ameausoone](https://github.com/Ameausoone) have took up the challenge to migrate to Typescript.

Thanks you.

## GitHub Action CVE

During the Hacktoberfest, the GitHub Action have been impacted by a [CVE](https://en.wikipedia.org/wiki/Common_Vulnerabilities_and_Exposures) on one of the GitHub Action core feature that been in used : [GHSA-mfwh-5m23-j46w](https://github.com/actions/toolkit/security/advisories/GHSA-mfwh-5m23-j46w).

Thanks you [@boolooper](https://github.com/boolooper) for the reporting.

On maintained branches, all impacted versions have been updated to fix this CVE and an advisory have been created on the project : [GHSA-7f32-hm4h-w77q](https://github.com/rlespinasse/github-slug-action/security/advisories/GHSA-7f32-hm4h-w77q).

## Before Hacktoberfest 2020

Thanks to [@Ameausoone](https://github.com/Ameausoone), [@m4rcs](https://github.com/m4rcs), and [@php-coder](https://github.com/php-coder) for yours contributions before this year event.
