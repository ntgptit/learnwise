package com.learn.wire.constant;

public final class AuthConst {

    private AuthConst() {
    }

    public static final String USER_TABLE_NAME = "app_users";
    public static final String REFRESH_TOKEN_TABLE_NAME = "auth_refresh_tokens";

    public static final int EMAIL_MAX_LENGTH = 255;
    public static final int PASSWORD_MIN_LENGTH = 8;
    public static final int PASSWORD_MAX_LENGTH = 120;
    public static final int DISPLAY_NAME_MAX_LENGTH = 120;
    public static final int TOKEN_HASH_MAX_LENGTH = 128;

    public static final int REFRESH_TOKEN_RANDOM_BYTE_SIZE = 48;

    public static final String EMAIL_REQUIRED_KEY = ErrorMessageConst.AUTH_VALIDATION_EMAIL_REQUIRED;
    public static final String EMAIL_INVALID_KEY = ErrorMessageConst.AUTH_VALIDATION_EMAIL_INVALID;
    public static final String EMAIL_TOO_LONG_KEY = ErrorMessageConst.AUTH_VALIDATION_EMAIL_TOO_LONG;
    public static final String PASSWORD_REQUIRED_KEY = ErrorMessageConst.AUTH_VALIDATION_PASSWORD_REQUIRED;
    public static final String PASSWORD_TOO_SHORT_KEY = ErrorMessageConst.AUTH_VALIDATION_PASSWORD_TOO_SHORT;
    public static final String PASSWORD_TOO_LONG_KEY = ErrorMessageConst.AUTH_VALIDATION_PASSWORD_TOO_LONG;
    public static final String DISPLAY_NAME_TOO_LONG_KEY = ErrorMessageConst.AUTH_VALIDATION_DISPLAY_NAME_TOO_LONG;
    public static final String REFRESH_TOKEN_REQUIRED_KEY = ErrorMessageConst.AUTH_VALIDATION_REFRESH_TOKEN_REQUIRED;

    public static final String EMAIL_ALREADY_EXISTS_KEY = ErrorMessageConst.AUTH_ERROR_EMAIL_ALREADY_EXISTS;
    public static final String INVALID_CREDENTIALS_KEY = ErrorMessageConst.AUTH_ERROR_INVALID_CREDENTIALS;
    public static final String REFRESH_TOKEN_INVALID_KEY = ErrorMessageConst.AUTH_ERROR_REFRESH_TOKEN_INVALID;
    public static final String UNAUTHORIZED_KEY = ErrorMessageConst.AUTH_ERROR_UNAUTHORIZED;

    public static final String EMAIL_REQUIRED_MESSAGE = "{" + EMAIL_REQUIRED_KEY + "}";
    public static final String EMAIL_INVALID_MESSAGE = "{" + EMAIL_INVALID_KEY + "}";
    public static final String EMAIL_TOO_LONG_MESSAGE = "{" + EMAIL_TOO_LONG_KEY + "}";
    public static final String PASSWORD_REQUIRED_MESSAGE = "{" + PASSWORD_REQUIRED_KEY + "}";
    public static final String PASSWORD_TOO_SHORT_MESSAGE = "{" + PASSWORD_TOO_SHORT_KEY + "}";
    public static final String PASSWORD_TOO_LONG_MESSAGE = "{" + PASSWORD_TOO_LONG_KEY + "}";
    public static final String DISPLAY_NAME_TOO_LONG_MESSAGE = "{" + DISPLAY_NAME_TOO_LONG_KEY + "}";
    public static final String REFRESH_TOKEN_REQUIRED_MESSAGE = "{" + REFRESH_TOKEN_REQUIRED_KEY + "}";
}
