package iibs.campustasks.entity;

import iibs.campustasks.entity.enums.*;
import iibs.campustasks.faux.*;
import org.junit.jupiter.api.*;

import java.time.*;

import static org.assertj.core.api.Assertions.*;

class TacheTest {

    private static final LocalDate AUJOURD_HUI = LocalDate.of(2026, 10, 3);

    private Utilisateur aminata;
    private Utilisateur moussa;
    private Matiere java;

    @BeforeEach
    void preparer() {
        aminata = DonneesDeTest.aminata();
        moussa = DonneesDeTest.moussa();
        java = DonneesDeTest.matiere(10L, "Programmation Java", aminata);
    }

    @Nested
    class Planification {

        @Test
        void creeLaTacheAFaireAvecUnePrioriteMoyenneParDefaut() {
            Tache tache = Tache.planifier(
                    "Rendre le TP", null, java, AUJOURD_HUI.plusDays(2), null, aminata);

            assertThat(tache.getStatut()).isEqualTo(StatutTache.A_FAIRE);
            assertThat(tache.getPriorite()).isEqualTo(Priorite.MOYENNE);
            assertThat(tache.appartientA(aminata)).isTrue();
        }

        @Test
        void normaliseLeTitreEtLaDescription() {
            Tache tache = Tache.planifier(
                    "  Rendre le TP  ", "   ", java, AUJOURD_HUI, Priorite.HAUTE, aminata);

            assertThat(tache.getTitre()).isEqualTo("Rendre le TP");
            assertThat(tache.getDescription()).isNull();
        }

        @Test
        void refuseUneMatiereDUnAutreEtudiant() {
            assertThatThrownBy(() -> Tache.planifier(
                    "Rendre le TP", null, java, AUJOURD_HUI, Priorite.HAUTE, moussa))
                    .isInstanceOf(IllegalStateException.class);
        }

        @Test
        void exigeUneDateLimite() {
            assertThatThrownBy(() -> Tache.planifier(
                    "Rendre le TP", null, java, null, Priorite.HAUTE, aminata))
                    .isInstanceOf(NullPointerException.class);
        }
    }

    @Nested
    class Retard {

        @Test
        void estEnRetardQuandLaDateLimiteEstDepasseeEtLaTacheNonTerminee() {
            Tache tache = DonneesDeTest.tache(1L, "TP", java, AUJOURD_HUI.minusDays(1), aminata);

            assertThat(tache.estEnRetard(AUJOURD_HUI)).isTrue();
        }

        @Test
        void nEstPasEnRetardLeJourDeLEcheance() {
            Tache tache = DonneesDeTest.tache(1L, "TP", java, AUJOURD_HUI, aminata);

            assertThat(tache.estEnRetard(AUJOURD_HUI)).isFalse();
        }

        @Test
        void nEstPlusEnRetardUneFoisTerminee() {
            Tache tache = DonneesDeTest.tache(1L, "TP", java, AUJOURD_HUI.minusDays(5), aminata);

            tache.terminer();

            assertThat(tache.estEnRetard(AUJOURD_HUI)).isFalse();
        }
    }

    @Nested
    class Statut {

        @Test
        void passeEnCoursPuisTerminee() {
            Tache tache = DonneesDeTest.tache(1L, "TP", java, AUJOURD_HUI, aminata);

            tache.changerStatut(StatutTache.EN_COURS);
            assertThat(tache.getStatut()).isEqualTo(StatutTache.EN_COURS);

            tache.changerStatut(StatutTache.TERMINEE);
            assertThat(tache.estTerminee()).isTrue();
        }

        @Test
        void refuseDeReappliquerLeStatutCourant() {
            Tache tache = DonneesDeTest.tache(1L, "TP", java, AUJOURD_HUI, aminata);

            assertThatThrownBy(() -> tache.changerStatut(StatutTache.A_FAIRE))
                    .isInstanceOf(IllegalStateException.class);
        }

        @Test
        void peutEtreRouverteApresTerminaison() {
            Tache tache = DonneesDeTest.tache(1L, "TP", java, AUJOURD_HUI, aminata);
            tache.terminer();

            tache.remettreAFaire();

            assertThat(tache.getStatut()).isEqualTo(StatutTache.A_FAIRE);
        }
    }

    @Nested
    class Modification {

        @Test
        void refuseDeDeplacerLaTacheVersLaMatiereDUnAutreEtudiant() {
            Tache tache = DonneesDeTest.tache(1L, "TP", java, AUJOURD_HUI, aminata);
            Matiere matiereDeMoussa = DonneesDeTest.matiere(20L, "Mathematiques", moussa);

            assertThatThrownBy(() -> tache.modifier(
                    "TP", null, matiereDeMoussa, AUJOURD_HUI, Priorite.BASSE))
                    .isInstanceOf(IllegalStateException.class);
        }
    }
}
