import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/matieres/matieres_bloc.dart';
import '../blocs/matieres/matieres_state.dart';
import '../blocs/taches/taches_bloc.dart';
import '../blocs/taches/taches_event.dart';
import '../blocs/taches/taches_state.dart';
import '../models/enums.dart';
import '../models/matiere.dart';
import '../models/tache.dart';
import '../routes/navigation.dart';
import '../widgets/carte_tache.dart';
import '../widgets/etat_erreur.dart';
import '../widgets/etat_vide.dart';

class PageTaches extends StatefulWidget {
  const PageTaches({super.key});

  @override
  State<PageTaches> createState() => _PageTachesState();
}

class _PageTachesState extends State<PageTaches> {
  late final ScrollController _controleurDefilement;

  @override
  void initState() {
    super.initState();

    final bloc = context.read<TachesBloc>();
    if (bloc.state is TachesInitial || bloc.state is TachesEchec) {
      bloc.add(const TachesChargementDemande());
    }

    _controleurDefilement = ScrollController()..addListener(_surDefilement);
  }

  @override
  void dispose() {
    _controleurDefilement.removeListener(_surDefilement);
    _controleurDefilement.dispose();
    super.dispose();
  }

  void _surDefilement() {
    final position = _controleurDefilement.position;
    final seuil = position.maxScrollExtent - 200;

    if (position.pixels < seuil) {
      return;
    }

    context.read<TachesBloc>().add(const TachesPageSuivanteDemandee());
  }

  void _basculerTerminee(Tache tache) {
    final nouveau =
        tache.estTerminee ? StatutTache.aFaire : StatutTache.terminee;
    context.read<TachesBloc>().add(TacheStatutChange(tache.id, nouveau));
  }

  Future<void> _confirmerSuppression(Tache tache) async {
    final bloc = context.read<TachesBloc>();

    final confirme = await showDialog<bool>(
      context: context,
      builder: (contexteDialogue) => AlertDialog(
        title: const Text('Supprimer cette tâche ?'),
        content: Text('« ${tache.titre} » sera définitivement supprimée.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(contexteDialogue, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(contexteDialogue, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirme == true) {
      bloc.add(TacheSupprimee(tache.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TachesBloc, TachesState>(
      listenWhen: (avant, apres) =>
          apres is TachesChargees && apres.messageAction != null,
      listener: _afficherMessage,
      child: Column(
        children: [
          _construireFiltres(),
          Expanded(
            child: BlocBuilder<TachesBloc, TachesState>(
              builder: (context, etat) {
                return switch (etat) {
                  TachesInitial() || TachesEnChargement() =>
                    const Center(child: CircularProgressIndicator()),
                  TachesEchec() => EtatErreur(
                      message: etat.message,
                      onReessayer: () => context
                          .read<TachesBloc>()
                          .add(const TachesChargementDemande()),
                    ),
                  TachesChargees() => etat.estVide
                      ? _construireVide(etat)
                      : _construireListe(etat),
                };
              },
            ),
          ),
        ],
      ),
    );
  }

  void _afficherMessage(BuildContext context, TachesState etat) {
    if (etat is! TachesChargees || etat.messageAction == null) return;

    final couleurs = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(etat.messageAction!),
          backgroundColor: etat.messageEstErreur ? couleurs.error : null,
        ),
      );
  }

  Widget _construireFiltres() {
    return BlocBuilder<TachesBloc, TachesState>(
      builder: (context, etat) {
        final bloc = context.read<TachesBloc>();

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _construirePuceStatut(bloc, null, 'Toutes'),
                    for (final statut in StatutTache.values)
                      _construirePuceStatut(bloc, statut, statut.libelle),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _construireSelecteurMatiere(bloc),
            ],
          ),
        );
      },
    );
  }

  Widget _construirePuceStatut(
    TachesBloc bloc,
    StatutTache? statut,
    String libelle,
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(libelle),
        selected: bloc.statutFiltre == statut,
        onSelected: (_) => bloc.add(TachesFiltreChange(
          matiereId: bloc.matiereIdFiltre,
          statut: statut,
        )),
      ),
    );
  }

  Widget _construireSelecteurMatiere(TachesBloc bloc) {
    return BlocBuilder<MatieresBloc, MatieresState>(
      builder: (context, etatMatieres) {
        final matieres = etatMatieres is MatieresChargees
            ? etatMatieres.matieres
            : const <Matiere>[];

        final selection = matieres.any((m) => m.id == bloc.matiereIdFiltre)
            ? bloc.matiereIdFiltre
            : null;

        return DropdownButtonFormField<int?>(
          key: ValueKey('filtre-matiere-$selection-${matieres.length}'),
          initialValue: selection,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Matière',
            prefixIcon: Icon(Icons.menu_book_outlined),
            isDense: true,
            border: OutlineInputBorder(),
          ),
          items: [
            const DropdownMenuItem<int?>(
              value: null,
              child: Text('Toutes les matières'),
            ),
            ...matieres.map(
              (matiere) => DropdownMenuItem<int?>(
                value: matiere.id,
                child: Text(matiere.nom, overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
          onChanged: (valeur) => bloc.add(TachesFiltreChange(
            matiereId: valeur,
            statut: bloc.statutFiltre,
          )),
        );
      },
    );
  }

  Widget _construireVide(TachesChargees etat) {
    if (etat.estFiltre) {
      return const EtatVide(
        icone: Icons.filter_alt_off_outlined,
        titre: 'Aucune tâche pour ces filtres',
        message: 'Modifiez le statut ou la matière sélectionnés.',
      );
    }

    return const EtatVide(
      icone: Icons.checklist,
      titre: 'Aucune tâche',
      message: 'Ajoutez votre première tâche avec le bouton « Tâche ».',
    );
  }

  Widget _construireListe(TachesChargees etat) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<TachesBloc>().add(const TachesRafraichissementDemande());
      },
      child: ListView.builder(
        controller: _controleurDefilement,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 4, bottom: 96),
        itemCount: etat.taches.length + (etat.chargementPageSuivante ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= etat.taches.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final tache = etat.taches[index];

          return CarteTache(
            tache: tache,
            enCours: etat.actionEnCoursSurId == tache.id,
            onTap: () => ouvrirEditionTache(context, tache: tache),
            onBasculerTerminee: () => _basculerTerminee(tache),
            actions: _construireMenu(tache),
          );
        },
      ),
    );
  }

  Widget _construireMenu(Tache tache) {
    final couleurs = Theme.of(context).colorScheme;

    return PopupMenuButton<String>(
      tooltip: 'Actions',
      onSelected: (choix) {
        if (choix == 'supprimer') {
          _confirmerSuppression(tache);
          return;
        }

        final statut = StatutTache.depuisJson(choix);
        context.read<TachesBloc>().add(TacheStatutChange(tache.id, statut));
      },
      itemBuilder: (context) => [
        for (final statut in StatutTache.values)
          if (statut != tache.statut)
            PopupMenuItem(
              value: statut.code,
              child: Text('Passer à « ${statut.libelle} »'),
            ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'supprimer',
          child: Text('Supprimer', style: TextStyle(color: couleurs.error)),
        ),
      ],
    );
  }
}
