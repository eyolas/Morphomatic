# Plan de Migration - World of Warcraft: Midnight (12.0)

Ce document récapitule les travaux de modernisation effectués et les points de vigilance technique pour assurer la compatibilité de **Morphomatic** avec les futures versions de World of Warcraft (The War Within 11.x et Midnight 12.0).

## 1. État Actuel
**Statut :** ✅ Prêt pour 11.1+ / Préparé pour 12.0
**API Interface :** Moderne (Utilisation de `Settings` au lieu de `InterfaceOptions`)
**Version TOC :** 110100

## 2. Actions Réalisées (Nettoyage & Modernisation)

### A. Résolution de Conflit d'Interface (Critique)
- **Problème :** Deux fichiers de configuration coexistaient : `options.lua` (API Moderne) et `settings.lua` (API Obsolète, code mort).
- **Action :** Suppression définitive de `addons/settings.lua`.
- **Résultat :** Élimination des appels obsolètes à `SetBackdrop` (qui auraient causé des erreurs Lua) et allègement du code.

### B. Mise à jour des Métadonnées
- **Action :** Mise à jour du fichier `Morphomatic.toc`.
- **Détail :** Passage de l'interface cible à `110100` pour refléter le support des derniers patchs.

### C. Vérification XML
- **Action :** Audit de `addons/main.xml`.
- **Résultat :** Confirmation que l'ordre de chargement est correct et ne fait plus référence aux fichiers supprimés.

## 3. Points de Vigilance Technique (Dette Technique)

Ces points ne sont pas bloquants actuellement mais doivent être surveillés lors des bêtas de Midnight (12.0).

### ⚠️ Chargement des Objets (Item Mixin)
- **Code concerné :** `helpers.lua`, `options.lua`
- **Fonction :** `C_Item.GetItemInfo(id)`
- **Risque :** Cette fonction est synchrone. Si l'objet n'est pas en cache, elle renvoie `nil`. Blizzard pousse vers l'utilisation asynchrone via `Item:CreateFromItemID(id):ContinueOnItemLoad()`.
- **Mitigation actuelle :** Le code gère le `nil` avec un fallback (`name or "Toy "..id`), ce qui empêche les crashs.
- **Action Future :** Si Blizzard rend `GetItemInfo` obsolète ou trop lent, il faudra refactoriser pour utiliser les Mixins asynchrones.

### ⚠️ Variables Globales
- **Code concerné :** Tout le projet
- **Risque :** L'espace de noms global se réduit à chaque extension.
- **État :** L'addon utilise correctement un namespace privé `MM` et ne pollue pas le global (vérifié via `.luacheckrc`).

## 4. Protocole de Test (PTR)

Lors de l'accès au PTR 11.1 ou 12.0 :
1.  **Ouvrir les options** (`/mm options`) : Vérifier que le panneau s'ouvre sans erreur de taint.
2.  **Bouton Flottant** : Vérifier que le glisser-déposer et le verrouillage fonctionnent (API `SecureActionButtonTemplate`).
3.  **Macro** : Vérifier que la régénération de la macro en combat/hors combat ne déclenche pas d'erreur "Script ran too long" ou de blocage sécurisé.

---
*Dernière mise à jour : 01 Janvier 2026*
