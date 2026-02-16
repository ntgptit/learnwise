package com.learn.wire.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.learn.wire.constant.ApiConst;
import com.learn.wire.dto.auth.request.AuthLoginRequest;
import com.learn.wire.dto.auth.request.AuthRefreshRequest;
import com.learn.wire.dto.auth.request.AuthRegisterRequest;
import com.learn.wire.dto.auth.response.AuthMeResponse;
import com.learn.wire.dto.auth.response.AuthTokenResponse;
import com.learn.wire.service.AuthService;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@RestController
@Tag(name = "Auth")
@RequestMapping(ApiConst.AUTH_PATH)
@Slf4j
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/register")
    @Operation(summary = "Register user")
    ResponseEntity<AuthTokenResponse> register(@Valid @RequestBody AuthRegisterRequest request) {
        final AuthTokenResponse response = this.authService.register(request);
        log.info("Registered user id={}", response.userId());
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PostMapping("/login")
    @Operation(summary = "Login user")
    ResponseEntity<AuthTokenResponse> login(@Valid @RequestBody AuthLoginRequest request) {
        final AuthTokenResponse response = this.authService.login(request);
        return ResponseEntity.ok(response);
    }

    @PostMapping("/refresh")
    @Operation(summary = "Refresh access token")
    ResponseEntity<AuthTokenResponse> refresh(@Valid @RequestBody AuthRefreshRequest request) {
        final AuthTokenResponse response = this.authService.refresh(request);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/me")
    @Operation(summary = "Get current user")
    ResponseEntity<AuthMeResponse> me() {
        final AuthMeResponse response = this.authService.me();
        return ResponseEntity.ok(response);
    }
}
