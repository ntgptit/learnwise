package com.learn.wire.security;

public record CurrentUser(
        Long userId,
        String email) {

    public String actor() {
        return String.valueOf(this.userId);
    }
}
