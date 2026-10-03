package iibs.campustasks.service;

import iibs.campustasks.controller.dto.*;

public interface AuthService {

    JetonReponseDto inscrire(InscriptionRequestDto dto);

    JetonReponseDto connecter(ConnexionRequestDto dto);

    JetonReponseDto rafraichir(RafraichissementRequestDto dto);

    UtilisateurReponseDto profilCourant();
}
