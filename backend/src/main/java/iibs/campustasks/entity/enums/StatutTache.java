package iibs.campustasks.entity.enums;

public enum StatutTache {

    A_FAIRE("À faire"),
    EN_COURS("En cours"),
    TERMINEE("Terminée");

    private final String libelle;

    StatutTache(String libelle) {
        this.libelle = libelle;
    }

    public String getLibelle() {
        return libelle;
    }

    public boolean estTerminee() {
        return this == TERMINEE;
    }
}
