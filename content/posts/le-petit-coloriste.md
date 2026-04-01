---
title: "Le Petit Coloriste : quand un papa qui ne sait pas dessiner découvre les Gems Gemini"
date: 2026-03-15T11:00:00+01:00
draft: false
summary: "Une Gem Gemini qui génère des pages de coloriage sur demande pour mes jumeaux de 5 ans — toujours deux exemplaires identiques."
featureimage: /img/posts/le-petit-coloriste/featured.svg
tags:
- ai
- google-gemini
- opensource
- french
categories:
- Technical posts
- Open Source
---

Mes jumeaux ont 5 ans, et ils adorent colorier.
Le problème, c'est qu'ils veulent des dessins bien précis — un dinosaure qui fait du vélo, une fusée avec un chat dedans — et qu'il en faut toujours deux exemplaires, un pour chacun.
Dessiner le même sujet deux fois à main levée, quand on a le niveau artistique d'un bonhomme bâton, c'est mission impossible.

J'ai commencé par demander à l'IA de générer des images à colorier.
Ça marche, mais chaque prompt devait re-spécifier les mêmes contraintes : contours noirs, fond blanc, pas de couleur, adapté à des enfants de 5 ans.
C'était fastidieux, et les résultats étaient incohérents d'un essai à l'autre.

## De prompts ad-hoc à une Gem structurée

Le bon workflow ne s'est pas construit en un jour — il s'est affiné par phases, sur plusieurs mois, jusqu'à s'accélérer récemment avec la Gem et le site vitrine.

![Évolution du workflow de génération](/img/posts/le-petit-coloriste/workflow-evolution.svg)

**Générer directement avec Imagen.** Le modèle de génération d'images de Google (intégré à Gemini) produit de bons résultats, mais le prompt doit être très détaillé à chaque fois. Oublier une contrainte — le fond blanc, le style trait — et le résultat est inutilisable.

**Demander à Gemini de rédiger le prompt.** Plutôt que d'écrire le prompt d'image moi-même, j'ai demandé à Gemini de le rédiger à ma place. Ça améliore la qualité, mais il faut toujours rappeler le contexte coloriage à chaque nouvelle conversation.

**Packager les instructions dans une Gem.** Les [Gems](https://gemini.google.com/) sont des assistants personnalisés dans Google Gemini : on définit une fois les instructions (personnalité, contraintes, format de sortie) et Gemini les mémorise d'une conversation à l'autre. J'ai créé une Gem avec toutes mes exigences de coloriage — plus besoin de répéter le briefing.

**Tester et affiner.** Les premières pages générées avaient des défauts : traits trop fins pour des crayons d'enfant, détails trop complexes pour leur âge. J'ai ajusté les instructions de la Gem au fil des essais jusqu'à obtenir des résultats que mes fils pouvaient réellement colorier.

## La séance de brainstorming

Le meilleur moment, c'est quand les garçons choisissent les dessins.
Ils attendaient ça depuis le début de la semaine — mais y a école — et quand le weekend arrive, c'est la séance de brainstorming.

Les idées fusent : un dragon qui mange une pizza, un tracteur sur la lune, un requin avec un chapeau de pirate.
Je tape leurs demandes dans la Gem, et en quelques secondes ils ont leurs pages de coloriage, identiques, prêtes à imprimer.

Le plus dur, c'est de les arrêter.
On a fini par mettre en place un quota de dessins par séance — sinon l'imprimante y passe le weekend.

## Le partager avec d'autres parents

Les parents des copains ont voulu essayer.
Mais leur dire "utilise cette Gem Gemini" ne suffisait pas — pour quelqu'un qui n'a jamais entendu parler des Gems, c'est du jargon.

J'ai créé un [site vitrine](https://github.com/rlespinasse/le-petit-coloriste) pour montrer les coloriages générés et expliquer comment utiliser la Gem.
Pour qu'un lien partagé sur les réseaux ou dans une messagerie affiche une vraie carte de prévisualisation — et pas juste une URL brute — le site embarque des métadonnées OpenGraph et Twitter Card, ainsi qu'un favicon pour que le projet soit identifiable dans les onglets du navigateur.
Le tout est du HTML/CSS statique, déployé automatiquement via GitHub Actions avec versionnement par semantic-release.

## Essayez-le

Le projet est sur [github.com/rlespinasse/le-petit-coloriste](https://github.com/rlespinasse/le-petit-coloriste).
Créer une Gem est gratuit — il suffit d'un compte Google.

Si vous avez des enfants qui aiment colorier, ou si vous cherchez un exemple concret de ce qu'on peut faire avec les Gems Gemini, allez y jeter un œil.
Et si vous avez d'autres tâches créatives répétitives, créer votre propre Gem est un bon point de départ.
