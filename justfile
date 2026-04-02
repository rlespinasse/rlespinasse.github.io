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

