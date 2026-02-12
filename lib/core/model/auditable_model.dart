import 'audit_metadata.dart';

mixin AuditableModel {
  AuditMetadata get audit;

  String get createdBy => audit.createdBy;
  String get updatedBy => audit.updatedBy;
  DateTime get createdAt => audit.createdAt;
  DateTime get updatedAt => audit.updatedAt;
}
