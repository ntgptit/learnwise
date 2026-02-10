package com.learn.wire.dto.folder.request;

import com.learn.wire.constant.FolderConst;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class FolderListRequest {

    private int page = FolderConst.DEFAULT_PAGE;
    private int size = FolderConst.DEFAULT_SIZE;
    private String search = "";
    private Long parentFolderId;
    private String sortBy = FolderConst.SORT_BY_CREATED_AT;
    private String sortDirection = FolderConst.SORT_DIRECTION_DESC;
}
