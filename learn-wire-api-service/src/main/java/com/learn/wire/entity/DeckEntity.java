package com.learn.wire.entity;

import com.learn.wire.constant.DeckConst;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Table(name = DeckConst.TABLE_NAME)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class DeckEntity extends AuditableSoftDeleteEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @Column(name = "folder_id", nullable = false)
    private Long folderId;

    @Column(name = "name", nullable = false, length = DeckConst.NAME_MAX_LENGTH)
    private String name;

    @Column(name = "normalized_name", length = DeckConst.NAME_MAX_LENGTH)
    private String normalizedName;

    @Column(name = "description", nullable = false, length = DeckConst.DESCRIPTION_MAX_LENGTH)
    private String description;

    @Column(name = "term_lang_code", length = 10)
    private String termLangCode;

    @Column(name = "setting_auto_play_audio_override")
    private Boolean settingAutoPlayAudioOverride;

    @Column(name = "setting_cards_per_session_override")
    private Integer settingCardsPerSessionOverride;

    @Column(name = "setting_tts_voice_id_override", length = 255)
    private String settingTtsVoiceIdOverride;

    @Column(name = "setting_tts_speech_rate_override")
    private Double settingTtsSpeechRateOverride;

    @Column(name = "setting_tts_pitch_override")
    private Double settingTtsPitchOverride;

    @Column(name = "setting_tts_volume_override")
    private Double settingTtsVolumeOverride;
}
