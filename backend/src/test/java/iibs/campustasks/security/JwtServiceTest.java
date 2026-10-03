package iibs.campustasks.security;

import org.junit.jupiter.api.*;

import static org.assertj.core.api.Assertions.*;

class JwtServiceTest {

    private static final String SECRET = "cle-de-test-suffisamment-longue-pour-hmac-sha-256";

    private JwtService jwtService;

    @BeforeEach
    void preparer() {
        jwtService = new JwtService(SECRET, 900_000, 604_800_000);
    }

    @Test
    void leJetonDAccesEstValideEtPorteLEmailEtLIdentifiant() {
        String jeton = jwtService.genererJetonAcces("aminata@test.sn", "ETUDIANT", 1L);

        assertThat(jwtService.estJetonAccesValide(jeton)).isTrue();
        assertThat(jwtService.extraireEmail(jeton)).isEqualTo("aminata@test.sn");
        assertThat(jwtService.extraireIdentifiant(jeton)).isEqualTo(1L);
        assertThat(jwtService.extraireRole(jeton)).isEqualTo("ETUDIANT");
    }

    @Test
    void unJetonDeRafraichissementNeSertPasDeJetonDAcces() {
        String jeton = jwtService.genererJetonRafraichissement("aminata@test.sn");

        assertThat(jwtService.estJetonRafraichissementValide(jeton)).isTrue();
        assertThat(jwtService.estJetonAccesValide(jeton)).isFalse();
    }
    
    @Test
    void unJetonAltereEstRefuse() {
        String jetonAminata = jwtService.genererJetonAcces("aminata@test.sn", "ETUDIANT", 1L);
        String jetonMoussa = jwtService.genererJetonAcces("moussa@test.sn", "ETUDIANT", 2L);

        String[] partiesAminata = jetonAminata.split("\\.");
        String[] partiesMoussa = jetonMoussa.split("\\.");

        String jetonForge = partiesAminata[0] + "." + partiesMoussa[1] + "." + partiesAminata[2];

        assertThat(jwtService.estValide(jetonForge)).isFalse();
    }


    @Test
    void unJetonSigneAvecUneAutreCleEstRefuse() {
        JwtService autre = new JwtService(
                "une-autre-cle-tout-aussi-longue-pour-hmac-sha-256", 900_000, 604_800_000);

        String jeton = autre.genererJetonAcces("aminata@test.sn", "ETUDIANT", 1L);

        assertThat(jwtService.estValide(jeton)).isFalse();
    }
}
