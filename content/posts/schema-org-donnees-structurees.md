---
title: "Schema.org sur ce blog : ce que le thème Blowfish génère déjà pour vous"
date: 2026-08-02T16:00:00+01:00
draft: true
summary: "Ce blog Hugo, sans configuration particulière, injecte déjà du JSON-LD Schema.org sur chaque page grâce au thème Blowfish. Décryptage du partial qui le génère, et de ce qu'il faut vérifier avant de s'en satisfaire."
featureimage: /img/posts/schema-org-donnees-structurees/featured.svg
tags:
- seo
- web
- json-ld
- hugo
- french
categories:
- Technical posts
- Tips & Tricks
---

Si le terme Schema.org vous est encore flou, [l'article Schema.org : définition sur sfeir.dev]({{< ref "sfeirdev-schema-org-definition.md" >}}) pose les bases : un vocabulaire commun, porté par les moteurs de recherche, pour décrire le contenu d'une page en JSON-LD.

Ce que cet article-là ne dit pas, c'est qu'il n'y a rien à installer pour en profiter, du moins pas sur ce blog. En inspectant le code source de n'importe quelle page de ce blog, on trouve déjà un bloc `<script type="application/ld+json">` généré automatiquement, sans qu'aucun front matter dédié n'ait été écrit. Voici d'où il vient et ce qu'il contient réellement.

## Un partial dédié dans le thème

Ce site utilise [Blowfish](https://blowfish.page/), un thème Hugo. Blowfish embarque un fichier `layouts/partials/schema.html` qui génère le balisage JSON-LD à la place du développeur, en s'appuyant uniquement sur les métadonnées déjà présentes dans le front matter et la configuration du site : titre, description, date, tags, auteur.

Deux cas sont traités distinctement :

- sur la page d'accueil, un type `WebSite`,
- sur toute page de contenu (comme celle-ci), un type `Article`, avec en option un `BreadcrumbList`.

## Ce qui est réellement publié pour cet article

En construisant le site avec `hugo --gc --minify`, le JSON-LD généré pour un article de ce blog ressemble à ceci (exemple pris sur un autre post du blog) :

```json
{
  "@context": "https://schema.org",
  "@type": "Article",
  "articleSection": "Posts",
  "name": "Hugo: Crafting Your Digital Identity",
  "headline": "Hugo: Crafting Your Digital Identity",
  "inLanguage": "en",
  "url": "https://www.romainlespinasse.dev/posts/gohugo/",
  "author": {
    "@type": "Person",
    "name": "Romain Lespinasse",
    "image": "https://www.romainlespinasse.dev/img/rlespinasse.jpg",
    "sameAs": [
      "https://github.com/rlespinasse",
      "https://gitlab.com/rlespinasse",
      "https://www.linkedin.com/in/romain-lespinasse",
      "https://dev.to/rlespinasse"
    ]
  },
  "copyrightYear": "2019",
  "dateCreated": "2019-10-27T10:42:00+02:00",
  "datePublished": "2019-10-27T10:42:00+02:00",
  "dateModified": "2019-10-27T10:42:00+02:00",
  "keywords": ["hugo", "staticsite", "github", "opensource"],
  "mainEntityOfPage": "https://www.romainlespinasse.dev/posts/gohugo/",
  "wordCount": "746"
}
```

Chaque champ vient directement du front matter ou de la configuration : `headline` reprend `title`, `keywords` reprend `tags`, `datePublished` reprend `date`. Le `author.sameAs` liste les profils sociaux déclarés côté configuration du site (GitHub, GitLab, LinkedIn, Dev.to), ce qui aide un moteur de recherche à relier l'auteur de l'article à une identité vérifiable ailleurs sur le web.

## Le détail qui mérite d'être vérifié : la résolution de l'auteur

Le partial de Blowfish sait résoudre l'auteur de deux façons : soit via une clé `authors` dans le front matter d'un article, pointant vers un fichier dans `data/authors/`, soit, en l'absence de cette clé, via l'auteur global défini dans la configuration du site. Ce blog n'a pas de dossier `data/authors/` : tous les articles retombent donc systématiquement sur l'auteur global, quel que soit leur contenu. Sur un blog collaboratif, oublier ce détail produirait un JSON-LD qui attribue chaque article au même auteur, même si le front matter mentionne quelqu'un d'autre.

## Une option silencieuse : les breadcrumbs structurés

Le partial peut aussi émettre un `BreadcrumbList`, mais seulement si `enableStructuredBreadcrumbs` est activé dans les paramètres du site, ce qui n'est pas le cas ici. C'est un exemple concret de fonctionnalité Schema.org disponible « gratuitement » dans le thème, mais qui reste invisible tant qu'elle n'est pas explicitement activée.

## Ce que ça signifie concrètement

Avoir du JSON-LD généré automatiquement ne dispense pas de le vérifier : un thème peut très bien produire un balisage syntaxiquement valide mais sémantiquement pauvre (pas d'image d'auteur configurée, pas de `sameAs`, breadcrumbs désactivés). Avant de considérer le sujet clos sur un site basé sur un thème existant, il vaut la peine de :

- ouvrir le code source d'une page et chercher `application/ld+json`,
- passer l'URL dans le [Rich Results Test](https://search.google.com/test/rich-results) ou le [Schema Markup Validator](https://validator.schema.org/),
- vérifier que les champs qui comptent pour vous (auteur, dates, image) sont bien renseignés dans la configuration, pas seulement dans le template.

Le thème fait le gros du travail ; il reste à s'assurer que les données qu'il assemble sont, elles, complètes et exactes.
