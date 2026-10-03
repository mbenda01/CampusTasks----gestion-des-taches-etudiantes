import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/erreur_api.dart';
import '../../core/journal.dart';
import '../../repositories/tableau_bord_repository.dart';
import 'tableau_bord_event.dart';
import 'tableau_bord_state.dart';

class TableauBordBloc extends Bloc<TableauBordEvent, TableauBordState> {
  static const String _origine = 'TableauBordBloc';

  final TableauBordRepository _depot;
  final Journal _journal;

  TableauBordBloc({
    required TableauBordRepository depot,
    required Journal journal,
  })  : _depot = depot,
        _journal = journal,
        super(const TableauBordInitial()) {
    on<TableauBordChargementDemande>(_surChargement);
    on<TableauBordRafraichissementDemande>(_surRafraichissement);
  }

  Future<void> _surChargement(
    TableauBordChargementDemande evenement,
    Emitter<TableauBordState> emit,
  ) async {
    emit(const TableauBordEnChargement());
    await _charger(emit);
  }

  Future<void> _surRafraichissement(
    TableauBordRafraichissementDemande evenement,
    Emitter<TableauBordState> emit,
  ) async {
    await _charger(emit);
  }

  Future<void> _charger(Emitter<TableauBordState> emit) async {
    try {
      final tableau = await _depot.consulter();

      _journal.debug(
        _origine,
        '${tableau.total} taches, ${tableau.enRetard} en retard',
      );

      emit(TableauBordCharge(tableau));
    } catch (erreur) {
      emit(_traduireEchec(erreur));
    }
  }

  TableauBordState _traduireEchec(Object erreur) {
    if (erreur is ErreurReseau) {
      _journal.avertissement(_origine, 'Erreur réseau');
      return const TableauBordEchec('Connexion impossible. Vérifiez votre réseau.');
    }

    if (erreur is ErreurApi) {
      _journal.avertissement(_origine, 'Échec : ${erreur.runtimeType}');
      return TableauBordEchec(erreur.message);
    }

    _journal.erreur(_origine, 'Erreur inattendue', erreur);
    return const TableauBordEchec('Une erreur est survenue');
  }
}
