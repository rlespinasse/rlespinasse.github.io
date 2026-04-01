---
title: "Hacktoberfest 2020: Reflections as drawio-cli and drawio-export Maintainer"
date: 2020-11-01T10:42:00+02:00
draft: false
featureimage: /img/posts/hacktoberfest/featured.svg
showTableOfContents: false
summary: Report on the Hacktoberfest 2020 for drawio-releated projects.
tags:
- hacktoberfest
- opensource
- maintainer
categories:
- Technical posts
- Open Source
---

> This post have been published first on [dev.to](https://dev.to/rlespinasse/hacktoberfest-2020-maintainer-of-drawio-cli-and-drawio-export-1018).

Earlier this year, I want to be able to automatically export diagrams from a `drawio` file. This need lead to the creation of 2 new open-sources projects :

The [drawio-cli](https://github.com/rlespinasse/drawio-cli) project is responsible to generate a docker image with a **raw** cli of drawio (thanks [drawio-desktop](https://github.com/jgraph/drawio-desktop)) for that.

The [drawio-export](https://github.com/rlespinasse/drawio-export) project use the `drawio-cli` project to enhance initial export capabilities.

## Support latest version of Drawio-desktop

At the beginning of Hacktoberfest, [@danquash](https://github.com/danquah) start working of this [issue](https://github.com/rlespinasse/drawio-cli/issues/4)

After an awesome work on debugging the version bump issues, he have create 2 pull-requests (1 on each project)

- [rlespinasse/drawio-cli PR #5](https://github.com/rlespinasse/drawio-cli/pull/5)
- [rlespinasse/drawio-export PR #29](https://github.com/rlespinasse/drawio-export/pull/29)

Thanks to him.

## Enhancements on drawio-export

Some `enhancement` issues have been [available for contribution](https://github.com/rlespinasse/drawio-export/contribute) during this Hacktoberfest 2020.

This new `--on-changes` option, to improve the speed of diagrams generation, have been develop by [@Nico385412](https://github.com/Nico385412).

[rlespinasse/drawio-export PR #34](https://github.com/rlespinasse/drawio-export/pull/34)

Thanks to him.

## Before Hacktoberfest 2020

Thanks to [@bogaertg](https://github.com/bogaertg) and [@Decat-SimonA](https://github.com/Decat-SimonA) for yours contributions before this year event.
