package com.learn.wire.service.impl;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.time.Instant;
import java.util.Base64;
import java.util.Locale;

import org.apache.commons.lang3.StringUtils;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.oauth2.jose.jws.MacAlgorithm;
import org.springframework.security.oauth2.jwt.JwsHeader;
import org.springframework.security.oauth2.jwt.JwtClaimsSet;
import org.springframework.security.oauth2.jwt.JwtEncoder;
import org.springframework.security.oauth2.jwt.JwtEncoderParameters;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.learn.wire.constant.AuthConst;
import com.learn.wire.constant.LogConst;
import com.learn.wire.constant.SecurityConst;
import com.learn.wire.dto.auth.request.AuthLoginRequest;
import com.learn.wire.dto.auth.request.AuthRefreshRequest;
import com.learn.wire.dto.auth.request.AuthRegisterRequest;
import com.learn.wire.dto.auth.request.AuthUpdateProfileRequest;
import com.learn.wire.dto.auth.request.AuthUpdateSettingsRequest;
import com.learn.wire.dto.auth.query.AuthThemeMode;
import com.learn.wire.dto.auth.response.AuthMeResponse;
import com.learn.wire.dto.auth.response.AuthTokenResponse;
import com.learn.wire.entity.AppUserEntity;
import com.learn.wire.entity.AuthRefreshTokenEntity;
import com.learn.wire.exception.BusinessException;
import com.learn.wire.exception.UnauthorizedException;
import com.learn.wire.repository.AppUserRepository;
import com.learn.wire.repository.AuthRefreshTokenRepository;
import com.learn.wire.security.CurrentUserAccessor;
import com.learn.wire.security.SecurityProperties;
import com.learn.wire.service.AuthService;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@Transactional
@Slf4j
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {

    private final AppUserRepository appUserRepository;
    private final AuthRefreshTokenRepository authRefreshTokenRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtEncoder jwtEncoder;
    private final SecurityProperties securityProperties;
    private final CurrentUserAccessor currentUserAccessor;

    @Override
    public AuthTokenResponse register(AuthRegisterRequest request) {
        final var normalizedEmail = normalizeEmail(request.email());
        final var emailAlreadyExists = this.appUserRepository.existsByNormalizedEmail(normalizedEmail);
        if (emailAlreadyExists) {
            throw new BusinessException(AuthConst.EMAIL_ALREADY_EXISTS_KEY);
        }

        final var user = new AppUserEntity();
        user.setEmail(normalizedEmail);
        user.setNormalizedEmail(normalizedEmail);
        user.setPasswordHash(this.passwordEncoder.encode(request.password()));
        user.setDisplayName(resolveDisplayName(request.displayName(), normalizedEmail));
        applyDefaultSettings(user);
        final var createdUser = this.appUserRepository.save(user);
        log.info(LogConst.AUTH_SERVICE_REGISTERED_NEW_USER, createdUser.getId(), createdUser.getEmail());
        return issueTokenResponse(createdUser);
    }

    @Override
    public AuthTokenResponse login(AuthLoginRequest request) {
        final var normalizedEmail = normalizeEmail(request.email());
        final var user = this.appUserRepository
                .findByNormalizedEmail(normalizedEmail)
                .orElseThrow(() -> new UnauthorizedException(AuthConst.INVALID_CREDENTIALS_KEY));

        final var passwordMatched = this.passwordEncoder.matches(request.password(), user.getPasswordHash());
        if (!passwordMatched) {
            throw new UnauthorizedException(AuthConst.INVALID_CREDENTIALS_KEY);
        }

        return issueTokenResponse(user);
    }

    @Override
    public AuthTokenResponse refresh(AuthRefreshRequest request) {
        final var rawRefreshToken = normalizeRefreshToken(request.refreshToken());
        final var refreshTokenHash = hashRefreshToken(rawRefreshToken);
        final var refreshToken = this.authRefreshTokenRepository
                .findByTokenHashAndRevokedAtIsNull(refreshTokenHash)
                .orElseThrow(() -> new UnauthorizedException(AuthConst.REFRESH_TOKEN_INVALID_KEY));

        final var now = Instant.now();
        if (refreshToken.getExpiresAt().isBefore(now)) {
            refreshToken.setRevokedAt(now);
            refreshToken.setLastUsedAt(now);
            this.authRefreshTokenRepository.save(refreshToken);
            throw new UnauthorizedException(AuthConst.REFRESH_TOKEN_INVALID_KEY);
        }

        final var user = this.appUserRepository
                .findById(refreshToken.getUserId())
                .orElseThrow(() -> new UnauthorizedException(AuthConst.REFRESH_TOKEN_INVALID_KEY));

        final var nextRefreshTokenMaterial = createRefreshTokenMaterial(now);
        final var nextRefreshToken = new AuthRefreshTokenEntity();
        nextRefreshToken.setUserId(user.getId());
        nextRefreshToken.setTokenHash(nextRefreshTokenMaterial.hash());
        nextRefreshToken.setExpiresAt(nextRefreshTokenMaterial.expiresAt());
        this.authRefreshTokenRepository.save(nextRefreshToken);

        refreshToken.setRevokedAt(now);
        refreshToken.setLastUsedAt(now);
        refreshToken.setReplacedByTokenHash(nextRefreshTokenMaterial.hash());
        this.authRefreshTokenRepository.save(refreshToken);

        final var accessToken = createAccessToken(user, now);
        return new AuthTokenResponse(
                accessToken,
                nextRefreshTokenMaterial.rawToken(),
                this.securityProperties.getAccessTokenTtlSeconds(),
                user.getId(),
                user.getEmail(),
                user.getDisplayName());
    }

    @Override
    @Transactional(readOnly = true)
    public AuthMeResponse me() {
        final var currentUser = this.currentUserAccessor.getCurrentUser();
        final var user = this.appUserRepository
                .findById(currentUser.userId())
                .orElseThrow(() -> new UnauthorizedException(AuthConst.UNAUTHORIZED_KEY));
        return toMeResponse(user);
    }

    @Override
    public AuthMeResponse updateMe(AuthUpdateProfileRequest request) {
        final var currentUser = this.currentUserAccessor.getCurrentUser();
        final var user = this.appUserRepository
                .findById(currentUser.userId())
                .orElseThrow(() -> new UnauthorizedException(AuthConst.UNAUTHORIZED_KEY));
        final var normalizedDisplayName = StringUtils.trimToEmpty(request.displayName());
        user.setDisplayName(normalizedDisplayName);
        final var updatedUser = this.appUserRepository.save(user);
        return toMeResponse(updatedUser);
    }

    @Override
    public AuthMeResponse updateSettings(AuthUpdateSettingsRequest request) {
        final var currentUser = this.currentUserAccessor.getCurrentUser();
        final var user = this.appUserRepository
                .findById(currentUser.userId())
                .orElseThrow(() -> new UnauthorizedException(AuthConst.UNAUTHORIZED_KEY));

        final var normalizedThemeMode = AuthThemeMode.fromValue(request.themeMode()).value();
        user.setThemeMode(normalizedThemeMode);
        user.setStudyAutoPlayAudio(request.studyAutoPlayAudio());
        user.setStudyCardsPerSession(request.studyCardsPerSession());

        final var updatedUser = this.appUserRepository.save(user);
        return toMeResponse(updatedUser);
    }

    private AuthTokenResponse issueTokenResponse(AppUserEntity user) {
        final var now = Instant.now();
        final var accessToken = createAccessToken(user, now);
        final var refreshTokenMaterial = createRefreshTokenMaterial(now);

        final var refreshTokenEntity = new AuthRefreshTokenEntity();
        refreshTokenEntity.setUserId(user.getId());
        refreshTokenEntity.setTokenHash(refreshTokenMaterial.hash());
        refreshTokenEntity.setExpiresAt(refreshTokenMaterial.expiresAt());
        this.authRefreshTokenRepository.save(refreshTokenEntity);

        return new AuthTokenResponse(
                accessToken,
                refreshTokenMaterial.rawToken(),
                this.securityProperties.getAccessTokenTtlSeconds(),
                user.getId(),
                user.getEmail(),
                user.getDisplayName());
    }

    private String createAccessToken(AppUserEntity user, Instant issuedAt) {
        final var expiresAt = issuedAt.plusSeconds(this.securityProperties.getAccessTokenTtlSeconds());
        final var claims = JwtClaimsSet.builder()
                .issuer(this.securityProperties.getTokenIssuer())
                .issuedAt(issuedAt)
                .expiresAt(expiresAt)
                .subject(String.valueOf(user.getId()))
                .claim(SecurityConst.JWT_CLAIM_EMAIL, user.getEmail())
                .claim(SecurityConst.JWT_CLAIM_DISPLAY_NAME, user.getDisplayName())
                .build();
        final var header = JwsHeader.with(MacAlgorithm.HS256).build();
        return this.jwtEncoder.encode(JwtEncoderParameters.from(header, claims)).getTokenValue();
    }

    private RefreshTokenMaterial createRefreshTokenMaterial(Instant issuedAt) {
        final var randomBytes = new byte[AuthConst.REFRESH_TOKEN_RANDOM_BYTE_SIZE];
        new java.security.SecureRandom().nextBytes(randomBytes);
        final var rawToken = Base64.getUrlEncoder().withoutPadding().encodeToString(randomBytes);
        final var tokenHash = hashRefreshToken(rawToken);
        final var expiresAt = issuedAt.plusSeconds(this.securityProperties.getRefreshTokenTtlSeconds());
        return new RefreshTokenMaterial(rawToken, tokenHash, expiresAt);
    }

    private String normalizeEmail(String value) {
        return StringUtils.trimToEmpty(value).toLowerCase(Locale.ROOT);
    }

    private String normalizeRefreshToken(String value) {
        final var normalized = StringUtils.trimToEmpty(value);
        if (normalized.isEmpty()) {
            throw new UnauthorizedException(AuthConst.REFRESH_TOKEN_INVALID_KEY);
        }
        return normalized;
    }

    private String resolveDisplayName(String value, String normalizedEmail) {
        final var normalizedDisplayName = StringUtils.trimToEmpty(value);
        if (!normalizedDisplayName.isEmpty()) {
            return normalizedDisplayName;
        }
        final var separatorIndex = normalizedEmail.indexOf(AuthConst.EMAIL_ADDRESS_SEPARATOR);
        if (separatorIndex > 0) {
            return normalizedEmail.substring(0, separatorIndex);
        }
        return normalizedEmail;
    }

    private void applyDefaultSettings(AppUserEntity user) {
        user.setThemeMode(AuthConst.THEME_MODE_DEFAULT);
        user.setStudyAutoPlayAudio(AuthConst.STUDY_AUTO_PLAY_AUDIO_DEFAULT);
        user.setStudyCardsPerSession(AuthConst.STUDY_CARDS_PER_SESSION_DEFAULT);
    }

    private String resolveThemeMode(String value) {
        final String normalizedValue = StringUtils.trimToNull(value);
        if (normalizedValue == null) {
            return AuthConst.THEME_MODE_DEFAULT;
        }
        return AuthThemeMode.fromValue(normalizedValue).value();
    }

    private Boolean resolveStudyAutoPlayAudio(Boolean value) {
        if (value == null) {
            return AuthConst.STUDY_AUTO_PLAY_AUDIO_DEFAULT;
        }
        return value;
    }

    private Integer resolveStudyCardsPerSession(Integer value) {
        if (value == null) {
            return AuthConst.STUDY_CARDS_PER_SESSION_DEFAULT;
        }
        return value;
    }

    private String hashRefreshToken(String rawToken) {
        final MessageDigest digest;
        try {
            digest = MessageDigest.getInstance(AuthConst.HASH_ALGORITHM_SHA_256);
        } catch (final NoSuchAlgorithmException exception) {
            throw new IllegalStateException(AuthConst.HASH_ALGORITHM_UNAVAILABLE_MESSAGE, exception);
        }
        final var encodedHash = digest.digest(rawToken.getBytes(StandardCharsets.UTF_8));
        return toHex(encodedHash);
    }

    private String toHex(byte[] bytes) {
        final var builder = new StringBuilder();
        for (final byte value : bytes) {
            final var hex = Integer.toHexString(AuthConst.HEX_UNSIGNED_BYTE_MASK & value);
            if (hex.length() == 1) {
                builder.append(AuthConst.HEX_LEADING_ZERO_CHAR);
            }
            builder.append(hex);
        }
        return builder.toString();
    }

    private AuthMeResponse toMeResponse(AppUserEntity user) {
        return new AuthMeResponse(
                user.getId(),
                user.getEmail(),
                user.getDisplayName(),
                resolveThemeMode(user.getThemeMode()),
                resolveStudyAutoPlayAudio(user.getStudyAutoPlayAudio()),
                resolveStudyCardsPerSession(user.getStudyCardsPerSession()));
    }

    private record RefreshTokenMaterial(
            String rawToken,
            String hash,
            Instant expiresAt) {
    }
}
