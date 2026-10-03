package iibs.campustasks.repository;

import iibs.campustasks.entity.*;
import iibs.campustasks.entity.enums.*;
import org.springframework.data.jpa.domain.*;

public final class TacheSpecifications {

    private TacheSpecifications() {
    }

    public static Specification<Tache> filtrer(Long proprietaireId, Long matiereId, StatutTache statut) {
        Specification<Tache> specification = appartientA(proprietaireId);

        if (matiereId != null) {
            specification = specification.and(deLaMatiere(matiereId));
        }

        if (statut != null) {
            specification = specification.and(aLeStatut(statut));
        }

        return specification;
    }

    public static Specification<Tache> appartientA(Long proprietaireId) {
        return (racine, requete, critere) ->
                critere.equal(racine.get("proprietaire").get("id"), proprietaireId);
    }

    public static Specification<Tache> deLaMatiere(Long matiereId) {
        return (racine, requete, critere) ->
                critere.equal(racine.get("matiere").get("id"), matiereId);
    }

    public static Specification<Tache> aLeStatut(StatutTache statut) {
        return (racine, requete, critere) ->
                critere.equal(racine.get("statut"), statut);
    }
}
