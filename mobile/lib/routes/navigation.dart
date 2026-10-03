import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/matieres/matieres_bloc.dart';
import '../blocs/matieres/matieres_event.dart';
import '../blocs/tableau_bord/tableau_bord_bloc.dart';
import '../blocs/tableau_bord/tableau_bord_event.dart';
import '../blocs/taches/taches_bloc.dart';
import '../blocs/taches/taches_event.dart';
import '../models/matiere.dart';
import '../models/tache.dart';
import 'app_routes.dart';

Future<void> ouvrirEditionTache(BuildContext context, {Tache? tache}) async {
  final enregistre = await Navigator.pushNamed(
    context,
    Routes.editionTache,
    arguments: tache,
  );

  if (enregistre != true || !context.mounted) return;

  context.read<TachesBloc>().add(TachesRafraichissementDemande(
        message: tache == null ? 'Tâche ajoutée' : 'Tâche modifiée',
      ));
  context.read<TableauBordBloc>().add(const TableauBordRafraichissementDemande());
}

Future<void> ouvrirEditionMatiere(BuildContext context, {Matiere? matiere}) async {
  final enregistre = await Navigator.pushNamed(
    context,
    Routes.editionMatiere,
    arguments: matiere,
  );

  if (enregistre != true || !context.mounted) return;

  context.read<MatieresBloc>().add(MatieresRafraichissementDemande(
        message: matiere == null ? 'Matière ajoutée' : 'Matière modifiée',
      ));
  context.read<TachesBloc>().add(const TachesRafraichissementDemande());
}
