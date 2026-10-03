import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/matieres/matieres_bloc.dart';
import '../blocs/matieres/matieres_event.dart';
import '../blocs/matieres/matieres_state.dart';
import '../models/matiere.dart';
import '../routes/navigation.dart';
import '../widgets/etat_erreur.dart';
import '../widgets/etat_vide.dart';

class PageMatieres extends StatefulWidget {
  final ValueChanged<Matiere>? onOuvrirMatiere;

  const PageMatieres({super.key, this.onOuvrirMatiere});

  @override
  State<PageMatieres> createState() => _PageMatieresState();
}

class _PageMatieresState extends State<PageMatieres> {
  @override
  void initState() {
    super.initState();

    final bloc = context.read<MatieresBloc>();
    if (bloc.state is! MatieresChargees) {
      bloc.add(const MatieresChargementDemande());
    }
  }

  Future<void> _confirmerSuppression(Matiere matiere) async {
    final bloc = context.read<MatieresBloc>();

    final confirme = await showDialog<bool>(
      context: context,
      builder: (contexteDialogue) => AlertDialog(
        title: const Text('Supprimer cette matière ?'),
        content: Text(
          '« ${matiere.nom} » sera supprimée. La suppression est refusée '
          'tant que des tâches y sont rattachées.',
        ),
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
      bloc.add(MatiereSupprimee(matiere.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MatieresBloc, MatieresState>(
      listenWhen: (avant, apres) =>
          apres is MatieresChargees && apres.messageAction != null,
      listener: _afficherMessage,
      builder: (context, etat) {
        return switch (etat) {
          MatieresInitial() || MatieresEnChargement() =>
            const Center(child: CircularProgressIndicator()),
          MatieresEchec() => EtatErreur(
              message: etat.message,
              onReessayer: () => context
                  .read<MatieresBloc>()
                  .add(const MatieresChargementDemande()),
            ),
          MatieresChargees() => etat.estVide
              ? const EtatVide(
                  icone: Icons.menu_book_outlined,
                  titre: 'Aucune matière',
                  message: 'Ajoutez votre première matière avec le bouton « Matière ».',
                )
              : _construireListe(etat),
        };
      },
    );
  }

  void _afficherMessage(BuildContext context, MatieresState etat) {
    if (etat is! MatieresChargees || etat.messageAction == null) return;

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

  Widget _construireListe(MatieresChargees etat) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<MatieresBloc>().add(const MatieresRafraichissementDemande());
      },
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 8, bottom: 96),
        itemCount: etat.matieres.length,
        itemBuilder: (context, index) {
          final matiere = etat.matieres[index];
          final enCours = etat.actionEnCoursSurId == matiere.id;

          return _construireCarte(matiere, enCours);
        },
      ),
    );
  }

  Widget _construireCarte(Matiere matiere, bool enCours) {
    final couleurs = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(16, 8, 4, 8),
        onTap: enCours ? null : () => widget.onOuvrirMatiere?.call(matiere),
        leading: CircleAvatar(
          backgroundColor: couleurs.primaryContainer,
          child: Text(
            matiere.initiale,
            style: TextStyle(
              color: couleurs.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          matiere.nom,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          matiere.aUneDescription ? matiere.description! : 'Toucher pour voir les tâches',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: enCours
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : PopupMenuButton<String>(
                tooltip: 'Actions',
                onSelected: (choix) {
                  switch (choix) {
                    case 'taches':
                      widget.onOuvrirMatiere?.call(matiere);
                    case 'modifier':
                      ouvrirEditionMatiere(context, matiere: matiere);
                    case 'supprimer':
                      _confirmerSuppression(matiere);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'taches', child: Text('Voir les tâches')),
                  const PopupMenuItem(value: 'modifier', child: Text('Modifier')),
                  PopupMenuItem(
                    value: 'supprimer',
                    child: Text('Supprimer', style: TextStyle(color: couleurs.error)),
                  ),
                ],
              ),
      ),
    );
  }
}
