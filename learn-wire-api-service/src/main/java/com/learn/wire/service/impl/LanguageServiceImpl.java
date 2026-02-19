package com.learn.wire.service.impl;

import java.util.List;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.learn.wire.dto.language.response.LanguageResponse;
import com.learn.wire.repository.LanguageRepository;
import com.learn.wire.service.LanguageService;

import com.learn.wire.constant.LogConst;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@Transactional(readOnly = true)
@Slf4j
@RequiredArgsConstructor
public class LanguageServiceImpl implements LanguageService {

    private final LanguageRepository languageRepository;

    @Override
    public List<LanguageResponse> getLanguages() {
        log.debug(LogConst.LANGUAGE_SERVICE_GET_LIST);
        return this.languageRepository.findByIsActiveTrueOrderBySortOrderAsc()
                .stream()
                .map(e -> new LanguageResponse(e.getCode(), e.getName(), e.getNativeName()))
                .toList();
    }
}
