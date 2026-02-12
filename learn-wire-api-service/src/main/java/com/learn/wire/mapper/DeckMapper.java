package com.learn.wire.mapper;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;

import com.learn.wire.dto.deck.request.DeckCreateRequest;
import com.learn.wire.dto.deck.request.DeckUpdateRequest;
import com.learn.wire.entity.DeckEntity;

@Mapper(componentModel = "spring")
public interface DeckMapper {

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "folderId", ignore = true)
    @Mapping(target = "normalizedName", ignore = true)
    @Mapping(target = "createdBy", ignore = true)
    @Mapping(target = "updatedBy", ignore = true)
    @Mapping(target = "deletedBy", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    @Mapping(target = "deletedAt", ignore = true)
    DeckEntity toEntity(DeckCreateRequest request);

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "folderId", ignore = true)
    @Mapping(target = "normalizedName", ignore = true)
    @Mapping(target = "createdBy", ignore = true)
    @Mapping(target = "updatedBy", ignore = true)
    @Mapping(target = "deletedBy", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    @Mapping(target = "deletedAt", ignore = true)
    void updateEntity(DeckUpdateRequest request, @MappingTarget DeckEntity entity);
}
