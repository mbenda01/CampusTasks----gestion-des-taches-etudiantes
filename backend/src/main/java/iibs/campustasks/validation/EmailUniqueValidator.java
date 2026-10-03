package iibs.campustasks.validation;

import iibs.campustasks.entity.*;
import iibs.campustasks.repository.*;
import jakarta.validation.*;
import lombok.*;

@RequiredArgsConstructor
public class EmailUniqueValidator implements ConstraintValidator<EmailUnique, String> {

    private final UtilisateurRepository utilisateurRepository;

    @Override
    public boolean isValid(String email, ConstraintValidatorContext context) {

        if (email == null || email.isBlank()) {
            return true;
        }

        return !utilisateurRepository.existsByEmail(
                Utilisateur.normaliserEmail(email));
    }
}
