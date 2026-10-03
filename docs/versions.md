# Versions

## Stratégie

Une version commune au backend et à l'application mobile, au format **MAJEUR.MINEUR.CORRECTIF** :

| Version | Type de changement |
|---|---|
| 1.0.0 | première livraison complète |
| 1.1.0 | fonctionnalité compatible avec l'existant (ex. nouveau filtre) |
| 1.1.1 | correction d'un défaut |
| 2.0.0 | changement incompatible nécessitant une adaptation du client |

Le préfixe `/api/v1` représente la version du **contrat** de l'API. Il ne change qu'en cas de changement incompatible du contrat, pas à chaque livraison.

## Correspondance des versions

| Version | Tag Git | Image Docker | Application Flutter | APK |
|---|---|---|---|---|
| 1.0.0 | `v1.0.0` | `mbenda01/campus-tasks-api:1.0.0` | `1.0.0+1` | `campus-tasks-1.0.0.apk` |

Dans `1.0.0+1`, `1` est le numéro de build Android (`versionCode`). Il est incrémenté à chaque APK publié, ce qui permet à Android d'installer la nouvelle version par-dessus l'ancienne.

## Branches et intégration

- `main` : version stable.
- `feature/<nom>` : une branche par fonctionnalité (par exemple `feature/authentication`, `feature/task-list`, `feature/documentation`).
- Intégration dans `main` par **pull request**, relue avant fusion. Le workflow `ci.yml` doit être vert.
- Les messages de commit décrivent clairement le changement (`feat: ...`, `fix: ...`, `docs: ...`).

## Procédure de livraison

1. Mettre à jour la version dans `backend/pom.xml` et `mobile/pubspec.yaml`.
2. Fusionner dans `main` par pull request.
3. Créer et pousser le tag : `git tag -a vX.Y.Z -m "Version X.Y.Z"` puis `git push origin vX.Y.Z`.
4. Le workflow `release.yml` publie l'image `X.Y.Z` sur Docker Hub.
5. Déployer l'image (voir [deploiement.md](deploiement.md)).
6. Construire l'APK signé et le publier dans la GitHub Release du tag, avec les notes de version.

## Notes de version

### 1.0.0

Première livraison complète :

- comptes étudiants (inscription, connexion, déconnexion), jetons JWT avec renouvellement automatique ;
- gestion des matières, avec suppression refusée si des tâches y sont rattachées ;
- gestion des tâches : création, consultation, modification, suppression, filtres par matière et par statut, tri par date limite ;
- tableau de bord : compteurs par statut, prochaines échéances, tâches en retard ;
- isolation des données entre étudiants ;
- image Docker `1.0.0`, déploiement HTTPS sur Render ;
- APK Android signé.
