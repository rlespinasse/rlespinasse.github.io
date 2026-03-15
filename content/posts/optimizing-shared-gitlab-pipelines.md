---
title: "Optimizing Shared GitLab Pipelines: Flexibility and Maintainability"
date: 2024-10-06T00:00:00+02:00
draft: false
toc: true
summary: Optimizing shared GitLab pipelines enhances flexibility and maintainability. Users can easily customize pipeline behavior by implementing variables as configuration points without compromising the original intent. While temporary workarounds exist, contributing to open-source projects to improve shared pipeline structures is highly recommended, especially during events like Hacktoberfest.
tags:
- gitlab
- ci/cd
categories:
- Technical posts
---

## The Challenge

A colleague seeks to modify the script section of a job in a shared GitLab pipeline, facing hardcoded configuration:

  ```yaml
  # https://gitlab.com/rlespinasse/foobar-shared-ci-templates/-/blob/main/pipeline-with-hardcoded-values.yml
  test-branch:
    stage: test
    before_script:
      - ls
    script: # it's for the example, the script can be more complex
      - ls ./wrong-folder
  ```

This rigid setup causes pipeline failure in their project:

  ```yaml
  # https://gitlab.com/rlespinasse/foobar-project/-/blob/main/.gitlab-ci.yml
  include:
    - project: 'rlespinasse/foobar-shared-ci-templates'
      ref: HEAD
      file:
        - '/pipeline-with-hardcoded-values.yml'
  ```

  ```shell
  $ ls ./wrong-folder
  ls: cannot access './wrong-folder': No such file or directory
  ```

## Ideal Solution

The optimal approach involves implementing [variables as configuration points](https://docs.gitlab.com/ee/ci/yaml/includes.html#override-included-configuration-values):

  ```yaml
  # https://gitlab.com/rlespinasse/foobar-shared-ci-templates/-/blob/main/pipeline-with-variables.yml
  variables:
    FOLDER_TO_TEST: wrong-folder

  test-branch:
    stage: test
    before_script:
      - ls
    script:
      - ls ./${FOLDER_TO_TEST}
  ```

This method allows for easy customization:

  ```yaml
  # https://gitlab.com/rlespinasse/foobar-project/-/merge_requests/2
  include:
    - project: 'rlespinasse/foobar-shared-ci-templates'
      ref: HEAD
      file:
        - '/pipeline-with-variables.yml'

  variables:
    FOLDER_TO_TEST: folder
  ```

  ```shell
  $ ls ./${FOLDER_TO_TEST}
  some-file
  ```

## Temporary Workaround

In the meantime, one can override only the `script` part:

  ```yaml
  # https://gitlab.com/rlespinasse/foobar-project/-/merge_requests/1
  include:
    - project: 'rlespinasse/foobar-shared-ci-templates'
      ref: HEAD
      file:
        - '/pipeline-with-hardcoded-values.yml'

  test-branch:
    stage: test
    script:
      - ls ./folder
  ```

  ```shell
  $ ls ./folder
  some-file
  ```

## Conclusion

While functional, this temporary solution may lead to divergences and maintenance issues.

It's recommended to contribute to open source or innersource projects (especially during [Hacktoberfest](https://hacktoberfest.com/)) by proposing the addition of variables.
This would allow users to adapt shared pipeline behaviors to their needs while preserving the original intent.

### Explore the code

You can explore the code on those repositories:

- <https://gitlab.com/rlespinasse/foobar-shared-ci-templates>
- <https://gitlab.com/rlespinasse/foobar-project>
