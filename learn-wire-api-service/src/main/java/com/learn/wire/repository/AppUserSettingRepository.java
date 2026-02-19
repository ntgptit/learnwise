package com.learn.wire.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.learn.wire.entity.AppUserSettingEntity;

public interface AppUserSettingRepository extends JpaRepository<AppUserSettingEntity, Long> {

    Optional<AppUserSettingEntity> findByUserId(Long userId);
}
