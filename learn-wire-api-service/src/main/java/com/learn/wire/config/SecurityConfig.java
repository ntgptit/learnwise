package com.learn.wire.config;

import java.nio.charset.StandardCharsets;
import java.util.List;

import javax.crypto.spec.SecretKeySpec;

import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.oauth2.jose.jws.MacAlgorithm;
import org.springframework.security.oauth2.jwt.JwtDecoder;
import org.springframework.security.oauth2.jwt.JwtEncoder;
import org.springframework.security.oauth2.jwt.NimbusJwtDecoder;
import org.springframework.security.oauth2.jwt.NimbusJwtEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import com.learn.wire.constant.ApiConst;
import com.learn.wire.constant.SecurityConst;
import com.learn.wire.security.SecurityProperties;
import com.nimbusds.jose.jwk.source.ImmutableSecret;

import lombok.RequiredArgsConstructor;

@Configuration
@RequiredArgsConstructor
@EnableConfigurationProperties(SecurityProperties.class)
public class SecurityConfig {

    private final SecurityProperties securityProperties;

    @Bean
    SecurityFilterChain securityFilterChain(HttpSecurity http) {
        http.csrf(AbstractHttpConfigurer::disable);
        http.formLogin(AbstractHttpConfigurer::disable);
        http.httpBasic(AbstractHttpConfigurer::disable);
        http.cors(Customizer.withDefaults());
        http.sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS));
        http.oauth2ResourceServer(oauth2 -> oauth2.jwt(Customizer.withDefaults()));
        http.authorizeHttpRequests(authorize -> authorize
                .requestMatchers(
                        SecurityConst.API_DOCS_PATH,
                        SecurityConst.SWAGGER_UI_PATH,
                        SecurityConst.SWAGGER_UI_HTML_PATH,
                        ApiConst.AUTH_REGISTER_PATH,
                        ApiConst.AUTH_LOGIN_PATH,
                        ApiConst.AUTH_REFRESH_PATH)
                .permitAll()
                .anyRequest()
                .authenticated());
        return http.build();
    }

    @Bean
    CorsConfigurationSource corsConfigurationSource() {
        final var corsConfiguration = new CorsConfiguration();
        corsConfiguration.setAllowCredentials(true);
        corsConfiguration.setAllowedOrigins(this.securityProperties.getCorsAllowedOrigins());
        corsConfiguration.setAllowedMethods(List.of(
                SecurityConst.HTTP_METHOD_GET,
                SecurityConst.HTTP_METHOD_POST,
                SecurityConst.HTTP_METHOD_PUT,
                SecurityConst.HTTP_METHOD_PATCH,
                SecurityConst.HTTP_METHOD_DELETE,
                SecurityConst.HTTP_METHOD_OPTIONS));
        corsConfiguration.setAllowedHeaders(List.of(
                SecurityConst.HEADER_AUTHORIZATION,
                SecurityConst.HEADER_CONTENT_TYPE,
                SecurityConst.HEADER_ACCEPT,
                SecurityConst.HEADER_X_REQUESTED_WITH));
        corsConfiguration.setExposedHeaders(List.of(SecurityConst.HEADER_LOCATION));
        corsConfiguration.setMaxAge(SecurityConst.CORS_MAX_AGE_SECONDS);

        final var source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", corsConfiguration);
        return source;
    }

    @Bean
    JwtDecoder jwtDecoder() {
        final var keyBytes = this.securityProperties.getJwtSecret().getBytes(StandardCharsets.UTF_8);
        final var key = new SecretKeySpec(keyBytes, SecurityConst.JWT_SECRET_ALGORITHM);
        return NimbusJwtDecoder.withSecretKey(key).macAlgorithm(MacAlgorithm.HS256).build();
    }

    @Bean
    JwtEncoder jwtEncoder() {
        final var keyBytes = this.securityProperties.getJwtSecret().getBytes(StandardCharsets.UTF_8);
        final var key = new SecretKeySpec(keyBytes, SecurityConst.JWT_SECRET_ALGORITHM);
        return new NimbusJwtEncoder(new ImmutableSecret<>(key));
    }

    @Bean
    PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}
