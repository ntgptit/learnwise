package com.learn.wire.service.factory;

import java.util.EnumMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Component;

import com.learn.wire.constant.StudyConst;
import com.learn.wire.dto.study.query.StudyMode;
import com.learn.wire.service.engine.StudyModeEngine;

@Component
public class StudyEngineFactory {

    private final Map<StudyMode, StudyModeEngine> engineByMode;

    public StudyEngineFactory(List<StudyModeEngine> engines) {
        final Map<StudyMode, StudyModeEngine> registry = new EnumMap<>(StudyMode.class);
        for (final StudyModeEngine engine : engines) {
            final StudyModeEngine previous = registry.put(engine.mode(), engine);
            if (previous == null) {
                continue;
            }
            throw new IllegalStateException(StudyConst.ENGINE_DUPLICATED_ERROR + engine.mode().value());
        }
        this.engineByMode = Map.copyOf(registry);
    }

    public StudyModeEngine getEngine(StudyMode mode) {
        final StudyModeEngine engine = this.engineByMode.get(mode);
        if (engine != null) {
            return engine;
        }
        throw new UnsupportedOperationException(StudyConst.ENGINE_NOT_REGISTERED_ERROR + mode.value());
    }
}
