package iibs.campustasks.controller.dto;

import java.time.*;

public record MatiereReponseDto(
        Long id,
        String nom,
        String description,
        LocalDateTime dateCreation,
        LocalDateTime dateModification
) {
}
