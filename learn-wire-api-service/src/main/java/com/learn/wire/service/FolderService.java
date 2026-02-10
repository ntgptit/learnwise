package com.learn.wire.service;

import com.learn.wire.dto.common.response.PageResponse;
import com.learn.wire.dto.folder.query.FolderListQuery;
import com.learn.wire.dto.folder.request.FolderCreateRequest;
import com.learn.wire.dto.folder.request.FolderUpdateRequest;
import com.learn.wire.dto.folder.response.FolderResponse;

public interface FolderService {

	PageResponse<FolderResponse> getFolders(FolderListQuery query);

	FolderResponse getFolder(Long folderId);

	FolderResponse createFolder(FolderCreateRequest request);

	FolderResponse updateFolder(Long folderId, FolderUpdateRequest request);

	void deleteFolder(Long folderId);
}
