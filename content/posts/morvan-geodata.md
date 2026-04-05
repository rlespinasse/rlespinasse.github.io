---
title: "Morvan : assembler des données géospatiales pour un parc naturel régional"
date: 2026-04-15T10:00:00+02:00
draft: true
summary: "Le Parc naturel régional du Morvan s'étend sur des forêts, des lacs et des villages à travers la Bourgogne. Construire une carte interactive pour ce territoire signifie assembler des données géographiques provenant de nombreuses sources dans une structure de couches cohérente — et automatiser le pipeline pour qu'il reste maintenable."
tags:
  - opensource
  - geospatial
categories:
  - Technical posts
---

Le [Parc naturel régional du Morvan](https://www.parcdumorvan.org/) est un espace protégé en Bourgogne.
Il couvre un paysage montagneux et boisé avec des lacs, des rivières, des petites communes et un riche patrimoine culturel.
Contrairement à une carte urbaine où un seul jeu de données fournit rues et bâtiments, cartographier un parc naturel régional implique de puiser des données dans de nombreuses sources différentes — limites administratives, éléments naturels, démographie, infrastructures touristiques, réseaux énergétiques, et bien d'autres.

[**Morvan**](https://github.com/rlespinasse/morvan) est un projet open source qui assemble ces données géospatiales dans un format structuré et réutilisable pour la cartographie interactive.

## Le défi : de nombreuses sources de données, une seule carte

Un parc naturel régional touche à presque toutes les catégories de données géographiques :

- **Limites administratives** — le périmètre du parc, les communes, les cantons, les départements
- **Démographie** — répartition de la population, densité, zones urbaines et rurales
- **Énergie** — infrastructures électriques, installations d'énergie renouvelable
- **Eau** — rivières, lacs, bassins versants, réseaux hydrographiques
- **Nature** — zones protégées, forêts, zones de biodiversité
- **Patrimoine** — sites historiques, monuments architecturaux, points d'intérêt culturel
- **Paysages** — classifications du terrain, zones panoramiques, caractéristiques géologiques
- **Programmes** — programmes de développement, initiatives environnementales, zones de planification
- **Tourisme** — sentiers, hébergements, centres d'accueil, points d'intérêt

Chaque catégorie provient d'institutions différentes, dans des formats différents, avec des fréquences de mise à jour différentes.
Le premier défi n'est pas d'afficher les données — c'est de les organiser.

## Choix de structure des couches

Le projet organise les données GeoJSON dans une hiérarchie de répertoires claire, un dossier par catégorie thématique.
Chaque catégorie peut contenir plusieurs couches — par exemple, la catégorie eau peut inclure des couches séparées pour les rivières, les lacs et les bassins versants.

Cette structure remplit deux objectifs.
Premièrement, elle rend les données navigables pour les humains — on peut trouver ce que l'on cherche sans lire le code.
Deuxièmement, elle correspond directement à la configuration des couches utilisée par l'application cartographique, donc ajouter une nouvelle source de données revient à ajouter un fichier dans le bon dossier et à mettre à jour une seule entrée de configuration.

## Pipeline de traitement

Les données géographiques brutes arrivent rarement dans le format exact dont on a besoin.
Les systèmes de coordonnées varient, les noms d'attributs diffèrent entre les sources, et certains jeux de données nécessitent un filtrage ou une simplification avant d'être utilisables sur une carte web.

Le projet inclut des scripts de traitement de données qui :

1. **Récupèrent** les données brutes depuis les portails de données ouvertes et les sources institutionnelles
2. **Valident** la structure des données et les systèmes de référence de coordonnées
3. **Transforment** les données en GeoJSON avec un nommage d'attributs cohérent
4. **Produisent** des fichiers propres prêts pour l'application cartographique

## Automatisation avec justfile

Le pipeline de traitement est automatisé grâce à un [justfile](https://just.systems/).
Chaque recette gère une étape spécifique — récupérer un jeu de données, exécuter une transformation, ou reconstruire l'ensemble de la collection de couches.

Cette approche garantit la reproductibilité du pipeline.
Un nouveau contributeur peut exécuter une seule commande pour reconstruire toutes les données géographiques à partir des sources, sans avoir besoin de connaître les détails de chaque étape de transformation.

## Documentation

La documentation du projet suit le framework [Diataxis](https://diataxis.fr/) dès le départ, avec des pages séparées pour les tutoriels, les guides pratiques, les explications et le matériel de référence.
Commencer avec une documentation structurée tôt — plutôt que de la rétrofiter plus tard — facilite l'intégration des contributeurs et la maintenance du projet à mesure que les sources de données évoluent.

## Et ensuite ?

Le projet en est à ses débuts. La structure fondamentale est en place — hiérarchie des couches, scripts de traitement, automatisation et documentation — mais la collecte de données est en cours.
Les travaux futurs incluent l'extension du nombre de couches dans chaque catégorie, l'amélioration de la gestion d'erreurs du pipeline de traitement, et la connexion des données à une application cartographique interactive.

Si vous vous intéressez à la géographie régionale française, au traitement de données ouvertes ou à l'organisation de projets géospatiaux, le dépôt est disponible sur [github.com/rlespinasse/morvan](https://github.com/rlespinasse/morvan).
