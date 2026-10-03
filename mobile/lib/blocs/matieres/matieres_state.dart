import 'package:equatable/equatable.dart';

import '../../models/matiere.dart';

sealed class MatieresState extends Equatable {
  const MatieresState();

  @override
  List<Object?> get props => [];
}

class MatieresInitial extends MatieresState {
  const MatieresInitial();
}

class MatieresEnChargement extends MatieresState {
  const MatieresEnChargement();
}

class MatieresChargees extends MatieresState {
  final List<Matiere> matieres;
  final int? actionEnCoursSurId;
  final String? messageAction;
  final bool messageEstErreur;

  const MatieresChargees({
    required this.matieres,
    this.actionEnCoursSurId,
    this.messageAction,
    this.messageEstErreur = false,
  });

  bool get estVide => matieres.isEmpty;

  MatieresChargees copierAvec({
    List<Matiere>? matieres,
    int? actionEnCoursSurId,
    bool effacerActionEnCours = false,
    String? messageAction,
    bool? messageEstErreur,
    bool effacerMessage = false,
  }) {
    return MatieresChargees(
      matieres: matieres ?? this.matieres,
      actionEnCoursSurId: effacerActionEnCours
          ? null
          : (actionEnCoursSurId ?? this.actionEnCoursSurId),
      messageAction: effacerMessage ? null : (messageAction ?? this.messageAction),
      messageEstErreur: messageEstErreur ?? this.messageEstErreur,
    );
  }

  @override
  List<Object?> get props => [
        matieres,
        actionEnCoursSurId,
        messageAction,
        messageEstErreur,
      ];
}

class MatieresEchec extends MatieresState {
  final String message;

  const MatieresEchec(this.message);

  @override
  List<Object?> get props => [message];
}
