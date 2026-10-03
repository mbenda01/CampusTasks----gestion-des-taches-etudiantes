import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/matieres/matieres_bloc.dart';
import '../blocs/tableau_bord/tableau_bord_bloc.dart';
import '../blocs/taches/taches_bloc.dart';
import '../blocs/theme/theme_cubit.dart';
import '../core/journal.dart';
import '../repositories/auth_repository.dart';
import '../repositories/jeton_repository.dart';
import '../repositories/matiere_repository.dart';
import '../repositories/tableau_bord_repository.dart';
import '../repositories/tache_repository.dart';
import '../repositories/theme_repository.dart';

class InjectionBlocs {
  InjectionBlocs._();

  static List<BlocProvider> get fournisseurs => [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            depot: context.read<AuthRepository>(),
            depotJetons: context.read<JetonRepository>(),
            journal: context.read<Journal>(),
          )..add(const AuthDemarrageDemande()),
        ),
        BlocProvider<TableauBordBloc>(
          create: (context) => TableauBordBloc(
            depot: context.read<TableauBordRepository>(),
            journal: context.read<Journal>(),
          ),
        ),
        BlocProvider<MatieresBloc>(
          create: (context) => MatieresBloc(
            depot: context.read<MatiereRepository>(),
            journal: context.read<Journal>(),
          ),
        ),
        BlocProvider<TachesBloc>(
          create: (context) => TachesBloc(
            depot: context.read<TacheRepository>(),
            journal: context.read<Journal>(),
          ),
        ),
        BlocProvider<ThemeCubit>(
          create: (context) => ThemeCubit(
            depot: context.read<ThemeRepository>(),
            journal: context.read<Journal>(),
          )..charger(),
        ),
      ];
}
