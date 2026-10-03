package iibs.campustasks.entity.enums;

public enum Role {

    ETUDIANT("Étudiant");

    private final String libelle;

    Role(String libelle) {
        this.libelle = libelle;
    }

    public String getLibelle() {
        return libelle;
    }

    public String autorite() {
        return "ROLE_" + name();
    }
}
