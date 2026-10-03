import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/erreur_api.dart';
import '../../core/journal.dart';
import '../../repositories/matiere_repository.dart';
import 'matieres_event.dart';
import 'matieres_state.dart';

class MatieresBloc extends Bloc<MatieresEvent, MatieresState> {
  static const String _origine = 'MatieresBloc';

  final MatiereRepository _depot;
  final Journal _journal;

  MatieresBloc({
    required MatiereRepository depot,
    required Journal journal,
  })  : _depot = depot,
        _journal = journal,
        super(const MatieresInitial()) {
    on<MatieresChargementDemande>(_surChargement);
    on<MatieresRafraichissementDemande>(_surRafraichissement);
    on<MatiereSupprimee>(_surSuppression);
  }

  Future<void> _surChargement(
    MatieresChargementDemande evenement,
    Emitter<MatieresState> emit,
  ) async {
    emit(const MatieresEnChargement());
    await _charger(emit);
  }

  Future<void> _surRafraichissement(
    MatieresRafraichissementDemande evenement,
    Emitter<MatieresState> emit,
  ) async {
    await _charger(emit, message: evenement.message);
  }

  Future<void> _surSuppression(
    MatiereSupprimee evenement,
    Emitter<MatieresState> emit,
  ) async {
    final etat = state;
    if (etat is MatieresChargees) {
      emit(etat.copierAvec(
        actionEnCoursSurId: evenement.id,
        effacerMessage: true,
      ));
    }

    try {
      await _depot.supprimer(evenement.id);

      _journal.info(_origine, 'Matière supprimée : id=${evenement.id}');

      await _charger(emit, message: 'Matière supprimée');
    } catch (erreur) {
      _journal.erreur(_origine, 'Échec de la suppression', erreur);
      emit(_echecAction(erreur));
    }
  }

  Future<void> _charger(
    Emitter<MatieresState> emit, {
    String? message,
  }) async {
    try {
      final matieres = await _depot.lister();

      _journal.debug(_origine, '${matieres.length} matières chargées');

      emit(MatieresChargees(matieres: matieres, messageAction: message));
    } catch (erreur) {
      emit(MatieresEchec(_messageDe(erreur)));
    }
  }

  MatieresState _echecAction(Object erreur) {
    final message = _messageDe(erreur);
    final etat = state;

    if (etat is MatieresChargees) {
      return etat.copierAvec(
        effacerActionEnCours: true,
        messageAction: message,
        messageEstErreur: true,
      );
    }

    return MatieresEchec(message);
  }

  String _messageDe(Object erreur) {
    if (erreur is ErreurReseau) {
      _journal.avertissement(_origine, 'Erreur réseau');
      return 'Connexion impossible. Vérifiez votre réseau.';
    }

    if (erreur is ErreurApi) {
      _journal.avertissement(_origine, 'Échec : ${erreur.runtimeType}');
      return erreur.message;
    }

    _journal.erreur(_origine, 'Erreur inattendue', erreur);
    return 'Une erreur est survenue';
  }
}
