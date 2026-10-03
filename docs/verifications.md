# Vérifications

Parcours essentiels demandés par le cahier des charges. Les preuves (captures) figurent dans le rapport de projet.

| # | Vérification | Moyen | Résultat attendu |
|---|---|---|---|
| 1 | Un étudiant peut créer un compte et se connecter | application mobile ou `POST /auth/register` puis `/auth/login` | 201 puis 200, jetons reçus |
| 2 | Il crée une matière et une tâche, et les retrouve après reconnexion | application mobile | données présentes après déconnexion et reconnexion |
| 3 | Il ne peut pas consulter ou modifier les données d'un autre étudiant | Moussa demande `GET /api/v1/tasks/1` (tâche d'Aminata) | 404 ; tests `ProtectionEntreEtudiants` |
| 4 | Une saisie invalide produit un message compréhensible | `POST /api/v1/tasks` avec un titre vide | 400 avec le message du champ `titre` |
| 5 | Les données restent présentes après un redémarrage des conteneurs | `docker compose restart` puis lecture | données inchangées |
| 6 | L'APK installé communique avec le backend distant | APK construit avec l'URL Render, installé sur un téléphone | connexion et affichage des données |
| 7 | Une nouvelle version signée met à jour l'application existante | installation de 1.0.1+2 par-dessus 1.0.0+1 | mise à jour proposée sans désinstallation |

## Tests automatisés

Commande : `./mvnw clean test`. Résultat : **37 tests, 0 échec**.

| Règle couverte | Tests |
|---|---|
| Protection des données entre étudiants | `TacheServiceImplTest.ProtectionEntreEtudiants`, `MatiereServiceImplTest.Isolation` |
| Suppression d'une matière refusée si des tâches existent | `MatiereServiceImplTest.Suppression` |
| Calcul du retard | `TacheTest.Retard` |
| Transitions de statut | `TacheTest.Statut`, `TacheServiceImplTest.ChangementDeStatut` |
| Tâche rattachée uniquement à une matière du même étudiant | `TacheTest.Planification`, `TacheTest.Modification` |
| Sécurité des comptes et des jetons | `AuthServiceImplTest`, `JwtServiceTest` |
| Indicateurs du tableau de bord | `TableauBordServiceImplTest` |
