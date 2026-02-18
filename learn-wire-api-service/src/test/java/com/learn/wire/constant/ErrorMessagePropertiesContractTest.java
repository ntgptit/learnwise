package com.learn.wire.constant;

import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.io.InputStream;
import java.io.InputStreamReader;
import java.lang.reflect.Field;
import java.lang.reflect.Modifier;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;

import org.junit.jupiter.api.Test;

class ErrorMessagePropertiesContractTest {

    @Test
    void shouldEnsureAllErrorMessageKeysExistInMessagesProperties() throws Exception {
        final var properties = new Properties();
        final InputStream resourceStream = getClass().getClassLoader().getResourceAsStream("messages.properties");
        assertNotNull(resourceStream, "messages.properties must exist in classpath");

        try (resourceStream; var reader = new InputStreamReader(resourceStream, StandardCharsets.UTF_8)) {
            properties.load(reader);
        }

        final List<String> missingKeys = new ArrayList<>();
        for (final Field field : ErrorMessageConst.class.getDeclaredFields()) {
            if (!Modifier.isStatic(field.getModifiers())) {
                continue;
            }
            if (!Modifier.isFinal(field.getModifiers())) {
                continue;
            }
            if (!String.class.equals(field.getType())) {
                continue;
            }

            final String key = (String) field.get(null);
            final boolean hasKey = properties.containsKey(key);
            if (!hasKey) {
                missingKeys.add(field.getName() + "=" + key);
            }
        }

        assertTrue(
                missingKeys.isEmpty(),
                () -> "Missing message keys in messages.properties: " + String.join(", ", missingKeys));
    }
}
