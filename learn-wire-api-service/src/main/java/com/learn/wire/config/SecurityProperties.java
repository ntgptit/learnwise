package com.learn.wire.config;

import java.util.List;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.validation.annotation.Validated;

import com.learn.wire.constant.SecurityConst;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
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
}
