package iibs.campustasks.controller.dto;

import iibs.campustasks.validation.*;
import jakarta.validation.constraints.*;

public record InscriptionRequestDto(

        @NotBlank(message = "Le nom est obligatoire")
        @Size(min = 2, max = 100, message = "Le nom doit contenir entre 2 et 100 caracteres")
        String nom,

        @NotBlank(message = "L'email est obligatoire")
        @Email(message = "Format d'email invalide")
        @Size(max = 150, message = "L'email ne doit pas depasser 150 caracteres")
        @EmailUnique(message = "Cet email est deja utilise")
        String email,

        @NotBlank(message = "Le mot de passe est obligatoire")
        @Size(min = 8, message = "Le mot de passe doit contenir au moins 8 caracteres")
        String motDePasse
) {
}
