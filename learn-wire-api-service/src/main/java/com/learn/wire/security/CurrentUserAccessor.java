package com.learn.wire.security;

import org.apache.commons.lang3.StringUtils;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;
import org.springframework.stereotype.Component;

import com.learn.wire.constant.AuthConst;
import com.learn.wire.constant.SecurityConst;
import com.learn.wire.exception.UnauthorizedException;

@Component
public class CurrentUserAccessor {

    public CurrentUser getCurrentUser() {
        final Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (!(authentication instanceof JwtAuthenticationToken jwtAuthenticationToken)) {
            throw new UnauthorizedException(AuthConst.UNAUTHORIZED_KEY);
        }
        final Jwt jwt = jwtAuthenticationToken.getToken();
        final Long userId = parseUserId(jwt.getSubject());
        final String email = jwt.getClaimAsString(SecurityConst.JWT_CLAIM_EMAIL);
        if (StringUtils.isBlank(email)) {
            throw new UnauthorizedException(AuthConst.UNAUTHORIZED_KEY);
        }
        return new CurrentUser(userId, email);
    }

    public String getCurrentActor() {
        return getCurrentUser().actor();
    }

    public Long getCurrentUserId() {
        return getCurrentUser().userId();
    }

    private Long parseUserId(String rawSubject) {
        final String normalizedSubject = StringUtils.trimToEmpty(rawSubject);
        if (normalizedSubject.isEmpty()) {
            throw new UnauthorizedException(AuthConst.UNAUTHORIZED_KEY);
        }
        try {
            return Long.parseLong(normalizedSubject);
        } catch (NumberFormatException exception) {
            throw new UnauthorizedException(AuthConst.UNAUTHORIZED_KEY);
        }
    }
}
