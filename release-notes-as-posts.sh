#!/usr/bin/env bash

release-notes-as-posts() {
    echo "+ Extract releases from repo $1"
    while read -r year; do
        echo "- ${year} releases"
        dates=$(gh release list --limit 100 --exclude-drafts --exclude-pre-releases --repo "rlespinasse/$1" --jq '.[]|select(.publishedAt | startswith("'"${year}"'"))' --json name,publishedAt | jq -r '.publishedAt')
        date=$(echo "${dates}" | sort | head -1)
        lastmod=$(echo "${dates}" | sort -r | head -1)
        releases_count=$(echo "${dates}" | wc -l)

        cat <<EOF >"content/posts/release-$1-${year}.md"
---
title: "${year} Changelog: All Releases and Updates for 'rlespinasse/${1}'"
summary: Changelog of the ${releases_count} releases for ${year}
date: ${date}
lastmod: ${lastmod}
showToC: false
draft: false
tags:
- opensource
- github
categories:
- Changelog posts
---
EOF

        while read -r release; do
            echo "\\ Add release ${release}"
            gh release view "${release}" --repo "rlespinasse/$1" --json body --template '{{.body}}' |
                sed "s/^# /## /" >>"content/posts/release-$1-${year}.md"
        done < <(gh release list --limit 100 --exclude-drafts --exclude-pre-releases --order desc --repo "rlespinasse/$1" --jq '.[]|select(.publishedAt | startswith("'"${year}"'"))' --json name,publishedAt | jq -r '.name')

    done < <(gh release list --limit 100 --exclude-drafts --exclude-pre-releases --order desc --repo "rlespinasse/$1" --json publishedAt | jq -r '.[].publishedAt' | sed 's/-.*//' | uniq | awk -F '[()]' "\$1 >= ${2:-2000}")
}

# release notes
release-notes-as-posts docker-drawio-desktop-headless
release-notes-as-posts drawio-export
release-notes-as-posts drawio-export-action
release-notes-as-posts drawio-exporter '2024' # Before 2024, the release was not created at the same time as the tag
release-notes-as-posts git-commit-data-action
release-notes-as-posts github-slug-action
release-notes-as-posts release-that
release-notes-as-posts shortify-git-revision
release-notes-as-posts slugify-value
release-notes-as-posts textlint-rule-link-title-case
release-notes-as-posts wints '2024' # Before 2024, the release was not created at the same time as the tag
