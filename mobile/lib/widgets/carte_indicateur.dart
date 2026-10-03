import 'package:flutter/material.dart';

class CarteIndicateur extends StatelessWidget {
  final String libelle;
  final int valeur;
  final IconData icone;
  final Color couleur;

  const CarteIndicateur({
    super.key,
    required this.libelle,
    required this.valeur,
    required this.icone,
    required this.couleur,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: couleur.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icone, color: couleur, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              '$valeur',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            Text(libelle, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
