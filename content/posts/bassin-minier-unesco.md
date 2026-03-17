---
title: "Bassin Minier UNESCO : une carte interactive du patrimoine avec des données ouvertes"
date: 2026-03-15T12:00:00+01:00
draft: false
summary: "Carte interactive du bassin minier UNESCO du Nord-Pas de Calais : données patrimoniales, limites administratives et informations géographiques ouvertes."
coverImg: /img/posts/bassin-minier-unesco/featured.svg
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
series_order: 2
---

Le [Bassin Minier du Nord-Pas de Calais](https://whc.unesco.org/fr/list/1360/) est l'un des plus grands sites du patrimoine mondial de l'UNESCO en France.
Il couvre un vaste paysage d'anciennes infrastructures minières — terrils, cités ouvrières, chevalements et voies ferrées — répartis sur deux départements et des dizaines de communes.

Comprendre la géographie du site à partir d'une simple liste est difficile.
Il faut une carte.

## De zéro à un SIG interactif

[**Bassin Minier UNESCO**](https://github.com/rlespinasse/bassin-minier-unesco) est passé d'un dépôt vide à une carte interactive déployée en un sprint concentré, atteignant la **v0.3.1** à travers cinq releases dès ses premiers jours.

Au départ, tout le code vivait dans ce dépôt : initialisation de Leaflet, chargement des couches GeoJSON, gestion des popups, interactions utilisateur et données patrimoniales — le tout dans un seul projet.
Au fil du développement, des patterns récurrents sont apparus : chaque couche nécessitait la même logique de chargement, chaque popup la même sanitisation, chaque superposition de polygones le même traitement de z-ordering.

Une session de travail dédiée a séparé le code générique du code spécifique au bassin minier.
Cette extraction a donné naissance à [Leaflet Atlas](https://github.com/rlespinasse/leaflet-atlas), un framework piloté par la configuration qui gère l'initialisation de la carte, la gestion des couches et les interactions utilisateur.
L'histoire complète de cette extraction est racontée dans [le post dédié à Leaflet Atlas](/posts/leaflet-atlas/).

Avec cette séparation, j'ai pu me concentrer sur les données et l'expérience utilisateur plutôt que sur la plomberie cartographique bas niveau.

## Ce que vous pouvez explorer

La carte comprend plusieurs couches d'informations géographiques :

- **Sites patrimoniaux UNESCO** — le jeu de données principal, affichant les éléments miniers individuels inscrits au patrimoine mondial
- **Limites des EPCI** — les intercommunalités qui gouvernent le territoire
- **Limites départementales** — pour un contexte géographique plus large
- **Recherche** — trouver des sites ou des lieux spécifiques par nom

Chaque élément sur la carte ouvre un panneau de détail affichant les métadonnées de l'élément sélectionné.
Le panneau est redimensionnable, ce qui permet d'ajuster l'espace d'écran partagé entre la carte et les détails.

Les raccourcis clavier permettent d'activer ou désactiver les couches et de naviguer sans utiliser la souris — utile quand on explore un jeu de données avec de nombreuses limites qui se superposent.

## Intégration des données

![Pipeline de données du projet](/img/posts/bassin-minier-unesco/data-pipeline.svg)

Les données géographiques proviennent de sources ouvertes, principalement [data.gouv.fr](https://www.data.gouv.fr/) et [geo.api.gouv.fr](https://geo.api.gouv.fr/).
Des scripts Python récupèrent les shapefiles et les flux WFS, puis les convertissent au format GeoJSON attendu par Leaflet Atlas.

La première itération a chargé neuf jeux de données du patrimoine minier : bien inscrit, zone tampon, cités minières, terrils, cavaliers, bâtis et puits de mines.
Une seconde passe a ajouté huit couches supplémentaires issues de sources WFS — sous-couches de la zone tampon (cavaliers, cités minières, espaces néo-naturels, parvis agricoles, terrils), communes, et équipements collectifs et d'extraction.

L'étape la plus délicate a été l'enrichissement par fusion de jeux de données qui se recouvraient.
Les couches `equipements-collectifs` et `equipements-extraction` ont été fusionnées dans `batis`, ajoutant des attributs comme le nom, la compagnie, la période et le propriétaire.
De même, les données `cites-erbm` ont été fusionnées dans `cites-minieres`, les enregistrements sans correspondance étant ajoutés en fin de couche.

Les couches de contexte administratif sont venues ensuite : les limites des EPCI depuis geo.api.gouv.fr, puis les contours des départements du Nord et du Pas-de-Calais, obtenus en fusionnant les géométries des communes.
Les communes ont été enrichies avec le nom et le code SIREN de leur EPCI de rattachement, créant des liens croisés entre les couches.

L'une des intégrations concerne le [BRGM](https://www.brgm.fr/) (Bureau de Recherches Géologiques et Minières), le service géologique national français.
Leurs données enrichissent la couche du patrimoine minier avec un contexte géologique, et des liens vers data.gouv.fr permettent de remonter à la source de chaque élément.

## Sécurisation

Quand votre carte affiche des données provenant de sources externes, il faut être vigilant sur ce qui est rendu dans le navigateur.
Une revue de sécurité a révélé que des URL du jeu de données BRGM pouvaient potentiellement contenir des schémas `javascript:` — un vecteur XSS classique.

Le correctif valide les schémas d'URL avant de rendre tout lien externe, bloquant tout ce qui n'est pas `http:` ou `https:`.
C'est un petit changement en termes de code, mais un changement important pour toute application publique qui affiche du contenu contrôlé par des utilisateurs ou provenant de sources externes.

## Conformité RGPD

En tant qu'application web accessible au public, le site doit se conformer aux réglementations françaises et européennes de protection des données.
Une modale d'informations légales affiche les mentions obligatoires LCEN (Loi pour la Confiance dans l'Économie Numérique) et RGPD.

C'est l'une de ces fonctionnalités qui n'a rien à voir avec la cartographie mais qui est essentielle pour tout site public en Europe.
La modale apparaît lors de la première visite et reste accessible depuis l'interface à tout moment.

## Migration vers Leaflet Atlas hébergé sur CDN

Après l'extraction, la carte dépendait d'une copie locale de Leaflet Atlas.
Quand le framework a mûri et a été publié sur npm, le site a migré vers le paquet hébergé sur CDN depuis [unpkg](https://unpkg.com/).

Cela a simplifié le processus de build — plus besoin de copier les fichiers de la bibliothèque lors du déploiement — et garantit que la carte utilise toujours la dernière version patch de Leaflet Atlas.
La section des crédits légaux a été mise à jour pour référencer la bibliothèque correctement.

## Documentation

La documentation du projet suit le framework [Diataxis](https://diataxis.fr/), avec quatre pages de guides couvrant :

- Comment ajouter une nouvelle couche géographique
- Comment mettre à jour les données existantes
- Comment concevoir le pipeline de traitement des données
- Comment structurer les fichiers GeoJSON pour l'application

Ces guides permettent aux contributeurs d'étendre la carte avec de nouvelles sources de données sans avoir à lire tout le code applicatif.

## Et ensuite ?

La carte est en ligne et fonctionnelle, mais il reste des données à intégrer.
Les travaux futurs incluent l'ajout de couches de détail patrimonial supplémentaires, l'amélioration de l'expérience mobile et l'extension du pipeline de traitement pour couvrir d'autres sources de données ouvertes.

Si vous vous intéressez au patrimoine français, aux données ouvertes ou à la cartographie interactive, explorez le projet sur [github.com/rlespinasse/bassin-minier-unesco](https://github.com/rlespinasse/bassin-minier-unesco).
