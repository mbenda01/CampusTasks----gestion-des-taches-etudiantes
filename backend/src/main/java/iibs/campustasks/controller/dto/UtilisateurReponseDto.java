package iibs.campustasks.controller.dto;

import iibs.campustasks.entity.enums.*;

import java.time.*;

public record UtilisateurReponseDto(
        Long id,
        String nom,
        String email,
        Role role,
        boolean actif,
        LocalDateTime dateCreation
) {
}
