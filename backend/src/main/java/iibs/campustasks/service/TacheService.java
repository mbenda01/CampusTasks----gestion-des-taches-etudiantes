package iibs.campustasks.service;

import iibs.campustasks.controller.dto.*;
import iibs.campustasks.entity.enums.*;
import org.springframework.data.domain.*;

public interface TacheService {

    Page<TacheReponseDto> lister(Long matiereId, StatutTache statut, Pageable pageable);

    TacheReponseDto obtenir(Long id);

    TacheReponseDto creer(TacheCreationDto dto);

    TacheReponseDto modifier(Long id, TacheModificationDto dto);

    TacheReponseDto changerStatut(Long id, StatutTache statut);

    void supprimer(Long id);
}
