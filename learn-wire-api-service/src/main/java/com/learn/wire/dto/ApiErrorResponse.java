package com.learn.wire.dto;

import java.time.Instant;

public record ApiErrorResponse(
	String code,
	String message,
	String detail,
	String path,
	Instant timestamp
) {

	public static ApiErrorResponse of(String code, String message, String detail, String path) {
		return new ApiErrorResponse(code, message, detail, path, Instant.now());
	}
}
