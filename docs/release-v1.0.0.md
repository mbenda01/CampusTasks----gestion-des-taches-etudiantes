# CampusTasks 1.0.0

Première version complète de CampusTasks, l'application de gestion des tâches étudiantes.

## Téléchargement

`campus-tasks-1.0.0.apk` : APK Android signé, connecté à l'API https://campus-tasks-api.onrender.com.

| Composant | Version |
|---|---|
| Tag Git | `v1.0.0` |
| Image Docker | `mbenda01/campus-tasks-api:1.0.0` |
| Application | `1.0.0+1` |

## Fonctionnalités

- Création de compte, connexion et déconnexion sécurisées (JWT).
- Gestion des matières : ajout, modification, suppression (refusée si des tâches y sont rattachées).
- Gestion des tâches : titre, description, matière, date limite, priorité, statut ; création, modification, suppression.
- Filtres par statut et par matière, tri par date limite.
- Tableau de bord : tâches à faire, en cours, terminées, en retard ; prochaines échéances.
- Thème clair, sombre ou automatique.

## Installation

1. Télécharger `campus-tasks-1.0.0.apk` sur le téléphone Android.
2. Ouvrir le fichier et autoriser l'installation depuis cette source si Android le demande.
3. Si une version précédente non signée avec la clé du projet est installée, la désinstaller d'abord.
4. Ouvrir CampusTasks, créer un compte ou utiliser le compte de démonstration `aminata@campustasks.sn` / `motdepasse123`.

## Limites connues

- L'API est hébergée sur une offre gratuite : après une période d'inactivité, le premier chargement peut prendre environ une minute. En cas d'échec de connexion, patienter puis réessayer.
- Une connexion Internet est nécessaire : pas de mode hors ligne dans cette version.
- Application testée sur Android uniquement.
