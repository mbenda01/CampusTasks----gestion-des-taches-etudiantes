package iibs.campustasks.controller.dto;

import java.util.*;

public record TableauBordDto(
        long aFaire,
        long enCours,
        long terminees,
        long total,
        long enRetard,
        List<TacheReponseDto> prochainesEcheances,
        List<TacheReponseDto> tachesEnRetard
) {
}
