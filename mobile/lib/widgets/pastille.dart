import 'package:flutter/material.dart';

import '../models/enums.dart';

class Pastille extends StatelessWidget {
  final String texte;
  final Color couleur;

  const Pastille({
    super.key,
    required this.texte,
    required this.couleur,
  });

  factory Pastille.statut(StatutTache statut) {
    return Pastille(texte: statut.libelle, couleur: couleurStatut(statut));
  }

  factory Pastille.priorite(Priorite priorite) {
    return Pastille(
      texte: 'Priorité ${priorite.libelle.toLowerCase()}',
      couleur: couleurPriorite(priorite),
    );
  }

  static Color couleurStatut(StatutTache statut) {
    switch (statut) {
      case StatutTache.aFaire:
        return Colors.blueGrey;
      case StatutTache.enCours:
        return Colors.orange.shade800;
      case StatutTache.terminee:
        return Colors.green.shade700;
    }
  }

  static Color couleurPriorite(Priorite priorite) {
    switch (priorite) {
      case Priorite.basse:
        return Colors.teal;
      case Priorite.moyenne:
        return Colors.indigo;
      case Priorite.haute:
        return Colors.red.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: couleur.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        texte,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: couleur,
        ),
      ),
    );
  }
}
