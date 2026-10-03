package iibs.campustasks.security;

import iibs.campustasks.entity.*;

import java.util.*;

public interface ContexteSecurite {

    Optional<Utilisateur> utilisateurCourant();

    Utilisateur utilisateurCourantRequis();

    Optional<Long> identifiantCourant();

    Optional<String> emailCourant();
}
