package iibs.campustasks.controller.dto;

import iibs.campustasks.entity.enums.*;

import java.time.*;

public record TacheReponseDto(
        Long id,
        String titre,
        String description,
        Long matiereId,
        String matiereNom,
        LocalDate dateLimite,
        Priorite priorite,
        StatutTache statut,
        boolean enRetard,
        LocalDateTime dateCreation,
        LocalDateTime dateModification
) {
}
