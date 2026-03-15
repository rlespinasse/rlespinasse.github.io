#!/usr/bin/env -S just --justfile

set quiet := true

default:
	just --choose

# Serve the site on local
[group('Development mode')]
serve:
	hugo server -D

# Lint blog posts
[group('Development mode')]
lint:
	npx markdownlint-cli2

# Lint and fix blog posts
[group('Development mode')]
lint-fix:
	npx markdownlint-cli2 --fix

# Generate site for production
[group('Production mode')]
generate-site:
	hugo --gc --minify
	cp CNAME public/
	touch public/.nojekyll

# Extract Personal Opensource Release Notes
[group('Content Generation')]
release-notes-as-posts:
	./release-notes-as-posts.sh
