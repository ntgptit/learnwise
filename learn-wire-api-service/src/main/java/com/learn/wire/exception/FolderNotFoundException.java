package com.learn.wire.exception;

import org.springframework.http.HttpStatus;

import com.learn.wire.constant.ApiConst;
import com.learn.wire.constant.ErrorMessageConst;

public class FolderNotFoundException extends ApiException {

    private static final long serialVersionUID = 1L;

    public FolderNotFoundException(Long folderId) {
        super(
                ApiConst.ERROR_CODE_FOLDER_NOT_FOUND,
                HttpStatus.NOT_FOUND,
                ErrorMessageConst.FOLDER_ERROR_NOT_FOUND,
                folderId);
    }
}
