package iibs.campustasks.service;

import iibs.campustasks.controller.dto.*;
import iibs.campustasks.entity.*;
import iibs.campustasks.entity.enums.*;
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
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class TableauBordServiceImplTest {

    @Mock
    private TacheRepository tacheRepository;

    @Mock
    private UtilisateurRepository utilisateurRepository;

    private TableauBordServiceImpl service;
    private Utilisateur aminata;
    private Matiere java;

    @BeforeEach
    void preparer() {
        aminata = DonneesDeTest.aminata();
        java = DonneesDeTest.matiere(10L, "Programmation Java", aminata);

        PolitiqueAcces politique = new PolitiqueAcces(
                new FauxContexteSecurite(aminata), utilisateurRepository);

        service = new TableauBordServiceImpl(tacheRepository, new TacheMapperImpl(), politique);
    }

    @Test
    void calculeLesIndicateursDuProprietaireCourant() {
        Tache prochaine = DonneesDeTest.tache(1L, "TP", java, LocalDate.now().plusDays(2), aminata);
        Tache enRetard = DonneesDeTest.tache(2L, "Expose", java, LocalDate.now().minusDays(3), aminata);

        when(tacheRepository.countByProprietaireIdAndStatut(1L, StatutTache.A_FAIRE)).thenReturn(3L);
        when(tacheRepository.countByProprietaireIdAndStatut(1L, StatutTache.EN_COURS)).thenReturn(2L);
        when(tacheRepository.countByProprietaireIdAndStatut(1L, StatutTache.TERMINEE)).thenReturn(1L);
        when(tacheRepository.compterEnRetard(1L)).thenReturn(1L);
        when(tacheRepository.listerProchainesEcheances(1L, 5)).thenReturn(List.of(prochaine));
        when(tacheRepository.listerEnRetard(1L, 5)).thenReturn(List.of(enRetard));

        TableauBordDto tableau = service.consulter();

        assertThat(tableau.aFaire()).isEqualTo(3);
        assertThat(tableau.enCours()).isEqualTo(2);
        assertThat(tableau.terminees()).isEqualTo(1);
        assertThat(tableau.total()).isEqualTo(6);
        assertThat(tableau.enRetard()).isEqualTo(1);
        assertThat(tableau.prochainesEcheances()).extracting(TacheReponseDto::titre).containsExactly("TP");
        assertThat(tableau.tachesEnRetard()).allMatch(TacheReponseDto::enRetard);
    }
}
