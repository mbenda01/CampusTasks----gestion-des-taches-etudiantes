import '../core/client_http_dio.dart';
import '../core/client_http_interface.dart';
import '../core/configuration.dart';
import '../core/journal.dart';
import '../repositories/auth_repository.dart';
import '../repositories/auth_repository_api.dart';
import '../repositories/jeton_repository.dart';
import '../repositories/jeton_repository_securise.dart';
import '../repositories/matiere_repository.dart';
import '../repositories/matiere_repository_api.dart';
import '../repositories/tableau_bord_repository.dart';
import '../repositories/tableau_bord_repository_api.dart';
import '../repositories/tache_repository.dart';
import '../repositories/tache_repository_api.dart';
import '../repositories/theme_repository.dart';
import '../repositories/theme_repository_local.dart';

class InjectionDepots {
  final Journal journal;
  final JetonRepository depotJetons;
  final AuthRepository depotAuth;
  final MatiereRepository depotMatieres;
  final TacheRepository depotTaches;
  final TableauBordRepository depotTableauBord;
  final ThemeRepository depotTheme;

  InjectionDepots._({
    required this.journal,
    required this.depotJetons,
    required this.depotAuth,
    required this.depotMatieres,
    required this.depotTaches,
    required this.depotTableauBord,
    required this.depotTheme,
  });

  factory InjectionDepots.construire() {
    final journal = JournalConsole();
    final depotJetons = JetonRepositorySecurise();

    journal.info('InjectionDepots', 'API : ${Configuration.urlApi}');

    final ClientHttpInterface client = ClientHttpDio(
      urlBase: Configuration.urlApi,
      depotJetons: depotJetons,
      journal: journal,
    );

    return InjectionDepots._(
      journal: journal,
      depotJetons: depotJetons,
      depotAuth: AuthRepositoryApi(client: client, depotJetons: depotJetons),
      depotMatieres: MatiereRepositoryApi(client: client),
      depotTaches: TacheRepositoryApi(client: client),
      depotTableauBord: TableauBordRepositoryApi(client: client),
      depotTheme: const ThemeRepositoryLocal(),
    );
  }
}
