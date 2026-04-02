---
title: "Fixing Textlint's README Terminology Rule"
date: 2026-04-03T00:30:00+02:00
draft: false
summary: "The default textlint terminology rule lowercases README to readme. Here is how to override it while keeping the rest of the built-in terms."
featureimage: /img/posts/textlint-readme-terminology/featured.svg
tags:
- textlint
- ci/cd
categories:
- Tips & Tricks
---

README is uppercase. It has been since the early Unix days, when filenames were capitalized so they would sort first in directory listings.
GitHub uses README. npm uses README. The convention is universal in software.

Yet the default textlint terminology rule maps `README` to `readme` — lowercase.
Every occurrence of README in documentation files gets flagged as incorrect.

## The problem

[textlint-rule-terminology](https://github.com/sapegin/textlint-rule-terminology) ships with a default term list that enforces lowercase `readme` for any variant of README.

```text
18:1   error  Incorrect term: "READMEs", use "Readmes" instead  terminology
20:69  error  Incorrect term: "README", use "readme" instead    terminology
```

Disabling the terminology rule entirely is not an option — it catches real mistakes like `file name` vs `filename` or `anti-pattern` vs `antipattern`.
The goal is to override a single term while keeping everything else.

## The fix

![Override flow: exclude the built-in pattern, then add a custom term](/img/posts/textlint-readme-terminology/override-flow.svg)

Add this to your `.textlintrc`:

```json
{
  "rules": {
    "terminology": {
      "skip": ["Link"],
      "exclude": [
        "readme(s)?"
      ],
      "terms": [
        ["README(s)?", "README$1"]
      ]
    }
  }
}
```

Three key settings:

- **`exclude`** removes the built-in `readme(s)?` pattern from the default term list. The value must match the **regular expression pattern** from the built-in list, not the replacement string.
- **`terms`** adds a custom replacement: match `README(s)?` and replace with `README$1`, preserving the plural when present.
- **`skip`** tells the rule to ignore link nodes — without this, URLs containing "README" would also get flagged.

### Super-Linter specificity

When using [Super-Linter](https://github.com/super-linter/super-linter), the `.textlintrc` must be placed in `.github/linters/.textlintrc`.
A `.textlintrc` at the repository root will not be picked up as a config file.

## Common mistakes

**Using the replacement string in `exclude`.**
Setting `"exclude": ["README"]` does nothing — the exclude matches against the regular expression pattern (`readme(s)?`), not the replacement.

**Setting `defaultTerms` to `false`.**
The `defaultTerms` option defaults to `true`, so it does not need to be set explicitly. Setting it to `false` removes all built-in terms — which defeats the purpose of using the terminology rule at all.

## Verifying

```bash
npx textlint --rule terminology docs/your-file.md
```

## The takeaway

The textlint terminology rule is useful, but its built-in term list reflects general English conventions that do not always match software conventions.
When a built-in term is wrong for a project, `exclude` the pattern and `terms` the correct replacement — do not fight the linter by disabling the whole rule.
