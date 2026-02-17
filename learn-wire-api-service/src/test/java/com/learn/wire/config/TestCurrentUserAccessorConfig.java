package com.learn.wire.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;

import com.learn.wire.constant.StudyConst;
import com.learn.wire.security.CurrentUser;
import com.learn.wire.security.CurrentUserAccessor;

@Configuration(proxyBeanMethods = false)
public class TestCurrentUserAccessorConfig {

    private static final Long TEST_USER_ID = 1L;
    private static final String TEST_EMAIL = "test-user@learnwise.local";
    private static final String TEST_ACTOR = StudyConst.DEFAULT_ACTOR;

    @Bean
    @Primary
    CurrentUserAccessor currentUserAccessor() {
        return new CurrentUserAccessor() {
            @Override
            public CurrentUser getCurrentUser() {
                return new CurrentUser(TEST_USER_ID, TEST_EMAIL);
            }

            @Override
            public String getCurrentActor() {
                return TEST_ACTOR;
            }

            @Override
            public Long getCurrentUserId() {
                return TEST_USER_ID;
            }
        };
    }
}
