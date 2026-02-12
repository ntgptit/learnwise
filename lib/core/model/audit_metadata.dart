import 'package:freezed_annotation/freezed_annotation.dart';

part 'audit_metadata.freezed.dart';
part 'audit_metadata.g.dart';

@freezed
sealed class AuditMetadata with _$AuditMetadata {
  const factory AuditMetadata({
    required String createdBy,
    required String updatedBy,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _AuditMetadata;

  factory AuditMetadata.fromJson(Map<String, dynamic> json) =>
      _$AuditMetadataFromJson(json);

  static const String createdByJsonKey = 'createdBy';
  static const String updatedByJsonKey = 'updatedBy';
  static const String createdAtJsonKey = 'createdAt';
  static const String updatedAtJsonKey = 'updatedAt';

  static Map<String, dynamic> readFlatJsonMap(Map<dynamic, dynamic> json) {
    return <String, dynamic>{
      createdByJsonKey: json[createdByJsonKey],
      updatedByJsonKey: json[updatedByJsonKey],
      createdAtJsonKey: json[createdAtJsonKey],
      updatedAtJsonKey: json[updatedAtJsonKey],
    };
  }
}
