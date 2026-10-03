package iibs.campustasks.entity;

import jakarta.persistence.*;
import lombok.*;
import org.springframework.data.annotation.*;
import org.springframework.data.jpa.domain.support.*;

import java.time.*;

@MappedSuperclass
@EntityListeners(AuditingEntityListener.class)
@Getter
@Setter
public abstract class Auditable {

    @CreatedDate
    @Column(updatable = false)
    private LocalDateTime dateCreation;

    @LastModifiedDate
    private LocalDateTime dateModification;

    @CreatedBy
    @Column(updatable = false, length = 150)
    private String creePar;

    @LastModifiedBy
    @Column(length = 150)
    private String modifiePar;
}
