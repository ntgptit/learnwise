package com.learn.wire.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.learn.wire.entity.AppUserEntity;

public interface AppUserRepository extends JpaRepository<AppUserEntity, Long> {

    boolean existsByNormalizedEmail(String normalizedEmail);

    Optional<AppUserEntity> findByNormalizedEmail(String normalizedEmail);
}
