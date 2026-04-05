---
title: "Skill french-language : les accents français sur tous les formats de fichiers"
date: 2026-04-08T10:00:00+02:00
draft: true
featureimage: /img/posts/french-language-skill/featured.svg
summary: "Le skill french-language impose les accents, la grammaire et la typographie française sur tous les fichiers générés — markdown, SVG, Mermaid, PlantUML, CSV, JSON, et plus."
tags:
- ai
- opensource
- github
categories:
- Technical posts
- Open Source
series: ["AI Skills"]
series_order: 7
---

Les assistants IA écrivent le français sans accents.

Pas systématiquement. Pas volontairement. Mais suffisamment souvent pour que ça devienne un problème. Demandez à un assistant de générer un diagramme SVG avec des étiquettes en français, et vous obtenez « qualite » au lieu de « qualité », « deploiement » au lieu de « déploiement », « cloture » au lieu de « clôture ». Le texte est compréhensible, mais il est faux — et en français, un accent manquant est une faute d'orthographe, pas une question de style.

Le problème se multiplie à travers les formats. Documentation markdown, sketch notes SVG, diagrammes Mermaid, exports CSV, configuration JSON, schémas PlantUML — chaque format contient du texte français, et chacun est une surface pour des accents manquants. Les corriger après coup fonctionne, mais c'est fastidieux et on rate toujours des occurrences.

Le skill [**french-language**](https://github.com/rlespinasse/agent-skills) répond à ce problème en établissant des règles d'écriture française qui s'appliquent à chaque fichier que l'assistant génère ou édite.

## Ce que fait le skill

Le skill opère sur deux axes : la **correction** (réparer le contenu existant) et la **génération** (écrire correctement dès le départ).

Pour la correction, il fournit un processus structuré : scanner tous les types de fichiers pour du texte français, identifier les accents manquants, présenter un tableau de corrections, appliquer les changements après approbation, et valider qu'il ne reste rien. Le mot clé est *tous les types de fichiers* — pas seulement le markdown.

Pour la génération, la règle est plus simple : écrire avec les accents dès le départ. Ne pas générer du contenu sans accents pour les corriger ensuite. Ça paraît évident, mais les LLM ont tendance à produire du texte « ASCII-safe » plus souvent qu'on ne le pense, surtout dans les formats structurés comme SVG ou Mermaid où le texte est imbriqué dans du balisage.

## Le problème des accents

Le français comporte neuf caractères accentués distincts, et chacun est obligatoire :

| Caractère | Nom | Souvent oublié dans |
| :--- | :--- | :--- |
| é | accent aigu | qualité, sécurité, équipe, périmètre |
| è | accent grave | stratège, modèle, problème |
| ê | accent circonflexe | être, clôture, rôle |
| à | a accent grave | à, déjà |
| ô | o accent circonflexe | contrôle, rôle, clôture |
| â | a accent circonflexe | bâtisseur, tâche |
| ç | cédille | ça, français, reçu |
| î | i accent circonflexe | maître, connaître |
| ù | u accent grave | où |

Le skill inclut un tableau des patterns les plus fréquemment oubliés — des mots comme « deploiement », « developpeur », « retrospective », « responsabilites » — pour que l'assistant les détecte de façon systématique plutôt que de se fier à ses connaissances linguistiques générales.

## Des règles par format

Chaque format de fichier nécessite un traitement différent. Le skill fournit des consignes pour chacun :

**Fichiers SVG** — modifier uniquement le contenu des éléments `<text>`, jamais les coordonnées ni les styles. Les caractères accentués peuvent être légèrement plus larges, il faut vérifier que le texte tient dans son conteneur. Les linters comme SVGO reformatent le fichier après édition — c'est normal et ne doit pas être annulé.

**Diagrammes Mermaid** — les accents fonctionnent nativement dans les étiquettes de nœuds (`A[Qualité]`), mais les étiquettes avec certains caractères spéciaux nécessitent des guillemets (`A["Clôture du projet"]`). Tester le rendu après les modifications.

**PlantUML** — les accents fonctionnent dans les labels et les notes. Les noms de participants avec accents peuvent nécessiter des guillemets : `participant "Développeur GenAI" as Dev`.

**Fichiers CSV** — le point critique est l'encodage. UTF-8 est obligatoire. Latin-1/ISO-8859-1 détruit les accents. Certains tableurs ré-encodent à l'export, donc vérifier après tout aller-retour.

**JSON et YAML** — les accents fonctionnent nativement. JSON impose UTF-8 par spécification. Aucun traitement spécial nécessaire.

**HTML** — utiliser les caractères UTF-8 directement (`é`), pas les entités HTML (`&eacute;`). Vérifier `<title>`, `<meta>`, les attributs `alt` et `aria-label` en plus du texte visible.

## Les termes techniques restent en anglais

Le skill préserve explicitement les termes techniques anglais universellement utilisés dans la culture tech française : Sprint, Backlog, Product Owner, CI/CD, DevOps, API, Pull Request, Prompt Engineering, et termes similaires.

La règle est pragmatique : si le terme est universellement utilisé en anglais dans le milieu tech français, on le garde. « Le Sprint Planning » est du français correct. « La planification de sprint » est techniquement valide mais personne ne le dit.

## Comment ce skill est né

Ce skill est né d'un projet réel — la construction de la documentation RACI pour un studio de conseil en IA. La documentation était en français, structurée avec le skill [diataxis](/posts/diataxis-documentation-skill/), et incluait des sketch notes SVG comme résumés visuels.

À chaque fois que l'assistant générait un SVG, le texte français sortait sans accents. À chaque fois. Je corrigeais, le linter reformatait le fichier, je rééditais, et quelque part dans ce cycle quelques accents passaient entre les mailles du filet. Multipliez ça par cinq fichiers SVG, neuf fichiers markdown et un CSV de référence — et la boucle de correction manuelle devenait le goulot d'étranglement.

Le skill encode ce que je faisais manuellement : scanner tous les fichiers, vérifier les patterns d'erreurs courants, les corriger systématiquement, et — surtout — écrire correctement dès le départ lors de la génération de nouveau contenu.

## Ce que j'ai observé en pratique

Le changement le plus significatif concerne la génération, pas la correction. Quand le skill est actif et que l'assistant génère un nouveau SVG ou diagramme Mermaid, le texte français sort avec les accents corrects dès le premier passage. Plus de cycle « générer-corriger-regénérer ».

Pour le contenu existant, le processus structuré — scanner, rapporter, approuver, appliquer, valider — attrape des patterns qu'une relecture manuelle rate. La règle « un pattern à la fois » pour les éditions `replace_all` empêche les remplacements larges qui peuvent introduire des régressions (par exemple, « ou » ne doit pas devenir « où » aveuglément — c'est le contexte qui détermine lequel est correct).

Le skill cohabite naturellement avec [diataxis](/posts/diataxis-documentation-skill/) et [conventional-commit](/posts/conventional-commit-skill/). Diataxis structure la documentation, french-language s'assure que le texte est correct, et conventional-commit gère les messages de commit. Chaque skill opère dans son domaine sans interférence.

## Installer le skill

```bash
npx skills add https://github.com/rlespinasse/agent-skills --skill french-language
```

Une fois installé, le skill s'active quand le projet est configuré en français (via CLAUDE.md ou équivalent), ou quand on l'invoque explicitement avec `/french-language`.

## Au-delà du français

Le skill est spécifiquement conçu pour le français, mais le pattern sous-jacent — imposer les conventions linguistiques sur tous les types de fichiers générés — s'applique à toute langue avec des signes diacritiques : l'allemand (ü, ö, ä, ß), l'espagnol (ñ, á, é), le portugais (ã, ç, ê), et d'autres.

Si vous travaillez dans une langue où les assistants IA suppriment systématiquement les diacritiques, le skill french-language peut servir de modèle pour construire un skill équivalent pour votre langue.

```bash
npx skills add https://github.com/rlespinasse/agent-skills --skill french-language
```

Le skill fait partie de la collection [agent-skills](https://github.com/rlespinasse/agent-skills).
