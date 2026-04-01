---
title: "Actions Hackathon: Keeping Your draw.io Diagrams in Sync Within Your Repository"
date: 2020-08-16T12:42:00+02:00
draft: false
featureimage: /img/posts/actions-hackathon/featured.svg
showTableOfContents: false
summary: Submission of drawio-export project to the dev.to Actions Hackathon.
tags: 
- hackathon
- opensource
- ci/cd
categories:
- Technical posts
---

> This post is link to a submission on Dev.to Github Action Hackathon
> This post have been published first on [dev.to](https://dev.to/rlespinasse/keep-your-draw-io-diagrams-in-sync-inside-your-repository-bka).

## My Workflow

You have [Draw.io](https://app.diagrams.net/) diagram files on your repository? You export them manually to have them as images (png, jpg) or pdf?

You can keep your diagrams as exported images (png, jpg) or pdf and keep them synchronized when the diagram files are updated.

## Submission Category

* Maintainer Must-Haves

## Yaml File or Link to Code

Example to keep your draw.io files exported as PNG files with associated Asciidoctor pages.

```yaml
name: Keep draw.io export synchronized
on:
  push:
    branches:
      - master
    paths:
      - "**.drawio"
      - .github/workflows/drawio-export.yml
jobs:
  drawio-export:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout sources
        uses: actions/checkout@v2
        with:
          token: ${{ secrets.GH_TOKEN }}

      - name: Export drawio files to asciidoctor and png files
        uses: docker://rlespinasse/drawio-export:v3.x
        with:
          args: --fileext adoc --folder drawio-assets --transparent --on-changes

      - name: Get author and committer info from HEAD commit
        uses: rlespinasse/git-commit-data-action@v1.x

      - name: Commit changed files
        uses: stefanzweifel/git-auto-commit-action@v4.1.6
        with:
          commit_message: "docs: sync draw.io exported files"
          commit_user_name: "${{ env.GIT_COMMIT_COMMITTER_NAME }}"
          commit_user_email: "${{ env.GIT_COMMIT_COMMITTER_EMAIL }}"
          commit_author: "${{ env.GIT_COMMIT_AUTHOR }}"
```

## Additional Resources / Info

Learn more about the [`drawio-export`](https://github.com/rlespinasse/drawio-export) docker image.

Contributions welcome.
