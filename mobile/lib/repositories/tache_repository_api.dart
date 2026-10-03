import '../core/client_http_interface.dart';
import '../models/enums.dart';
import '../models/page_resultat.dart';
import '../models/tache.dart';
import 'api_repository_base.dart';
import 'tache_repository.dart';

class TacheRepositoryApi extends ApiRepositoryBase implements TacheRepository {
  const TacheRepositoryApi({required ClientHttpInterface client})
      : super(client: client);

  @override
  Future<PageResultat<Tache>> lister({
    int? matiereId,
    StatutTache? statut,
    int page = 0,
    int taille = 20,
  }) {
    return executer(
      () => client.get(
        '/api/v1/tasks',
        parametres: {
          'page': page,
          'size': taille,
          'sort': 'dateLimite,asc',
          if (matiereId != null) 'matiereId': matiereId,
          if (statut != null) 'statut': statut.code,
        },
      ),
      (donnees) => PageResultat.depuisJson(
        donnees as Map<String, dynamic>,
        Tache.depuisJson,
      ),
    );
  }

  @override
  Future<Tache> obtenir(int id) {
    return executer(
      () => client.get('/api/v1/tasks/$id'),
      (donnees) => Tache.depuisJson(donnees as Map<String, dynamic>),
    );
  }

  @override
  Future<Tache> creer(Tache tache) {
    return executer(
      () => client.post('/api/v1/tasks', donnees: tache.versJsonCreation()),
      (donnees) => Tache.depuisJson(donnees as Map<String, dynamic>),
    );
  }

  @override
  Future<Tache> modifier(int id, Tache tache) {
    return executer(
      () => client.put('/api/v1/tasks/$id', donnees: tache.versJsonModification()),
      (donnees) => Tache.depuisJson(donnees as Map<String, dynamic>),
    );
  }

  @override
  Future<Tache> changerStatut(int id, StatutTache statut) {
    return executer(
      () => client.patch(
        '/api/v1/tasks/$id/status',
        donnees: {'statut': statut.code},
      ),
      (donnees) => Tache.depuisJson(donnees as Map<String, dynamic>),
    );
  }

  @override
  Future<void> supprimer(int id) {
    return executer(
      () => client.delete('/api/v1/tasks/$id'),
      (_) {},
    );
  }
}
