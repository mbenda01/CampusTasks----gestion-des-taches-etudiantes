package iibs.campustasks.entity;

import iibs.campustasks.entity.enums.*;
import jakarta.persistence.*;
import lombok.*;

import java.util.*;

@Entity
@Table(name = "utilisateurs")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Utilisateur extends Auditable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 100)
    private String nom;

    @Column(nullable = false, unique = true, length = 150)
    private String email;

    @Column(nullable = false)
    private String motDePasse;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private Role role = Role.ETUDIANT;

    @Column(nullable = false)
    private boolean actif = true;

    private Utilisateur(String nom, String email, String empreinteMotDePasse, Role role) {
        this.nom = nom;
        this.email = email;
        this.motDePasse = empreinteMotDePasse;
        this.role = role;
        this.actif = true;
    }

    public static Utilisateur inscrire(
            String nom,
            String email,
            String empreinteMotDePasse
    ) {
        Objects.requireNonNull(nom, "Le nom est obligatoire");
        Objects.requireNonNull(email, "L'email est obligatoire");
        Objects.requireNonNull(empreinteMotDePasse, "Le mot de passe est obligatoire");

        return new Utilisateur(
                nom.trim(),
                normaliserEmail(email),
                empreinteMotDePasse,
                Role.ETUDIANT
        );
    }

    public static String normaliserEmail(String email) {
        return email == null ? null : email.trim().toLowerCase();
    }

    public void renommer(String nouveauNom) {
        Objects.requireNonNull(nouveauNom, "Le nom est obligatoire");
        this.nom = nouveauNom.trim();
    }

    public void changerMotDePasse(String nouvelleEmpreinte) {
        Objects.requireNonNull(nouvelleEmpreinte, "Le mot de passe est obligatoire");
        this.motDePasse = nouvelleEmpreinte;
    }

    public void desactiver() {
        if (!actif) {
            throw new IllegalStateException("Le compte est deja desactive");
        }
        this.actif = false;
    }

    public void reactiver() {
        if (actif) {
            throw new IllegalStateException("Le compte est deja actif");
        }
        this.actif = true;
    }

    public boolean peutSeConnecter() {
        return actif;
    }

    @Override
    public String toString() {
        return "Utilisateur(%d, %s)".formatted(id, role);
    }
}
