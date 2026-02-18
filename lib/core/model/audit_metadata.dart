import 'package:freezed_annotation/freezed_annotation.dart';

part 'audit_metadata.freezed.dart';
part 'audit_metadata.g.dart';

const List<String> _createdByDisplayNameCandidates = <String>[
  'createdByDisplayName',
  'createdByName',
  'createdByFullName',
];
const List<String> _updatedByDisplayNameCandidates = <String>[
  'updatedByDisplayName',
  'updatedByName',
  'updatedByFullName',
];

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
    final Object? createdBy = _resolveActor(
      json: json,
      displayNameKeys: _createdByDisplayNameCandidates,
      fallbackKey: createdByJsonKey,
    );
    final Object? updatedBy = _resolveActor(
      json: json,
      displayNameKeys: _updatedByDisplayNameCandidates,
      fallbackKey: updatedByJsonKey,
    );
    return <String, dynamic>{
      createdByJsonKey: createdBy,
      updatedByJsonKey: updatedBy,
      createdAtJsonKey: json[createdAtJsonKey],
      updatedAtJsonKey: json[updatedAtJsonKey],
    };
  }

  static Object? _resolveActor({
    required Map<dynamic, dynamic> json,
    required List<String> displayNameKeys,
    required String fallbackKey,
  }) {
    for (final String key in displayNameKeys) {
      final Object? value = json[key];
      if (value != null) {
        return value;
      }
    }
    return json[fallbackKey];
  }
}
