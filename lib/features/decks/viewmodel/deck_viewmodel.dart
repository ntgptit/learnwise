import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/error/api_error_mapper.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/error/error_code.dart';
import '../model/deck_constants.dart';
import '../model/deck_models.dart';
import '../repository/deck_repository.dart';
import '../repository/deck_repository_provider.dart';

part 'deck_viewmodel.g.dart';

// quality-guard: allow-large-file
// quality-guard: allow-large-class
// quality-guard: allow-long-function

@Riverpod(keepAlive: true)
class DeckQueryController extends _$DeckQueryController {
  @override
  DeckListQuery build(int folderId) {
    return DeckListQuery.initial(folderId: folderId);
  }

  void setSearch(String value) {
    final String normalized = value.trim();
    if (state.search == normalized) {
      return;
    }
    state = state.copyWith(search: normalized);
  }

  void setSortBy(DeckSortBy value) {
    if (state.sortBy == value) {
      return;
    }
    state = state.copyWith(sortBy: value);
  }

  void setSortDirection(DeckSortDirection value) {
    if (state.sortDirection == value) {
      return;
    }
    state = state.copyWith(sortDirection: value);
  }
}

class DeckSubmitResult {
  const DeckSubmitResult._({required this.isSuccess, this.nameErrorMessage});

  const DeckSubmitResult.success() : this._(isSuccess: true);

  const DeckSubmitResult.failure({String? nameErrorMessage})
    : this._(isSuccess: false, nameErrorMessage: nameErrorMessage);

  final bool isSuccess;
  final String? nameErrorMessage;
}

@Riverpod(keepAlive: true)
class DeckController extends _$DeckController {
  late final DeckRepository _repository;
  late final AppErrorAdvisor _errorAdvisor;
  bool _isBootstrapCompleted = false;
  bool _isQueryListenerBound = false;
  int _queryRequestVersion = DeckConstants.defaultPage;
  late int _folderId;

  @override
  Future<DeckListingState> build(int folderId) async {
    _folderId = folderId;
    _repository = ref.read(deckRepositoryProvider);
    _errorAdvisor = ref.read(appErrorAdvisorProvider);
    _bindQueryListener();
    _isBootstrapCompleted = false;
    try {
      return await _loadBootstrapListing();
    } finally {
      _isBootstrapCompleted = true;
    }
  }

  void applySearch(String searchText) {
    ref
        .read(deckQueryControllerProvider(_folderId).notifier)
        .setSearch(searchText);
  }

  void applySortBy(DeckSortBy value) {
    ref.read(deckQueryControllerProvider(_folderId).notifier).setSortBy(value);
  }

  void applySortDirection(DeckSortDirection value) {
    ref
        .read(deckQueryControllerProvider(_folderId).notifier)
        .setSortDirection(value);
  }

  Future<void> refresh() async {
    final DeckListQuery query = ref.read(
      deckQueryControllerProvider(_folderId),
    );
    await _reloadForQuery(query: query, isRefresh: true);
  }

  Future<void> loadMore() async {
    final DeckListingState? currentListing = _currentListing;
    if (currentListing == null) {
      return;
    }
    if (!currentListing.hasNext) {
      return;
    }
    if (currentListing.isLoadingMore) {
      return;
    }

    final DeckListQuery query = ref.read(
      deckQueryControllerProvider(_folderId),
    );
    state = AsyncData<DeckListingState>(
      currentListing.copyWith(isLoadingMore: true),
    );

    try {
      final DeckPageResult nextPage = await _repository.getDecks(
        query: query,
        page: currentListing.page + 1,
      );
      if (_isQueryStale(query)) {
        return;
      }
      state = AsyncData<DeckListingState>(currentListing.appendPage(nextPage));
    } catch (error) {
      if (_isQueryStale(query)) {
        return;
      }
      state = AsyncData<DeckListingState>(currentListing);
      _errorAdvisor.handle(error, fallback: AppErrorCode.folderLoadFailed);
    }
  }

  Future<DeckSubmitResult> submitCreateDeck(DeckUpsertInput input) async {
    final DeckUpsertInput normalized = _normalizeInput(input);
    if (!_isInputValid(normalized)) {
      _errorAdvisor.handle(
        const BadRequestAppException(),
        fallback: AppErrorCode.badRequest,
      );
      return const DeckSubmitResult.failure();
    }

    try {
      await _repository.createDeck(folderId: _folderId, input: normalized);
      await refresh();
      return const DeckSubmitResult.success();
    } catch (error) {
      final AppException exception = _errorAdvisor.toAppException(
        error,
        fallback: AppErrorCode.folderCreateFailed,
      );
      final String? nameErrorMessage = _resolveNameConflictErrorMessage(
        exception: exception,
        error: error,
      );
      if (nameErrorMessage != null) {
        return DeckSubmitResult.failure(nameErrorMessage: nameErrorMessage);
      }
      _errorAdvisor.handle(error, fallback: AppErrorCode.folderCreateFailed);
      return const DeckSubmitResult.failure();
    }
  }

  Future<DeckSubmitResult> submitUpdateDeck({
    required int deckId,
    required DeckUpsertInput input,
  }) async {
    final DeckUpsertInput normalized = _normalizeInput(input);
    if (!_isInputValid(normalized)) {
      _errorAdvisor.handle(
        const BadRequestAppException(),
        fallback: AppErrorCode.badRequest,
      );
      return const DeckSubmitResult.failure();
    }

    final DeckListingState? snapshot = _currentListing;
    if (snapshot != null) {
      final List<DeckItem> optimisticItems = snapshot.items.map((item) {
        if (item.id != deckId) {
          return item;
        }
        return item.copyWith(
          name: normalized.name,
          description: normalized.description,
          audit: item.audit.copyWith(
            updatedBy: DeckConstants.optimisticActorLabel,
            updatedAt: DateTime.now().toUtc(),
          ),
        );
      }).toList();
      state = AsyncData<DeckListingState>(
        snapshot.copyWith(items: optimisticItems),
      );
    }

    try {
      await _repository.updateDeck(
        folderId: _folderId,
        deckId: deckId,
        input: normalized,
      );
      await refresh();
      return const DeckSubmitResult.success();
    } catch (error) {
      if (snapshot != null) {
        state = AsyncData<DeckListingState>(snapshot);
      }
      final AppException exception = _errorAdvisor.toAppException(
        error,
        fallback: AppErrorCode.folderUpdateFailed,
      );
      final String? nameErrorMessage = _resolveNameConflictErrorMessage(
        exception: exception,
        error: error,
      );
      if (nameErrorMessage != null) {
        return DeckSubmitResult.failure(nameErrorMessage: nameErrorMessage);
      }
      _errorAdvisor.handle(error, fallback: AppErrorCode.folderUpdateFailed);
      return const DeckSubmitResult.failure();
    }
  }

  Future<bool> deleteDeck(int deckId) async {
    final DeckListingState? snapshot = _currentListing;
    if (snapshot == null) {
      return false;
    }

    final List<DeckItem> optimisticItems = snapshot.items.where((item) {
      return item.id != deckId;
    }).toList();
    state = AsyncData<DeckListingState>(
      snapshot.copyWith(items: optimisticItems),
    );

    try {
      await _repository.deleteDeck(folderId: _folderId, deckId: deckId);
      await refresh();
      return true;
    } catch (error) {
      state = AsyncData<DeckListingState>(snapshot);
      _errorAdvisor.handle(error, fallback: AppErrorCode.folderDeleteFailed);
      return false;
    }
  }

  Future<DeckListingState> _loadInitial({required DeckListQuery query}) async {
    try {
      final DeckPageResult page = await _repository.getDecks(
        query: query,
        page: DeckConstants.defaultPage,
      );
      return DeckListingState.fromPage(page);
    } catch (error) {
      _errorAdvisor.handle(error, fallback: AppErrorCode.folderLoadFailed);
      rethrow;
    }
  }

  Future<DeckListingState> _loadBootstrapListing() async {
    DeckListQuery query = ref.read(deckQueryControllerProvider(_folderId));
    while (true) {
      final DeckListingState listing = await _loadInitial(query: query);
      if (!_isQueryStale(query)) {
        return listing;
      }
      query = ref.read(deckQueryControllerProvider(_folderId));
    }
  }

  void _bindQueryListener() {
    if (_isQueryListenerBound) {
      return;
    }
    _isQueryListenerBound = true;
    ref.listen<DeckListQuery>(deckQueryControllerProvider(_folderId), (
      previousQuery,
      nextQuery,
    ) {
      if (!_isBootstrapCompleted) {
        return;
      }
      if (previousQuery == nextQuery) {
        return;
      }
      unawaited(_reloadForQuery(query: nextQuery, isRefresh: false));
    });
  }

  Future<void> _reloadForQuery({
    required DeckListQuery query,
    required bool isRefresh,
  }) async {
    final int requestVersion = _nextQueryRequestVersion();
    _setLoadingState(isRefresh: isRefresh);

    try {
      final DeckListingState listing = await _loadInitial(query: query);
      if (_shouldSkipCommit(query: query, requestVersion: requestVersion)) {
        return;
      }
      state = AsyncData<DeckListingState>(listing);
    } catch (error, stackTrace) {
      if (_shouldSkipCommit(query: query, requestVersion: requestVersion)) {
        return;
      }
      final DeckListingState? previousListing = _currentListing;
      if (previousListing != null) {
        state = AsyncData<DeckListingState>(previousListing);
        return;
      }
      state = AsyncError<DeckListingState>(error, stackTrace);
    }
  }

  void _setLoadingState({required bool isRefresh}) {
    final AsyncValue<DeckListingState> previousState = state;
    if (!previousState.hasValue && !previousState.hasError) {
      state = const AsyncLoading<DeckListingState>();
      return;
    }
    // ignore: invalid_use_of_internal_member
    state = const AsyncLoading<DeckListingState>().copyWithPrevious(
      previousState,
      isRefresh: isRefresh,
    );
  }

  int _nextQueryRequestVersion() {
    _queryRequestVersion++;
    return _queryRequestVersion;
  }

  bool _shouldSkipCommit({
    required DeckListQuery query,
    required int requestVersion,
  }) {
    if (_isQueryStale(query)) {
      return true;
    }
    if (requestVersion != _queryRequestVersion) {
      return true;
    }
    return false;
  }

  DeckUpsertInput _normalizeInput(DeckUpsertInput input) {
    return DeckUpsertInput(
      name: input.name.trim(),
      description: input.description.trim(),
    );
  }

  bool _isInputValid(DeckUpsertInput input) {
    if (input.name.length < DeckConstants.nameMinLength) {
      return false;
    }
    if (input.name.length > DeckConstants.nameMaxLength) {
      return false;
    }
    if (input.description.length > DeckConstants.descriptionMaxLength) {
      return false;
    }
    return true;
  }

  DeckListingState? get _currentListing {
    final AsyncValue<DeckListingState> currentState = state;
    if (!currentState.hasValue) {
      return null;
    }
    return currentState.requireValue;
  }

  bool _isQueryStale(DeckListQuery expectedQuery) {
    final DeckListQuery currentQuery = ref.read(
      deckQueryControllerProvider(_folderId),
    );
    return currentQuery != expectedQuery;
  }

  String? _resolveNameConflictErrorMessage({
    required AppException exception,
    required Object error,
  }) {
    if (exception.code != AppErrorCode.conflict) {
      return null;
    }
    final String? backendMessage = _errorAdvisor.extractBackendMessage(error);
    if (backendMessage != null) {
      return backendMessage;
    }
    return AppExceptionMessage.conflict;
  }
}
