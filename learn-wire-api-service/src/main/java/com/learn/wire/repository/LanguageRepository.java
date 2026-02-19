package com.learn.wire.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.learn.wire.entity.LanguageEntity;

public interface LanguageRepository extends JpaRepository<LanguageEntity, String> {

    List<LanguageEntity> findByIsActiveTrueOrderBySortOrderAsc();
}
