---
title: "Points chauds France : cartographier les feux détectés par satellite après les incendies de Gironde"
date: 2026-08-02T20:00:00+01:00
draft: false
summary: "Points chauds France est une carte interactive des détections thermiques satellite NASA FIRMS sur le territoire français, née des incendies de Gironde de juillet 2026. Construite avec leaflet-atlas, elle affiche les 5 derniers jours de détections VIIRS, colorées par puissance radiative et rejouables jour par jour."
featureimage: /img/posts/points-chauds-france/featured.svg
tags:
- opensource
- github
- geospatial
- leaflet
- french
categories:
- Technical posts
- Open Source
- Geospatial
series: ["Geospatial Open Data"]
series_order: 4
---

En juillet 2026, des feux de forêt majeurs ont touché la Gironde.
Comme beaucoup, j'ai suivi leur évolution via des cartes de détection satellite partagées sur les réseaux sociaux, mais ces cartes étaient éphémères, coincées dans un fil d'actualité, sans possibilité de rejouer les jours précédents ni de zoomer sur une commune précise.

J'avais déjà [Leaflet Atlas](/posts/leaflet-atlas/), le framework cartographique piloté par configuration extrait du projet [Bassin Minier UNESCO](/posts/bassin-minier-unesco/) et utilisé ensuite pour [Morvan](/posts/morvan-geodata/).
Les données de détection thermique de la NASA, elles, sont en accès libre via l'API FIRMS.
Il ne manquait qu'un projet pour assembler les deux.

[**Points chauds France**](https://github.com/rlespinasse/points-chauds-france) est cette carte : les détections thermiques satellite des 5 derniers jours sur le territoire français, rafraîchies toutes les 3 heures, à explorer sur [rlespinasse.github.io/points-chauds-france](https://rlespinasse.github.io/points-chauds-france/).

## Ce qu'elle affiche (et ce qu'elle n'affiche pas)

La carte agrège les détections FIRMS VIIRS de trois satellites (Suomi NPP, NOAA-20 et NOAA-21) sur la France et la Corse.

Un point important : **il ne s'agit pas d'une carte des feux de forêt**.
FIRMS détecte des anomalies thermiques par satellite, sans distinguer leur origine.
Un feu de forêt, une torchère de raffinerie, un brûlage agricole ou un site industriel produisent la même signature thermique vue de l'orbite.
Une version antérieure du projet filtrait les données avec [BD Forêt](https://geoservices.ign.fr/telechargement-api/BDFORET) (la couche de couverture forestière française) pour isoler les feux de forêt probables. Ce filtre a été délibérément retiré, car il masquait autant de vraies détections qu'il n'en excluait de fausses.

Ce que la carte montre, c'est donc la réalité brute : chaque détection thermique satellite, géocodée vers sa commune française, colorée selon sa puissance radiative du feu (FRP), rejouable jour par jour.
Charge à qui l'explore de faire la part des choses en croisant avec le contexte local, exactement ce que je faisais manuellement en suivant les feux de Gironde.

## Le pipeline

![Pipeline de données : satellites NASA FIRMS vers carte interactive](/img/posts/points-chauds-france/pipeline.svg)

Le projet n'a ni backend ni base de données. Toutes les 3 heures, un workflow GitHub Actions exécute la chaîne complète :

1. **Récupération** : l'API de zone FIRMS est interrogée une fois par satellite, sur la fenêtre maximale de 5 jours qu'elle autorise par requête.
2. **Géocodage inverse** de chaque point vers sa commune via [geo.api.gouv.fr](https://geo.api.gouv.fr/), avec un cache de 30 jours indexé par coordonnées arrondies : sans lui, la fenêtre de 5 jours d'une exécution chevauche à ~5/6 celle de la précédente, donc presque chaque point serait re-géocodé à chaque passage.
3. **Répartition par FRP** dans trois fichiers GeoJSON distincts (faible / modérée / forte), puisque `leaflet-atlas` stylise une couche entière d'un coup.
4. **Archivage** : chaque point est ajouté à une archive quotidienne, dédupliquée par satellite + horodatage + coordonnées (FIRMS n'a pas d'identifiant stable par détection), conservée 90 jours.

Le résultat est commité directement sur `main`, ce qui redéclenche le déploiement GitHub Pages du site : pas de base de données, pas de serveur, juste des fichiers GeoJSON statiques.

## La limite des 5 jours (et comment la contourner)

L'API FIRMS plafonne une requête unique à 5 jours de données : une contrainte stricte de la NASA, pas un choix du projet.
Les données « en direct » de la carte respectent donc toujours cette fenêtre glissante.

Pour voir plus loin dans le passé, le curseur temporel du frontend accède à l'archive locale accumulée au fil des exécutions du cron, jusqu'à 90 jours en arrière.
Et pour rattraper une plage plus ancienne que ce que le cron a déjà accumulé, `FIRMS_BACKFILL_DAYS=<n> npm run fetch-firms` relance des requêtes par tranches de 5 jours (dans la limite de ce que FIRMS conserve encore en quasi temps réel pour ces dates).

## Deux contrôles construits à la main

`leaflet-atlas` fournit les couches, la recherche par lieu et les pages légales.
Deux éléments d'interface sont en revanche spécifiques à ce projet, dans `src/main.ts` :

- Un **curseur temporel** (en bas à droite) qui parcourt les 5 derniers jours un jour calendaire parisien à la fois. Comme `leaflet-atlas` n'a pas d'API de filtrage par entité, il accède directement au `FeatureGroup` Leaflet de chaque couche.
- Une **légende FRP** (en bas à gauche), pilotée par le même tableau de seuils que celui utilisé pour les styles de couches, pour qu'elle ne puisse jamais se désynchroniser de la coloration réelle des points.

## Explorer les données

La carte est disponible sur [rlespinasse.github.io/points-chauds-france](https://rlespinasse.github.io/points-chauds-france/), avec une exécution locale possible en clonant le dépôt et une clé FIRMS gratuite pour rafraîchir les données soi-même.

La documentation complète (architecture, formats de données, scripts, guides pour déployer ou travailler avec les archives) est structurée selon [Diataxis](/posts/diataxis-documentation-skill/) dans [`docs/`](https://github.com/rlespinasse/points-chauds-france/tree/main/docs).

Comme pour [Bassin Minier UNESCO](/posts/bassin-minier-unesco/) et [Morvan](/posts/morvan-geodata/), ce projet referme la boucle avec [Leaflet Atlas](/posts/leaflet-atlas/) : chaque nouvelle carte expose des besoins que la précédente n'avait pas, et ces découvertes profitent ensuite à toutes les autres.
Rapports de bugs et contributions sont bienvenus sur [github.com/rlespinasse/points-chauds-france](https://github.com/rlespinasse/points-chauds-france).
