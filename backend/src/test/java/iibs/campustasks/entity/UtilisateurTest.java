package iibs.campustasks.entity;

import iibs.campustasks.entity.enums.*;
import iibs.campustasks.faux.*;
import org.junit.jupiter.api.*;

import static org.assertj.core.api.Assertions.*;

class UtilisateurTest {

    @Test
    void inscriptionNormaliseLEmailEtAttribueLeRoleEtudiant() {
        Utilisateur utilisateur = Utilisateur.inscrire(
                "  Aminata Diop ", "  Aminata@Test.SN ", DonneesDeTest.EMPREINTE);

        assertThat(utilisateur.getNom()).isEqualTo("Aminata Diop");
        assertThat(utilisateur.getEmail()).isEqualTo("aminata@test.sn");
        assertThat(utilisateur.getRole()).isEqualTo(Role.ETUDIANT);
        assertThat(utilisateur.peutSeConnecter()).isTrue();
    }

    @Test
    void refuseDeDesactiverDeuxFois() {
        Utilisateur utilisateur = DonneesDeTest.aminata();
        utilisateur.desactiver();

        assertThat(utilisateur.peutSeConnecter()).isFalse();
        assertThatThrownBy(utilisateur::desactiver)
                .isInstanceOf(IllegalStateException.class);
    }
}
