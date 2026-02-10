package com.learn.wire.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import com.learn.wire.constant.ApiConst;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;

@Configuration
public class OpenApiConfig {

    @Bean
    OpenAPI openAPI() {
        return new OpenAPI().info(new Info()
                .title(ApiConst.OPEN_API_TITLE)
                .description(ApiConst.OPEN_API_DESCRIPTION)
                .version(ApiConst.OPEN_API_VERSION));
    }
}
