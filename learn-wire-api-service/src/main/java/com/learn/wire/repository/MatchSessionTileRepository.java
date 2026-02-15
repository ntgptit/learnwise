package com.learn.wire.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.learn.wire.entity.MatchSessionTileEntity;

public interface MatchSessionTileRepository extends JpaRepository<MatchSessionTileEntity, Long> {

    List<MatchSessionTileEntity> findBySessionIdAndSideOrderByTileOrderAsc(Long sessionId, String side);

    Optional<MatchSessionTileEntity> findBySessionIdAndId(Long sessionId, Long id);

    long countBySessionIdAndMatchedTrue(Long sessionId);
}
