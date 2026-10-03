package iibs.campustasks.config;

import iibs.campustasks.entity.*;
import iibs.campustasks.entity.enums.*;
import iibs.campustasks.repository.*;
import lombok.*;
import lombok.extern.slf4j.*;
import org.springframework.boot.*;
import org.springframework.security.crypto.password.*;
import org.springframework.stereotype.*;

import java.time.*;

@Slf4j
@Component
@RequiredArgsConstructor
public class DonneesInitiales implements CommandLineRunner {

    private final UtilisateurRepository utilisateurRepository;
    private final MatiereRepository matiereRepository;
    private final TacheRepository tacheRepository;
    private final PasswordEncoder encodeurMotDePasse;

    @Override
    public void run(String... args) {
        if (utilisateurRepository.count() > 0) {
            log.debug("Donnees de demarrage deja presentes, initialisation ignoree");
            return;
        }

        LocalDate aujourdHui = LocalDate.now();

        Utilisateur aminata = utilisateurRepository.save(
                Utilisateur.inscrire(
                        "Aminata Diop", "aminata@campustasks.sn",
                        encodeurMotDePasse.encode("motdepasse123")));

        Utilisateur moussa = utilisateurRepository.save(
                Utilisateur.inscrire(
                        "Moussa Fall", "moussa@campustasks.sn",
                        encodeurMotDePasse.encode("motdepasse123")));

        Matiere java = creerMatiere(aminata, "Programmation Java",
                "Spring Boot, JPA et API REST");
        Matiere flutter = creerMatiere(aminata, "Developpement mobile",
                "Flutter, Dart et gestion d'etat");
        Matiere reseaux = creerMatiere(aminata, "Reseaux",
                "Protocoles TCP/IP et administration");

        planifier(aminata, java, "Rendre le TP Spring Security",
                "Securiser l'API avec JWT", aujourdHui.plusDays(2), Priorite.HAUTE, null);
        planifier(aminata, java, "Reviser JPA",
                "Relations et requetes JPQL", aujourdHui.plusDays(6), Priorite.MOYENNE, StatutTache.EN_COURS);
        planifier(aminata, flutter, "Maquettes de l'application",
                "Ecrans de connexion et de liste", aujourdHui.minusDays(3), Priorite.HAUTE, null);
        planifier(aminata, flutter, "Expose sur BLoC",
                "Preparer les diapositives", aujourdHui.plusDays(10), Priorite.BASSE, null);
        planifier(aminata, reseaux, "Compte rendu de TP",
                "Configuration du routage", aujourdHui.minusDays(5), Priorite.MOYENNE, StatutTache.TERMINEE);

        Matiere maths = creerMatiere(moussa, "Mathematiques",
                "Algebre lineaire");

        planifier(moussa, maths, "Exercices chapitre 3",
                "Matrices et determinants", aujourdHui.plusDays(4), Priorite.MOYENNE, null);

        log.info("Donnees de demarrage inserees : {} utilisateurs, {} matieres, {} taches",
                utilisateurRepository.count(), matiereRepository.count(), tacheRepository.count());
    }

    private Matiere creerMatiere(Utilisateur proprietaire, String nom, String description) {
        return matiereRepository.save(Matiere.creer(nom, description, proprietaire));
    }

    private void planifier(
            Utilisateur proprietaire,
            Matiere matiere,
            String titre,
            String description,
            LocalDate dateLimite,
            Priorite priorite,
            StatutTache statut
    ) {
        Tache tache = Tache.planifier(titre, description, matiere, dateLimite, priorite, proprietaire);

        if (statut != null) {
            tache.changerStatut(statut);
        }

        tacheRepository.save(tache);
    }
}
