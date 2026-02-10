package com.learn.wire.mapper;

import com.learn.wire.dto.folder.request.FolderCreateRequest;
import com.learn.wire.dto.folder.request.FolderUpdateRequest;
import com.learn.wire.entity.FolderEntity;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;

@Mapper(componentModel = "spring")
public interface FolderMapper {

	@Mapping(target = "id", ignore = true)
	@Mapping(target = "directFlashcardCount", ignore = true)
	@Mapping(target = "aggregateFlashcardCount", ignore = true)
	@Mapping(target = "createdBy", ignore = true)
	@Mapping(target = "updatedBy", ignore = true)
	@Mapping(target = "deletedBy", ignore = true)
	@Mapping(target = "createdAt", ignore = true)
	@Mapping(target = "updatedAt", ignore = true)
	@Mapping(target = "deletedAt", ignore = true)
	FolderEntity toEntity(FolderCreateRequest request);

	@Mapping(target = "id", ignore = true)
	@Mapping(target = "directFlashcardCount", ignore = true)
	@Mapping(target = "aggregateFlashcardCount", ignore = true)
	@Mapping(target = "createdBy", ignore = true)
	@Mapping(target = "updatedBy", ignore = true)
	@Mapping(target = "deletedBy", ignore = true)
	@Mapping(target = "createdAt", ignore = true)
	@Mapping(target = "updatedAt", ignore = true)
	@Mapping(target = "deletedAt", ignore = true)
	void updateEntity(FolderUpdateRequest request, @MappingTarget FolderEntity entity);
}
