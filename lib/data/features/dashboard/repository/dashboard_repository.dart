import 'package:learnwise/domain/features/dashboard/model/dashboard_models.dart';

abstract class DashboardRepository {
  Future<DashboardSnapshot> loadSnapshot();
}
