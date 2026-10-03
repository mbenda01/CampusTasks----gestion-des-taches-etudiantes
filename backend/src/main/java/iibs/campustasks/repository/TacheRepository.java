package iibs.campustasks.repository;

import iibs.campustasks.entity.*;
import iibs.campustasks.entity.enums.*;
import org.springframework.data.domain.*;
import org.springframework.data.jpa.domain.*;
import org.springframework.data.jpa.repository.*;
import org.springframework.data.repository.query.*;
import org.springframework.stereotype.*;

import java.time.*;
import java.util.*;

@Repository
public interface TacheRepository extends JpaRepository<Tache, Long>, JpaSpecificationExecutor<Tache> {

    @Override
    @EntityGraph(attributePaths = "matiere")
    Page<Tache> findAll(Specification<Tache> specification, Pageable pageable);

    @EntityGraph(attributePaths = "matiere")
    Optional<Tache> findByIdAndProprietaireId(Long id, Long proprietaireId);

    boolean existsByMatiereId(Long matiereId);

    long countByMatiereId(Long matiereId);

    long countByProprietaireIdAndStatut(Long proprietaireId, StatutTache statut);

    @Query("""
            select count(t) from Tache t
            where t.proprietaire.id = :proprietaireId
              and t.statut <> :statutExclu
              and t.dateLimite < :reference
            """)
    long compterEnRetardAu(
            @Param("proprietaireId") Long proprietaireId,
            @Param("statutExclu") StatutTache statutExclu,
            @Param("reference") LocalDate reference
    );

    @Query("""
            select t from Tache t join fetch t.matiere
            where t.proprietaire.id = :proprietaireId
              and t.statut <> :statutExclu
              and t.dateLimite >= :reference
            order by t.dateLimite asc, t.id asc
            """)
    List<Tache> trouverProchainesEcheances(
            @Param("proprietaireId") Long proprietaireId,
            @Param("statutExclu") StatutTache statutExclu,
            @Param("reference") LocalDate reference,
            Limit limite
    );

    @Query("""
            select t from Tache t join fetch t.matiere
            where t.proprietaire.id = :proprietaireId
              and t.statut <> :statutExclu
              and t.dateLimite < :reference
            order by t.dateLimite asc, t.id asc
            """)
    List<Tache> trouverEnRetard(
            @Param("proprietaireId") Long proprietaireId,
            @Param("statutExclu") StatutTache statutExclu,
            @Param("reference") LocalDate reference,
            Limit limite
    );

    default long compterEnRetard(Long proprietaireId) {
        return compterEnRetardAu(proprietaireId, StatutTache.TERMINEE, LocalDate.now());
    }

    default List<Tache> listerProchainesEcheances(Long proprietaireId, int nombre) {
        return trouverProchainesEcheances(
                proprietaireId,
                StatutTache.TERMINEE,
                LocalDate.now(),
                Limit.of(nombre)
        );
    }

    default List<Tache> listerEnRetard(Long proprietaireId, int nombre) {
        return trouverEnRetard(
                proprietaireId,
                StatutTache.TERMINEE,
                LocalDate.now(),
                Limit.of(nombre)
        );
    }
}
