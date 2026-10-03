# API REST

- Base de production : `https://campus-tasks-api.onrender.com`
- Préfixe de version : `/api/v1`
- Documentation interactive : `/swagger-ui/index.html`
- Contrat OpenAPI : `/v3/api-docs`

## Format des réponses

Toutes les réponses sont enveloppées dans le même objet :

```json
{
  "timestamp": "2026-10-03T14:00:57.606",
  "statut": 200,
  "succes": true,
  "message": "Taches recuperees",
  "data": { }
}
```

En cas d'erreur de validation (400), `data` contient le message de chaque champ en erreur :

```json
{
  "statut": 400,
  "succes": false,
  "message": "Validation echouee",
  "data": { "titre": "Le titre est obligatoire" }
}
```

## Authentification

Après l'appel à `/auth/login` ou `/auth/register`, envoyer le jeton d'accès dans l'en-tête de chaque requête :

```
Authorization: Bearer <jetonAcces>
```

| Méthode | Route | Corps | Réponse |
|---|---|---|---|
| POST | `/api/v1/auth/register` | `{"nom","email","motDePasse"}` | 201 + jetons |
| POST | `/api/v1/auth/login` | `{"email","motDePasse"}` | 200 + jetons |
| POST | `/api/v1/auth/refresh` | `{"jetonRafraichissement"}` | 200 + nouveaux jetons |
| GET | `/api/v1/auth/me` | aucun | 200 + profil |

Exemple de réponse de connexion (`data`) :

```json
{
  "jetonAcces": "eyJ...",
  "jetonRafraichissement": "eyJ...",
  "typeJeton": "Bearer",
  "expiresIn": 900,
  "utilisateur": { "id": 1, "nom": "Aminata Diop", "email": "aminata@campustasks.sn", "role": "ETUDIANT" }
}
```

## Matières

| Méthode | Route | Rôle | Codes |
|---|---|---|---|
| GET | `/api/v1/subjects?page=0&size=50` | lister ses matières (triées par nom) | 200 |
| GET | `/api/v1/subjects/{id}` | détail | 200, 404 |
| POST | `/api/v1/subjects` | ajouter `{"nom","description"}` | 201, 400, 409 (nom déjà utilisé) |
| PUT | `/api/v1/subjects/{id}` | modifier | 200, 400, 404, 409 |
| DELETE | `/api/v1/subjects/{id}` | supprimer | 200, 404, **409 si des tâches existent** |

## Tâches

| Méthode | Route | Rôle | Codes |
|---|---|---|---|
| GET | `/api/v1/tasks` | lister, filtrer, trier | 200 |
| GET | `/api/v1/tasks/{id}` | détail | 200, 404 |
| POST | `/api/v1/tasks` | créer | 201, 400, 404 |
| PUT | `/api/v1/tasks/{id}` | modifier (statut facultatif) | 200, 400, 404, 409 |
| PATCH | `/api/v1/tasks/{id}/status` | changer le statut `{"statut"}` | 200, 404, 409 |
| DELETE | `/api/v1/tasks/{id}` | supprimer | 200, 404 |

Paramètres de `GET /api/v1/tasks` :

| Paramètre | Exemple | Effet |
|---|---|---|
| `matiereId` | `1` | tâches d'une matière |
| `statut` | `A_FAIRE`, `EN_COURS`, `TERMINEE` | tâches d'un statut |
| `sort` | `dateLimite,asc` ou `dateLimite,desc` | tri (par défaut : date limite croissante) |
| `page`, `size` | `0`, `20` | pagination (50 éléments au maximum) |

Corps de création :

```json
{
  "titre": "Rendre le TP Spring Security",
  "description": "Securiser l'API avec JWT",
  "matiereId": 1,
  "dateLimite": "2026-10-10",
  "priorite": "HAUTE"
}
```

Chaque tâche renvoyée contient notamment `matiereNom`, `statut`, `priorite`, `enRetard` et `dateCreation`.

## Tableau de bord

`GET /api/v1/dashboard` :

```json
{
  "aFaire": 3, "enCours": 1, "terminees": 1, "total": 5, "enRetard": 1,
  "prochainesEcheances": [ ],
  "tachesEnRetard": [ ]
}
```

## Codes HTTP

| Code | Signification |
|---|---|
| 200 / 201 | succès / création |
| 400 | données invalides (détail par champ) ou requête illisible |
| 401 | jeton absent, expiré ou invalide ; identifiants incorrects |
| 403 | accès refusé |
| 404 | ressource inexistante **ou appartenant à un autre étudiant** |
| 409 | conflit métier (e-mail ou nom déjà utilisé, suppression refusée, statut identique) |
| 500 | erreur interne inattendue |

## Supervision

`GET /actuator/health` renvoie `{"status":"UP"}` quand l'API et la base sont disponibles.
