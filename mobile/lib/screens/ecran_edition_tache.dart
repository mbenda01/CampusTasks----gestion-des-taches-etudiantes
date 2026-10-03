import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/matieres/matieres_bloc.dart';
import '../blocs/matieres/matieres_state.dart';
import '../core/erreur_api.dart';
import '../models/enums.dart';
import '../models/matiere.dart';
import '../models/tache.dart';
import '../repositories/tache_repository.dart';
import '../widgets/barre_retour.dart';

class EcranEditionTache extends StatefulWidget {
  final Tache? tache;

  const EcranEditionTache({super.key, this.tache});

  @override
  State<EcranEditionTache> createState() => _EcranEditionTacheState();
}

class _EcranEditionTacheState extends State<EcranEditionTache> {
  final _formulaireCle = GlobalKey<FormState>();

  late final TextEditingController _controleurTitre;
  late final TextEditingController _controleurDescription;

  int? _matiereId;
  DateTime? _dateLimite;
  late Priorite _priorite;
  late StatutTache _statut;

  bool _enregistrementEnCours = false;
  String? _messageErreur;
  Map<String, String> _erreursChamps = const {};

  bool get _enModification => widget.tache != null;

  @override
  void initState() {
    super.initState();

    final tache = widget.tache;

    _controleurTitre = TextEditingController(text: tache?.titre ?? '');
    _controleurDescription = TextEditingController(text: tache?.description ?? '');
    _matiereId = tache?.matiereId;
    _dateLimite = tache?.dateLimite;
    _priorite = tache?.priorite ?? Priorite.moyenne;
    _statut = tache?.statut ?? StatutTache.aFaire;
  }

  @override
  void dispose() {
    _controleurTitre.dispose();
    _controleurDescription.dispose();
    super.dispose();
  }

  Future<void> _choisirDate() async {
    final maintenant = DateTime.now();
    final aujourdHui = DateTime(maintenant.year, maintenant.month, maintenant.day);
    final premiereDate = _enModification ? DateTime(2000) : aujourdHui;

    var initiale = _dateLimite ?? aujourdHui;
    if (initiale.isBefore(premiereDate)) {
      initiale = premiereDate;
    }

    final choisie = await showDatePicker(
      context: context,
      initialDate: initiale,
      firstDate: premiereDate,
      lastDate: DateTime(maintenant.year + 5),
      helpText: 'Date limite',
    );

    if (choisie != null && mounted) {
      setState(() => _dateLimite = choisie);
    }
  }

  Future<void> _enregistrer() async {
    if (!_formulaireCle.currentState!.validate()) return;

    final depot = context.read<TacheRepository>();
    final description = _controleurDescription.text.trim();

    final tache = Tache(
      id: widget.tache?.id ?? 0,
      titre: _controleurTitre.text.trim(),
      description: description.isEmpty ? null : description,
      matiereId: _matiereId!,
      dateLimite: _dateLimite!,
      priorite: _priorite,
      statut: _statut,
    );

    setState(() {
      _enregistrementEnCours = true;
      _messageErreur = null;
      _erreursChamps = const {};
    });

    try {
      if (_enModification) {
        await depot.modifier(widget.tache!.id, tache);
      } else {
        await depot.creer(tache);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } on ErreurValidation catch (erreur) {
      if (!mounted) return;
      setState(() {
        _enregistrementEnCours = false;
        _messageErreur = erreur.message;
        _erreursChamps = erreur.champs;
      });
    } on ErreurApi catch (erreur) {
      if (!mounted) return;
      setState(() {
        _enregistrementEnCours = false;
        _messageErreur = erreur.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BarreRetour(
        titre: _enModification ? 'Modifier la tâche' : 'Nouvelle tâche',
      ),
      body: Form(
        key: _formulaireCle,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _controleurTitre,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Titre',
                hintText: 'Ex. Rendre le TP Spring Security',
                prefixIcon: const Icon(Icons.title),
                errorText: _erreursChamps['titre'],
              ),
              validator: (valeur) {
                if (valeur == null || valeur.trim().length < 3) {
                  return 'Le titre doit contenir au moins 3 caractères';
                }
                if (valeur.trim().length > 150) {
                  return 'Le titre ne doit pas dépasser 150 caractères';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _controleurDescription,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Description (facultative)',
                alignLabelWithHint: true,
                prefixIcon: const Icon(Icons.notes_outlined),
                errorText: _erreursChamps['description'],
              ),
            ),
            const SizedBox(height: 16),
            _construireSelecteurMatiere(),
            const SizedBox(height: 16),
            _construireChampDate(),
            const SizedBox(height: 24),
            const Text('Priorité', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            SegmentedButton<Priorite>(
              segments: Priorite.values
                  .map((priorite) => ButtonSegment<Priorite>(
                        value: priorite,
                        label: Text(priorite.libelle),
                      ))
                  .toList(),
              selected: {_priorite},
              onSelectionChanged: (selection) {
                setState(() => _priorite = selection.first);
              },
            ),
            if (_enModification) ...[
              const SizedBox(height: 24),
              const Text('Statut', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              SegmentedButton<StatutTache>(
                segments: StatutTache.values
                    .map((statut) => ButtonSegment<StatutTache>(
                          value: statut,
                          label: Text(statut.libelle),
                        ))
                    .toList(),
                selected: {_statut},
                onSelectionChanged: (selection) {
                  setState(() => _statut = selection.first);
                },
              ),
            ],
            if (_messageErreur != null) ...[
              const SizedBox(height: 16),
              Text(
                _messageErreur!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _enregistrementEnCours ? null : _enregistrer,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _enregistrementEnCours
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_enModification ? 'Enregistrer' : 'Créer la tâche'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construireSelecteurMatiere() {
    return BlocBuilder<MatieresBloc, MatieresState>(
      builder: (context, etat) {
        if (etat is! MatieresChargees) {
          return const LinearProgressIndicator();
        }

        final matieres = etat.matieres;

        if (matieres.isEmpty) {
          return Text(
            "Créez d'abord une matière avant d'ajouter une tâche.",
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          );
        }

        final selection =
            matieres.any((m) => m.id == _matiereId) ? _matiereId : null;

        return DropdownButtonFormField<int>(
          key: ValueKey('matiere-${matieres.length}'),
          initialValue: selection,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Matière',
            prefixIcon: const Icon(Icons.menu_book_outlined),
            errorText: _erreursChamps['matiereId'],
          ),
          items: matieres
              .map((Matiere matiere) => DropdownMenuItem<int>(
                    value: matiere.id,
                    child: Text(matiere.nom, overflow: TextOverflow.ellipsis),
                  ))
              .toList(),
          onChanged: (valeur) => setState(() => _matiereId = valeur),
          validator: (valeur) => valeur == null ? 'Choisissez une matière' : null,
        );
      },
    );
  }

  Widget _construireChampDate() {
    return FormField<DateTime>(
      validator: (_) =>
          _dateLimite == null ? 'La date limite est obligatoire' : null,
      builder: (etatChamp) {
        return InkWell(
          onTap: _choisirDate,
          borderRadius: BorderRadius.circular(4),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Date limite',
              prefixIcon: const Icon(Icons.event_outlined),
              errorText: etatChamp.errorText ?? _erreursChamps['dateLimite'],
            ),
            child: Text(
              _dateLimite == null
                  ? 'Choisir une date'
                  : Tache.formaterDate(_dateLimite!),
            ),
          ),
        );
      },
    );
  }
}
