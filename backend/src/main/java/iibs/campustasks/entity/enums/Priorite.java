package iibs.campustasks.entity.enums;

public enum Priorite {

    BASSE("Basse"),
    MOYENNE("Moyenne"),
    HAUTE("Haute");

    private final String libelle;

    Priorite(String libelle) {
        this.libelle = libelle;
    }

    public String getLibelle() {
        return libelle;
    }
}
