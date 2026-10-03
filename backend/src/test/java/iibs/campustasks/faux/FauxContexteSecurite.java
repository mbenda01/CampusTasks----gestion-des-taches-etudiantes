package iibs.campustasks.faux;

import iibs.campustasks.entity.*;
import iibs.campustasks.exception.*;
import iibs.campustasks.security.*;

import java.util.*;

public class FauxContexteSecurite implements ContexteSecurite {

    private Utilisateur utilisateur;

    public FauxContexteSecurite() {
        this.utilisateur = null;
    }

    public FauxContexteSecurite(Utilisateur utilisateur) {
        this.utilisateur = utilisateur;
    }

    public void connecter(Utilisateur utilisateur) {
        this.utilisateur = utilisateur;
    }

    public void deconnecter() {
        this.utilisateur = null;
    }

    @Override
    public Optional<Utilisateur> utilisateurCourant() {
        return Optional.ofNullable(utilisateur);
    }

    @Override
    public Utilisateur utilisateurCourantRequis() {
        return utilisateurCourant()
                .orElseThrow(() -> new AccesRefuseException("Authentification requise"));
    }

    @Override
    public Optional<Long> identifiantCourant() {
        return utilisateurCourant().map(Utilisateur::getId);
    }

    @Override
    public Optional<String> emailCourant() {
        return utilisateurCourant().map(Utilisateur::getEmail);
    }
}
