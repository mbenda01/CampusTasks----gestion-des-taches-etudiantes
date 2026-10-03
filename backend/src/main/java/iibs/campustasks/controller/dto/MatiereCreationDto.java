package iibs.campustasks.controller.dto;

import jakarta.validation.constraints.*;

public record MatiereCreationDto(

        @NotBlank(message = "Le nom de la matiere est obligatoire")
        @Size(min = 2, max = 100, message = "Le nom doit contenir entre 2 et 100 caracteres")
        String nom,

        @Size(max = 500, message = "La description ne doit pas depasser 500 caracteres")
        String description
) {
}
