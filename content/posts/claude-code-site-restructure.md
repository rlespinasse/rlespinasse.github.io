---
title: "Migrating a Hugo Site to Blowfish with Claude Code"
date: 2026-03-31T10:00:00+01:00
lastmod: 2026-03-31T10:00:00+01:00
draft: false
featureimage: /img/posts/claude-code-site-restructure/featured.svg
summary: "110 posts, a monolithic about page, an aging theme, and 54 auto-generated release notes posts. I used Claude Code to migrate to Blowfish, simplify the content structure, and clean up years of accumulated cruft — in one session."
tags:
- ai
- hugo
- opensource
- github
- claude-code
categories:
- Technical posts
---

This site had grown organically since [2019](/posts/gohugo/). 110 posts, a monolithic about page, a theme that no longer matched what I needed, and 54 auto-generated release notes posts that were cluttering the feed. I wanted a cleaner theme and a simpler content structure.

I did the entire thing with [Claude Code](https://docs.anthropic.com/en/docs/claude-code) in one session.

## Planning before touching a file

The first thing I did was enter plan mode. Before any code changes, I asked Claude Code to research theme options — Blowfish, Congo, and even non-Hugo alternatives like Astro. It read each theme's documentation, compared shortcode support (galleries, GitHub cards, badges), and presented a structured comparison.

I chose [Blowfish](https://blowfish.page/) for its built-in gallery shortcode, GitHub repository cards, and flexible taxonomy support. Claude Code then designed a migration plan:

1. Theme swap (Kayal to Blowfish)
2. Configuration rewrite
3. Front matter bulk updates
4. Gallery format conversion
5. About page restructure
6. Release notes cleanup

Having the full plan upfront meant I could review the scope, reorder phases, and flag decisions that needed my input — all before a single file was modified.

## What Claude Code actually did

**Theme swap.** Removed the Kayal submodule, added Blowfish, and rewrote five config files (`hugo.toml`, `params.toml`, `markup.toml`, plus new `languages.en.toml` and `menus.en.toml`).

**Bulk front matter updates.** Renamed `showToC` to `showTableOfContents` across 84 post files, and `coverImg` to `featureimage` across 19 posts (Blowfish's param for hero and thumbnail images). A trivial find-and-replace in isolation, but combined with other front matter changes per file, doing it by hand would have been error-prone.

**Gallery conversion.** The old theme used photoswipe with nested `figure` shortcodes. Blowfish uses a different gallery format with plain `img` tags. Claude Code converted all 18 Townscaper posts (122 images total), transforming this:

```html
{{</* load-photoswipe */>}}
{{</* gallery */>}}
  {{</* figure src="/img/townscaper/red_city/city_far.jpg" caption="Far away" */>}}
  {{</* figure src="/img/townscaper/red_city/city_side1.jpg" caption="From the side" */>}}
{{</* /gallery */>}}
```

Into this:

```html
{{</* gallery */>}}
  <img src="/img/townscaper/red_city/city_far.jpg" class="grid-w33" alt="Far away" />
  <img src="/img/townscaper/red_city/city_side1.jpg" class="grid-w33" alt="From the side" />
{{</* /gallery */>}}
```

No more `load-photoswipe` dependency, and the old photoswipe shortcodes and CSS were deleted entirely.

**About page restructure.** Rather than creating dedicated Projects and Certifications sections, I kept the about page as the single place for that information — but restructured it to cover all active projects. Claude Code read the release notes script to identify the full project list and added five projects that were missing from the original about page: `github-actions-toolbox`, `agent-skills`, `textlint-rule-link-title-case`, `bassin-minier-unesco`, and `leaflet-atlas`, organized into new "tools" and "geospatial" sections alongside the existing GitHub Actions, Draw.io ecosystem, and Rust sections. Certifications tables were preserved in full.

**Release notes cleanup.** The site had 54 auto-generated changelog posts (`release-*.md`) produced by a shell script that pulled GitHub release data. These posts added noise to the feed without adding much value. Claude Code removed all 54 files, deleted the generation script, and removed the corresponding `just` recipe.

## What worked well

**Plan mode for research.** Evaluating themes requires reading documentation, checking feature lists, and comparing trade-offs. Having Claude Code do that research and present a structured summary saved significant time and meant I was comparing options on the same criteria.

**Bulk operations.** 84 front matter renames, 19 image param renames, 18 gallery conversions, 54 file deletions. These are the tasks where an AI assistant shines: repetitive, pattern-based, but with enough variation per file that a simple `sed` script would miss edge cases.

**Build error diagnosis.** After the migration, Claude Code identified two build errors on its own — a missing `series` taxonomy declaration and broken partial references in a leftover custom layout — and fixed both before the first successful build.

**Theme migration knowledge.** Claude Code read Blowfish's example configs and documentation to understand partial override patterns, shortcode syntax, and taxonomy configuration. This is the kind of framework-specific knowledge that normally requires reading docs, trying things, and debugging — compressed into the planning phase.

## What needed human judgment

Claude Code presented comparisons and options. I made the decisions:

- **Theme choice.** Claude Code compared Blowfish, Congo, and Astro. I chose Blowfish based on the feature comparison and my preference for staying with Hugo.
- **Content structure.** Dedicated sections vs. a restructured about page. I chose to keep everything in about rather than add navigation complexity.
- **What to cut.** Deciding that 54 release notes posts weren't worth keeping required knowing how I actually use the site.
- **Domain knowledge.** Certification dates, issuer details, project descriptions — information that lives in my head, not in the codebase.

## The result

```text
                  │ EN
──────────────────┼─────
 Pages            │ 180
 Static files     │ 134
 Processed images │   8

Total in ~246 ms
```

180 pages, zero build errors, in a single session. A cleaner feed, a restructured about page that actually covers all current projects, and a theme that renders correctly with hero images, galleries, and series navigation. 54 changelog posts and a generation script gone.

The migration touched over 130 files. The kind of restructure I would have spread across a week, done in an evening.
