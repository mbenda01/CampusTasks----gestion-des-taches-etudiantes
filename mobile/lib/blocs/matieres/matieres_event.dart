import 'package:equatable/equatable.dart';

sealed class MatieresEvent extends Equatable {
  const MatieresEvent();

  @override
  List<Object?> get props => [];
}

class MatieresChargementDemande extends MatieresEvent {
  const MatieresChargementDemande();
}

class MatieresRafraichissementDemande extends MatieresEvent {
  final String? message;

  const MatieresRafraichissementDemande({this.message});

  @override
  List<Object?> get props => [message];
}

class MatiereSupprimee extends MatieresEvent {
  final int id;

  const MatiereSupprimee(this.id);

  @override
  List<Object?> get props => [id];
}
