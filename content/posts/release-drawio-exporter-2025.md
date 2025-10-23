---
title: "2025 Changelog: All Releases and Updates for 'rlespinasse/drawio-exporter'"
summary: Changelog of the 4 releases for 2025
date: 2025-03-02T21:25:58Z
lastmod: 2025-10-22T22:51:31Z
showToC: false
draft: false
tags:
- opensource
- github
categories:
- Changelog posts
---
## 1.4.0 - 2025-10-22

### Added

- Support Draw.io Desktop v22.1.16
  - --svg-theme is now supported for SVG format
  - --svg-links-target is available for SVG format
- Support Draw.io Desktop v26.0.3
  - --embed-svg-fonts is available for SVG format
- Support '--all-pages' (or '-a') for exporting all pages into one PDF per drawio file

### Fixed

- Make XML format export compliant with the non-support of page index
- Prevent drawio-desktop CLI errors to be masked
## 1.3.2 - 2025-06-04

### Fixed

- Support Draw.io Desktop v27.0.2
  - Option `--page-index` is now using 1-based index
## [1.3.1](https://github.com/rlespinasse/drawio-export/compare/v1.3.0...v1.3.1) (2025-03-06)

### Fixed

- Option `--drawio-desktop-headless` wasn't properly set as a boolean flag [#80](https://github.com/rlespinasse/drawio-exporter/pull/80)
## [1.3.0](https://github.com/rlespinasse/drawio-export/compare/v1.2.0...v1.3.0) (2025-03-02)

### Added

- Move to Rust 2024 to be up-to-date [#79](https://github.com/rlespinasse/drawio-exporter/pull/79)

### Changes

- Remove any illegal characters from the generated filename [#70](https://github.com/rlespinasse/drawio-exporter/pull/70)
- Change starting character for each log type [#54](https://github.com/rlespinasse/drawio-exporter/pull/54)

### Fixed

- Update dependencies to avoid vulnerabilities
