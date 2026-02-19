package com.learn.wire.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.learn.wire.constant.ApiConst;
import com.learn.wire.constant.ApiDocConst;
import com.learn.wire.constant.LogConst;
import com.learn.wire.dto.language.response.LanguageResponse;
import com.learn.wire.service.LanguageService;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@RestController
@Tag(name = ApiDocConst.TAG_LANGUAGES)
@RequestMapping(ApiConst.LANGUAGES_PATH)
@Slf4j
@RequiredArgsConstructor
public class LanguageController {

    private final LanguageService languageService;

    @GetMapping
    @Operation(summary = ApiDocConst.LANGUAGE_OPERATION_GET_LIST)
    ResponseEntity<List<LanguageResponse>> getLanguages() {
        log.debug(LogConst.LANGUAGE_CONTROLLER_GET_LIST);
        return ResponseEntity.ok(this.languageService.getLanguages());
    }
}
