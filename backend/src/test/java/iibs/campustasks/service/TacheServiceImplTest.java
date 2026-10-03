package iibs.campustasks.service;

import iibs.campustasks.controller.dto.*;
import iibs.campustasks.entity.*;
import iibs.campustasks.entity.enums.*;
import iibs.campustasks.exception.*;
import iibs.campustasks.faux.*;
import iibs.campustasks.repository.*;
import iibs.campustasks.service.impl.*;
import iibs.campustasks.service.mapper.*;
import org.junit.jupiter.api.*;
import org.junit.jupiter.api.extension.*;
import org.mockito.*;
import org.mockito.junit.jupiter.*;

import java.time.*;
import java.util.*;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class TacheServiceImplTest {

    @Mock
    private TacheRepository tacheRepository;

    @Mock
    private MatiereService matiereService;

    @Mock
    private UtilisateurRepository utilisateurRepository;

    private FauxContexteSecurite contexte;
    private TacheServiceImpl service;

    private Utilisateur aminata;
    private Utilisateur moussa;
    private Matiere java;
    private Tache tache;
    private LocalDate echeance;

    @BeforeEach
    void preparer() {
        aminata = DonneesDeTest.aminata();
        moussa = DonneesDeTest.moussa();
        java = DonneesDeTest.matiere(10L, "Programmation Java", aminata);
        echeance = LocalDate.now().plusDays(3);
        tache = DonneesDeTest.tache(100L, "Rendre le TP", java, echeance, aminata);

        contexte = new FauxContexteSecurite(aminata);
        PolitiqueAcces politique = new PolitiqueAcces(contexte, utilisateurRepository);

        service = new TacheServiceImpl(
                tacheRepository, matiereService, new TacheMapperImpl(), politique);
    }

    @Nested
    class ProtectionEntreEtudiants {

        @Test
        void unEtudiantNePeutPasConsulterLaTacheDUnAutre() {
            contexte.connecter(moussa);
            when(tacheRepository.findByIdAndProprietaireId(100L, 2L)).thenReturn(Optional.empty());

            assertThatThrownBy(() -> service.obtenir(100L))
                    .isInstanceOf(RessourceNonTrouveeException.class);
        }

        @Test
        void unEtudiantNePeutPasModifierLaTacheDUnAutre() {
            contexte.connecter(moussa);
            when(tacheRepository.findByIdAndProprietaireId(100L, 2L)).thenReturn(Optional.empty());

            assertThatThrownBy(() -> service.modifier(100L, new TacheModificationDto(
                    "Modifie", null, 10L, echeance, Priorite.BASSE, null)))
                    .isInstanceOf(RessourceNonTrouveeException.class);

            verify(tacheRepository, never()).save(any());
        }

        @Test
        void unEtudiantNePeutPasSupprimerLaTacheDUnAutre() {
            contexte.connecter(moussa);
            when(tacheRepository.findByIdAndProprietaireId(100L, 2L)).thenReturn(Optional.empty());

            assertThatThrownBy(() -> service.supprimer(100L))
                    .isInstanceOf(RessourceNonTrouveeException.class);

            verify(tacheRepository, never()).delete(any(Tache.class));
        }

        @Test
        void unEtudiantNePeutPasCreerUneTacheDansLaMatiereDUnAutre() {
            contexte.connecter(moussa);
            when(utilisateurRepository.getReferenceById(2L)).thenReturn(moussa);
            when(matiereService.trouverDuProprietaire(10L))
                    .thenThrow(RessourceNonTrouveeException.pour("Matiere", 10L));

            assertThatThrownBy(() -> service.creer(new TacheCreationDto(
                    "Intrusion", null, 10L, echeance, Priorite.HAUTE)))
                    .isInstanceOf(RessourceNonTrouveeException.class);

            verify(tacheRepository, never()).save(any());
        }
    }

    @Nested
    class Creation {

        @Test
        void creeLaTacheAFaireDansLaMatiereDuProprietaire() {
            when(utilisateurRepository.getReferenceById(1L)).thenReturn(aminata);
            when(matiereService.trouverDuProprietaire(10L)).thenReturn(java);
            when(tacheRepository.save(any(Tache.class)))
                    .thenAnswer(invocation -> invocation.getArgument(0));

            TacheReponseDto reponse = service.creer(new TacheCreationDto(
                    "Reviser JPA", "Chapitres 1 a 3", 10L, echeance, Priorite.HAUTE));

            assertThat(reponse.statut()).isEqualTo(StatutTache.A_FAIRE);
            assertThat(reponse.priorite()).isEqualTo(Priorite.HAUTE);
            assertThat(reponse.matiereNom()).isEqualTo("Programmation Java");
            assertThat(reponse.enRetard()).isFalse();
        }
    }

    @Nested
    class ChangementDeStatut {

        @Test
        void appliqueLeNouveauStatut() {
            when(tacheRepository.findByIdAndProprietaireId(100L, 1L)).thenReturn(Optional.of(tache));
            when(tacheRepository.save(tache)).thenReturn(tache);

            TacheReponseDto reponse = service.changerStatut(100L, StatutTache.EN_COURS);

            assertThat(reponse.statut()).isEqualTo(StatutTache.EN_COURS);
        }

        @Test
        void traduitUnStatutIdentiqueEnConflitMetier() {
            when(tacheRepository.findByIdAndProprietaireId(100L, 1L)).thenReturn(Optional.of(tache));

            assertThatThrownBy(() -> service.changerStatut(100L, StatutTache.A_FAIRE))
                    .isInstanceOf(ConflitMetierException.class);

            verify(tacheRepository, never()).save(any());
        }
    }
}
