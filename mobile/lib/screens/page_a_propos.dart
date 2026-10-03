import 'package:flutter/material.dart';

import '../core/configuration.dart';
import '../widgets/barre_retour.dart';

class PageAPropos extends StatelessWidget {
  const PageAPropos({super.key});

  static const String _description =
      "Application de gestion des tâches étudiantes connectée à une API "
      "Spring Boot : matières, devoirs, échéances et tableau de bord.";

  static const List<_PointTechnique> _points = [
    _PointTechnique(
      Icons.architecture,
      'Architecture en couches',
      'Dépôts, blocs, écrans et widgets séparés',
    ),
    _PointTechnique(
      Icons.hub_outlined,
      'Gestion d\'état réactive',
      'BLoC pour la logique métier et l\'état de l\'interface',
    ),
    _PointTechnique(
      Icons.cloud_outlined,
      'API REST sécurisée',
      'Spring Boot, PostgreSQL et Docker',
    ),
    _PointTechnique(
      Icons.security_outlined,
      'Authentification',
      'Jetons JWT stockés de façon sécurisée, renouvelés automatiquement',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final couleurs = Theme.of(context).colorScheme;
    final textes = Theme.of(context).textTheme;

    return Scaffold(
      appBar: const BarreRetour(titre: 'À propos'),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: couleurs.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.task_alt,
                    size: 44,
                    color: couleurs.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 16),
                Text('CampusTasks', style: textes.headlineSmall),
                const SizedBox(height: 4),
                Text('Version ${Configuration.version}', style: textes.bodySmall),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            _description,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, height: 1.5),
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          ..._points.map((point) => _construirePoint(context, point)),
        ],
      ),
    );
  }

  Widget _construirePoint(BuildContext context, _PointTechnique point) {
    final couleurs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(point.icone, size: 22, color: couleurs.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  point.titre,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(point.detail, style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PointTechnique {
  final IconData icone;
  final String titre;
  final String detail;

  const _PointTechnique(this.icone, this.titre, this.detail);
}
