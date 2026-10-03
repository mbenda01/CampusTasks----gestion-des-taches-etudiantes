package iibs.campustasks.service.mapper;

import iibs.campustasks.controller.dto.*;
import iibs.campustasks.entity.*;
import org.mapstruct.*;

import java.util.*;

@Mapper(
        componentModel = MappingConstants.ComponentModel.SPRING,
        unmappedTargetPolicy = ReportingPolicy.ERROR
)
public interface MatiereMapper {

    MatiereReponseDto versReponse(Matiere matiere);

    List<MatiereReponseDto> versReponses(List<Matiere> matieres);
}
