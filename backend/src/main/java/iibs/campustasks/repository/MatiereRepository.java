package iibs.campustasks.repository;

import iibs.campustasks.entity.*;
import org.springframework.data.domain.*;
import org.springframework.data.jpa.repository.*;
import org.springframework.stereotype.*;

import java.util.*;

@Repository
public interface MatiereRepository extends JpaRepository<Matiere, Long> {

    Page<Matiere> findByProprietaireId(Long proprietaireId, Pageable pageable);

    Optional<Matiere> findByIdAndProprietaireId(Long id, Long proprietaireId);

    boolean existsByProprietaireIdAndNomIgnoreCase(Long proprietaireId, String nom);

    boolean existsByProprietaireIdAndNomIgnoreCaseAndIdNot(Long proprietaireId, String nom, Long id);
}
