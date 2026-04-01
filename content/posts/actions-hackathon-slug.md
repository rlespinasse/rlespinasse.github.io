---
title: "Actions Hackathon: Streamlining Workflows with Slug Variables"
date: 2020-08-16T10:42:00+02:00
draft: false
featureimage: /img/posts/actions-hackathon/featured.svg
showTableOfContents: false
summary: Submission of github-slug-action project to the dev.to Actions Hackathon.
tags: 
- hackathon
- opensource
- ci/cd
categories:
- Technical posts
---

> This post is link to a submission on Dev.to Github Action Hackathon
> This post have been published first on [dev.to](https://dev.to/rlespinasse/use-slug-variable-for-your-release-and-deployment-workflows-558o).

## My Workflow

Want to use the branch name in an url during a deployment? Want to use a commit hash in a release process?

[Slug it](https://github.com/rlespinasse/github-slug-action).

This action give you access to multiple slug version of some GitHub variables to be use on your release or deployment workflows.

## Submission Category

* Maintainer Must-Haves
* DIY Deployments

## Yaml File or Link to Code

This action source code is available on [https://github.com/rlespinasse/github-slug-action](https://github.com/rlespinasse/github-slug-action)

```yaml
- name: Inject slug/short variables
  uses: rlespinasse/github-slug-action@v2.x

- name: Print slug/short variables
  run: |
    echo "Slug variables"
    echo "   ref        : ${{ env.GITHUB_REF_SLUG }}"
    echo "   head ref   : ${{ env.GITHUB_HEAD_REF_SLUG }}"
    echo "   base ref   : ${{ env.GITHUB_BASE_REF_SLUG }}"
    echo "   event ref  : ${{ env.GITHUB_EVENT_REF_SLUG }}"
    echo "   repository : ${{ env.GITHUB_REPOSITORY_SLUG }}"
    echo "Slug URL variables"
    echo "   ref        : ${{ env.GITHUB_REF_SLUG_URL }}"
    echo "   head ref   : ${{ env.GITHUB_HEAD_REF_SLUG_URL }}"
    echo "   base ref   : ${{ env.GITHUB_BASE_REF_SLUG_URL }}"
    echo "   event ref  : ${{ env.GITHUB_EVENT_REF_SLUG_URL }}"
    echo "   repository : ${{ env.GITHUB_REPOSITORY_SLUG_URL }}"
    echo "Short SHA variables"
    echo "   sha        : ${{ env.GITHUB_SHA_SHORT }}"
```

## Additional Resources / Info

Some repositories already using it like

* [Delegation-numerique-en-sante/mesconseilscovid](https://github.com/Delegation-numerique-en-sante/mesconseilscovid/blob/master/.github/workflows/build.yml)
* [ibm-garage-cloud/ibm-garage-cli-tools](https://github.com/ibm-garage-cloud/ibm-garage-cli-tools/blob/master/.github/workflows/release.yaml)

And more on [GitHub search page](https://github.com/search?q=%22rlespinasse%2Fgithub-slug-action%22&type=Code)

Contributions welcome.
