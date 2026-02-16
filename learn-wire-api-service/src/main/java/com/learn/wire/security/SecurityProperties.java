package com.learn.wire.security;

import java.util.List;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.validation.annotation.Validated;

import com.learn.wire.constant.SecurityConst;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Positive;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Validated
@ConfigurationProperties(prefix = SecurityConst.SECURITY_PROPERTIES_PREFIX)
public class SecurityProperties {

    @NotBlank
    private String jwtSecret;

    @NotEmpty
    private List<String> corsAllowedOrigins;

    @Positive
    private long accessTokenTtlSeconds = 900L;

    @Positive
    private long refreshTokenTtlSeconds = 2592000L;

    @NotBlank
    private String tokenIssuer = "learnwise-api";
}
