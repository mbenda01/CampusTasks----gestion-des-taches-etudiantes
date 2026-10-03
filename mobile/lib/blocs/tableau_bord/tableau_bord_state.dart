import 'package:equatable/equatable.dart';

import '../../models/tableau_bord.dart';

sealed class TableauBordState extends Equatable {
  const TableauBordState();

  @override
  List<Object?> get props => [];
}

class TableauBordInitial extends TableauBordState {
  const TableauBordInitial();
}

class TableauBordEnChargement extends TableauBordState {
  const TableauBordEnChargement();
}

class TableauBordCharge extends TableauBordState {
  final TableauBord tableau;

  const TableauBordCharge(this.tableau);

  @override
  List<Object?> get props => [tableau];
}

class TableauBordEchec extends TableauBordState {
  final String message;

  const TableauBordEchec(this.message);

  @override
  List<Object?> get props => [message];
}
