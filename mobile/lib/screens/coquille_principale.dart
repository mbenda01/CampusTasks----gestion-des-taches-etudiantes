import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/matieres/matieres_bloc.dart';
import '../blocs/matieres/matieres_event.dart';
import '../blocs/taches/taches_bloc.dart';
import '../blocs/taches/taches_event.dart';
import '../models/matiere.dart';
import '../routes/app_routes.dart';
import '../routes/navigation.dart';
import '../widgets/barre_navigation.dart';
import 'page_matieres.dart';
import 'page_tableau_bord.dart';
import 'page_taches.dart';

class CoquillePrincipale extends StatefulWidget {
  const CoquillePrincipale({super.key});

  @override
  State<CoquillePrincipale> createState() => _CoquillePrincipaleState();
}

class _CoquillePrincipaleState extends State<CoquillePrincipale> {
  int _indexActif = 0;

  static const List<String> _titres = [
    'Tableau de bord',
    'Mes tâches',
    'Mes matières',
  ];

  @override
  void initState() {
    super.initState();
    context.read<MatieresBloc>().add(const MatieresChargementDemande());
    context.read<TachesBloc>().add(
          const TachesChargementDemande(reinitialiserFiltres: true),
        );
  }

  void _changerOnglet(int index) {
    if (index < 0 || index >= _titres.length) return;
    if (index == _indexActif) return;

    setState(() {
      _indexActif = index;
    });
  }

  void _ouvrirTachesDeLaMatiere(Matiere matiere) {
    context.read<TachesBloc>().add(TachesFiltreChange(matiereId: matiere.id));
    _changerOnglet(1);
  }

  void _ajouter() {
    if (_indexActif == 2) {
      ouvrirEditionMatiere(context);
    } else {
      ouvrirEditionTache(context);
    }
  }

  Widget _construirePage(int index) {
    switch (index) {
      case 1:
        return const PageTaches();
      case 2:
        return PageMatieres(onOuvrirMatiere: _ouvrirTachesDeLaMatiere);
      default:
        return PageTableauBord(onVoirTaches: () => _changerOnglet(1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _indexActif == 0,
      onPopInvokedWithResult: (bool aQuitte, Object? resultat) {
        if (aQuitte) return;
        _changerOnglet(0);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _titres[_indexActif],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: 'Réglages',
              onPressed: () => Navigator.pushNamed(context, Routes.reglages),
            ),
          ],
        ),
        body: _construirePage(_indexActif),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _ajouter,
          icon: const Icon(Icons.add),
          label: Text(_indexActif == 2 ? 'Matière' : 'Tâche'),
        ),
        bottomNavigationBar: BarreNavigation(
          indexActif: _indexActif,
          onChangement: _changerOnglet,
        ),
      ),
    );
  }
}
