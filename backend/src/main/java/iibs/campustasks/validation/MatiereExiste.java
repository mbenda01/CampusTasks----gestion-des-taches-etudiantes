package iibs.campustasks.validation;

import jakarta.validation.*;

import java.lang.annotation.*;

@Documented
@Constraint(validatedBy = MatiereExisteValidator.class)
@Target({ElementType.FIELD, ElementType.PARAMETER, ElementType.RECORD_COMPONENT})
@Retention(RetentionPolicy.RUNTIME)
public @interface MatiereExiste {

    String message() default "Cette matiere n'existe pas";

    Class<?>[] groups() default {};

    Class<? extends Payload>[] payload() default {};
}
