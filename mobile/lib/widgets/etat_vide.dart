import 'package:flutter/material.dart';

class EtatVide extends StatelessWidget {
  final IconData icone;
  final String titre;
  final String message;

  const EtatVide({
    super.key,
    required this.icone,
    required this.titre,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final couleurs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: couleurs.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(icone, size: 44, color: couleurs.onPrimaryContainer),
            ),
            const SizedBox(height: 24),
            Text(
              titre,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
