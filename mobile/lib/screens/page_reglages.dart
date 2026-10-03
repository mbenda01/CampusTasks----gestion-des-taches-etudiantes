import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_event.dart';
import '../blocs/auth/auth_state.dart';
import '../blocs/theme/theme_cubit.dart';
import '../core/configuration.dart';
import '../models/preference_theme.dart';
import '../routes/app_routes.dart';
import '../widgets/barre_retour.dart';

class PageReglages extends StatelessWidget {
  const PageReglages({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BarreRetour(titre: 'Réglages'),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _construireTitreSection(context, 'Compte'),
          _construireLigneCompte(context),
          const Divider(height: 32),
          _construireTitreSection(context, 'Apparence'),
          _construireSelecteurTheme(context),
          const Divider(height: 32),
          _construireTitreSection(context, 'Serveur'),
          const ListTile(
            leading: Icon(Icons.dns_outlined),
            title: Text('Adresse de l\'API'),
            subtitle: Text(Configuration.urlApi),
          ),
          const Divider(height: 32),
          _construireTitreSection(context, 'Application'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('À propos'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, Routes.aPropos),
          ),
          const SizedBox(height: 16),
          _construireBoutonDeconnexion(context),
        ],
      ),
    );
  }

  Widget _construireTitreSection(BuildContext context, String texte) {
    final couleur = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        texte.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: couleur,
        ),
      ),
    );
  }

  Widget _construireLigneCompte(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, etat) {
        if (etat is! AuthAuthentifie) return const SizedBox.shrink();

        final couleurs = Theme.of(context).colorScheme;
        final utilisateur = etat.utilisateur;

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: couleurs.primaryContainer,
            child: Text(
              utilisateur.initiale,
              style: TextStyle(color: couleurs.onPrimaryContainer),
            ),
          ),
          title: Text(utilisateur.nom),
          subtitle: Text(utilisateur.email),
        );
      },
    );
  }

  Widget _construireSelecteurTheme(BuildContext context) {
    return BlocBuilder<ThemeCubit, EtatTheme>(
      builder: (context, etatTheme) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<PreferenceTheme>(
                segments: const [
                  ButtonSegment(
                    value: PreferenceTheme.automatique,
                    icon: Icon(Icons.brightness_auto),
                    label: Text('Auto'),
                  ),
                  ButtonSegment(
                    value: PreferenceTheme.clair,
                    icon: Icon(Icons.light_mode),
                    label: Text('Clair'),
                  ),
                  ButtonSegment(
                    value: PreferenceTheme.sombre,
                    icon: Icon(Icons.dark_mode),
                    label: Text('Sombre'),
                  ),
                ],
                selected: {etatTheme.preference},
                onSelectionChanged: (selection) {
                  context.read<ThemeCubit>().changer(selection.first);
                },
              ),
              const SizedBox(height: 8),
              Text(
                ThemeCubit.libelleDe(etatTheme.preference),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _construireBoutonDeconnexion(BuildContext context) {
    final couleurs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: OutlinedButton.icon(
        onPressed: () => _confirmerDeconnexion(context),
        icon: const Icon(Icons.logout),
        label: const Text('Se déconnecter'),
        style: OutlinedButton.styleFrom(
          foregroundColor: couleurs.error,
          side: BorderSide(color: couleurs.error),
        ),
      ),
    );
  }

  Future<void> _confirmerDeconnexion(BuildContext context) async {
    final blocAuth = context.read<AuthBloc>();
    final navigateur = Navigator.of(context);

    final confirme = await showDialog<bool>(
      context: context,
      builder: (contexteDialogue) => AlertDialog(
        title: const Text('Se déconnecter ?'),
        content: const Text(
          'Le jeton de connexion sera supprimé de cet appareil.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(contexteDialogue, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(contexteDialogue, true),
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );

    if (confirme == true) {
      blocAuth.add(const AuthDeconnexionDemandee());
      navigateur.popUntil((route) => route.isFirst);
    }
  }
}
