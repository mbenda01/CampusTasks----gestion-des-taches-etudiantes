import 'package:equatable/equatable.dart';

import 'enums.dart';

class Tache extends Equatable {
  static const List<String> _mois = [
    'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
    'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.',
  ];

  final int id;
  final String titre;
  final String? description;
  final int matiereId;
  final String? matiereNom;
  final DateTime dateLimite;
  final Priorite priorite;
  final StatutTache statut;
  final bool enRetard;
  final DateTime? dateCreation;

  const Tache({
    required this.id,
    required this.titre,
    this.description,
    required this.matiereId,
    this.matiereNom,
    required this.dateLimite,
    this.priorite = Priorite.moyenne,
    this.statut = StatutTache.aFaire,
    this.enRetard = false,
    this.dateCreation,
  });

  bool get estTerminee => statut.estTerminee;

  bool get aUneDescription => description != null && description!.isNotEmpty;

  String get dateLimiteFormatee => formaterDate(dateLimite);

  int get joursRestants {
    final maintenant = DateTime.now();
    final aujourdHui = DateTime(maintenant.year, maintenant.month, maintenant.day);
    final echeance = DateTime(dateLimite.year, dateLimite.month, dateLimite.day);
    return echeance.difference(aujourdHui).inDays;
  }

  String get echeanceRelative {
    if (estTerminee) return 'Terminée';

    final jours = joursRestants;
    if (jours < 0) return 'En retard de ${-jours} j';
    if (jours == 0) return "Aujourd'hui";
    if (jours == 1) return 'Demain';
    return 'Dans $jours jours';
  }

  static String formaterDate(DateTime date) {
    return '${date.day} ${_mois[date.month - 1]} ${date.year}';
  }

  static String formaterDateIso(DateTime date) {
    final annee = date.year.toString().padLeft(4, '0');
    final mois = date.month.toString().padLeft(2, '0');
    final jour = date.day.toString().padLeft(2, '0');
    return '$annee-$mois-$jour';
  }

  factory Tache.depuisJson(Map<String, dynamic> json) {
    return Tache(
      id: _lireEntier(json['id']) ?? 0,
      titre: _lireTexte(json['titre']) ?? 'Sans titre',
      description: _lireTexte(json['description']),
      matiereId: _lireEntier(json['matiereId']) ?? 0,
      matiereNom: _lireTexte(json['matiereNom']),
      dateLimite: _lireDate(json['dateLimite']) ?? DateTime.now(),
      priorite: Priorite.depuisJson(json['priorite']),
      statut: StatutTache.depuisJson(json['statut']),
      enRetard: json['enRetard'] is bool ? json['enRetard'] as bool : false,
      dateCreation: _lireDate(json['dateCreation']),
    );
  }

  Map<String, dynamic> versJsonCreation() {
    return {
      'titre': titre,
      'description': description,
      'matiereId': matiereId,
      'dateLimite': formaterDateIso(dateLimite),
      'priorite': priorite.code,
    };
  }

  Map<String, dynamic> versJsonModification() {
    return {
      ...versJsonCreation(),
      'statut': statut.code,
    };
  }

  static int? _lireEntier(Object? valeur) {
    if (valeur is int) return valeur;
    if (valeur is num) return valeur.toInt();
    if (valeur is String) return int.tryParse(valeur);
    return null;
  }

  static String? _lireTexte(Object? valeur) {
    if (valeur is! String) return null;
    final nettoye = valeur.trim();
    return nettoye.isEmpty ? null : nettoye;
  }

  static DateTime? _lireDate(Object? valeur) {
    if (valeur is! String) return null;
    return DateTime.tryParse(valeur);
  }

  @override
  List<Object?> get props => [
        id,
        titre,
        description,
        matiereId,
        matiereNom,
        dateLimite,
        priorite,
        statut,
        enRetard,
        dateCreation,
      ];

  @override
  String toString() => 'Tache($id, $titre)';
}
