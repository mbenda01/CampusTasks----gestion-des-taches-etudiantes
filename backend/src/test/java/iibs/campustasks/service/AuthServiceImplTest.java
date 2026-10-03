package iibs.campustasks.service;

import iibs.campustasks.controller.dto.*;
import iibs.campustasks.entity.*;
import iibs.campustasks.exception.*;
import iibs.campustasks.faux.*;
import iibs.campustasks.repository.*;
import iibs.campustasks.security.*;
import iibs.campustasks.service.impl.*;
import iibs.campustasks.service.mapper.*;
import org.junit.jupiter.api.*;
import org.junit.jupiter.api.extension.*;
import org.mockito.*;
import org.mockito.junit.jupiter.*;
import org.springframework.security.crypto.password.*;

import java.util.*;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class AuthServiceImplTest {

    @Mock
    private UtilisateurRepository utilisateurRepository;

    @Mock
    private PasswordEncoder encodeurMotDePasse;

    private JwtService jwtService;
    private AuthServiceImpl service;
    private Utilisateur aminata;

    @BeforeEach
    void preparer() {
        jwtService = new JwtService(
                "cle-de-test-suffisamment-longue-pour-hmac-sha-256", 900_000, 604_800_000);

        service = new AuthServiceImpl(
                utilisateurRepository,
                new UtilisateurMapperImpl(),
                encodeurMotDePasse,
                jwtService,
                new FauxContexteSecurite());

        aminata = DonneesDeTest.aminata();
    }

    @Nested
    class Inscription {

        @Test
        void refuseUnEmailDejaUtilise() {
            when(utilisateurRepository.existsByEmail("aminata@test.sn")).thenReturn(true);

            assertThatThrownBy(() -> service.inscrire(new InscriptionRequestDto(
                    "Aminata Diop", "  Aminata@Test.sn ", "motdepasse123")))
                    .isInstanceOf(ConflitMetierException.class);

            verify(utilisateurRepository, never()).save(any());
        }

        @Test
        void enregistreUneEmpreinteEtJamaisLeMotDePasseEnClair() {
            when(utilisateurRepository.existsByEmail("aminata@test.sn")).thenReturn(false);
            when(encodeurMotDePasse.encode("motdepasse123")).thenReturn(DonneesDeTest.EMPREINTE);
            when(utilisateurRepository.save(any(Utilisateur.class))).thenReturn(aminata);

            JetonReponseDto reponse = service.inscrire(new InscriptionRequestDto(
                    "Aminata Diop", "aminata@test.sn", "motdepasse123"));

            ArgumentCaptor<Utilisateur> capture = ArgumentCaptor.forClass(Utilisateur.class);
            verify(utilisateurRepository).save(capture.capture());

            assertThat(capture.getValue().getMotDePasse()).isEqualTo(DonneesDeTest.EMPREINTE);
            assertThat(reponse.jetonAcces()).isNotBlank();
        }
    }

    @Nested
    class Connexion {

        @Test
        void retourneDeuxJetonsQuandLesIdentifiantsSontCorrects() {
            when(utilisateurRepository.findByEmail("aminata@test.sn")).thenReturn(Optional.of(aminata));
            when(encodeurMotDePasse.matches("motdepasse123", DonneesDeTest.EMPREINTE)).thenReturn(true);

            JetonReponseDto reponse = service.connecter(
                    new ConnexionRequestDto("aminata@test.sn", "motdepasse123"));

            assertThat(reponse.typeJeton()).isEqualTo("Bearer");
            assertThat(jwtService.estJetonAccesValide(reponse.jetonAcces())).isTrue();
            assertThat(jwtService.estJetonRafraichissementValide(reponse.jetonRafraichissement())).isTrue();
            assertThat(reponse.utilisateur().email()).isEqualTo("aminata@test.sn");
        }

        @Test
        void neDistinguePasEmailInconnuEtMotDePasseIncorrect() {
            when(utilisateurRepository.findByEmail("inconnu@test.sn")).thenReturn(Optional.empty());
            when(utilisateurRepository.findByEmail("aminata@test.sn")).thenReturn(Optional.of(aminata));
            when(encodeurMotDePasse.matches("mauvais", DonneesDeTest.EMPREINTE)).thenReturn(false);

            Throwable emailInconnu = catchThrowable(() -> service.connecter(
                    new ConnexionRequestDto("inconnu@test.sn", "mauvais")));
            Throwable motDePasseIncorrect = catchThrowable(() -> service.connecter(
                    new ConnexionRequestDto("aminata@test.sn", "mauvais")));

            assertThat(emailInconnu).isInstanceOf(IdentifiantsInvalidesException.class);
            assertThat(motDePasseIncorrect).isInstanceOf(IdentifiantsInvalidesException.class);
            assertThat(emailInconnu.getMessage()).isEqualTo(motDePasseIncorrect.getMessage());
        }
    }
}
