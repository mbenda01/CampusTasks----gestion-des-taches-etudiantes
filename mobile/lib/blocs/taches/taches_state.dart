import 'package:equatable/equatable.dart';

import '../../models/enums.dart';
import '../../models/tache.dart';

sealed class TachesState extends Equatable {
  const TachesState();

  @override
  List<Object?> get props => [];
}

class TachesInitial extends TachesState {
  const TachesInitial();
}

class TachesEnChargement extends TachesState {
  const TachesEnChargement();
}

class TachesChargees extends TachesState {
  final List<Tache> taches;
  final int totalElements;
  final bool aUnePageSuivante;
  final bool chargementPageSuivante;
  final int? matiereId;
  final StatutTache? statut;
  final int? actionEnCoursSurId;
  final String? messageAction;
  final bool messageEstErreur;

  const TachesChargees({
    required this.taches,
    required this.totalElements,
    required this.aUnePageSuivante,
    this.chargementPageSuivante = false,
    this.matiereId,
    this.statut,
    this.actionEnCoursSurId,
    this.messageAction,
    this.messageEstErreur = false,
  });

  bool get estVide => taches.isEmpty;

  bool get estFiltre => matiereId != null || statut != null;

  TachesChargees copierAvec({
    List<Tache>? taches,
    int? totalElements,
    bool? aUnePageSuivante,
    bool? chargementPageSuivante,
    int? actionEnCoursSurId,
    bool effacerActionEnCours = false,
    String? messageAction,
    bool? messageEstErreur,
    bool effacerMessage = false,
  }) {
    return TachesChargees(
      taches: taches ?? this.taches,
      totalElements: totalElements ?? this.totalElements,
      aUnePageSuivante: aUnePageSuivante ?? this.aUnePageSuivante,
      chargementPageSuivante:
          chargementPageSuivante ?? this.chargementPageSuivante,
      matiereId: matiereId,
      statut: statut,
      actionEnCoursSurId: effacerActionEnCours
          ? null
          : (actionEnCoursSurId ?? this.actionEnCoursSurId),
      messageAction: effacerMessage ? null : (messageAction ?? this.messageAction),
      messageEstErreur: messageEstErreur ?? this.messageEstErreur,
    );
  }

  @override
  List<Object?> get props => [
        taches,
        totalElements,
        aUnePageSuivante,
        chargementPageSuivante,
        matiereId,
        statut,
        actionEnCoursSurId,
        messageAction,
        messageEstErreur,
      ];
}

class TachesEchec extends TachesState {
  final String message;

  const TachesEchec(this.message);

  @override
  List<Object?> get props => [message];
}
