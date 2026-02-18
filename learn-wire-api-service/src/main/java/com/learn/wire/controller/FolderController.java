package com.learn.wire.controller;

import com.learn.wire.constant.ApiConst;
import com.learn.wire.constant.ApiDocConst;
import com.learn.wire.constant.LogConst;
import com.learn.wire.dto.common.response.PageResponse;
import com.learn.wire.dto.folder.query.FolderListQuery;
import com.learn.wire.dto.folder.request.FolderCreateRequest;
import com.learn.wire.dto.folder.request.FolderListRequest;
import com.learn.wire.dto.folder.request.FolderUpdateRequest;
import com.learn.wire.dto.folder.response.FolderResponse;
import com.learn.wire.service.FolderService;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@Tag(name = ApiDocConst.TAG_FOLDERS)
@RequestMapping(ApiConst.FOLDERS_PATH)
@Slf4j
@RequiredArgsConstructor
public class FolderController {

	private final FolderService folderService;

	@GetMapping
	@Operation(summary = ApiDocConst.FOLDER_OPERATION_GET_LIST)
	ResponseEntity<PageResponse<FolderResponse>> getFolders(@ModelAttribute FolderListRequest request) {
		FolderListQuery query = FolderListQuery.fromRequest(request);
		log.debug(LogConst.FOLDER_CONTROLLER_GET_LIST, query.page(), query.size(), query.parentFolderId());
		return ResponseEntity.ok(folderService.getFolders(query));
	}

	@GetMapping(ApiConst.FOLDER_ID_SUB_PATH)
	@Operation(summary = ApiDocConst.FOLDER_OPERATION_GET_BY_ID)
	ResponseEntity<FolderResponse> getFolder(@PathVariable Long folderId) {
		log.debug(LogConst.FOLDER_CONTROLLER_GET_BY_ID, folderId);
		return ResponseEntity.ok(folderService.getFolder(folderId));
	}

	@PostMapping
	@Operation(summary = ApiDocConst.FOLDER_OPERATION_CREATE)
	ResponseEntity<FolderResponse> createFolder(
		@Valid @RequestBody FolderCreateRequest request
	) {
		FolderResponse response = folderService.createFolder(request);
		log.info(LogConst.FOLDER_CONTROLLER_CREATED, response.id());
		return ResponseEntity.status(HttpStatus.CREATED).body(response);
	}

	@PutMapping(ApiConst.FOLDER_ID_SUB_PATH)
	@Operation(summary = ApiDocConst.FOLDER_OPERATION_UPDATE)
	ResponseEntity<FolderResponse> updateFolder(
		@PathVariable Long folderId,
		@Valid @RequestBody FolderUpdateRequest request
	) {
		log.info(LogConst.FOLDER_CONTROLLER_UPDATED, folderId);
		return ResponseEntity.ok(folderService.updateFolder(folderId, request));
	}

	@DeleteMapping(ApiConst.FOLDER_ID_SUB_PATH)
	@Operation(summary = ApiDocConst.FOLDER_OPERATION_DELETE)
	ResponseEntity<Void> deleteFolder(@PathVariable Long folderId) {
		log.info(LogConst.FOLDER_CONTROLLER_DELETED, folderId);
		folderService.deleteFolder(folderId);
		return ResponseEntity.noContent().build();
	}
}
