import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/journal.dart';
import '../repositories/auth_repository.dart';
import '../repositories/jeton_repository.dart';
import '../repositories/matiere_repository.dart';
import '../repositories/tableau_bord_repository.dart';
import '../repositories/tache_repository.dart';
import '../repositories/theme_repository.dart';
import 'injection_blocs.dart';
import 'injection_depots.dart';

class Injection extends StatefulWidget {
  final Widget enfant;

  const Injection({super.key, required this.enfant});

  @override
  State<Injection> createState() => _InjectionState();
}

class _InjectionState extends State<Injection> {
  late final InjectionDepots _depots;

  @override
  void initState() {
    super.initState();
    _depots = InjectionDepots.construire();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<Journal>.value(value: _depots.journal),
        RepositoryProvider<JetonRepository>.value(value: _depots.depotJetons),
        RepositoryProvider<AuthRepository>.value(value: _depots.depotAuth),
        RepositoryProvider<MatiereRepository>.value(value: _depots.depotMatieres),
        RepositoryProvider<TacheRepository>.value(value: _depots.depotTaches),
        RepositoryProvider<TableauBordRepository>.value(value: _depots.depotTableauBord),
        RepositoryProvider<ThemeRepository>.value(value: _depots.depotTheme),
      ],
      child: MultiBlocProvider(
        providers: InjectionBlocs.fournisseurs,
        child: widget.enfant,
      ),
    );
  }
}
