package iibs.campustasks.controller;

import iibs.campustasks.controller.dto.*;
import iibs.campustasks.exception.*;
import iibs.campustasks.service.*;
import io.swagger.v3.oas.annotations.*;
import io.swagger.v3.oas.annotations.security.*;
import io.swagger.v3.oas.annotations.tags.*;
import jakarta.validation.*;
import lombok.*;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
@Tag(name = "Authentification", description = "Inscription, connexion, rafraichissement et profil")
public class AuthController {

    private final AuthService authService;

    @PostMapping("/register")
    @SecurityRequirements
    @Operation(
            summary = "Creer un compte",
            description = "Cree un compte etudiant et retourne les jetons."
    )
    public ResponseEntity<ApiResponse<JetonReponseDto>> inscrire(
            @Valid @RequestBody InscriptionRequestDto dto
    ) {
        JetonReponseDto reponse = authService.inscrire(dto);

        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.succes(reponse, "Compte cree", HttpStatus.CREATED));
    }

    @PostMapping("/login")
    @SecurityRequirements
    @Operation(
            summary = "Se connecter",
            description = """
                    Verifie les identifiants et retourne deux jetons.

                    Le jeton d'acces est valable 15 minutes et s'envoie a
                    chaque requete. Le jeton de rafraichissement est valable
                    7 jours et sert uniquement a renouveler le premier.
                    """
    )
    public ResponseEntity<ApiResponse<JetonReponseDto>> connecter(
            @Valid @RequestBody ConnexionRequestDto dto
    ) {
        JetonReponseDto reponse = authService.connecter(dto);

        return ResponseEntity.ok(ApiResponse.succes(reponse, "Connexion reussie"));
    }

    @PostMapping("/refresh")
    @SecurityRequirements
    @Operation(
            summary = "Renouveler le jeton d'acces",
            description = "A appeler quand le jeton d'acces expire. Retourne un nouveau couple de jetons."
    )
    public ResponseEntity<ApiResponse<JetonReponseDto>> rafraichir(
            @Valid @RequestBody RafraichissementRequestDto dto
    ) {
        JetonReponseDto reponse = authService.rafraichir(dto);

        return ResponseEntity.ok(ApiResponse.succes(reponse, "Jetons renouveles"));
    }

    @GetMapping("/me")
    @Operation(
            summary = "Profil courant",
            description = "Retourne les informations de l'etudiant authentifie."
    )
    public ResponseEntity<ApiResponse<UtilisateurReponseDto>> profil() {
        UtilisateurReponseDto reponse = authService.profilCourant();

        return ResponseEntity.ok(ApiResponse.succes(reponse, "Profil recupere"));
    }
}
