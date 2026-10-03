package iibs.campustasks.service.impl;

import iibs.campustasks.controller.dto.*;
import iibs.campustasks.entity.*;
import iibs.campustasks.entity.enums.*;
import iibs.campustasks.exception.*;
import iibs.campustasks.repository.*;
import iibs.campustasks.service.*;
import iibs.campustasks.service.mapper.*;
import lombok.*;
import lombok.extern.slf4j.*;
import org.springframework.data.domain.*;
import org.springframework.stereotype.*;
import org.springframework.transaction.annotation.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class TacheServiceImpl implements TacheService {

    private final TacheRepository tacheRepository;
    private final MatiereService matiereService;
    private final TacheMapper tacheMapper;
    private final PolitiqueAcces politique;

    @Override
    @Transactional(readOnly = true)
    public Page<TacheReponseDto> lister(Long matiereId, StatutTache statut, Pageable pageable) {
        Long proprietaireId = politique.identifiantCourant();

        log.debug("Liste des taches de l'utilisateur id={}, matiere={}, statut={}",
                proprietaireId, matiereId, statut);

        return tacheRepository
                .findAll(TacheSpecifications.filtrer(proprietaireId, matiereId, statut), pageable)
                .map(tacheMapper::versReponse);
    }

    @Override
    @Transactional(readOnly = true)
    public TacheReponseDto obtenir(Long id) {
        return tacheMapper.versReponse(chargerOuLever(id));
    }

    @Override
    @Transactional
    public TacheReponseDto creer(TacheCreationDto dto) {
        Utilisateur proprietaire = politique.proprietaireCourant();
        Matiere matiere = matiereService.trouverDuProprietaire(dto.matiereId());

        Tache tache = Tache.planifier(
                dto.titre(),
                dto.description(),
                matiere,
                dto.dateLimite(),
                dto.priorite(),
                proprietaire);

        Tache enregistree = tacheRepository.save(tache);

        log.info("Tache creee : id={}, matiere={}, proprietaire={}",
                enregistree.getId(), matiere.getId(), proprietaire.getId());

        return tacheMapper.versReponse(enregistree);
    }

    @Override
    @Transactional
    public TacheReponseDto modifier(Long id, TacheModificationDto dto) {
        Tache tache = chargerOuLever(id);
        Matiere matiere = matiereService.trouverDuProprietaire(dto.matiereId());

        tache.modifier(
                dto.titre(),
                dto.description(),
                matiere,
                dto.dateLimite(),
                dto.priorite());

        if (dto.statut() != null && dto.statut() != tache.getStatut()) {
            appliquerStatut(tache, dto.statut());
        }

        Tache enregistree = tacheRepository.save(tache);

        log.info("Tache modifiee : id={}", id);

        return tacheMapper.versReponse(enregistree);
    }

    @Override
    @Transactional
    public TacheReponseDto changerStatut(Long id, StatutTache statut) {
        Tache tache = chargerOuLever(id);

        appliquerStatut(tache, statut);

        Tache enregistree = tacheRepository.save(tache);

        log.info("Statut de la tache id={} change en {}", id, statut);

        return tacheMapper.versReponse(enregistree);
    }

    @Override
    @Transactional
    public void supprimer(Long id) {
        Tache tache = chargerOuLever(id);

        tacheRepository.delete(tache);

        log.info("Tache supprimee : id={}", id);
    }

    private void appliquerStatut(Tache tache, StatutTache statut) {
        try {
            tache.changerStatut(statut);
        } catch (IllegalStateException exception) {
            throw new ConflitMetierException(exception.getMessage());
        }
    }

    private Tache chargerOuLever(Long id) {
        return tacheRepository.findByIdAndProprietaireId(id, politique.identifiantCourant())
                .orElseThrow(() -> {
                    politique.tracerTentativeAcces("tache", id);
                    return RessourceNonTrouveeException.pour("Tache", id);
                });
    }
}
