package com.learn.wire.config;

import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

@Testcontainers(disabledWithoutDocker = true)
public abstract class AbstractPostgresIntegrationTest {

    private static final String POSTGRES_IMAGE = "postgres:16-alpine";
    private static final String DB_NAME = "learnwise_test";
    private static final String DB_USERNAME = "learnwise";
    private static final String DB_PASSWORD = "learnwise";
    private static final String POSTGRES_DRIVER = "org.postgresql.Driver";
    private static final String POSTGRES_DIALECT = "org.hibernate.dialect.PostgreSQLDialect";

    @Container
    @SuppressWarnings("resource")
    private static final PostgreSQLContainer<?> POSTGRES_CONTAINER = new PostgreSQLContainer<>(POSTGRES_IMAGE)
            .withDatabaseName(DB_NAME)
            .withUsername(DB_USERNAME)
            .withPassword(DB_PASSWORD);

    @DynamicPropertySource
    static void registerPostgresProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", POSTGRES_CONTAINER::getJdbcUrl);
        registry.add("spring.datasource.username", POSTGRES_CONTAINER::getUsername);
        registry.add("spring.datasource.password", POSTGRES_CONTAINER::getPassword);
        registry.add("spring.datasource.driver-class-name", () -> POSTGRES_DRIVER);
        registry.add("spring.jpa.properties.hibernate.dialect", () -> POSTGRES_DIALECT);
    }
}
