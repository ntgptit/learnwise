package com.learn.wire.mapper;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;

import com.learn.wire.dto.flashcard.request.FlashcardCreateRequest;
import com.learn.wire.dto.flashcard.request.FlashcardUpdateRequest;
import com.learn.wire.entity.FlashcardEntity;

@Mapper(componentModel = "spring")
public interface FlashcardMapper {

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "deckId", ignore = true)
    @Mapping(target = "createdBy", ignore = true)
    @Mapping(target = "updatedBy", ignore = true)
    @Mapping(target = "deletedBy", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    @Mapping(target = "deletedAt", ignore = true)
    FlashcardEntity toEntity(FlashcardCreateRequest request);

    @Mapping(target = "id", ignore = true)
    @Mapping(target = "deckId", ignore = true)
    @Mapping(target = "createdBy", ignore = true)
    @Mapping(target = "updatedBy", ignore = true)
    @Mapping(target = "deletedBy", ignore = true)
    @Mapping(target = "createdAt", ignore = true)
    @Mapping(target = "updatedAt", ignore = true)
    @Mapping(target = "deletedAt", ignore = true)
    void updateEntity(FlashcardUpdateRequest request, @MappingTarget FlashcardEntity entity);
}
