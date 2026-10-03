import '../models/enums.dart';
import '../models/page_resultat.dart';
import '../models/tache.dart';

abstract class TacheRepository {
  Future<PageResultat<Tache>> lister({
    int? matiereId,
    StatutTache? statut,
    int page = 0,
    int taille = 20,
  });

  Future<Tache> obtenir(int id);
  Future<Tache> creer(Tache tache);
  Future<Tache> modifier(int id, Tache tache);
  Future<Tache> changerStatut(int id, StatutTache statut);
  Future<void> supprimer(int id);
}
