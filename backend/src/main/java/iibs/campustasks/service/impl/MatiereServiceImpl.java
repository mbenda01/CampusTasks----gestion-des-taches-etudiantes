package iibs.campustasks.service.impl;

import iibs.campustasks.controller.dto.*;
import iibs.campustasks.entity.*;
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
public class MatiereServiceImpl implements MatiereService {

    private final MatiereRepository matiereRepository;
    private final TacheRepository tacheRepository;
    private final MatiereMapper matiereMapper;
    private final PolitiqueAcces politique;

    @Override
    @Transactional(readOnly = true)
    public Page<MatiereReponseDto> lister(Pageable pageable) {
        Long proprietaireId = politique.identifiantCourant();

        log.debug("Liste des matieres de l'utilisateur id={}, page {}",
                proprietaireId, pageable.getPageNumber());

        return matiereRepository.findByProprietaireId(proprietaireId, pageable)
                .map(matiereMapper::versReponse);
    }

    @Override
    @Transactional(readOnly = true)
    public MatiereReponseDto obtenir(Long id) {
        return matiereMapper.versReponse(trouverDuProprietaire(id));
    }

    @Override
    @Transactional(readOnly = true)
    public Matiere trouverDuProprietaire(Long id) {
        return matiereRepository.findByIdAndProprietaireId(id, politique.identifiantCourant())
                .orElseThrow(() -> {
                    politique.tracerTentativeAcces("matiere", id);
                    return RessourceNonTrouveeException.pour("Matiere", id);
                });
    }

    @Override
    @Transactional
    public MatiereReponseDto creer(MatiereCreationDto dto) {
        Utilisateur proprietaire = politique.proprietaireCourant();

        if (matiereRepository.existsByProprietaireIdAndNomIgnoreCase(
                proprietaire.getId(), dto.nom().trim())) {
            throw new ConflitMetierException("Une matiere porte deja ce nom");
        }

        Matiere matiere = Matiere.creer(dto.nom(), dto.description(), proprietaire);

        Matiere enregistree = matiereRepository.save(matiere);

        log.info("Matiere creee : id={}, proprietaire={}",
                enregistree.getId(), proprietaire.getId());

        return matiereMapper.versReponse(enregistree);
    }

    @Override
    @Transactional
    public MatiereReponseDto modifier(Long id, MatiereModificationDto dto) {
        Matiere matiere = trouverDuProprietaire(id);

        if (matiereRepository.existsByProprietaireIdAndNomIgnoreCaseAndIdNot(
                politique.identifiantCourant(), dto.nom().trim(), id)) {
            throw new ConflitMetierException("Une matiere porte deja ce nom");
        }

        matiere.modifier(dto.nom(), dto.description());

        Matiere enregistree = matiereRepository.save(matiere);

        log.info("Matiere modifiee : id={}", id);

        return matiereMapper.versReponse(enregistree);
    }

    @Override
    @Transactional
    public void supprimer(Long id) {
        Matiere matiere = trouverDuProprietaire(id);

        long nombreTaches = tacheRepository.countByMatiereId(id);

        if (nombreTaches > 0) {
            log.debug("Suppression refusee : matiere id={} rattachee a {} tache(s)",
                    id, nombreTaches);
            throw new ConflitMetierException(
                    "Impossible de supprimer la matiere : %d tache(s) y sont rattachees"
                            .formatted(nombreTaches));
        }

        matiereRepository.delete(matiere);

        log.info("Matiere supprimee : id={}", id);
    }
}
