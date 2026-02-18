package com.learn.wire.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.learn.wire.constant.ApiConst;
import com.learn.wire.constant.ApiDocConst;
import com.learn.wire.constant.LogConst;
import com.learn.wire.dto.study.request.StudySessionEventRequest;
import com.learn.wire.dto.study.request.StudySessionStartRequest;
import com.learn.wire.dto.study.response.StudySessionResponse;
import com.learn.wire.service.StudySessionService;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@RestController
@Tag(name = ApiDocConst.TAG_STUDY_SESSIONS)
@RequestMapping
@Slf4j
@RequiredArgsConstructor
public class StudySessionController {

    private final StudySessionService studySessionService;

    @PostMapping(ApiConst.STUDY_SESSIONS_PATH)
    @Operation(summary = ApiDocConst.STUDY_OPERATION_CREATE_SESSION)
    ResponseEntity<StudySessionResponse> startSession(
            @PathVariable Long deckId,
            @Valid @RequestBody StudySessionStartRequest request) {
        final StudySessionResponse response = this.studySessionService.startSession(deckId, request);
        log.info(LogConst.STUDY_CONTROLLER_STARTED, response.sessionId(), deckId);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping(ApiConst.STUDY_SESSION_BY_ID_PATH)
    @Operation(summary = ApiDocConst.STUDY_OPERATION_GET_SESSION)
    ResponseEntity<StudySessionResponse> getSession(@PathVariable Long sessionId) {
        log.debug(LogConst.STUDY_CONTROLLER_GET_SESSION, sessionId);
        return ResponseEntity.ok(this.studySessionService.getSession(sessionId));
    }

    @PostMapping(ApiConst.STUDY_SESSION_EVENTS_PATH)
    @Operation(summary = ApiDocConst.STUDY_OPERATION_SUBMIT_EVENT)
    ResponseEntity<StudySessionResponse> submitEvent(
            @PathVariable Long sessionId,
            @Valid @RequestBody StudySessionEventRequest request) {
        log.debug(LogConst.STUDY_CONTROLLER_SUBMIT_EVENT, sessionId);
        return ResponseEntity.ok(this.studySessionService.submitEvent(sessionId, request));
    }

    @PostMapping(ApiConst.STUDY_SESSION_COMPLETE_PATH)
    @Operation(summary = ApiDocConst.STUDY_OPERATION_COMPLETE_SESSION)
    ResponseEntity<StudySessionResponse> completeSession(@PathVariable Long sessionId) {
        log.info(LogConst.STUDY_CONTROLLER_COMPLETED, sessionId);
        return ResponseEntity.ok(this.studySessionService.completeSession(sessionId));
    }
}
