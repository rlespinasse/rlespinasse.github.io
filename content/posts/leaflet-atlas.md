---
title: "Leaflet Atlas: A Config-Driven Framework for Interactive GeoJSON Maps"
date: 2026-03-14T10:00:00+01:00
draft: false
summary: "Building interactive maps from GeoJSON files usually means writing the same Leaflet boilerplate over and over. Leaflet Atlas turns a JSON configuration and a folder of GeoJSON files into a full-featured map application — with layer filtering, smart polygon click-through, and auto-generated tile thumbnails."
tags:
- opensource
- github
- leaflet
- geospatial
categories:
- Technical posts
- Open Source
- Geospatial
---

It started with a territory, not a library.

I wanted to explore the open data available around the [Bassin Minier du Nord-Pas de Calais](https://github.com/rlespinasse/bassin-minier-unesco), a UNESCO World Heritage site near where I live.
The idea was simple: build an interactive map to discover the local heritage — mining sites, administrative boundaries, geological data — and learn about the territory through its open datasets.

As the map grew, something predictable happened.
The code that initialized Leaflet, loaded GeoJSON layers, wired up popups, handled polygon overlaps, and managed the layer control started looking less like application code and more like a library.
Patterns emerged: every layer needed the same loading logic, every popup needed the same sanitization, every set of overlapping polygons needed the same z-ordering trick.

Rather than letting that code stay buried inside a single project, I extracted it into [**Leaflet Atlas**](https://github.com/rlespinasse/leaflet-atlas) — a reusable, config-driven framework that would let me (and others) start the next map without rewriting the same boilerplate.

## The extraction

The goal was clear: take everything that was generic in the Bassin Minier map and turn it into a standalone npm package.
The application-specific parts — the actual heritage data, the BRGM integration, the legal overlay — stayed in the Bassin Minier project.
Everything else — map initialization, layer management, UI components, security sanitization — moved into Leaflet Atlas.

The Bassin Minier app then switched from its local copy of the code to the CDN-hosted Leaflet Atlas package.
What had been tightly coupled application code became a clean dependency.

## What is Leaflet Atlas?

Leaflet Atlas is a config-driven framework built on top of [Leaflet](https://leafletjs.com/).
Instead of writing JavaScript to set up every aspect of your map, you provide a JSON configuration that describes your layers, base tiles, and map behavior.
The framework reads that configuration, loads your GeoJSON files, and renders a fully interactive map.

If you can describe your map, you should not have to code it from scratch.

## Key features

Leaflet Atlas went from v0.0.0 to **v0.2.0** in its first week, driven by real needs from the Bassin Minier project:

### Config-driven layers

Define your GeoJSON layers in a configuration object. Each layer gets a name, a path to its GeoJSON file, and optional styling and popup templates. The framework handles loading, rendering, and layer control registration automatically.

### Smart polygon click-through with auto z-ordering

When polygons overlap — which happens constantly with administrative boundaries like EPCI and department limits — clicking on the map should reach the right feature.
Leaflet Atlas implements automatic z-ordering so that smaller polygons sit above larger ones, and click events pass through to the most specific feature under the cursor.

### Auto-generated tile thumbnails

Switching between base layers (satellite, street map, terrain) is easier when you can see what you are choosing.
Leaflet Atlas generates preview thumbnails for each base layer automatically, so the layer switcher shows a visual preview instead of just a text label.

### Searchable filter bar

As the number of layers grows, scrolling through a long list becomes impractical.
The layers drawer includes a searchable filter bar with keyboard shortcut support, letting users find and toggle layers quickly.

### Security

XSS prevention is built-in from the start.
User-provided content in popups and external URLs is sanitized before rendering — a lesson learned firsthand when reviewing BRGM data URLs in the Bassin Minier project.

## Getting started

Leaflet Atlas is published on npm and available via CDN.

### Via CDN

The quickest way to try Leaflet Atlas is to include it directly from a CDN:

```html
<link rel="stylesheet" href="https://unpkg.com/leaflet-atlas/dist/leaflet-atlas.css" />
<script src="https://unpkg.com/leaflet-atlas/dist/leaflet-atlas.umd.js"></script>
```

### Via npm

For projects using a bundler:

```bash
npm install leaflet-atlas
```

Then import and initialize:

```javascript
import { LeafletAtlas } from 'leaflet-atlas';

const atlas = new LeafletAtlas({
  target: 'map',
  // your configuration here
});
```

## Quality and CI

The project uses [Vitest](https://vitest.dev/) for unit testing, ESLint with flat config for linting, and a testing matrix across Node LTS versions.
Releases are automated with [semantic-release](https://semantic-release.gitbook.io/) via GitHub Actions, publishing to npm with OIDC trusted publisher authentication.

Dependabot monitors dependencies weekly, and contributor guidelines are in place for anyone who wants to get involved.

## A virtuous cycle: library and maps feeding each other

The interesting part of this approach is the feedback loop between Leaflet Atlas and the maps that use it.

The [Bassin Minier UNESCO](https://github.com/rlespinasse/bassin-minier-unesco) map was where the library was born — its needs shaped the initial feature set.
Now I am building a second map for the [Parc naturel régional du Morvan](https://github.com/rlespinasse/morvan), an entirely different territory in Burgundy with its own layers: forests, lakes, hiking trails, administrative boundaries, demographic data.

Each new map surfaces new requirements.
The Morvan project is already revealing features that the Bassin Minier map did not need, and exposing edge cases that only appear with different data shapes.
Those discoveries flow back into Leaflet Atlas as new features and bugfixes, which in turn benefit every map that depends on the library.

At the same time, the industrialization of the npm package — proper versioning, CI/CD, documentation, CDN distribution — makes each subsequent map project faster to bootstrap.
What took days of custom code for the first map takes minutes of configuration for the next one.

## What comes next

The framework is still young — v0.2.0 is the latest release — and there is plenty of room to grow.
Every new mapping project I start is an opportunity to discover what Leaflet Atlas is missing and push the library further.

If you work with GeoJSON data and want to spend less time on map boilerplate, give Leaflet Atlas a try.
Contributions, bug reports, and feature requests are welcome at [github.com/rlespinasse/leaflet-atlas](https://github.com/rlespinasse/leaflet-atlas).
