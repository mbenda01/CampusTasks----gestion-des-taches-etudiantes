package iibs.campustasks.entity;

import jakarta.persistence.*;
import lombok.*;

import java.util.*;

@Entity
@Table(
        name = "matieres",
        uniqueConstraints = @UniqueConstraint(
                name = "uk_matiere_proprietaire_nom",
                columnNames = {"proprietaire_id", "nom"}
        )
)
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Matiere extends Auditable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "nom", nullable = false, length = 100)
    private String nom;

    @Column(length = 500)
    private String description;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "proprietaire_id", nullable = false)
    private Utilisateur proprietaire;

    private Matiere(String nom, String description, Utilisateur proprietaire) {
        this.nom = nom;
        this.description = description;
        this.proprietaire = proprietaire;
    }

    public static Matiere creer(String nom, String description, Utilisateur proprietaire) {
        Objects.requireNonNull(nom, "Le nom est obligatoire");
        Objects.requireNonNull(proprietaire, "Le proprietaire est obligatoire");

        return new Matiere(nom.trim(), normaliserTexte(description), proprietaire);
    }

    public void modifier(String nom, String description) {
        Objects.requireNonNull(nom, "Le nom est obligatoire");

        this.nom = nom.trim();
        this.description = normaliserTexte(description);
    }

    public boolean appartientA(Utilisateur utilisateur) {
        return utilisateur != null
                && proprietaire != null
                && Objects.equals(proprietaire.getId(), utilisateur.getId());
    }

    private static String normaliserTexte(String texte) {
        if (texte == null) {
            return null;
        }
        String nettoye = texte.trim();
        return nettoye.isEmpty() ? null : nettoye;
    }

    @Override
    public String toString() {
        return "Matiere(%d, %s)".formatted(id, nom);
    }
}
