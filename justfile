#!/usr/bin/env -S just --justfile

set quiet := true

default:
	just --choose

# Serve the site on local
[group('Development mode')]
serve:
	hugo server -D --buildFuture

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

# List all draft posts on the drafts branch
[group('Drafts')]
drafts:
	#!/usr/bin/env bash
	set -euo pipefail
	current_branch="$(git branch --show-current)"
	if [ "$current_branch" != "drafts" ]; then
		echo "Listing draft posts from the drafts branch (you are on $current_branch):"
		files="$(git diff main..drafts --name-only -- content/posts/ 2>/dev/null || true)"
	else
		echo "Draft posts on current branch:"
		files="$(git diff main --name-only -- content/posts/)"
	fi
	if [ -z "$files" ]; then
		echo "  No draft posts found."
	else
		echo "$files" | sed 's|content/posts/||;s|\.md$||' | while read -r slug; do
			echo "  - $slug"
		done
	fi

# Prepare a post for publication: creates a post/<slug> branch from main with the post's files
[group('Drafts')]
prepare-post slug:
	#!/usr/bin/env bash
	set -euo pipefail
	SLUG='{{ slug }}'

	# Verify we have the post on drafts
	if ! git cat-file -e "drafts:content/posts/${SLUG}.md" 2>/dev/null; then
		echo "Error: content/posts/${SLUG}.md not found on drafts branch"
		exit 1
	fi

	# Check branch doesn't already exist
	if git show-ref --verify --quiet "refs/heads/post/${SLUG}"; then
		echo "Error: branch post/${SLUG} already exists"
		exit 1
	fi

	# Create branch from main
	git checkout -b "post/${SLUG}" main

	# Bring post file
	git checkout drafts -- "content/posts/${SLUG}.md"

	# Bring images if they exist
	if git ls-tree -d "drafts:assets/img/posts/${SLUG}" &>/dev/null; then
		git checkout drafts -- "assets/img/posts/${SLUG}/"
	fi

	echo ""
	echo "Branch post/${SLUG} created."
	echo "Next steps:"
	echo "  1. Set draft: false and the publication date in the frontmatter"
	echo "  2. Commit, push, and open a PR to main"

# Rebase drafts branch onto main (run after merging a post PR)
[group('Drafts')]
sync-drafts:
	#!/usr/bin/env bash
	set -euo pipefail
	current_branch="$(git branch --show-current)"
	git checkout drafts
	git rebase main
	echo "drafts branch rebased onto main."
	if [ "$current_branch" != "drafts" ]; then
		git checkout "$current_branch"
	fi

# Initialize a sfeir.dev redirect post from its URL
[group('Content')]
add-sfeirdev url:
	#!/usr/bin/env bash
	set -euo pipefail
	URL='{{ url }}'

	# Extract last path segment as article slug
	ARTICLE_SLUG="$(echo "${URL%/}" | rev | cut -d'/' -f1 | rev)"
	POST_SLUG="sfeirdev-${ARTICLE_SLUG}"
	POST_FILE="content/posts/${POST_SLUG}.md"
	IMG_DIR="assets/img/posts/${POST_SLUG}"

	if [ -f "$POST_FILE" ]; then
		echo "Post already exists: $POST_FILE"
		exit 1
	fi

	echo "Fetching ${URL}..."
	HTML="$(curl -sL "$URL")"

	# Extract OG meta tags (handles both attribute orderings)
	extract_og() {
		local prop="$1"
		local val
		val="$(echo "$HTML" | grep -oE "property=\"${prop}\" content=\"[^\"]+\"" | grep -oE 'content="[^"]+"' | cut -d'"' -f2 | head -1)"
		[ -z "$val" ] && val="$(echo "$HTML" | grep -oE "content=\"[^\"]+\" property=\"${prop}\"" | cut -d'"' -f2 | head -1)"
		echo "$val"
	}

	OG_IMAGE="$(extract_og 'og:image')"
	OG_TITLE="$(extract_og 'og:title')"
	OG_DESC="$(extract_og 'og:description')"
	PUB_DATE="$(extract_og 'article:published_time')"
	[ -z "$PUB_DATE" ] && PUB_DATE="$(date +"%Y-%m-%dT00:00:00+02:00")"

	if [ -z "$OG_IMAGE" ]; then
		echo "Could not find og:image on ${URL}"
		exit 1
	fi

	# Get file extension (strip query string if any)
	EXT="${OG_IMAGE##*.}"
	EXT="${EXT%%\?*}"

	# Download feature image
	mkdir -p "$IMG_DIR"
	echo "Downloading feature image (${EXT})..."
	curl -sL "$OG_IMAGE" -o "$IMG_DIR/featured.${EXT}"

	# Write post file
	{
		printf -- '---\n'
		printf 'title: "%s (sfeir.dev)"\n' "$OG_TITLE"
		printf 'date: %s\n' "$PUB_DATE"
		printf 'layout: "redirect"\n'
		printf 'featureimage: /img/posts/%s/featured.%s\n' "$POST_SLUG" "$EXT"
		[ -n "$OG_DESC" ] && printf 'summary: "%s"\n' "$OG_DESC"
		printf 'tags:\n- french\ncategories:\n- Technical posts\n- Sfeir.dev\n'
		printf -- '---\n\n'
		printf '<script>window.location.href = "%s";</script>\n' "$URL"
		printf '<meta http-equiv="refresh" content="0; url=%s">\n\n' "$URL"
		printf 'If you are not redirected automatically, [click here](%s).\n' "$URL"
	} > "$POST_FILE"

	echo "Created: $POST_FILE"
	echo "Image:   $IMG_DIR/featured.${EXT}"

