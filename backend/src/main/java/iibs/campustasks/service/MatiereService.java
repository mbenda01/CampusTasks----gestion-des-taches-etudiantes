package iibs.campustasks.service;

import iibs.campustasks.controller.dto.*;
import iibs.campustasks.entity.*;
import org.springframework.data.domain.*;

public interface MatiereService {

    Page<MatiereReponseDto> lister(Pageable pageable);

    MatiereReponseDto obtenir(Long id);

    Matiere trouverDuProprietaire(Long id);

    MatiereReponseDto creer(MatiereCreationDto dto);

    MatiereReponseDto modifier(Long id, MatiereModificationDto dto);

    void supprimer(Long id);
}
