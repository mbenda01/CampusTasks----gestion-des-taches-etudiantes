package iibs.campustasks.controller;

import iibs.campustasks.controller.dto.*;
import iibs.campustasks.entity.enums.*;
import iibs.campustasks.exception.*;
import iibs.campustasks.service.*;
import io.swagger.v3.oas.annotations.*;
import io.swagger.v3.oas.annotations.tags.*;
import jakarta.validation.*;
import lombok.*;
import org.springframework.data.domain.*;
import org.springframework.data.web.*;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@RestController
@RequestMapping("/api/v1/tasks")
@RequiredArgsConstructor
@Tag(name = "Taches", description = "Gestion des taches de l'etudiant")
public class TacheController {

    private static final Set<String> TRIS_AUTORISES = Set.of(
            "id", "titre", "dateLimite", "statut", "dateCreation"
    );

    private static final Sort TRI_PAR_DEFAUT = Sort.by(Sort.Direction.ASC, "dateLimite");

    private final TacheService tacheService;
    private final TriUtils triUtils;

    @GetMapping
    @Operation(
            summary = "Lister et filtrer ses taches",
            description = """
                    Filtres optionnels : matiereId, statut (A_FAIRE, EN_COURS, TERMINEE).

                    Tri par defaut : date limite croissante.
                    Tri autorise sur : id, titre, dateLimite, statut, dateCreation.
                    """
    )
    public ResponseEntity<ApiResponse<Page<TacheReponseDto>>> lister(
            @RequestParam(required = false) Long matiereId,
            @RequestParam(required = false) StatutTache statut,
            @PageableDefault(size = 20) Pageable pageable
    ) {
        Pageable borne = triUtils.assainir(pageable, TRIS_AUTORISES, TRI_PAR_DEFAUT);

        Page<TacheReponseDto> taches = tacheService.lister(matiereId, statut, borne);

        return ResponseEntity.ok(ApiResponse.succes(taches, "Taches recuperees"));
    }

    @GetMapping("/{id}")
    @Operation(
            summary = "Detail d'une tache",
            description = "404 si la tache n'existe pas ou appartient a un autre etudiant."
    )
    public ResponseEntity<ApiResponse<TacheReponseDto>> obtenir(@PathVariable Long id) {
        TacheReponseDto tache = tacheService.obtenir(id);

        return ResponseEntity.ok(ApiResponse.succes(tache, "Tache recuperee"));
    }

    @PostMapping
    @Operation(
            summary = "Creer une tache",
            description = "La tache est creee au statut A_FAIRE, priorite MOYENNE par defaut."
    )
    public ResponseEntity<ApiResponse<TacheReponseDto>> creer(
            @Valid @RequestBody TacheCreationDto dto
    ) {
        TacheReponseDto tache = tacheService.creer(dto);

        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.succes(tache, "Tache creee", HttpStatus.CREATED));
    }

    @PutMapping("/{id}")
    @Operation(
            summary = "Modifier une tache",
            description = "Remplace le contenu de la tache ; le statut est optionnel."
    )
    public ResponseEntity<ApiResponse<TacheReponseDto>> modifier(
            @PathVariable Long id,
            @Valid @RequestBody TacheModificationDto dto
    ) {
        TacheReponseDto tache = tacheService.modifier(id, dto);

        return ResponseEntity.ok(ApiResponse.succes(tache, "Tache modifiee"));
    }

    @PatchMapping("/{id}/status")
    @Operation(
            summary = "Changer le statut d'une tache",
            description = "409 si la tache a deja ce statut."
    )
    public ResponseEntity<ApiResponse<TacheReponseDto>> changerStatut(
            @PathVariable Long id,
            @Valid @RequestBody TacheStatutRequestDto dto
    ) {
        TacheReponseDto tache = tacheService.changerStatut(id, dto.statut());

        return ResponseEntity.ok(ApiResponse.succes(tache, "Statut modifie"));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "Supprimer une tache")
    public ResponseEntity<ApiResponse<Void>> supprimer(@PathVariable Long id) {
        tacheService.supprimer(id);

        return ResponseEntity.ok(ApiResponse.succes(null, "Tache supprimee"));
    }
}
