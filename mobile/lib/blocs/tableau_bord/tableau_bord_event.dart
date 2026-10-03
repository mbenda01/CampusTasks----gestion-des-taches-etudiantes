import 'package:equatable/equatable.dart';

sealed class TableauBordEvent extends Equatable {
  const TableauBordEvent();

  @override
  List<Object?> get props => [];
}

class TableauBordChargementDemande extends TableauBordEvent {
  const TableauBordChargementDemande();
}

class TableauBordRafraichissementDemande extends TableauBordEvent {
  const TableauBordRafraichissementDemande();
}
