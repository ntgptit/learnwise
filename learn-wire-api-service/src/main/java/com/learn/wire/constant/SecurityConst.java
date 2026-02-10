package com.learn.wire.constant;

public final class SecurityConst {

    private SecurityConst() {
    }

    public static final String SECURITY_PROPERTIES_PREFIX = "app.security";
    public static final String JWT_SECRET_ALGORITHM = "HmacSHA256";

    public static final String API_DOCS_PATH = "/v3/api-docs/**";
    public static final String SWAGGER_UI_PATH = "/swagger-ui/**";
    public static final String SWAGGER_UI_HTML_PATH = "/swagger-ui.html";

    public static final String HTTP_METHOD_GET = "GET";
    public static final String HTTP_METHOD_POST = "POST";
    public static final String HTTP_METHOD_PUT = "PUT";
    public static final String HTTP_METHOD_PATCH = "PATCH";
    public static final String HTTP_METHOD_DELETE = "DELETE";
    public static final String HTTP_METHOD_OPTIONS = "OPTIONS";

    public static final String HEADER_AUTHORIZATION = "Authorization";
    public static final String HEADER_CONTENT_TYPE = "Content-Type";
    public static final String HEADER_ACCEPT = "Accept";
    public static final String HEADER_X_REQUESTED_WITH = "X-Requested-With";
    public static final String HEADER_LOCATION = "Location";

    public static final long CORS_MAX_AGE_SECONDS = 3600L;
}
