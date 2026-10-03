import 'package:flutter/material.dart';

import '../models/matiere.dart';
import '../models/tache.dart';
import '../screens/ecran_edition_matiere.dart';
import '../screens/ecran_edition_tache.dart';
import '../screens/page_a_propos.dart';
import '../screens/page_reglages.dart';

class Routes {
  const Routes._();

  static const String accueil = '/';
  static const String reglages = '/reglages';
  static const String aPropos = '/a-propos';
  static const String editionTache = '/taches/edition';
  static const String editionMatiere = '/matieres/edition';

  static Map<String, WidgetBuilder> get table => {
        reglages: (context) => const PageReglages(),
        aPropos: (context) => const PageAPropos(),
      };

  static Route<dynamic>? generer(RouteSettings parametres) {
    switch (parametres.name) {
      case editionTache:
        final argument = parametres.arguments;

        return MaterialPageRoute<bool>(
          builder: (context) => EcranEditionTache(
            tache: argument is Tache ? argument : null,
          ),
          settings: parametres,
        );

      case editionMatiere:
        final argument = parametres.arguments;

        return MaterialPageRoute<bool>(
          builder: (context) => EcranEditionMatiere(
            matiere: argument is Matiere ? argument : null,
          ),
          settings: parametres,
        );

      default:
        return null;
    }
  }

  static Route<dynamic> inconnue(RouteSettings parametres) {
    return MaterialPageRoute(
      builder: (context) => _EcranIntrouvable(nomRoute: parametres.name),
    );
  }
}

class _EcranIntrouvable extends StatelessWidget {
  final String? nomRoute;

  const _EcranIntrouvable({this.nomRoute});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page introuvable')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.help_outline, size: 48),
              const SizedBox(height: 16),
              Text(
                nomRoute == null
                    ? "Cette page n'existe pas."
                    : "La route « $nomRoute » est introuvable.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  Routes.accueil,
                  (route) => false,
                ),
                child: const Text("Retour à l'accueil"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
