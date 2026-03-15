---
title: "2021 Changelog: All Releases and Updates for 'rlespinasse/drawio-exporter'"
summary: Changelog of the 2 releases of 2021
date: 2021-03-24T23:33:06Z
lastmod: 2021-03-29T23:33:06Z
showToC: false
draft: false
tags:
- opensource
- github
categories:
- Changelog posts
---
## [1.1.0](https://github.com/rlespinasse/drawio-export/compare/v1.0.0...v1.1.0) (2021-03-29)


### Features

* Add option to use Draw.io Desktop in headless mode [#3](https://github.com/rlespinasse/drawio-exporter/pull/3)

### Bug Fixes

* Remove file list output when using `--git-ref` option [#3](https://github.com/rlespinasse/drawio-exporter/pull/3)
* Improve changes filtering using `--git-ref` option [#3](https://github.com/rlespinasse/drawio-exporter/pull/3)
* Prevent the `PATH` arg from being empty. If needed, fallback to the current directory [#3](https://github.com/rlespinasse/drawio-exporter/pull/3)
* Process page index correctly [#3](https://github.com/rlespinasse/drawio-exporter/pull/3)

### Refactoring

* Improve the error logs on Draw.io Desktop call  [#3](https://github.com/rlespinasse/drawio-exporter/pull/3)
* Support Draw.io Desktop `v14.5.1` [#3](https://github.com/rlespinasse/drawio-exporter/pull/3)
   * `--embed-diagram` is now supported for PDF format [#3](https://github.com/rlespinasse/drawio-exporter/pull/3)
* Updates default Linux path used by Draw.io Desktop since `v14.5.1` [#3](https://github.com/rlespinasse/drawio-exporter/pull/3)
* Support more link extraction types upon `mxfile` format [#3](https://github.com/rlespinasse/drawio-exporter/pull/3)
   * Link attached to a shape [#3](https://github.com/rlespinasse/drawio-exporter/pull/3)
   * Link label on multiple lines [#3](https://github.com/rlespinasse/drawio-exporter/pull/3)
* Process the `drawio` files in the same order across OS [#3](https://github.com/rlespinasse/drawio-exporter/pull/3)



## 1.0.0 (2021-03-24)


### Features

* Setup drawio exporter [#1](https://github.com/rlespinasse/drawio-exporter/pull/1)



