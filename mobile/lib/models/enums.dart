enum Priorite {
  basse('BASSE', 'Basse'),
  moyenne('MOYENNE', 'Moyenne'),
  haute('HAUTE', 'Haute');

  final String code;
  final String libelle;

  const Priorite(this.code, this.libelle);

  static Priorite depuisJson(Object? valeur) {
    if (valeur is! String) return Priorite.moyenne;

    for (final priorite in Priorite.values) {
      if (priorite.code == valeur) return priorite;
    }

    return Priorite.moyenne;
  }
}

enum StatutTache {
  aFaire('A_FAIRE', 'À faire'),
  enCours('EN_COURS', 'En cours'),
  terminee('TERMINEE', 'Terminée');

  final String code;
  final String libelle;

  const StatutTache(this.code, this.libelle);

  bool get estTerminee => this == StatutTache.terminee;

  static StatutTache depuisJson(Object? valeur) {
    if (valeur is! String) return StatutTache.aFaire;

    for (final statut in StatutTache.values) {
      if (statut.code == valeur) return statut;
    }

    return StatutTache.aFaire;
  }
}

enum Role {
  etudiant('ETUDIANT', 'Étudiant');

  final String code;
  final String libelle;

  const Role(this.code, this.libelle);

  static Role depuisJson(Object? valeur) {
    if (valeur is! String) return Role.etudiant;

    for (final role in Role.values) {
      if (role.code == valeur) return role;
    }

    return Role.etudiant;
  }
}
