---
title: "Antora 1.0 : Transformez votre wiki en site de documentation performant"
date: 2018-04-18T10:42:00+02:00
draft: false
showTableOfContents: false
summary: Decouverte d'Antora comme votre prochain site de documentation.
featureimage: /img/posts/antora/featured.jpg
tags:
- antora
- asciidoctor
- french
- documentation
categories:
- Technical posts
- Documentation
---

> Hi, the english version of this article can be read [on this site](/posts/antora-en/)

Peu importe votre projet informatique, il y aura toujours un besoin de stocker de la documentation.
Le choix d'utiliser un [wiki](https://fr.wikipedia.org/wiki/Wiki) est assez courant en entreprise.

Parlons de vous, développeur sur un de ces programmes, la documentation des différents projets est-elle gérée par un wiki facilement accessible et éditable?

Et si vous regardez le contenu de ce wiki, vous y trouverez surement :

* Des pages avec des sections `à documenter`,
* Des pages avec des informations erronées,
* Des pages dépréciées,
* Des pages uniquement utiles pour une équipe ou une autre,
* Des pages avec de la documentation sur une future évolution.

Vous vous demandez donc comment faire pour faciliter la tâche des personnes travaillant sur les différents projets.

À ce moment là, le principe de la `documentation as code` vous paraît être la solution à votre besoin.

## Vous vous lancez dans l'aventure de la documentation as code

Voir la documentation comme du code au même titre que les sources du programme est intéressant.
Vous souhaitez remplacer votre wiki actuel par un projet dédié à la documentation, et vous permettre de faire des `code review` sur ces changements.
Mais cela ne corrige qu'une partie du problème, vous avez seulement remplacé des pages wiki par des fichiers écrits dans un autre format comme :

* le format [Markdown](https://daringfireball.net/projects/markdown/syntax),
* le format [Asciidoc](http://www.methods.co.nz/asciidoc/).

Du fait de sa syntaxe simple et accessible, le format `Markdown` est un des plus répandu, surtout sur des sites comme github ou gitlab. Mais le format est trop simple pour une documentation plus approfondie.

Le format `Asciidoc` est [plus intéressant](https://github.com/asciidoctor/asciidoctor.org/blob/master/docs/_includes/asciidoc-vs-markdown.adoc), il permet d'être plus expressif dans votre documentation.
L'outil associé [Asciidoctor](https://asciidoctor.org/) apporte des [fonctionnalités utiles](https://asciidoctor.org/docs/asciidoc-writers-guide/) ainsi que des intégrations comme la génération de diagrammes avec [plantuml](http://plantuml.com/).

Vous choisissez donc d'écrire la documentation en **Asciidoctor** dans chacun des projets.
Cela vous permet de livrer la documentation à jour en même temps que le code associé.

Même si votre programme se compose d'un ensemble de projets avec chacun sa documentation, vous souhaitez garder un site unique pour y accèder.

Les personnes derrière Asciidoctor ont récemment ouvert, à la communauté open-source, un générateur de site de documentations aggrégées: [Antora](https://antora.org/) en version stable (`1.0.0`).

![Antora](/img/posts/antora/site.png)

## Vous créez votre nouveau site de documentation avec Antora / Asciidoctor

Un site généré par Antora est [composé de trois éléments](https://docs.antora.org) :

* Vos projets qui contiennent leurs documentations,
* Le [**playbook**](https://docs.antora.org/antora/1.0/playbook/) qui configure la génération du site de documentation,
* Une [**UI**](https://docs.antora.org/antora/1.0/playbook/configure-ui/) qui définit le visuel de votre site (celle par défaut conviendra).

Pour être utilisé par Antora, un projet se doit de respecter une [structure de fichiers](https://docs.antora.org/antora/1.0/component-structure/)

```text
./docs
├── antora.yml
└── modules
    └── ROOT
        ├── _attributes.adoc
        ├── nav.adoc
        └── pages
            ├── _attributes.adoc
            └── index.adoc
```

### Vous mettez en place la documentation as code sur vos projets

Vous vous appliquez donc à le mettre en place sur :

* Vos APIs ([api A](https://github.com/rlespinasse/api-a), [api B](https://github.com/rlespinasse/api-b), [api C](https://github.com/rlespinasse/api-c)),
* Vos outils ([build tools](https://github.com/rlespinasse/buildtools)),
* Votre guide de development ([guidelines](https://github.com/rlespinasse/guidelines)).

La documentation au format `Asciidoctor` est disponible dans le dossier `docs`.
> Il n'est pas nécessaire d'utiliser cette arborescence pour `guideline`, qui est uniquement un projet de documentation.

### Vous vous préparez à générer votre site de documentation

Vous créez donc un [projet spécifique](https://github.com/rlespinasse/docssite) pour stocker le **playbook**.

```yaml
site:
  title: "Romain Lespinasse // Docs"
  start_page: guidelines::index
  url: https://rlespinasse.github.io/docssite
content:
  sources:
  - url: https://github.com/rlespinasse/api-a.git
    branches: master
    tags: v*
    start_path: docs
  - url: https://github.com/rlespinasse/api-b.git
    branches: master
    tags: v*
    start_path: docs
  - url: https://github.com/rlespinasse/api-c.git
    branches: master
    tags: v*
    start_path: docs
  - url: https://github.com/rlespinasse/buildtools.git
    branches: master
    tags: v*
    start_path: docs
  - url: https://github.com/rlespinasse/guidelines.git
    branches: master
ui:
  bundle:
    url: https://gitlab.com/antora/antora-ui-default/-/jobs/artifacts/master/raw/build/ui-bundle.zip?job=bundle-stable
    snapshot: true
  output_dir: ui-bundle
  supplemental_files: ./supplemental-ui
output:
  dir: ./docs
```

Le contenu du [playbook](https://docs.antora.org/antora/1.0/playbook/playbook/) `site.yml` définit :

* les [informations relatives](https://docs.antora.org/antora/1.0/playbook/configure-site/) au site en lui-même via `site:`,
* la définition du [contenu](https://docs.antora.org/antora/1.0/playbook/configure-content-sources/) via `content:`,
* le [theme du site](https://docs.antora.org/antora/1.0/playbook/configure-ui/) via `ui:`,
* Le [dossier de génération](https://docs.antora.org/antora/1.0/playbook/configure-output/) via `output:`.

La documentation officielle n'en fait pas référence, car il s'agit d'un [dévelopement encore au stade expérimental](https://gitlab.com/antora/antora/issues/147) mais vous configurez la barre de navigation pour rajouter les liens utiles via un fichier `header-content.hbs` dans `supplemental-ui/partials/`.
> D'autres fichiers templates sont disponibles pour remplacement dans [Antora Default UI](https://gitlab.com/antora/antora-ui-default/tree/master/src/partials).

## Vous générez et déployez votre nouveau site de documentation

Vous pouvez installer antora via ce [guide](https://docs.antora.org/antora/1.0/install/install-antora/) ou utiliser l'image docker via la commande ``docker run -v `pwd`:/antora --rm antora/antora --stacktrace site.yml`` (où **site.yml** est le playbook)

Le playbook défini le dossier `docs` pour mettre à disposition votre nouveau site de documentation.

![Site preview](/img/posts/antora/site-preview.png)

Par exemple, pour le rendre accessible sur Github, vous le déployez via les Github Pages de votre projet `docssite`.

![Github document configuration](/img/posts/antora/github.png)

La plateforme s'occupera automatiquement d'exposer le contenu du dossier `/docs` à l'adresse [https://rlespinasse.github.io/docssite](https://rlespinasse.github.io/docssite).

## Vous faites profitez aux autres du nouveau site de documentation

Dorénavant, les personnes, travaillant sur le programme, pourront ajouter, créer, maintenir de la documentation relative à chacun des projets très facilement. Votre nouveau site de documentation permettant d'accèder à toutes ces pages.

Le site [docs.antora.org](https://docs.antora.org) utilise lui-même le projet `Antora`.

> Merci à [Aurélien Allienne](https://twitter.com/sn0rks), [Antoine Méausoone](https://twitter.com/AMeausoone), [Hubert Sablonnière](https://twitter.com/hsablonniere), [Tanguy Baudrin](https://twitter.com/TanguyBAUDRIN), et [Tony Proum](https://twitter.com/chezTone) pour la relecture de l'article.

Cet article a été publié en premier sur [lemag.sfeir.com](https://sfeir.com).
