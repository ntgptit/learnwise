package com.learn.wire.service;

import com.learn.wire.dto.auth.request.AuthLoginRequest;
import com.learn.wire.dto.auth.request.AuthRefreshRequest;
import com.learn.wire.dto.auth.request.AuthRegisterRequest;
import com.learn.wire.dto.auth.response.AuthMeResponse;
import com.learn.wire.dto.auth.response.AuthTokenResponse;

public interface AuthService {

    AuthTokenResponse register(AuthRegisterRequest request);

    AuthTokenResponse login(AuthLoginRequest request);

    AuthTokenResponse refresh(AuthRefreshRequest request);

    AuthMeResponse me();
}
