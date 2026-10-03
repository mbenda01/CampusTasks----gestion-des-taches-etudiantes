import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/erreur_api.dart';
import '../models/matiere.dart';
import '../repositories/matiere_repository.dart';
import '../widgets/barre_retour.dart';

class EcranEditionMatiere extends StatefulWidget {
  final Matiere? matiere;

  const EcranEditionMatiere({super.key, this.matiere});

  @override
  State<EcranEditionMatiere> createState() => _EcranEditionMatiereState();
}

class _EcranEditionMatiereState extends State<EcranEditionMatiere> {
  final _formulaireCle = GlobalKey<FormState>();

  late final TextEditingController _controleurNom;
  late final TextEditingController _controleurDescription;

  bool _enregistrementEnCours = false;
  String? _messageErreur;
  Map<String, String> _erreursChamps = const {};

  bool get _enModification => widget.matiere != null;

  @override
  void initState() {
    super.initState();
    _controleurNom = TextEditingController(text: widget.matiere?.nom ?? '');
    _controleurDescription =
        TextEditingController(text: widget.matiere?.description ?? '');
  }

  @override
  void dispose() {
    _controleurNom.dispose();
    _controleurDescription.dispose();
    super.dispose();
  }

  Future<void> _enregistrer() async {
    if (!_formulaireCle.currentState!.validate()) return;

    final depot = context.read<MatiereRepository>();
    final description = _controleurDescription.text.trim();

    final matiere = Matiere(
      id: widget.matiere?.id ?? 0,
      nom: _controleurNom.text.trim(),
      description: description.isEmpty ? null : description,
    );

    setState(() {
      _enregistrementEnCours = true;
      _messageErreur = null;
      _erreursChamps = const {};
    });

    try {
      if (_enModification) {
        await depot.modifier(widget.matiere!.id, matiere);
      } else {
        await depot.creer(matiere);
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
        titre: _enModification ? 'Modifier la matière' : 'Nouvelle matière',
      ),
      body: Form(
        key: _formulaireCle,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _controleurNom,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'Nom de la matière',
                hintText: 'Ex. Programmation Java',
                prefixIcon: const Icon(Icons.menu_book_outlined),
                errorText: _erreursChamps['nom'],
              ),
              validator: (valeur) {
                if (valeur == null || valeur.trim().length < 2) {
                  return 'Le nom doit contenir au moins 2 caractères';
                }
                if (valeur.trim().length > 100) {
                  return 'Le nom ne doit pas dépasser 100 caractères';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _controleurDescription,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description (facultative)',
                alignLabelWithHint: true,
                prefixIcon: const Icon(Icons.notes_outlined),
                errorText: _erreursChamps['description'],
              ),
              validator: (valeur) {
                if (valeur != null && valeur.trim().length > 500) {
                  return 'La description ne doit pas dépasser 500 caractères';
                }
                return null;
              },
            ),
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
                  : Text(_enModification ? 'Enregistrer' : 'Ajouter'),
            ),
          ],
        ),
      ),
    );
  }
}
