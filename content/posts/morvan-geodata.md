---
title: "Morvan : assembler des données géospatiales pour un parc naturel régional"
date: 2026-05-07T09:00:00
draft: false
featureimage: /img/posts/morvan-geodata/featured.svg
summary: "Le projet Morvan transforme des données ouvertes françaises (téléchargées depuis data.gouv.fr et TerNum BFC) en 73 couches GeoJSON organisées en 9 catégories thématiques. Le pipeline automatisé avec just gère la reprojection Lambert 93 vers WGS84 et la configuration d'une carte Leaflet interactive, avec une structure conçue pour rester maintenable à mesure que les sources évoluent."
tags:
  - opensource
  - geospatial
categories:
  - Technical posts
---

Le [Parc naturel régional du Morvan](https://www.parcdumorvan.org/) est un espace protégé en Bourgogne.
Il couvre un paysage montagneux et boisé avec des lacs, des rivières, des petites communes et un riche patrimoine culturel.
Contrairement à une carte urbaine où un seul jeu de données fournit rues et bâtiments, cartographier un parc naturel régional implique de puiser des données dans de nombreuses sources différentes : limites administratives, éléments naturels, démographie, infrastructures touristiques, réseaux énergétiques, et bien d'autres.

[**Morvan**](https://github.com/rlespinasse/morvan) est un projet open source qui assemble ces données géospatiales dans un format structuré et réutilisable pour la cartographie interactive.

## Explorer les données disponibles

Le point de départ est simple : je veux faire une carte du Morvan. Quelles données existent ?

Pour explorer l'offre disponible, j'ai utilisé [datagouv-mcp](https://github.com/datagouv/datagouv-mcp), un serveur MCP qui expose l'API data.gouv.fr directement dans Claude Code.
Plutôt que de naviguer manuellement dans l'interface web, j'ai pu interroger le catalogue par mots-clés, explorer les jeux de données d'un producteur, et inspecter les ressources disponibles sans quitter le terminal.

Les recherches autour du Morvan et du Parc naturel régional font remonter des jeux de données publiés par le Parc lui-même, par [TerNum BFC](https://trouver.ternum-bfc.fr/) (le portail régional Bourgogne-Franche-Comté), et par des organismes nationaux.

Ce qui frappe d'emblée : les données existent, en quantité, mais elles sont dispersées entre de nombreux producteurs.
Un dataset pour les communes adhérentes, un autre pour les zones Natura 2000, un autre pour les installations d'énergie renouvelable, chacun dans son propre format, avec sa propre projection.

C'est ce constat qui motive la structure du projet : avant de cartographier, il faut assembler.

## Le défi : de nombreuses sources de données, une seule carte

Un parc naturel régional touche à presque toutes les catégories de données géographiques :

- **Limites administratives** : le périmètre du parc, les communes, les cantons, les départements
- **Démographie** : répartition de la population, densité, zones urbaines et rurales
- **Énergie** : infrastructures électriques, installations d'énergie renouvelable
- **Eau** : rivières, lacs, bassins versants, réseaux hydrographiques
- **Nature** : zones protégées, forêts, zones de biodiversité
- **Patrimoine** : sites historiques, monuments architecturaux, points d'intérêt culturel
- **Paysages** : classifications du terrain, zones panoramiques, caractéristiques géologiques
- **Programmes** : programmes de développement, initiatives environnementales, zones de planification
- **Tourisme** : sentiers, hébergements, centres d'accueil, points d'intérêt

Toutes ces données proviennent de deux portails de données ouvertes françaises : [data.gouv.fr](https://www.data.gouv.fr/) pour les jeux nationaux et [TerNum BFC](https://trouver.ternum-bfc.fr/) pour les données régionales Bourgogne-Franche-Comté.
Le premier défi n'est pas d'afficher les données : c'est de les organiser.

## Choix de structure des couches

Le projet organise les données GeoJSON dans une hiérarchie de répertoires claire, un dossier par catégorie thématique.

```
data/layers/
├── administratif/        # 5 couches : périmètre, communes, EPCI, départements…
├── hydrographie/         # 13 couches : cours d'eau, bassins versants, contrats territoriaux…
├── nature-environnement/ # 9 couches : Natura 2000, forêts, tourbières…
├── paysages/             # 11 couches : entités paysagères, points de vue, routes d'intérêt…
├── patrimoine-culture/   # 7 couches : patrimoine bâti, châteaux, écomusée…
├── tourisme-economie/    # 11 couches : hébergements, grandes itinérances, sentiers…
├── programmes/           # 5 couches : LEADER, animations EnR, parcelles acquises
├── demographie/          # 5 couches : population, logements, emplois…
└── energie/              # 7 couches : installations EnR, chaufferies bois…
```

Cette structure remplit deux objectifs.
Premièrement, elle rend les données navigables pour les humains : on peut trouver ce que l'on cherche sans lire le code.
Deuxièmement, elle correspond directement à la configuration des couches utilisée par l'application cartographique, donc ajouter une nouvelle source de données revient à ajouter un fichier dans le bon dossier et à mettre à jour une seule entrée de configuration.

## Pipeline de traitement

Les données institutionnelles françaises sont distribuées en projection [Lambert 93](https://epsg.io/2154) (EPSG:2154), mais [Leaflet](https://leafletjs.com/) et la spécification [RFC 7946](https://www.rfc-editor.org/rfc/rfc7946) exigent du [WGS84](https://epsg.io/4326) (EPSG:4326).
Le pipeline résout ce décalage en deux étapes distinctes.

`data/layers/` conserve les fichiers bruts en Lambert 93 comme source de vérité : traçabilité garantie, coordonnées d'origine préservées.
`site/public/data/layers/` contient les versions reprojetées en WGS84, régénérées à chaque déploiement.

Le pipeline est écrit en Python avec trois bibliothèques :

- **requests** : télécharge les GeoJSON depuis les portails via les URLs référencées dans `sources.json`
- **pyproj** : reprojette Lambert 93 vers WGS84 avec arrondi à 6 décimales (~10 cm de précision)
- **shapely** : calcule les relations spatiales entre couches (appartenance de communes à des zones Natura 2000, contenance de points d'intérêt dans des entités paysagères)

![Pipeline de traitement : des portails vers Leaflet](/img/posts/morvan-geodata/pipeline.svg)

## Automatisation avec justfile

Le pipeline de traitement est automatisé grâce à un [justfile](https://just.systems/).
Chaque recette gère une étape spécifique :

```sh
just fetch      # télécharge les 73 couches depuis les portails
just reproject  # reprojette Lambert 93 → WGS84
just prepare    # reconstruit l'ensemble des données web
just all        # installation + téléchargement + validation
```

Un nouveau contributeur peut reconstruire toutes les données géographiques à partir des sources avec une seule commande, sans connaître les détails de chaque transformation.

## Documentation

La documentation du projet suit le framework [Diataxis](https://diataxis.fr/) dès le départ, avec des pages séparées pour les tutoriels, les guides pratiques, les explications et le matériel de référence.
Commencer avec une documentation structurée tôt (plutôt que de la rétrofiter plus tard) facilite l'intégration des contributeurs et la maintenance du projet à mesure que les sources de données évoluent.

## Et ensuite ?

La structure fondamentale est en place : 73 couches dans 9 catégories, pipeline de traitement, automatisation et documentation.
La collecte de données est en cours : l'objectif est d'enrichir chaque catégorie au fil des nouvelles sources disponibles sur les portails.
L'application cartographique Leaflet est déjà intégrée dans le dépôt et exploite l'ensemble des couches générées, avec des liens spatiaux bidirectionnels entre couches pour naviguer entre une commune, ses données démographiques, ses zones naturelles et ses points d'intérêt touristique.

Certains jeux de données dépassent les 8 000 entrées : un volume qui pose des questions de performance sur une carte web.
Charger et afficher autant de features en GeoJSON brut n'est pas viable ; la suite implique d'explorer des stratégies comme le clustering, le filtrage côté client, ou la tuile vectorielle pour garder l'application fluide à toutes les échelles.

Si vous vous intéressez à la géographie régionale française, au traitement de données ouvertes ou à l'organisation de projets géospatiaux, le dépôt est disponible sur [github.com/rlespinasse/morvan](https://github.com/rlespinasse/morvan).
