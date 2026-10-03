import 'package:equatable/equatable.dart';

import '../../models/enums.dart';

sealed class TachesEvent extends Equatable {
  const TachesEvent();

  @override
  List<Object?> get props => [];
}

class TachesChargementDemande extends TachesEvent {
  final bool reinitialiserFiltres;

  const TachesChargementDemande({this.reinitialiserFiltres = false});

  @override
  List<Object?> get props => [reinitialiserFiltres];
}

class TachesRafraichissementDemande extends TachesEvent {
  final String? message;

  const TachesRafraichissementDemande({this.message});

  @override
  List<Object?> get props => [message];
}

class TachesPageSuivanteDemandee extends TachesEvent {
  const TachesPageSuivanteDemandee();
}

class TachesFiltreChange extends TachesEvent {
  final int? matiereId;
  final StatutTache? statut;

  const TachesFiltreChange({this.matiereId, this.statut});

  @override
  List<Object?> get props => [matiereId, statut];
}

class TacheStatutChange extends TachesEvent {
  final int id;
  final StatutTache statut;

  const TacheStatutChange(this.id, this.statut);

  @override
  List<Object?> get props => [id, statut];
}

class TacheSupprimee extends TachesEvent {
  final int id;

  const TacheSupprimee(this.id);

  @override
  List<Object?> get props => [id];
}
