import 'package:equatable/equatable.dart';

class Matiere extends Equatable {
  final int id;
  final String nom;
  final String? description;
  final DateTime? dateCreation;

  const Matiere({
    required this.id,
    required this.nom,
    this.description,
    this.dateCreation,
  });

  String get initiale => nom.isEmpty ? '?' : nom[0].toUpperCase();

  bool get aUneDescription => description != null && description!.isNotEmpty;

  factory Matiere.depuisJson(Map<String, dynamic> json) {
    return Matiere(
      id: _lireEntier(json['id']) ?? 0,
      nom: _lireTexte(json['nom']) ?? 'Sans nom',
      description: _lireTexte(json['description']),
      dateCreation: _lireDate(json['dateCreation']),
    );
  }

  Map<String, dynamic> versJson() {
    return {
      'nom': nom,
      'description': description,
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
  List<Object?> get props => [id, nom, description, dateCreation];

  @override
  String toString() => 'Matiere($id, $nom)';
}
