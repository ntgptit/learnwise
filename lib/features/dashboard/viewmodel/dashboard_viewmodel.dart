import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/error/api_error_mapper.dart';
import '../../../core/error/error_code.dart';
import '../model/dashboard_models.dart';
import '../repository/dashboard_repository.dart';
import '../repository/dashboard_service.dart';

part 'dashboard_viewmodel.g.dart';

@Riverpod(keepAlive: true)
DashboardRepository dashboardRepository(Ref ref) {
  return DashboardService();
}

@Riverpod(keepAlive: true)
class DashboardController extends _$DashboardController {
  late final DashboardRepository _repository;
  late final AppErrorAdvisor _errorAdvisor;

  @override
  Future<DashboardSnapshot> build() async {
    _repository = ref.read(dashboardRepositoryProvider);
    _errorAdvisor = ref.read(appErrorAdvisorProvider);
    return _load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading<DashboardSnapshot>();
    try {
      final DashboardSnapshot snapshot = await _load();
      state = AsyncData<DashboardSnapshot>(snapshot);
    } catch (error, stackTrace) {
      state = AsyncError<DashboardSnapshot>(error, stackTrace);
    }
  }

  Future<DashboardSnapshot> _load() async {
    try {
      return await _repository.loadSnapshot();
    } catch (error) {
      _errorAdvisor.handle(error, fallback: AppErrorCode.dashboardLoadFailed);
      rethrow;
    }
  }
}
