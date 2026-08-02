---
title: "The Simplest Way to Make Just Interactive: Use --choose"
date: 2026-02-20T21:20:00+0100
draft: false
summary: "Forget complex piping and xargs. Learn how to use the built-in --choose flag to turn your justfile into an interactive menu instantly."
featureimage: /img/posts/interactive-just-recipes/featured.svg
tags:
- terminal
- productivity
- just
- fzf
categories:
- Tips & Tricks
---

## The "native" way

While you *can* manually pipe `just --list` into `fzf`, `just` has a built-in feature that handles this natively.
If you have `fzf` installed, you don't need a custom recipe at all.

### The One-Liner

Simply run:

```bash
just --choose
```

This command automatically parses your recipes, opens `fzf`, and executes your selection once you hit Enter.

## Level up with shell aliases

If you find yourself running specific types of tasks frequently, you can combine `just --choose` with a shell alias.
This is perfect for filtering down to specific "namespaces" if you use a prefix naming convention (e.g., `docker-build`, `docker-up`).

Add this to your `.zshrc` or `.bashrc`:

```bash
# General interactive just
alias j='just --choose'

# Interactive just filtered for Docker tasks only
alias jd='just --choose --chooser "fzf --query=docker"'
```

## Customizing the UI

You can customize the look and feel of the chooser globally by setting the `JUST_CHOOSER` environment variable.
This allows you to add colors or change the layout without touching your `justfile`.

```bash
export JUST_CHOOSER='fzf --header "⚡ Select Task" --height 40% --layout reverse --border'
```

## Why this is better

1. **Zero Boilerplate:** You don't need to pollute your `justfile` with a "menu" recipe.
2. **Clean Output:** It respects docstrings and ignores internal recipes (those starting with an underscore).
3. **Speed:** It's a single binary call rather than a chain of piped commands.

## The "one-touch" justfile

If you want the interactive menu to appear by default when you just type `just` in your terminal, add this to the top of your file:

```just
# Run the interactive chooser by default
default:
    @just --choose
```

## Conclusion

`just --choose` turns a justfile into an interactive menu without any manual piping or custom recipe.
It works the same whether you are picking a Docker task or just triggering a local build.
