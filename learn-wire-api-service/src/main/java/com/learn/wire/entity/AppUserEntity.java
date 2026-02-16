package com.learn.wire.entity;

import java.time.Instant;

import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import com.learn.wire.constant.AuthConst;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = AuthConst.USER_TABLE_NAME)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class AppUserEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @Column(name = "email", nullable = false, length = AuthConst.EMAIL_MAX_LENGTH)
    private String email;

    @Column(name = "normalized_email", nullable = false, length = AuthConst.EMAIL_MAX_LENGTH)
    private String normalizedEmail;

    @Column(name = "password_hash", nullable = false, length = AuthConst.PASSWORD_MAX_LENGTH * 2)
    private String passwordHash;

    @Column(name = "display_name", nullable = false, length = AuthConst.DISPLAY_NAME_MAX_LENGTH)
    private String displayName;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;
}
