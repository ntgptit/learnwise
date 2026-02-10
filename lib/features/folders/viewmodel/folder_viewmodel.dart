import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/error/api_error_mapper.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/error/error_code.dart';
import '../../../core/network/api_client.dart';
import '../model/folder_constants.dart';
import '../model/folder_models.dart';
import '../repository/folder_api_service.dart';
import '../repository/folder_repository.dart';

part 'folder_viewmodel.g.dart';

@Riverpod(keepAlive: true)
FolderRepository folderRepository(Ref ref) {
  final ApiClient apiClient = ref.read(apiClientProvider);
  return FolderApiService(apiClient: apiClient);
}

@Riverpod(keepAlive: true)
class FolderQueryController extends _$FolderQueryController {
  @override
  FolderListQuery build() {
    return FolderListQuery.initial();
  }

  void setSearch(String value) {
    final String normalized = value.trim();
    state = state.copyWith(search: normalized);
  }

  void setSortBy(FolderSortBy value) {
    state = state.copyWith(sortBy: value);
  }

  void setSortDirection(FolderSortDirection value) {
    state = state.copyWith(sortDirection: value);
  }

  void enterFolder(FolderItem folder) {
    if (state.parentFolderId == folder.id) {
      return;
    }

    final int existingIndex = state.breadcrumbs.indexWhere((
      FolderBreadcrumb item,
    ) {
      return item.id == folder.id;
    });
    if (existingIndex >= FolderConstants.minPage) {
      final List<FolderBreadcrumb> existingPath = state.breadcrumbs.sublist(
        FolderConstants.minPage,
        existingIndex + 1,
      );
      state = state.copyWith(
        parentFolderId: folder.id,
        breadcrumbs: existingPath,
      );
      return;
    }

    final List<FolderBreadcrumb> breadcrumbs = <FolderBreadcrumb>[
      ...state.breadcrumbs,
      FolderBreadcrumb(id: folder.id, name: folder.name),
    ];
    state = state.copyWith(parentFolderId: folder.id, breadcrumbs: breadcrumbs);
  }

  void goToRoot() {
    state = state.copyWith(
      parentFolderId: null,
      breadcrumbs: const <FolderBreadcrumb>[],
    );
  }

  void goToParent() {
    if (state.breadcrumbs.isEmpty) {
      return;
    }
    final List<FolderBreadcrumb> breadcrumbs = state.breadcrumbs.sublist(
      FolderConstants.minPage,
      state.breadcrumbs.length - 1,
    );
    final int? parentFolderId = breadcrumbs.isEmpty
        ? null
        : breadcrumbs.last.id;
    state = state.copyWith(
      parentFolderId: parentFolderId,
      breadcrumbs: breadcrumbs,
    );
  }

  void goToBreadcrumb(int index) {
    if (index < FolderConstants.minPage) {
      return;
    }
    if (index >= state.breadcrumbs.length) {
      return;
    }
    final List<FolderBreadcrumb> breadcrumbs = state.breadcrumbs.sublist(
      FolderConstants.minPage,
      index + 1,
    );
    final int? parentFolderId = breadcrumbs.isEmpty
        ? null
        : breadcrumbs.last.id;
    state = state.copyWith(
      parentFolderId: parentFolderId,
      breadcrumbs: breadcrumbs,
    );
  }
}

class FolderUiState {
  const FolderUiState({
    required this.isSearchVisible,
    required this.isTransitionInProgress,
  });

  const FolderUiState.initial()
    : isSearchVisible = false,
      isTransitionInProgress = false;

  final bool isSearchVisible;
  final bool isTransitionInProgress;

  FolderUiState copyWith({
    bool? isSearchVisible,
    bool? isTransitionInProgress,
  }) {
    return FolderUiState(
      isSearchVisible: isSearchVisible ?? this.isSearchVisible,
      isTransitionInProgress:
          isTransitionInProgress ?? this.isTransitionInProgress,
    );
  }
}

@Riverpod(keepAlive: true)
class FolderUiController extends _$FolderUiController {
  @override
  FolderUiState build() {
    return const FolderUiState.initial();
  }

  void toggleSearchVisibility() {
    state = state.copyWith(isSearchVisible: !state.isSearchVisible);
  }

  void setTransitionInProgress(bool isInProgress) {
    if (state.isTransitionInProgress == isInProgress) {
      return;
    }
    state = state.copyWith(isTransitionInProgress: isInProgress);
  }
}

@Riverpod(keepAlive: true)
class FolderController extends _$FolderController {
  late final FolderRepository _repository;
  late final AppErrorAdvisor _errorAdvisor;

  @override
  Future<FolderListingState> build() async {
    _repository = ref.read(folderRepositoryProvider);
    _errorAdvisor = ref.read(appErrorAdvisorProvider);
    final FolderListQuery query = ref.watch(folderQueryControllerProvider);
    return _loadInitial(query: query);
  }

  void applySearch(String searchText) {
    ref.read(folderQueryControllerProvider.notifier).setSearch(searchText);
  }

  void applySortBy(FolderSortBy value) {
    ref.read(folderQueryControllerProvider.notifier).setSortBy(value);
  }

  void applySortDirection(FolderSortDirection value) {
    ref.read(folderQueryControllerProvider.notifier).setSortDirection(value);
  }

  void enterFolder(FolderItem folder) {
    ref.read(folderQueryControllerProvider.notifier).enterFolder(folder);
  }

  Future<bool> hasDirectChildren(int parentFolderId) async {
    final FolderListQuery currentQuery = ref.read(
      folderQueryControllerProvider,
    );
    final FolderListQuery probeQuery = currentQuery.copyWith(
      parentFolderId: parentFolderId,
      size: FolderConstants.minPageSize,
    );

    try {
      final FolderPageResult probePage = await _repository.getFolders(
        query: probeQuery,
        page: FolderConstants.defaultPage,
      );
      if (probePage.items.isNotEmpty) {
        return true;
      }
      return false;
    } catch (error) {
      _errorAdvisor.handle(error, fallback: AppErrorCode.folderLoadFailed);
      return true;
    }
  }

  void goToRoot() {
    ref.read(folderQueryControllerProvider.notifier).goToRoot();
  }

  void goToParent() {
    ref.read(folderQueryControllerProvider.notifier).goToParent();
  }

  void goToBreadcrumb(int index) {
    ref.read(folderQueryControllerProvider.notifier).goToBreadcrumb(index);
  }

  Future<void> refresh() async {
    final FolderListQuery query = ref.read(folderQueryControllerProvider);
    final FolderListingState? previousListing = _currentListing;
    if (previousListing == null) {
      state = const AsyncLoading<FolderListingState>();
    }
    try {
      final FolderListingState listing = await _loadInitial(query: query);
      if (_isQueryStale(query)) {
        return;
      }
      state = AsyncData<FolderListingState>(listing);
    } catch (error, stackTrace) {
      if (_isQueryStale(query)) {
        return;
      }
      if (_currentListing != null) {
        return;
      }
      state = AsyncError<FolderListingState>(error, stackTrace);
    }
  }

  Future<void> loadMore() async {
    final FolderListingState? currentListing = _currentListing;
    if (currentListing == null) {
      return;
    }
    if (!currentListing.hasNext) {
      return;
    }
    if (currentListing.isLoadingMore) {
      return;
    }

    final FolderListQuery query = ref.read(folderQueryControllerProvider);
    state = AsyncData<FolderListingState>(
      currentListing.copyWith(isLoadingMore: true),
    );

    try {
      final FolderPageResult nextPage = await _repository.getFolders(
        query: query,
        page: currentListing.page + 1,
      );
      if (_isQueryStale(query)) {
        return;
      }
      state = AsyncData<FolderListingState>(
        currentListing.appendPage(nextPage),
      );
    } catch (error) {
      if (_isQueryStale(query)) {
        return;
      }
      state = AsyncData<FolderListingState>(currentListing);
      _errorAdvisor.handle(error, fallback: AppErrorCode.folderLoadFailed);
    }
  }

  Future<bool> createFolder(FolderUpsertInput input) async {
    final FolderListQuery query = ref.read(folderQueryControllerProvider);
    final FolderUpsertInput normalized = _normalizeInput(
      input.copyWith(parentFolderId: query.parentFolderId),
    );
    if (!_isInputValid(normalized)) {
      _errorAdvisor.handle(
        const BadRequestAppException(),
        fallback: AppErrorCode.badRequest,
      );
      return false;
    }

    try {
      await _repository.createFolder(normalized);
      await refresh();
      return true;
    } catch (error) {
      _errorAdvisor.handle(error, fallback: AppErrorCode.folderCreateFailed);
      return false;
    }
  }

  Future<bool> updateFolder({
    required int folderId,
    required FolderUpsertInput input,
  }) async {
    final FolderUpsertInput normalized = _normalizeInput(input);
    if (!_isInputValid(normalized)) {
      _errorAdvisor.handle(
        const BadRequestAppException(),
        fallback: AppErrorCode.badRequest,
      );
      return false;
    }

    final FolderListingState? snapshot = _currentListing;
    if (snapshot != null) {
      final List<FolderItem> optimisticItems = snapshot.items.map((
        FolderItem item,
      ) {
        if (item.id != folderId) {
          return item;
        }
        return item.copyWith(
          name: normalized.name,
          description: normalized.description,
          colorHex: normalized.colorHex,
          updatedBy: FolderConstants.optimisticActorLabel,
          updatedAt: DateTime.now().toUtc(),
        );
      }).toList();
      state = AsyncData<FolderListingState>(
        snapshot.copyWith(items: optimisticItems),
      );
    }

    try {
      await _repository.updateFolder(folderId: folderId, input: normalized);
      await refresh();
      return true;
    } catch (error) {
      if (snapshot != null) {
        state = AsyncData<FolderListingState>(snapshot);
      }
      _errorAdvisor.handle(error, fallback: AppErrorCode.folderUpdateFailed);
      return false;
    }
  }

  Future<bool> deleteFolder(int folderId) async {
    final FolderListingState? snapshot = _currentListing;
    if (snapshot == null) {
      return false;
    }

    final List<FolderItem> optimisticItems = snapshot.items.where((
      FolderItem item,
    ) {
      return item.id != folderId;
    }).toList();
    state = AsyncData<FolderListingState>(
      snapshot.copyWith(items: optimisticItems),
    );

    try {
      await _repository.deleteFolder(folderId);
      await refresh();
      return true;
    } catch (error) {
      state = AsyncData<FolderListingState>(snapshot);
      _errorAdvisor.handle(error, fallback: AppErrorCode.folderDeleteFailed);
      return false;
    }
  }

  Future<FolderListingState> _loadInitial({
    required FolderListQuery query,
  }) async {
    try {
      final FolderPageResult page = await _repository.getFolders(
        query: query,
        page: FolderConstants.defaultPage,
      );
      return FolderListingState.fromPage(page);
    } catch (error) {
      _errorAdvisor.handle(error, fallback: AppErrorCode.folderLoadFailed);
      rethrow;
    }
  }

  FolderUpsertInput _normalizeInput(FolderUpsertInput input) {
    final String name = input.name.trim();
    final String description = input.description.trim();
    final String colorHex = input.colorHex.trim().toUpperCase();
    return FolderUpsertInput(
      name: name,
      description: description,
      colorHex: colorHex,
      parentFolderId: input.parentFolderId,
    );
  }

  bool _isInputValid(FolderUpsertInput input) {
    if (input.name.length < FolderConstants.nameMinLength) {
      return false;
    }
    if (input.name.length > FolderConstants.nameMaxLength) {
      return false;
    }
    if (input.description.length > FolderConstants.descriptionMaxLength) {
      return false;
    }
    if (!FolderConstants.colorHexPattern.hasMatch(input.colorHex)) {
      return false;
    }
    return true;
  }

  FolderListingState? get _currentListing {
    final AsyncValue<FolderListingState> currentState = state;
    if (!currentState.hasValue) {
      return null;
    }
    return currentState.requireValue;
  }

  bool _isQueryStale(FolderListQuery expectedQuery) {
    final FolderListQuery currentQuery = ref.read(
      folderQueryControllerProvider,
    );
    return currentQuery != expectedQuery;
  }
}
