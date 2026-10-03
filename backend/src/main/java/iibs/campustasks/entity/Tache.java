package iibs.campustasks.entity;

import iibs.campustasks.entity.enums.*;
import jakarta.persistence.*;
import lombok.*;

import java.time.*;
import java.util.*;

@Entity
@Table(
        name = "taches",
        indexes = {
                @Index(name = "idx_tache_proprietaire_statut", columnList = "proprietaire_id, statut"),
                @Index(name = "idx_tache_proprietaire_date_limite", columnList = "proprietaire_id, date_limite")
        }
)
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Tache extends Auditable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 150)
    private String titre;

    @Column(length = 2000)
    private String description;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "matiere_id", nullable = false)
    private Matiere matiere;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "proprietaire_id", nullable = false)
    private Utilisateur proprietaire;

    @Column(name = "date_limite", nullable = false)
    private LocalDate dateLimite;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private Priorite priorite = Priorite.MOYENNE;

    @Enumerated(EnumType.STRING)
    @Column(name = "statut", nullable = false, length = 20)
    private StatutTache statut = StatutTache.A_FAIRE;

    private Tache(
            String titre,
            String description,
            Matiere matiere,
            LocalDate dateLimite,
            Priorite priorite,
            Utilisateur proprietaire
    ) {
        this.titre = titre;
        this.description = description;
        this.matiere = matiere;
        this.dateLimite = dateLimite;
        this.priorite = priorite;
        this.proprietaire = proprietaire;
        this.statut = StatutTache.A_FAIRE;
    }

    public static Tache planifier(
            String titre,
            String description,
            Matiere matiere,
            LocalDate dateLimite,
            Priorite priorite,
            Utilisateur proprietaire
    ) {
        Objects.requireNonNull(titre, "Le titre est obligatoire");
        Objects.requireNonNull(matiere, "La matiere est obligatoire");
        Objects.requireNonNull(dateLimite, "La date limite est obligatoire");
        Objects.requireNonNull(proprietaire, "Le proprietaire est obligatoire");

        verifierMatiere(matiere, proprietaire);

        return new Tache(
                titre.trim(),
                normaliserTexte(description),
                matiere,
                dateLimite,
                priorite == null ? Priorite.MOYENNE : priorite,
                proprietaire
        );
    }

    public void modifier(
            String titre,
            String description,
            Matiere matiere,
            LocalDate dateLimite,
            Priorite priorite
    ) {
        Objects.requireNonNull(titre, "Le titre est obligatoire");
        Objects.requireNonNull(matiere, "La matiere est obligatoire");
        Objects.requireNonNull(dateLimite, "La date limite est obligatoire");

        verifierMatiere(matiere, proprietaire);

        this.titre = titre.trim();
        this.description = normaliserTexte(description);
        this.matiere = matiere;
        this.dateLimite = dateLimite;
        this.priorite = priorite == null ? Priorite.MOYENNE : priorite;
    }

    public void remettreAFaire() {
        if (statut == StatutTache.A_FAIRE) {
            throw new IllegalStateException("La tache est deja a faire");
        }
        this.statut = StatutTache.A_FAIRE;
    }

    public void demarrer() {
        if (statut == StatutTache.EN_COURS) {
            throw new IllegalStateException("La tache est deja en cours");
        }
        this.statut = StatutTache.EN_COURS;
    }

    public void terminer() {
        if (statut == StatutTache.TERMINEE) {
            throw new IllegalStateException("La tache est deja terminee");
        }
        this.statut = StatutTache.TERMINEE;
    }

    public void changerStatut(StatutTache nouveau) {
        Objects.requireNonNull(nouveau, "Le statut est obligatoire");

        switch (nouveau) {
            case A_FAIRE -> remettreAFaire();
            case EN_COURS -> demarrer();
            case TERMINEE -> terminer();
        }
    }

    public boolean estTerminee() {
        return statut != null && statut.estTerminee();
    }

    public boolean estEnRetard(LocalDate reference) {
        return !estTerminee()
                && dateLimite != null
                && reference != null
                && dateLimite.isBefore(reference);
    }

    public boolean estEnRetard() {
        return estEnRetard(LocalDate.now());
    }

    public boolean appartientA(Utilisateur utilisateur) {
        return utilisateur != null
                && proprietaire != null
                && Objects.equals(proprietaire.getId(), utilisateur.getId());
    }

    private static void verifierMatiere(Matiere matiere, Utilisateur proprietaire) {
        if (!matiere.appartientA(proprietaire)) {
            throw new IllegalStateException("La matiere n'appartient pas au proprietaire de la tache");
        }
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
        return "Tache(%d, %s)".formatted(id, titre);
    }
}
