import '../core/client_http_interface.dart';
import '../models/matiere.dart';
import '../models/page_resultat.dart';
import 'api_repository_base.dart';
import 'matiere_repository.dart';

class MatiereRepositoryApi extends ApiRepositoryBase
    implements MatiereRepository {
  const MatiereRepositoryApi({required ClientHttpInterface client})
      : super(client: client);

  @override
  Future<List<Matiere>> lister() {
    return executer(
      () => client.get(
        '/api/v1/subjects',
        parametres: {'size': 50, 'sort': 'nom,asc'},
      ),
      (donnees) => PageResultat.depuisJson(
        donnees as Map<String, dynamic>,
        Matiere.depuisJson,
      ).contenu,
    );
  }

  @override
  Future<Matiere> creer(Matiere matiere) {
    return executer(
      () => client.post('/api/v1/subjects', donnees: matiere.versJson()),
      (donnees) => Matiere.depuisJson(donnees as Map<String, dynamic>),
    );
  }

  @override
  Future<Matiere> modifier(int id, Matiere matiere) {
    return executer(
      () => client.put('/api/v1/subjects/$id', donnees: matiere.versJson()),
      (donnees) => Matiere.depuisJson(donnees as Map<String, dynamic>),
    );
  }

  @override
  Future<void> supprimer(int id) {
    return executer(
      () => client.delete('/api/v1/subjects/$id'),
      (_) {},
    );
  }
}
