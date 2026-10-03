# CampusTasks

Application mobile de gestion des tâches étudiantes : matières, devoirs, exposés, projets et révisions, avec un tableau de bord des échéances.

Projet de Licence 3 (IIBS) couvrant toute la chaîne de réalisation : développement Flutter et Spring Boot, gestion des versions avec Git, conteneurisation Docker, publication sur Docker Hub, déploiement HTTPS et distribution d'un APK Android signé.

| Élément | Lien |
|---|---|
| API déployée (HTTPS) | https://campus-tasks-api.onrender.com |
| Documentation de l'API (Swagger) | https://campus-tasks-api.onrender.com/swagger-ui/index.html |
| Disponibilité | https://campus-tasks-api.onrender.com/actuator/health |
| Image Docker | [mbenda01/campus-tasks-api](https://hub.docker.com/r/mbenda01/campus-tasks-api) |
| APK Android | onglet [Releases](https://github.com/mbenda01/CampusTasks----gestion-des-taches-etudiantes/releases) |

## Fonctionnalités

- **Comptes** : inscription, connexion, déconnexion. Mots de passe hachés (BCrypt), authentification par jetons JWT.
- **Matières** : ajout, modification, consultation, suppression. La suppression est refusée tant que des tâches y sont rattachées.
- **Tâches** : titre, description, matière, date limite, priorité (basse, moyenne, haute), statut (à faire, en cours, terminée), date de création automatique. Création, consultation, modification, suppression, filtre par matière ou par statut, tri par date limite.
- **Tableau de bord** : nombre de tâches par statut, prochaines échéances, tâches en retard (date limite dépassée et statut différent de « terminée »).
- **Isolation des données** : chaque étudiant n'accède qu'à ses propres matières et tâches.

## Architecture

```
Application Flutter  ──HTTPS / JSON──▶  API REST Spring Boot  ──JDBC──▶  PostgreSQL
 (Android, BLoC)                        (JWT, validation,               (volume persistant,
                                          règles de gestion)              non exposée)
```

Le détail est décrit dans [docs/architecture.md](docs/architecture.md).

## Organisation du dépôt

| Dossier | Contenu |
|---|---|
| [`backend/`](backend/README.md) | API Java 25 / Spring Boot 4, Spring Data JPA, Spring Security |
| [`mobile/`](mobile/README.md) | Application Flutter (Dart) |
| `deployment/` | `compose.yaml` (API + PostgreSQL), `.env.example`, configuration HTTPS (Caddy) |
| [`docs/`](docs/) | Architecture, base de données, API, déploiement, versions, vérifications |
| `.github/workflows/` | Intégration continue et publication de l'image Docker |

## Démarrage rapide avec Docker Compose

Prérequis : Docker Engine avec le plugin Compose (Docker Desktop ou Docker dans WSL).

```bash
git clone https://github.com/mbenda01/CampusTasks----gestion-des-taches-etudiantes.git
cd CampusTasks----gestion-des-taches-etudiantes/deployment
cp .env.example .env
```

Dans `.env`, renseigner au minimum :

| Variable | Valeur |
|---|---|
| `DOCKERHUB_USERNAME` | `mbenda01` |
| `API_VERSION` | `1.0.0` |
| `DB_PASSWORD` | un mot de passe |
| `JWT_SECRET` | une chaîne aléatoire d'au moins 32 caractères |

Puis :

```bash
docker compose up -d
docker compose ps
```

L'API est disponible sur http://localhost:8080 (Swagger : http://localhost:8080/swagger-ui.html). Les données sont conservées dans le volume `campustasks-db-data` entre deux redémarrages.

## Comptes de démonstration

Créés automatiquement au premier démarrage sur une base vide :

| E-mail | Mot de passe | Contenu |
|---|---|---|
| `aminata@campustasks.sn` | `motdepasse123` | 3 matières, 5 tâches dont une en retard |
| `moussa@campustasks.sn` | `motdepasse123` | 1 matière, 1 tâche (sert à vérifier l'isolation) |

## Versionnement

- Version commune au backend et au mobile, au format `MAJEUR.MINEUR.CORRECTIF`.
- Correspondance de la version 1.0.0 : tag Git `v1.0.0` = image `mbenda01/campus-tasks-api:1.0.0` = Flutter `1.0.0+1`.
- Branche `main` stable ; une branche `feature/...` par fonctionnalité, intégrée par pull request relue.
- Le préfixe `/api/v1` désigne la version du contrat de l'API.

Détails : [docs/versions.md](docs/versions.md).

## Intégration continue (GitHub Actions)

| Workflow | Déclencheur | Actions |
|---|---|---|
| `ci.yml` | pull request et push sur `main` | compilation et tests du backend, `flutter analyze` |
| `release.yml` | tag `v*.*.*` | construction de l'image Docker et publication sur Docker Hub |

Secrets GitHub requis : `DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN`.

## Sécurité des secrets

Aucun mot de passe, jeton ou clé de signature n'est versionné. Les fichiers `.env`, `key.properties` et `*.jks` sont exclus par `.gitignore`. Les valeurs fictives se trouvent dans `deployment/.env.example`.

## Documentation

- [Architecture](docs/architecture.md)
- [Base de données](docs/base-de-donnees.md)
- [API](docs/api.md)
- [Déploiement et exploitation](docs/deploiement.md)
- [Versions et notes de version](docs/versions.md)
- [Vérifications](docs/verifications.md)

## Auteur

Mame Mbenda LO — Licence 3 Data/IA & Génie Logiciel, IIBS Dakar.
