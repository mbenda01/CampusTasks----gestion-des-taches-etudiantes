package iibs.campustasks.service.mapper;

import iibs.campustasks.controller.dto.*;
import iibs.campustasks.entity.*;
import org.mapstruct.*;

import java.util.*;

@Mapper(
        componentModel = MappingConstants.ComponentModel.SPRING,
        unmappedTargetPolicy = ReportingPolicy.ERROR
)
public interface TacheMapper {

    @Mapping(target = "matiereId", source = "matiere.id")
    @Mapping(target = "matiereNom", source = "matiere.nom")
    @Mapping(target = "enRetard", expression = "java(tache.estEnRetard())")
    TacheReponseDto versReponse(Tache tache);

    List<TacheReponseDto> versReponses(List<Tache> taches);
}
