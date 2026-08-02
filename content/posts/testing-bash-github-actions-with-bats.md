---
title: "Testing a Bash-Based GitHub Action Without Docker: Split Logic from Orchestration"
date: 2026-08-02T14:00:00+01:00
draft: true
summary: "Split a Docker action's entrypoint into a side-effect-free lib.sh and a thin runner.sh so its logic can be unit-tested with bats, without ever building the image."
featureimage: /img/posts/testing-bash-github-actions-with-bats/featured.svg
tags:
- github
- bash
- testing
- ci/cd
categories:
- Tips & Tricks
series: ["GitHub Actions Ecosystem"]
series_order: 5
---

[drawio-export-action](https://github.com/rlespinasse/drawio-export-action) is a Docker-based GitHub Action. Its `src/runner.sh` entrypoint used to hold everything in one file: `git config --system --add safe.directory` side effects, `exit 1`/`exit 0` control flow, the action-mode and reference resolution logic, and the argument building for the underlying `drawio-exporter` binary.

That worked, but it made the logic almost impossible to test in isolation. The only way to exercise it was to actually run the action end-to-end: `make test`, which builds the Docker image and runs the `tests/*.bats` integration suite against it. Every edge case in the action-mode decision table (`auto`, `reference`, `recent`, `push`, `pull_request`, `skip`, `none`, shallow-clone detection) required a full Docker build to verify, which made iterating on a one-line logic fix painfully slow ([issue #36](https://github.com/rlespinasse/drawio-export-action/issues/36)).

## Split the pure logic from the side effects

The fix was to extract everything that could be pure logic into a new `src/lib.sh`: `resolve_action_mode`, `resolve_reference`, `build_args_array`, `is_shallow_repository`, `report_error`, plus thin wrappers around the external git calls (`git_branch_contains`, `git_merge_base_of_head`) so they can be stubbed in tests.

The rule for `lib.sh` is strict: sourcing it must have **no side effect**. No `exit`, no git config mutation, no process invocation: only function definitions. `src/runner.sh` keeps everything that actually does something: it sources `lib.sh`, performs the real side-effecting steps (the safe.directory config, the shallow-clone check with `exit 1`, skip/none handling with `exit 0`/`exit 1`), and finally invokes the packaged `drawio-exporter` binary with the built args.

That single boundary (logic that's safe to `source` versus a wrapper that does the real I/O and exits) is what makes the logic testable without Docker at all.

## Reuse the test framework you already have

The project already used [bats-core](https://github.com/bats-core/bats-core) for its Docker-based integration tests. Rather than reaching for `shunit2` or `shellspec` for the new unit layer, the same framework was reused for a `tests/unit/` suite that sources `lib.sh` directly and exercises every branch without Docker, without a real GitHub Actions context, and largely without a real git repository:

```bash
npx bats -r tests/unit
```

Wired up as `make unit-test`, this is now the fast, no-build path documented in `CONTRIBUTING.md`, sitting next to the slower `make test` that still builds the image and runs the pre-existing `tests/*.bats` integration suite. The two suites are complementary, not redundant: unit tests give fast, exhaustive coverage of the decision logic; integration tests give confidence that the packaged action still works end-to-end: Docker build, `action.yml` inputs mapping, and the real exporter binary included.

## The catch: state leaks when you `source` instead of running a subshell

![Two bats tests running in the same process: an INPUT_MODE value set in one test leaks into the next because lib.sh is sourced, not run in a subshell](/img/posts/testing-bash-github-actions-with-bats/state-leak.svg)

Because the unit tests `source` `lib.sh` directly into the bats test process rather than running it in a subshell, any global variable or `INPUT_*`/`GITHUB_*` env var left over from one test bleeds into the next unless it's explicitly unset. `lib.sh`'s functions communicate entirely through globals: they read a long list of `INPUT_*`/`GITHUB_*` env vars and set `action_mode`, `error_message`, `reference`, `args_array` as their "return value", so a `test_helper.bash` with a `reset_inputs()` run in `setup()` is required to unset every one of them before each test.

The trap is that this list has to be manually kept in sync with every input the logic reads. Add a new input to `action.yml`/`lib.sh` without a matching entry in `reset_inputs`, and nothing breaks immediately: it silently leaks into whichever test happens to run next, producing flaky, order-dependent failures that are hard to trace back to a missing `unset`.

The unit suite also isn't wired into any CI workflow yet: only `make unit-test` run locally exercises it, so a regression it would catch can still slip through green CI today. Worth remembering: a fast, thorough test suite only gives real safety once it's actually in the pipeline.

## The general pattern

None of this is specific to drawio-exporter. For any bash-based GitHub composite or Docker action:

- Split the entrypoint into a **side-effect-free logic library** (safe to `source`, no `exit`, no external mutation) and a **thin orchestration wrapper** that does the real I/O and exit calls. The logic can then be unit-tested with `bats` (or `shunit2`/`shellspec`) without Docker, without a GitHub Actions context, and without a real git repository for most cases.
- If you already have a test framework for integration tests, **reuse it** for the unit layer instead of introducing a second one. One runner, one syntax, one dependency to maintain.
- If your logic communicates through global variables instead of arguments and return values, be deliberate about resetting them between tests, and remember to actually wire the new suite into CI, or it's just a false sense of safety.
