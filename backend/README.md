# CampusTasks — Backend

API REST de CampusTasks : authentification, matières, tâches et tableau de bord.

## Stack

| Composant | Version / outil |
|---|---|
| Langage | Java 25 |
| Framework | Spring Boot 4.1.1 (Spring Web MVC, Spring Data JPA, Spring Security, Validation, Actuator) |
| Base de données | PostgreSQL 17 |
| Authentification | JWT (jjwt 0.12.6) : jeton d'accès 15 min, jeton de rafraîchissement 7 jours |
| Mapping | MapStruct 1.6.3, Lombok |
| Documentation | springdoc-openapi 3.1.0 (Swagger UI) |
| Tests | JUnit 5, Mockito, AssertJ |

## Architecture en couches

```
src/main/java/iibs/campustasks/
├── controller/       contrôleurs REST (Auth, Matiere, Tache, TableauBord) et DTO (records)
├── service/          interfaces, implémentations, PolitiqueAcces, mappers MapStruct
├── repository/       Spring Data JPA, spécifications de filtrage des tâches
├── entity/           modèle de domaine riche (Utilisateur, Matiere, Tache, Auditable, enums)
├── security/         JWT, filtre, contexte de sécurité, gestion 401/403
├── exception/        ApiResponse, gestionnaire global des erreurs, exceptions métier
├── validation/       contraintes personnalisées (@EmailUnique, @MatiereExiste)
└── config/           sécurité, audit, OpenAPI, journalisation, données de démonstration
```

Principes appliqués :

- **Modèle de domaine riche** : les règles (statut, retard, appartenance d'une tâche à une matière du même étudiant) vivent dans les entités.
- **Isolation par propriétaire** : chaque lecture passe par `findByIdAndProprietaireId`. Une ressource d'un autre étudiant renvoie **404**, sans révéler son existence.
- **Réponses uniformes** : chaque réponse est enveloppée dans `ApiResponse` (`timestamp`, `statut`, `succes`, `message`, `data`).
- **Erreurs cohérentes** : 400 validation (détail par champ), 401 authentification, 403 accès refusé, 404 introuvable, 409 conflit métier.

## Configuration

| Profil | Fichier | Usage |
|---|---|---|
| (base) | `application.properties` | valeurs communes, lues depuis les variables d'environnement |
| `local` | `application-local.properties` | développement, PostgreSQL du `docker-compose.yml` local |
| `prod` | `application-prod.properties` | production : journalisation réduite, prise en compte du proxy HTTPS |

Variables d'environnement :

| Variable | Rôle |
|---|---|
| `DB_URL` | URL JDBC, par exemple `jdbc:postgresql://db:5432/campustasks_db` |
| `DB_USERNAME`, `DB_PASSWORD` | identifiants PostgreSQL |
| `JWT_SECRET` | clé de signature des jetons (au moins 32 caractères) |
| `CORS_ORIGINES` | origines autorisées, séparées par des virgules |
| `PORT` | port HTTP (8080 par défaut) |
| `DDL_AUTO` | stratégie Hibernate (`update` par défaut) |

## Lancer en local

1. Démarrer PostgreSQL (port 5434 sur la machine) :

   ```bash
   docker compose up -d
   ```

2. Lancer l'API avec le profil local. Sous Windows (CMD) :

   ```cmd
   mvnw.cmd spring-boot:run "-Dspring-boot.run.profiles=local"
   ```

   Sous Linux ou WSL :

   ```bash
   ./mvnw spring-boot:run -Dspring-boot.run.profiles=local
   ```

3. Ouvrir http://localhost:8080/swagger-ui.html.

## Tests

```bash
./mvnw clean test
```

37 tests unitaires, exécutés sans base de données (Mockito) :

| Classe | Ce qui est vérifié |
|---|---|
| `TacheTest` | création, calcul du retard, transitions de statut, refus d'une matière d'un autre étudiant |
| `UtilisateurTest` | normalisation de l'e-mail, rôle, désactivation |
| `JwtServiceTest` | jeton valide, type de jeton, jeton falsifié, mauvaise clé |
| `AuthServiceImplTest` | e-mail déjà utilisé, mot de passe haché, connexion, message identique en cas d'échec |
| `MatiereServiceImplTest` | isolation, nom en double, suppression refusée si des tâches existent |
| `TacheServiceImplTest` | isolation (consultation, modification, suppression, création), statut |
| `TableauBordServiceImplTest` | calcul des indicateurs |

## Image Docker

Construction multi-étapes (JDK pour compiler, JRE pour exécuter), utilisateur sans privilèges :

```bash
docker build -t mbenda01/campus-tasks-api:1.0.0 .
docker push mbenda01/campus-tasks-api:1.0.0
```

En pratique, l'image est publiée automatiquement par GitHub Actions lors de la création d'un tag `v*.*.*`.

## Endpoints principaux

Préfixe : `/api/v1`. La liste complète, avec exemples, est dans [`../docs/api.md`](../docs/api.md).

| Méthode | Route | Rôle |
|---|---|---|
| POST | `/auth/register`, `/auth/login`, `/auth/refresh` | comptes et jetons |
| GET | `/auth/me` | profil courant |
| GET, POST | `/subjects` | lister, ajouter une matière |
| GET, PUT, DELETE | `/subjects/{id}` | consulter, modifier, supprimer |
| GET, POST | `/tasks` | lister (filtres `matiereId`, `statut`, tri), créer |
| GET, PUT, DELETE | `/tasks/{id}` | consulter, modifier, supprimer |
| PATCH | `/tasks/{id}/status` | changer le statut |
| GET | `/dashboard` | indicateurs |
