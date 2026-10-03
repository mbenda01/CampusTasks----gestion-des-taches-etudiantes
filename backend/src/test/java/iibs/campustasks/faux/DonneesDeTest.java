package iibs.campustasks.faux;

import iibs.campustasks.entity.*;

import java.lang.reflect.*;
import java.time.*;

public final class DonneesDeTest {

    public static final String EMPREINTE = "$2a$10$empreinte.factice.pour.les.tests";

    private DonneesDeTest() {
    }

    public static Utilisateur etudiant(Long id, String nom, String email) {
        Utilisateur utilisateur = Utilisateur.inscrire(nom, email, EMPREINTE);
        poserIdentifiant(utilisateur, id);
        return utilisateur;
    }

    public static Utilisateur aminata() {
        return etudiant(1L, "Aminata Diop", "aminata@test.sn");
    }

    public static Utilisateur moussa() {
        return etudiant(2L, "Moussa Fall", "moussa@test.sn");
    }

    public static Matiere matiere(Long id, String nom, Utilisateur proprietaire) {
        Matiere matiere = Matiere.creer(nom, "Description de test", proprietaire);
        poserIdentifiant(matiere, id);
        return matiere;
    }

    public static Tache tache(
            Long id,
            String titre,
            Matiere matiere,
            LocalDate dateLimite,
            Utilisateur proprietaire
    ) {
        Tache tache = Tache.planifier(titre, "Description de test", matiere, dateLimite, null, proprietaire);
        poserIdentifiant(tache, id);
        return tache;
    }

    private static void poserIdentifiant(Object entite, Long id) {
        if (id == null) return;

        Class<?> classe = entite.getClass();

        while (classe != null) {
            try {
                Field champ = classe.getDeclaredField("id");
                champ.setAccessible(true);
                champ.set(entite, id);
                return;
            } catch (NoSuchFieldException exception) {
                classe = classe.getSuperclass();
            } catch (IllegalAccessException exception) {
                throw new IllegalStateException(
                        "Impossible de poser l'identifiant de test", exception);
            }
        }

        throw new IllegalStateException(
                "Champ id introuvable sur " + entite.getClass().getName());
    }
}
