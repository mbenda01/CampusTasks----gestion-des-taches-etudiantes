package iibs.campustasks.controller.dto;

import iibs.campustasks.entity.enums.*;
import iibs.campustasks.validation.*;
import jakarta.validation.constraints.*;

import java.time.*;

public record TacheCreationDto(

        @NotBlank(message = "Le titre est obligatoire")
        @Size(min = 3, max = 150, message = "Le titre doit contenir entre 3 et 150 caracteres")
        String titre,

        @Size(max = 2000, message = "La description ne doit pas depasser 2000 caracteres")
        String description,

        @NotNull(message = "La matiere est obligatoire")
        @MatiereExiste
        Long matiereId,

        @NotNull(message = "La date limite est obligatoire")
        @FutureOrPresent(message = "La date limite ne peut pas etre dans le passe")
        LocalDate dateLimite,

        Priorite priorite
) {
}
