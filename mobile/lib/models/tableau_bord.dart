import 'tache.dart';

class TableauBord {
  final int aFaire;
  final int enCours;
  final int terminees;
  final int total;
  final int enRetard;
  final List<Tache> prochainesEcheances;
  final List<Tache> tachesEnRetard;

  const TableauBord({
    required this.aFaire,
    required this.enCours,
    required this.terminees,
    required this.total,
    required this.enRetard,
    this.prochainesEcheances = const [],
    this.tachesEnRetard = const [],
  });

  double get tauxAchevement => total == 0 ? 0 : terminees / total;

  int get pourcentageAchevement => (tauxAchevement * 100).round();

  factory TableauBord.depuisJson(Map<String, dynamic> json) {
    return TableauBord(
      aFaire: _lireEntier(json['aFaire']) ?? 0,
      enCours: _lireEntier(json['enCours']) ?? 0,
      terminees: _lireEntier(json['terminees']) ?? 0,
      total: _lireEntier(json['total']) ?? 0,
      enRetard: _lireEntier(json['enRetard']) ?? 0,
      prochainesEcheances: _lireTaches(json['prochainesEcheances']),
      tachesEnRetard: _lireTaches(json['tachesEnRetard']),
    );
  }

  static List<Tache> _lireTaches(Object? valeur) {
    if (valeur is! List) return const [];

    final taches = <Tache>[];
    for (final element in valeur) {
      if (element is Map<String, dynamic>) {
        taches.add(Tache.depuisJson(element));
      }
    }
    return List.unmodifiable(taches);
  }

  static int? _lireEntier(Object? valeur) {
    if (valeur is int) return valeur;
    if (valeur is num) return valeur.toInt();
    if (valeur is String) return int.tryParse(valeur);
    return null;
  }
}
