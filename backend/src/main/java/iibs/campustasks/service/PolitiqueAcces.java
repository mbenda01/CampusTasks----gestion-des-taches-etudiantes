package iibs.campustasks.service;

import iibs.campustasks.entity.*;
import iibs.campustasks.repository.*;
import iibs.campustasks.security.*;
import lombok.*;
import lombok.extern.slf4j.*;
import org.springframework.stereotype.*;

@Slf4j
@Component
@RequiredArgsConstructor
public class PolitiqueAcces {

    private final ContexteSecurite contexte;
    private final UtilisateurRepository utilisateurRepository;

    public Long identifiantCourant() {
        return contexte.utilisateurCourantRequis().getId();
    }

    public Utilisateur proprietaireCourant() {
        return utilisateurRepository.getReferenceById(identifiantCourant());
    }

    public void tracerTentativeAcces(String ressource, Long identifiant) {
        log.warn("Acces a une ressource absente ou etrangere : {}={}, utilisateur={}",
                ressource, identifiant, identifiantCourant());
    }
}
