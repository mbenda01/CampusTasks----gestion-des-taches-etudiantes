import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/auth/auth_bloc.dart';
import '../blocs/auth/auth_state.dart';
import '../blocs/tableau_bord/tableau_bord_bloc.dart';
import '../blocs/tableau_bord/tableau_bord_event.dart';
import '../blocs/tableau_bord/tableau_bord_state.dart';
import '../models/tableau_bord.dart';
import '../models/tache.dart';
import '../routes/navigation.dart';
import '../widgets/carte_indicateur.dart';
import '../widgets/carte_tache.dart';
import '../widgets/etat_erreur.dart';

class PageTableauBord extends StatefulWidget {
  final VoidCallback? onVoirTaches;

  const PageTableauBord({super.key, this.onVoirTaches});

  @override
  State<PageTableauBord> createState() => _PageTableauBordState();
}

class _PageTableauBordState extends State<PageTableauBord> {
  @override
  void initState() {
    super.initState();
    context.read<TableauBordBloc>().add(const TableauBordChargementDemande());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TableauBordBloc, TableauBordState>(
      builder: (context, etat) {
        return switch (etat) {
          TableauBordInitial() || TableauBordEnChargement() =>
            const Center(child: CircularProgressIndicator()),
          TableauBordEchec() => EtatErreur(
              message: etat.message,
              onReessayer: () => context
                  .read<TableauBordBloc>()
                  .add(const TableauBordChargementDemande()),
            ),
          TableauBordCharge() => _construireContenu(etat.tableau),
        };
      },
    );
  }

  Widget _construireContenu(TableauBord tableau) {
    return RefreshIndicator(
      onRefresh: () async {
        context
            .read<TableauBordBloc>()
            .add(const TableauBordRafraichissementDemande());
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          _construireSalutation(),
          const SizedBox(height: 16),
          _construireIndicateurs(tableau),
          const SizedBox(height: 16),
          _construireProgression(tableau),
          if (tableau.tachesEnRetard.isNotEmpty) ...[
            const SizedBox(height: 24),
            _construireTitreSection(
              'En retard',
              Icons.warning_amber_rounded,
              Theme.of(context).colorScheme.error,
            ),
            ...tableau.tachesEnRetard.map(_construireTache),
          ],
          const SizedBox(height: 24),
          _construireTitreSection(
            'Prochaines échéances',
            Icons.event_outlined,
            Theme.of(context).colorScheme.primary,
          ),
          if (tableau.prochainesEcheances.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Aucune échéance à venir.'),
            )
          else
            ...tableau.prochainesEcheances.map(_construireTache),
          if (widget.onVoirTaches != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: widget.onVoirTaches,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Voir toutes les tâches'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _construireSalutation() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, etat) {
        final prenom = etat is AuthAuthentifie ? etat.utilisateur.prenom : '';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              prenom.isEmpty ? 'Bonjour' : 'Bonjour, $prenom',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 4),
            Text(
              "Voici l'état de vos devoirs et révisions.",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        );
      },
    );
  }

  Widget _construireIndicateurs(TableauBord tableau) {
    final couleurs = Theme.of(context).colorScheme;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CarteIndicateur(
                libelle: 'À faire',
                valeur: tableau.aFaire,
                icone: Icons.radio_button_unchecked,
                couleur: couleurs.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CarteIndicateur(
                libelle: 'En cours',
                valeur: tableau.enCours,
                icone: Icons.timelapse,
                couleur: Colors.orange.shade800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CarteIndicateur(
                libelle: 'Terminées',
                valeur: tableau.terminees,
                icone: Icons.check_circle_outline,
                couleur: Colors.green.shade700,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CarteIndicateur(
                libelle: 'En retard',
                valeur: tableau.enRetard,
                icone: Icons.warning_amber_rounded,
                couleur: couleurs.error,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _construireProgression(TableauBord tableau) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Progression',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Text('${tableau.terminees}/${tableau.total} · ${tableau.pourcentageAchevement} %'),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: tableau.tauxAchevement,
                minHeight: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construireTitreSection(String texte, IconData icone, Color couleur) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icone, size: 20, color: couleur),
          const SizedBox(width: 8),
          Text(
            texte,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: couleur,
            ),
          ),
        ],
      ),
    );
  }

  Widget _construireTache(Tache tache) {
    return CarteTache(
      tache: tache,
      marge: const EdgeInsets.symmetric(vertical: 4),
      onTap: () => ouvrirEditionTache(context, tache: tache),
    );
  }
}
