import 'package:flutter/material.dart';

class EtatErreur extends StatelessWidget {
  final String message;
  final VoidCallback onReessayer;

  const EtatErreur({
    super.key,
    required this.message,
    required this.onReessayer,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onReessayer,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}
