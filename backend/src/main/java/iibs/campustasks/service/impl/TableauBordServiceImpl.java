package iibs.campustasks.service.impl;

import iibs.campustasks.controller.dto.*;
import iibs.campustasks.entity.enums.*;
import iibs.campustasks.repository.*;
import iibs.campustasks.service.*;
import iibs.campustasks.service.mapper.*;
import lombok.*;
import lombok.extern.slf4j.*;
import org.springframework.stereotype.*;
import org.springframework.transaction.annotation.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class TableauBordServiceImpl implements TableauBordService {

    private static final int NOMBRE_ECHEANCES = 5;

    private final TacheRepository tacheRepository;
    private final TacheMapper tacheMapper;
    private final PolitiqueAcces politique;

    @Override
    @Transactional(readOnly = true)
    public TableauBordDto consulter() {
        Long proprietaireId = politique.identifiantCourant();

        long aFaire = tacheRepository.countByProprietaireIdAndStatut(proprietaireId, StatutTache.A_FAIRE);
        long enCours = tacheRepository.countByProprietaireIdAndStatut(proprietaireId, StatutTache.EN_COURS);
        long terminees = tacheRepository.countByProprietaireIdAndStatut(proprietaireId, StatutTache.TERMINEE);
        long enRetard = tacheRepository.compterEnRetard(proprietaireId);

        log.debug("Tableau de bord utilisateur id={} : {} a faire, {} en cours, {} terminees, {} en retard",
                proprietaireId, aFaire, enCours, terminees, enRetard);

        return new TableauBordDto(
                aFaire,
                enCours,
                terminees,
                aFaire + enCours + terminees,
                enRetard,
                tacheMapper.versReponses(
                        tacheRepository.listerProchainesEcheances(proprietaireId, NOMBRE_ECHEANCES)),
                tacheMapper.versReponses(
                        tacheRepository.listerEnRetard(proprietaireId, NOMBRE_ECHEANCES)));
    }
}
