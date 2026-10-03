package iibs.campustasks.controller;

import iibs.campustasks.controller.dto.*;
import iibs.campustasks.exception.*;
import iibs.campustasks.service.*;
import io.swagger.v3.oas.annotations.*;
import io.swagger.v3.oas.annotations.tags.*;
import lombok.*;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/dashboard")
@RequiredArgsConstructor
@Tag(name = "Tableau de bord", description = "Indicateurs de l'etudiant")
public class TableauBordController {

    private final TableauBordService tableauBordService;

    @GetMapping
    @Operation(
            summary = "Consulter les indicateurs",
            description = """
                    Nombre de taches par statut, prochaines echeances et taches
                    en retard (date limite depassee et statut different de TERMINEE).
                    """
    )
    public ResponseEntity<ApiResponse<TableauBordDto>> consulter() {
        TableauBordDto tableau = tableauBordService.consulter();

        return ResponseEntity.ok(ApiResponse.succes(tableau, "Tableau de bord recupere"));
    }
}
