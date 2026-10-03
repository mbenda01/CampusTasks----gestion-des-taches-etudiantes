package iibs.campustasks.validation;

import iibs.campustasks.repository.*;
import iibs.campustasks.security.*;
import jakarta.validation.*;
import lombok.*;

@RequiredArgsConstructor
public class MatiereExisteValidator implements ConstraintValidator<MatiereExiste, Long> {

    private final MatiereRepository matiereRepository;
    private final ContexteSecurite contexte;

    @Override
    public boolean isValid(Long matiereId, ConstraintValidatorContext context) {
        if (matiereId == null) {
            return true;
        }

        return contexte.identifiantCourant()
                .map(proprietaireId -> matiereRepository
                        .findByIdAndProprietaireId(matiereId, proprietaireId)
                        .isPresent())
                .orElse(true);
    }
}
