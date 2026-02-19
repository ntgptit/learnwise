package com.learn.wire.service;

import java.util.List;

import com.learn.wire.dto.language.response.LanguageResponse;

public interface LanguageService {

    List<LanguageResponse> getLanguages();
}
