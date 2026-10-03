package iibs.campustasks.controller;

import iibs.campustasks.controller.dto.*;
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
@RequestMapping("/api/v1/subjects")
@RequiredArgsConstructor
@Tag(name = "Matieres", description = "Gestion des matieres de l'etudiant")
public class MatiereController {

    private static final Set<String> TRIS_AUTORISES = Set.of(
            "id", "nom", "dateCreation"
    );

    private static final Sort TRI_PAR_DEFAUT = Sort.by(Sort.Direction.ASC, "nom");

    private final MatiereService matiereService;
    private final TriUtils triUtils;

    @GetMapping
    @Operation(
            summary = "Lister ses matieres",
            description = "Retourne les matieres de l'etudiant connecte, triees par nom."
    )
    public ResponseEntity<ApiResponse<Page<MatiereReponseDto>>> lister(
            @PageableDefault(size = 50) Pageable pageable
    ) {
        Pageable borne = triUtils.assainir(pageable, TRIS_AUTORISES, TRI_PAR_DEFAUT);

        Page<MatiereReponseDto> matieres = matiereService.lister(borne);

        return ResponseEntity.ok(ApiResponse.succes(matieres, "Matieres recuperees"));
    }

    @GetMapping("/{id}")
    @Operation(
            summary = "Detail d'une matiere",
            description = "404 si la matiere n'existe pas ou appartient a un autre etudiant."
    )
    public ResponseEntity<ApiResponse<MatiereReponseDto>> obtenir(@PathVariable Long id) {
        MatiereReponseDto matiere = matiereService.obtenir(id);

        return ResponseEntity.ok(ApiResponse.succes(matiere, "Matiere recuperee"));
    }

    @PostMapping
    @Operation(
            summary = "Ajouter une matiere",
            description = "Le nom doit etre unique parmi les matieres de l'etudiant."
    )
    public ResponseEntity<ApiResponse<MatiereReponseDto>> creer(
            @Valid @RequestBody MatiereCreationDto dto
    ) {
        MatiereReponseDto matiere = matiereService.creer(dto);

        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.succes(matiere, "Matiere creee", HttpStatus.CREATED));
    }

    @PutMapping("/{id}")
    @Operation(
            summary = "Modifier une matiere",
            description = "Modifie le nom et la description."
    )
    public ResponseEntity<ApiResponse<MatiereReponseDto>> modifier(
            @PathVariable Long id,
            @Valid @RequestBody MatiereModificationDto dto
    ) {
        MatiereReponseDto matiere = matiereService.modifier(id, dto);

        return ResponseEntity.ok(ApiResponse.succes(matiere, "Matiere modifiee"));
    }

    @DeleteMapping("/{id}")
    @Operation(
            summary = "Supprimer une matiere",
            description = "Refusee (409) si des taches sont encore rattachees a la matiere."
    )
    public ResponseEntity<ApiResponse<Void>> supprimer(@PathVariable Long id) {
        matiereService.supprimer(id);

        return ResponseEntity.ok(ApiResponse.succes(null, "Matiere supprimee"));
    }
}
