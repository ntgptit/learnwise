package com.learn.wire.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.learn.wire.constant.ApiConst;
import com.learn.wire.constant.ApiDocConst;
import com.learn.wire.constant.LogConst;
import com.learn.wire.dto.auth.request.AuthLoginRequest;
import com.learn.wire.dto.auth.request.AuthRefreshRequest;
import com.learn.wire.dto.auth.request.AuthRegisterRequest;
import com.learn.wire.dto.auth.request.AuthUpdateProfileRequest;
import com.learn.wire.dto.auth.request.AuthUpdateSettingsRequest;
import com.learn.wire.dto.auth.response.AuthMeResponse;
import com.learn.wire.dto.auth.response.AuthTokenResponse;
import com.learn.wire.service.AuthService;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@RestController
@Tag(name = ApiDocConst.TAG_AUTH)
@RequestMapping(ApiConst.AUTH_PATH)
@Slf4j
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping(ApiConst.AUTH_REGISTER_SUB_PATH)
    @Operation(summary = ApiDocConst.AUTH_OPERATION_REGISTER_USER)
    ResponseEntity<AuthTokenResponse> register(@Valid @RequestBody AuthRegisterRequest request) {
        final AuthTokenResponse response = this.authService.register(request);
        log.info(LogConst.AUTH_CONTROLLER_REGISTERED_USER_ID, response.userId());
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @PostMapping(ApiConst.AUTH_LOGIN_SUB_PATH)
    @Operation(summary = ApiDocConst.AUTH_OPERATION_LOGIN_USER)
    ResponseEntity<AuthTokenResponse> login(@Valid @RequestBody AuthLoginRequest request) {
        final AuthTokenResponse response = this.authService.login(request);
        return ResponseEntity.ok(response);
    }

    @PostMapping(ApiConst.AUTH_REFRESH_SUB_PATH)
    @Operation(summary = ApiDocConst.AUTH_OPERATION_REFRESH_ACCESS_TOKEN)
    ResponseEntity<AuthTokenResponse> refresh(@Valid @RequestBody AuthRefreshRequest request) {
        final AuthTokenResponse response = this.authService.refresh(request);
        return ResponseEntity.ok(response);
    }

    @GetMapping(ApiConst.AUTH_ME_SUB_PATH)
    @Operation(summary = ApiDocConst.AUTH_OPERATION_GET_CURRENT_USER)
    ResponseEntity<AuthMeResponse> me() {
        final AuthMeResponse response = this.authService.me();
        return ResponseEntity.ok(response);
    }

    @PatchMapping(ApiConst.AUTH_ME_SUB_PATH)
    @Operation(summary = ApiDocConst.AUTH_OPERATION_UPDATE_CURRENT_USER_PROFILE)
    ResponseEntity<AuthMeResponse> updateMe(@Valid @RequestBody AuthUpdateProfileRequest request) {
        final AuthMeResponse response = this.authService.updateMe(request);
        return ResponseEntity.ok(response);
    }

    @PatchMapping(ApiConst.AUTH_ME_SETTINGS_SUB_PATH)
    @Operation(summary = ApiDocConst.AUTH_OPERATION_UPDATE_CURRENT_USER_SETTINGS)
    ResponseEntity<AuthMeResponse> updateSettings(@Valid @RequestBody AuthUpdateSettingsRequest request) {
        final AuthMeResponse response = this.authService.updateSettings(request);
        return ResponseEntity.ok(response);
    }
}
