package com.learn.wire.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.learn.wire.entity.AuthRefreshTokenEntity;

public interface AuthRefreshTokenRepository extends JpaRepository<AuthRefreshTokenEntity, Long> {

    Optional<AuthRefreshTokenEntity> findByTokenHashAndRevokedAtIsNull(String tokenHash);
}
