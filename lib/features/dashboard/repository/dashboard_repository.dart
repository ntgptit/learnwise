import '../model/dashboard_models.dart';

abstract class DashboardRepository {
  Future<DashboardSnapshot> loadSnapshot();
}
