# Déploiement et exploitation

L'API est déployée sur **Render** à partir de l'image publiée sur **Docker Hub**. Le dépôt fournit aussi une configuration **Docker Compose** pour un serveur équipé de Docker.

## Configuration des environnements

| Environnement | Profil Spring | Base | Configuration |
|---|---|---|---|
| Développement | `local` | PostgreSQL du `backend/docker-compose.yml` (port 5434) | `application-local.properties` |
| Production | `prod` | PostgreSQL Render (réseau interne) | variables d'environnement Render |
| Serveur Docker | `prod` | service `db` de `deployment/compose.yaml` | `deployment/.env` |

## 1. Premier déploiement sur Render

### Publier l'image

L'image est publiée automatiquement par le workflow `release.yml` lors du push d'un tag :

```bash
git tag -a v1.0.0 -m "Version 1.0.0"
git push origin v1.0.0
```

Publication manuelle, si besoin :

```bash
cd backend
docker build -t mbenda01/campus-tasks-api:1.0.0 .
docker push mbenda01/campus-tasks-api:1.0.0
```

### Créer la base PostgreSQL

Dans Render, **New → Postgres** : base `campustasks_db`, utilisateur `campustasks_user`, région Frankfurt.

Dans **Access Control**, retirer l'accès public : la base n'est alors joignable que par l'adresse interne, depuis les services Render de la même région.

### Créer le service web

Dans Render, **New → Web Service → Existing Image**, avec l'image `docker.io/mbenda01/campus-tasks-api:1.0.0`, dans la même région que la base.

| Variable | Valeur |
|---|---|
| `SPRING_PROFILES_ACTIVE` | `prod` |
| `DB_URL` | `jdbc:postgresql://<hôte-interne>:5432/campustasks_db` |
| `DB_USERNAME` / `DB_PASSWORD` | identifiants de la base Render |
| `JWT_SECRET` | chaîne aléatoire d'au moins 32 caractères |
| `CORS_ORIGINES` | `https://campus-tasks-api.onrender.com` |

Health Check Path : `/actuator/health`. Render fournit le certificat HTTPS et la variable `PORT`.

### Vérifier

- https://campus-tasks-api.onrender.com/actuator/health renvoie `{"status":"UP"}`.
- Swagger : https://campus-tasks-api.onrender.com/swagger-ui/index.html
- Journaux : onglet **Logs** du service. Le message `Started CampusTasksApiApplication` confirme le démarrage.

Sur le plan gratuit, le service se met en veille après une période d'inactivité. La requête suivante le réveille, avec un délai d'environ une minute.

## 2. Déploiement sur un serveur avec Docker Compose

```bash
git clone <dépôt>
cd <dépôt>/deployment
cp .env.example .env
nano .env
```

Dans `.env`, renseigner `DOCKERHUB_USERNAME=mbenda01`, `API_VERSION`, `DB_PASSWORD` et `JWT_SECRET`.

Démarrage en HTTP local :

```bash
docker compose up -d
```

Démarrage en HTTPS, avec un nom de domaine pointant vers le serveur (`API_DOMAIN` dans `.env`) :

```bash
docker compose -f compose.yaml -f compose.https.yaml up -d
```

Propriétés de cette configuration :

- PostgreSQL attend d'être prêt (`healthcheck`) avant le démarrage de l'API (`depends_on: service_healthy`).
- Les données sont persistantes dans le volume `campustasks-db-data`.
- Redémarrage automatique : `restart: unless-stopped`.
- La base ne publie aucun port et reste accessible uniquement par le réseau interne.

Supervision :

```bash
docker compose ps
docker compose logs -f api
curl http://localhost:8080/actuator/health
```

## 3. Mise à jour vers une nouvelle image

1. Publier la nouvelle version, par exemple avec le tag `v1.1.0`, ce qui produit l'image `1.1.0`.
2. Déployer :
   - **Render** : Settings → Image URL → `docker.io/mbenda01/campus-tasks-api:1.1.0`, puis **Manual Deploy**.
   - **Docker Compose** : mettre `API_VERSION=1.1.0` dans `.env`, puis :
     ```bash
     docker compose pull api
     docker compose up -d api
     ```
3. Vérifier `/actuator/health` et les journaux.

## 4. Retour à une image précédente

- **Render** : remettre l'ancien tag dans **Image URL** (par exemple `1.0.0`), puis **Manual Deploy**. L'onglet **Deploys** permet aussi de relancer un déploiement antérieur.
- **Docker Compose** : `API_VERSION=1.0.0` dans `.env`, puis `docker compose up -d api`.

**Précaution sur le schéma de la base.** Hibernate (`ddl-auto=update`) ajoute les nouvelles colonnes, mais ne supprime ni ne renomme jamais rien. Une ancienne image fonctionne donc en général avec un schéma plus récent si les changements ne font qu'ajouter des éléments. En revanche, si une version a renommé une colonne, rendu un champ obligatoire ou transformé des données, revenir à l'ancienne image peut provoquer des erreurs. Il faut alors **sauvegarder la base avant chaque mise à jour**, pour pouvoir la restaurer en même temps que l'ancienne image.

## 5. Sauvegarde et restauration de la base

### Docker Compose

```bash
docker compose exec db pg_dump -U campustasks_user -d campustasks_db > sauvegarde-$(date +%F).sql
cat sauvegarde-2026-10-03.sql | docker compose exec -T db psql -U campustasks_user -d campustasks_db
```

La première commande produit la sauvegarde, la seconde la restaure.

### Render

Autoriser temporairement l'adresse IP du poste dans **Access Control**, récupérer l'*External Database URL*, puis :

```bash
pg_dump "<External Database URL>" > sauvegarde-render.sql
psql "<External Database URL>" < sauvegarde-render.sql
```

Retirer ensuite l'autorisation IP.

Les fichiers `sauvegarde-*.sql` sont exclus de Git par `.gitignore`. Ils contiennent des données personnelles et ne doivent pas être publiés.

## 6. Vérifier la persistance

```bash
docker compose restart
docker compose down
docker compose up -d
```

Après chacune de ces commandes, les comptes, matières et tâches doivent être toujours présents. Seul `docker compose down -v` supprime le volume, et donc les données.
