package com.learn.wire.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.learn.wire.entity.MatchSessionTileEntity;

public interface MatchSessionTileRepository extends JpaRepository<MatchSessionTileEntity, Long> {

    List<MatchSessionTileEntity> findByModeStateIdAndSideOrderByTileOrderAsc(Long modeStateId, String side);

    Optional<MatchSessionTileEntity> findByModeStateIdAndId(Long modeStateId, Long id);

    long countByModeStateIdAndMatchedTrue(Long modeStateId);
}
