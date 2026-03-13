---
title: "2026 Changelog: All Releases and Updates for 'rlespinasse/bassin-minier-unesco'"
summary: Changelog of the 4 releases for 2026
date: 2026-03-12T11:32:00Z
lastmod: 2026-03-13T08:32:03Z
showToC: false
draft: false
tags:
- opensource
- github
categories:
- Changelog posts
---
## Fixes

- Validate BRGM URL scheme to prevent XSS

## Other

- Upgrade leaflet-atlas from 0.1.0 to 0.1.1
- Replace local leaflet-atlas lib with CDN package
- Remove dead code and modernize helpers
- Extract shared utilities into utils.py
- Add LICENSE and CONTRIBUTING files
- Add missing Diataxis documentation pages
- Reference leaflet-atlas library in legal credits## Features

- Add favicon and web app manifest
- Display favicon icon in title panel
- Add legal information overlay (mentions légales, confidentialité, crédits)

## Other

- Use blue background and grey terrils for favicon
- Extract reusable leaflet-atlas library from app code## Features

- Add EPCI intercommunality layer and commune enrichment
- Add department boundary layer with reverse links
- Restructure detail panel header with layer type above title
- Add resizable detail panel with wider default on large screens
- Center default view on bassin minier layer
- Add partial toggle state for layer groups
- Add keyboard shortcuts and help overlay

## Fixes

- Skip GoatCounter analytics on localhost
- Track single page view instead of every hash change
- Add border click layers for context layer interaction
- Prefix GoatCounter event paths with base URL

## Other

- Restructure documentation following the Diataxis framework
- Split monolithic JS and CSS into focused modulesFirst feature release of the Bassin Minier UNESCO interactive map.

## Features

### Map
- Add static site with interactive Leaflet map
- Add search control to find features across all map layers
- Replace base maps with IGN Plan and CartoDB Positron
- Add gray mask outside bassin-minier perimeter and reorganize layers
- Make map full-viewport with overlay controls
- Add data.gouv.fr source links to feature detail panels
- Display all unused dataset fields in detail panels
- Close detail panel on Escape key and map click
- Replace layer controls with unified layers drawer
- Replace layer checkboxes with +/- toggle buttons
- Add SVG pattern textures to polygon layers
- Add cross-layer links in detail panel
- Add shareable URL state and reset view control
- Add back/forward navigation in detail panel
- Add bidirectional reverse links between features
- Integrate GoatCounter analytics for page views and events

### Data
- Add data conversion scripts for GeoJSON generation
- Add WFS datasets for buffer zones, communes, and equipment layers
- Add GeoJSON enrichment script to merge overlapping datasets

## Bug Fixes
- Show feature count for all grouped layers
- Position detail panel as absolute overlay on desktop
- Ensure small features inside larger ones remain clickable
- Improve bottom controls layout on mobile
- Match commune cross-links with accented names
- Use dynamic viewport height for mobile browsers
- Respect safe area insets on iPhone
- Improve element link highlight visibility
- Improve reverse link readability in detail panel

## Refactoring
- Improve layer visual hierarchy and click behavior
- Modernize app.js with ES6 syntax and fix hover reset bug
- Introduce CSS custom properties and deduplicate styles
- Merge duplicate layer groups and disambiguate labels

## Style
- Use magnifying glass icons for zoom controls

## CI/CD & Build
- Add justfile for project tasks
- Add GitHub Pages deployment workflow and Dependabot config
- Set up mise for tooling

## Documentation
- Add README with project documentation
- Split datasets section by source and document enrichments