package com.learn.wire.dto.folder.request;

import com.learn.wire.constant.FolderConst;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record FolderUpdateRequest(
        @NotBlank(message = FolderConst.NAME_IS_REQUIRED_MESSAGE) @Size(min = FolderConst.NAME_MIN_LENGTH, max = FolderConst.NAME_MAX_LENGTH, message = FolderConst.NAME_TOO_LONG_MESSAGE) String name,

        @Size(max = FolderConst.DESCRIPTION_MAX_LENGTH, message = FolderConst.DESCRIPTION_TOO_LONG_MESSAGE) String description,

        @NotBlank(message = FolderConst.COLOR_HEX_INVALID_MESSAGE) @Pattern(regexp = FolderConst.COLOR_HEX_PATTERN, message = FolderConst.COLOR_HEX_INVALID_MESSAGE) String colorHex,

        Long parentFolderId) {
}
