package com.learn.wire.controller;

import com.learn.wire.constant.ApiConst;
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
@Tag(name = "Folders")
@RequestMapping(ApiConst.FOLDERS_PATH)
@Slf4j
@RequiredArgsConstructor
public class FolderController {

	private final FolderService folderService;

	@GetMapping
	@Operation(summary = "Get folder list")
	ResponseEntity<PageResponse<FolderResponse>> getFolders(@ModelAttribute FolderListRequest request) {
		FolderListQuery query = FolderListQuery.fromRequest(request);
		log.debug("Get folders with page={}, size={}, parentFolderId={}", query.page(), query.size(), query.parentFolderId());
		return ResponseEntity.ok(folderService.getFolders(query));
	}

	@GetMapping("/{folderId}")
	@Operation(summary = "Get folder by id")
	ResponseEntity<FolderResponse> getFolder(@PathVariable Long folderId) {
		log.debug("Get folder by id={}", folderId);
		return ResponseEntity.ok(folderService.getFolder(folderId));
	}

	@PostMapping
	@Operation(summary = "Create folder")
	ResponseEntity<FolderResponse> createFolder(
		@Valid @RequestBody FolderCreateRequest request
	) {
		FolderResponse response = folderService.createFolder(request);
		log.info("Created folder with id={}", response.id());
		return ResponseEntity.status(HttpStatus.CREATED).body(response);
	}

	@PutMapping("/{folderId}")
	@Operation(summary = "Update folder")
	ResponseEntity<FolderResponse> updateFolder(
		@PathVariable Long folderId,
		@Valid @RequestBody FolderUpdateRequest request
	) {
		log.info("Update folder id={}", folderId);
		return ResponseEntity.ok(folderService.updateFolder(folderId, request));
	}

	@DeleteMapping("/{folderId}")
	@Operation(summary = "Delete folder")
	ResponseEntity<Void> deleteFolder(@PathVariable Long folderId) {
		log.info("Delete folder id={}", folderId);
		folderService.deleteFolder(folderId);
		return ResponseEntity.noContent().build();
	}
}
