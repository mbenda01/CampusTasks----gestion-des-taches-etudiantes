import '../core/client_http_interface.dart';
import '../models/jetons.dart';
import '../models/utilisateur.dart';
import 'api_repository_base.dart';
import 'auth_repository.dart';
import 'jeton_repository.dart';

class AuthRepositoryApi extends ApiRepositoryBase implements AuthRepository {
  final JetonRepository _depotJetons;

  const AuthRepositoryApi({
    required ClientHttpInterface client,
    required JetonRepository depotJetons,
  })  : _depotJetons = depotJetons,
        super(client: client);

  @override
  Future<Jetons> inscrire(String nom, String email, String motDePasse) async {
    final jetons = await executer(
      () => client.post(
        '/api/v1/auth/register',
        authentifie: false,
        donnees: {'nom': nom, 'email': email, 'motDePasse': motDePasse},
      ),
      (donnees) => Jetons.depuisJson(donnees as Map<String, dynamic>),
    );

    await _depotJetons.enregistrerJetons(jetons);
    return jetons;
  }

  @override
  Future<Jetons> connecter(String email, String motDePasse) async {
    final jetons = await executer(
      () => client.post(
        '/api/v1/auth/login',
        authentifie: false,
        donnees: {'email': email, 'motDePasse': motDePasse},
      ),
      (donnees) => Jetons.depuisJson(donnees as Map<String, dynamic>),
    );

    await _depotJetons.enregistrerJetons(jetons);
    return jetons;
  }

  @override
  Future<Utilisateur> profilCourant() {
    return executer(
      () => client.get('/api/v1/auth/me'),
      (donnees) => Utilisateur.depuisJson(donnees as Map<String, dynamic>),
    );
  }

  @override
  Future<void> deconnecter() async {
    await _depotJetons.effacerJetons();
  }
}
