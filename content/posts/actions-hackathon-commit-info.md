---
title: "Actions Hackathon: Leveraging Commit Info for Enhanced Release and Deployment Workflows"
date: 2020-08-16T11:42:00+02:00
draft: false
featureimage: /img/posts/actions-hackathon/featured.svg
showTableOfContents: false
summary: Submission of git-commit-data-action project to the dev.to Actions Hackathon.
tags: 
- hackathon
- opensource
- ci/cd
categories:
- Technical posts
---

> This post is link to a submission on Dev.to Github Action Hackathon
> This post have been published first on [dev.to](https://dev.to/rlespinasse/access-commit-info-for-your-release-and-deployment-workflows-4h09).

## My Workflow

Need to access git commit information in your workflow like this

```yaml
- name: Get author and committer info from HEAD commit
  uses: rlespinasse/git-commit-data-action@v1.x

- name: Commit changed files
  uses: stefanzweifel/git-auto-commit-action@v4.1.6
  with:
    commit_message: "Automated commit message"
    commit_user_name: "${{ env.GIT_COMMIT_COMMITTER_NAME }}"
    commit_user_email: "${{ env.GIT_COMMIT_COMMITTER_EMAIL }}"
    commit_author: "${{ env.GIT_COMMIT_AUTHOR }}"
```

## Submission Category

* DIY Deployments

## Yaml File or Link to Code

This action source code is available on [https://github.com/rlespinasse/git-commit-data-action](https://github.com/rlespinasse/git-commit-data-action)

```yaml
- name: Expose git commit data
  uses: rlespinasse/git-commit-data-action@v1.x

- name: Print git commit data
  run: |
    echo "Get author info"
    echo " - ${{ env.GIT_COMMIT_AUTHOR }}"
    echo " - ${{ env.GIT_COMMIT_AUTHOR_NAME }}"
    echo " - ${{ env.GIT_COMMIT_AUTHOR_EMAIL }}"
    echo "Get committer info"
    echo " - ${{ env.GIT_COMMIT_COMMITTER }}"
    echo " - ${{ env.GIT_COMMIT_COMMITTER_NAME }}"
    echo " - ${{ env.GIT_COMMIT_COMMITTER_EMAIL }}"
```

## Additional Resources / Info

Currently, use on my client project. If you use it, tell me.

Contributions welcome.
