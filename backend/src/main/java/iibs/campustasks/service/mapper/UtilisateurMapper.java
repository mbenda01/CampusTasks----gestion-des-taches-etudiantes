package iibs.campustasks.service.mapper;

import iibs.campustasks.controller.dto.*;
import iibs.campustasks.entity.*;
import org.mapstruct.*;

@Mapper(
        componentModel = MappingConstants.ComponentModel.SPRING,
        unmappedTargetPolicy = ReportingPolicy.ERROR
)
public interface UtilisateurMapper {

    UtilisateurReponseDto versReponse(Utilisateur utilisateur);
}
