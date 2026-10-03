import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/erreur_api.dart';
import '../../core/journal.dart';
import '../../models/enums.dart';
import '../../repositories/tache_repository.dart';
import 'taches_event.dart';
import 'taches_state.dart';

class TachesBloc extends Bloc<TachesEvent, TachesState> {
  static const String _origine = 'TachesBloc';
  static const int _taillePage = 20;

  final TacheRepository _depot;
  final Journal _journal;

  int _pageCourante = 0;
  int? _matiereId;
  StatutTache? _statut;

  TachesBloc({
    required TacheRepository depot,
    required Journal journal,
  })  : _depot = depot,
        _journal = journal,
        super(const TachesInitial()) {
    on<TachesChargementDemande>(_surChargement);
    on<TachesRafraichissementDemande>(_surRafraichissement);
    on<TachesPageSuivanteDemandee>(
      _surPageSuivante,
      transformer: droppable(),
    );
    on<TachesFiltreChange>(_surFiltreChange);
    on<TacheStatutChange>(_surStatutChange);
    on<TacheSupprimee>(_surSuppression);
  }

  int? get matiereIdFiltre => _matiereId;

  StatutTache? get statutFiltre => _statut;

  Future<void> _surChargement(
    TachesChargementDemande evenement,
    Emitter<TachesState> emit,
  ) async {
    if (evenement.reinitialiserFiltres) {
      _matiereId = null;
      _statut = null;
    }

    emit(const TachesEnChargement());
    await _charger(emit);
  }

  Future<void> _surRafraichissement(
    TachesRafraichissementDemande evenement,
    Emitter<TachesState> emit,
  ) async {
    await _charger(emit, message: evenement.message);
  }

  Future<void> _surFiltreChange(
    TachesFiltreChange evenement,
    Emitter<TachesState> emit,
  ) async {
    _matiereId = evenement.matiereId;
    _statut = evenement.statut;

    _journal.debug(
      _origine,
      'Filtres appliqués : matiere=$_matiereId, statut=${_statut?.code}',
    );

    emit(const TachesEnChargement());
    await _charger(emit);
  }

  Future<void> _surPageSuivante(
    TachesPageSuivanteDemandee evenement,
    Emitter<TachesState> emit,
  ) async {
    final etat = state;
    if (etat is! TachesChargees || !etat.aUnePageSuivante) return;
    if (etat.chargementPageSuivante) return;

    emit(etat.copierAvec(chargementPageSuivante: true, effacerMessage: true));

    try {
      final page = _pageCourante + 1;

      final resultat = await _depot.lister(
        matiereId: _matiereId,
        statut: _statut,
        page: page,
        taille: _taillePage,
      );

      _pageCourante = page;

      emit(etat.copierAvec(
        taches: [...etat.taches, ...resultat.contenu],
        totalElements: resultat.totalElements,
        aUnePageSuivante: resultat.aUnePageSuivante,
        chargementPageSuivante: false,
        effacerMessage: true,
      ));
    } catch (erreur) {
      _journal.erreur(_origine, 'Échec du chargement de la page suivante', erreur);
      emit(etat.copierAvec(chargementPageSuivante: false, effacerMessage: true));
    }
  }

  Future<void> _surStatutChange(
    TacheStatutChange evenement,
    Emitter<TachesState> emit,
  ) async {
    final etat = state;
    if (etat is TachesChargees) {
      emit(etat.copierAvec(
        actionEnCoursSurId: evenement.id,
        effacerMessage: true,
      ));
    }

    try {
      await _depot.changerStatut(evenement.id, evenement.statut);

      _journal.info(
        _origine,
        'Statut changé : id=${evenement.id} -> ${evenement.statut.code}',
      );

      await _charger(emit, message: 'Statut : ${evenement.statut.libelle}');
    } catch (erreur) {
      _journal.erreur(_origine, 'Échec du changement de statut', erreur);
      emit(_echecAction(erreur));
    }
  }

  Future<void> _surSuppression(
    TacheSupprimee evenement,
    Emitter<TachesState> emit,
  ) async {
    final etat = state;
    if (etat is TachesChargees) {
      emit(etat.copierAvec(
        actionEnCoursSurId: evenement.id,
        effacerMessage: true,
      ));
    }

    try {
      await _depot.supprimer(evenement.id);

      _journal.info(_origine, 'Tâche supprimée : id=${evenement.id}');

      await _charger(emit, message: 'Tâche supprimée');
    } catch (erreur) {
      _journal.erreur(_origine, 'Échec de la suppression', erreur);
      emit(_echecAction(erreur));
    }
  }

  Future<void> _charger(
    Emitter<TachesState> emit, {
    String? message,
  }) async {
    try {
      _pageCourante = 0;

      final resultat = await _depot.lister(
        matiereId: _matiereId,
        statut: _statut,
        page: 0,
        taille: _taillePage,
      );

      _journal.debug(
        _origine,
        '${resultat.contenu.length} tâches chargées sur ${resultat.totalElements}',
      );

      emit(TachesChargees(
        taches: resultat.contenu,
        totalElements: resultat.totalElements,
        aUnePageSuivante: resultat.aUnePageSuivante,
        matiereId: _matiereId,
        statut: _statut,
        messageAction: message,
      ));
    } catch (erreur) {
      emit(TachesEchec(_messageDe(erreur)));
    }
  }

  TachesState _echecAction(Object erreur) {
    final message = _messageDe(erreur);
    final etat = state;

    if (etat is TachesChargees) {
      return etat.copierAvec(
        effacerActionEnCours: true,
        messageAction: message,
        messageEstErreur: true,
      );
    }

    return TachesEchec(message);
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
