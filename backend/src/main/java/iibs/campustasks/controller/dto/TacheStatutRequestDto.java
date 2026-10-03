package iibs.campustasks.controller.dto;

import iibs.campustasks.entity.enums.*;
import jakarta.validation.constraints.*;

public record TacheStatutRequestDto(

        @NotNull(message = "Le statut est obligatoire")
        StatutTache statut
) {
}
