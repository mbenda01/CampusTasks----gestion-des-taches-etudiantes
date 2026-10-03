import '../models/matiere.dart';

abstract class MatiereRepository {
  Future<List<Matiere>> lister();
  Future<Matiere> creer(Matiere matiere);
  Future<Matiere> modifier(int id, Matiere matiere);
  Future<void> supprimer(int id);
}
