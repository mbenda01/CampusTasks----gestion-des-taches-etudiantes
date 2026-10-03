# CampusTasks — Application mobile

Application Flutter de CampusTasks, connectée à l'API REST du backend.

## Stack

| Composant | Rôle |
|---|---|
| Flutter / Dart | interface Android |
| flutter_bloc, equatable, bloc_concurrency | gestion d'état (BLoC / Cubit) |
| dio | client HTTP, ajout du jeton et rafraîchissement automatique |
| flutter_secure_storage | stockage chiffré des jetons |
| shared_preferences | préférence de thème |
| flutter_localizations | interface et calendrier en français |

## Écrans

- **Connexion / inscription** : un seul écran, avec bascule entre les deux modes.
- **Tableau de bord** : indicateurs (à faire, en cours, terminées, en retard), progression, tâches en retard, prochaines échéances.
- **Tâches** : liste paginée, filtres par statut et par matière, tri par date limite, changement rapide de statut, suppression.
- **Matières** : liste, modification, suppression (refus affiché si des tâches sont rattachées).
- **Formulaires** de tâche et de matière, avec validation locale et affichage des erreurs du serveur.
- **Réglages** : compte, thème (automatique, clair, sombre), adresse de l'API, déconnexion.

Chaque écran gère les états de chargement, d'erreur (avec bouton « Réessayer ») et de liste vide.

## Architecture

```
lib/
├── core/           client HTTP (Dio), erreurs typées, journal, configuration
├── models/         Utilisateur, Jetons, Matiere, Tache, TableauBord, PageResultat
├── repositories/   interfaces + implémentations API, jetons sécurisés, thème
├── blocs/          auth, tableau_bord, matieres, taches, theme
├── di/             injection des dépôts et des blocs
├── routes/         table des routes, ouverture des formulaires
├── screens/        écrans
├── widgets/        composants réutilisables
└── theme/          thèmes clair et sombre (Material 3)
```

## Adresse du backend

L'adresse de l'API est fixée à la compilation avec `--dart-define`. Elle s'affiche dans **Réglages**.

| Environnement | Commande |
|---|---|
| Émulateur Android + API locale | `flutter run` (défaut : `http://10.0.2.2:8080`) |
| Téléphone + API locale (même Wi-Fi) | `flutter run --dart-define=API_URL=http://IP-DU-PC:8080` |
| Production | `--dart-define=API_URL=https://campus-tasks-api.onrender.com` |

## Gestion du jeton

- Les jetons sont stockés avec `flutter_secure_storage`.
- Le jeton d'accès est ajouté à chaque requête. En cas de réponse 401, l'application le renouvelle automatiquement avec le jeton de rafraîchissement.
- À la déconnexion, les jetons sont supprimés de l'appareil.

## Commandes

```bash
flutter pub get
flutter analyze
flutter run
```

## Générer l'APK signé

1. Créer la clé de signature, une seule fois, **hors du dépôt** :

   ```bash
   keytool -genkey -v -keystore CHEMIN/campus-tasks.jks -keyalg RSA -keysize 2048 -validity 10000 -alias campus-tasks
   ```

2. Créer `android/key.properties`. Ce fichier n'est **jamais versionné** :

   ```properties
   storePassword=...
   keyPassword=...
   keyAlias=campus-tasks
   storeFile=CHEMIN/campus-tasks.jks
   ```

   `android/app/build.gradle.kts` lit ce fichier et signe la variante `release` avec cette clé.

3. Construire :

   ```bash
   flutter build apk --release --dart-define=API_URL=https://campus-tasks-api.onrender.com
   ```

4. Vérifier la signature :

   ```bash
   keytool -printcert -jarfile build/app/outputs/flutter-apk/app-release.apk
   ```

5. Renommer en `campus-tasks-1.0.0.apk` et publier dans la GitHub Release `v1.0.0`.

La même clé doit être conservée pour toutes les versions suivantes : sans elle, Android refuse la mise à jour de l'application installée.

## Version

Définie dans `pubspec.yaml` : `1.0.0+1` (version 1.0.0, build 1). Chaque nouvelle livraison incrémente le numéro de build.

## Remarque Windows

Si le SDK Flutter est installé dans un chemin contenant un espace, la compilation des « native assets » échoue. Contournement : créer un lecteur virtuel sans espace.

```cmd
subst X: "F:\chemin avec espace"
X:\flutter\bin\flutter build apk --release
```
