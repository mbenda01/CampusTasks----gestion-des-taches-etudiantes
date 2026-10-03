package iibs.campustasks.service;

import iibs.campustasks.controller.dto.*;
import iibs.campustasks.entity.*;
import iibs.campustasks.exception.*;
import iibs.campustasks.faux.*;
import iibs.campustasks.repository.*;
import iibs.campustasks.service.impl.*;
import iibs.campustasks.service.mapper.*;
import org.junit.jupiter.api.*;
import org.junit.jupiter.api.extension.*;
import org.mockito.*;
import org.mockito.junit.jupiter.*;
import org.springframework.data.domain.*;

import java.util.*;

import static org.assertj.core.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class MatiereServiceImplTest {

    @Mock
    private MatiereRepository matiereRepository;

    @Mock
    private TacheRepository tacheRepository;

    @Mock
    private UtilisateurRepository utilisateurRepository;

    private FauxContexteSecurite contexte;
    private MatiereServiceImpl service;

    private Utilisateur aminata;
    private Utilisateur moussa;
    private Matiere java;

    @BeforeEach
    void preparer() {
        aminata = DonneesDeTest.aminata();
        moussa = DonneesDeTest.moussa();
        java = DonneesDeTest.matiere(10L, "Programmation Java", aminata);

        contexte = new FauxContexteSecurite(aminata);
        PolitiqueAcces politique = new PolitiqueAcces(contexte, utilisateurRepository);

        service = new MatiereServiceImpl(
                matiereRepository, tacheRepository, new MatiereMapperImpl(), politique);
    }

    @Nested
    class Isolation {

        @Test
        void neListeQueLesMatieresDuProprietaireCourant() {
            Pageable page = PageRequest.of(0, 20);
            when(matiereRepository.findByProprietaireId(1L, page))
                    .thenReturn(new PageImpl<>(List.of(java)));

            Page<MatiereReponseDto> resultat = service.lister(page);

            assertThat(resultat.getContent()).extracting(MatiereReponseDto::nom)
                    .containsExactly("Programmation Java");
            verify(matiereRepository).findByProprietaireId(1L, page);
        }

        @Test
        void laMatiereDUnAutreEtudiantEstIntrouvable() {
            contexte.connecter(moussa);
            when(matiereRepository.findByIdAndProprietaireId(10L, 2L)).thenReturn(Optional.empty());

            assertThatThrownBy(() -> service.obtenir(10L))
                    .isInstanceOf(RessourceNonTrouveeException.class);
        }

        @Test
        void unAutreEtudiantNePeutPasModifierLaMatiere() {
            contexte.connecter(moussa);
            when(matiereRepository.findByIdAndProprietaireId(10L, 2L)).thenReturn(Optional.empty());

            assertThatThrownBy(() -> service.modifier(10L,
                    new MatiereModificationDto("Piratage", null)))
                    .isInstanceOf(RessourceNonTrouveeException.class);

            verify(matiereRepository, never()).save(any());
        }

        @Test
        void exigeUneAuthentification() {
            contexte.deconnecter();

            assertThatThrownBy(() -> service.lister(PageRequest.of(0, 20)))
                    .isInstanceOf(AccesRefuseException.class);
        }
    }

    @Nested
    class Creation {

        @Test
        void refuseUnNomDejaUtiliseParLEtudiant() {
            when(utilisateurRepository.getReferenceById(1L)).thenReturn(aminata);
            when(matiereRepository.existsByProprietaireIdAndNomIgnoreCase(1L, "Programmation Java"))
                    .thenReturn(true);

            assertThatThrownBy(() -> service.creer(
                    new MatiereCreationDto("Programmation Java", null)))
                    .isInstanceOf(ConflitMetierException.class);

            verify(matiereRepository, never()).save(any());
        }

        @Test
        void rattacheLaMatiereAuProprietaireCourant() {
            when(utilisateurRepository.getReferenceById(1L)).thenReturn(aminata);
            when(matiereRepository.existsByProprietaireIdAndNomIgnoreCase(1L, "Reseaux"))
                    .thenReturn(false);
            when(matiereRepository.save(any(Matiere.class)))
                    .thenAnswer(invocation -> invocation.getArgument(0));

            MatiereReponseDto reponse = service.creer(new MatiereCreationDto("  Reseaux ", "TCP/IP"));

            ArgumentCaptor<Matiere> capture = ArgumentCaptor.forClass(Matiere.class);
            verify(matiereRepository).save(capture.capture());

            assertThat(reponse.nom()).isEqualTo("Reseaux");
            assertThat(capture.getValue().appartientA(aminata)).isTrue();
        }
    }

    @Nested
    class Suppression {

        @Test
        void refuseLaSuppressionSiDesTachesSontRattachees() {
            when(matiereRepository.findByIdAndProprietaireId(10L, 1L)).thenReturn(Optional.of(java));
            when(tacheRepository.countByMatiereId(10L)).thenReturn(2L);

            assertThatThrownBy(() -> service.supprimer(10L))
                    .isInstanceOf(ConflitMetierException.class)
                    .hasMessageContaining("2 tache");

            verify(matiereRepository, never()).delete(any());
        }

        @Test
        void supprimeUneMatiereSansTache() {
            when(matiereRepository.findByIdAndProprietaireId(10L, 1L)).thenReturn(Optional.of(java));
            when(tacheRepository.countByMatiereId(10L)).thenReturn(0L);

            service.supprimer(10L);

            verify(matiereRepository).delete(java);
        }
    }
}
