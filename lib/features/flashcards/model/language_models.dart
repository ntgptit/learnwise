import 'package:freezed_annotation/freezed_annotation.dart';

part 'language_models.freezed.dart';
part 'language_models.g.dart';

@freezed
sealed class LanguageItem with _$LanguageItem {
  @JsonSerializable(explicitToJson: true)
  const factory LanguageItem({
    required String code,
    required String name,
    required String nativeName,
  }) = _LanguageItem;

  factory LanguageItem.fromJson(Map<String, dynamic> json) =>
      _$LanguageItemFromJson(json);
}
