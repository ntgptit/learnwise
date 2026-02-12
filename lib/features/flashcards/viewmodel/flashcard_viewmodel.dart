import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/error/api_error_mapper.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/error/error_code.dart';
import '../../../core/network/api_client.dart';
import '../model/flashcard_constants.dart';
import '../model/flashcard_models.dart';
import '../repository/flashcard_api_service.dart';
import '../repository/flashcard_repository.dart';

part 'flashcard_viewmodel.g.dart';

@Riverpod(keepAlive: true)
FlashcardRepository flashcardRepository(Ref ref) {
  final ApiClient apiClient = ref.read(apiClientProvider);
  return FlashcardApiService(apiClient: apiClient);
}

@Riverpod(keepAlive: true)
class FlashcardQueryController extends _$FlashcardQueryController {
  @override
  FlashcardListQuery build(int deckId) {
    return FlashcardListQuery.initial(deckId: deckId);
  }

  void setSearch(String value) {
    final String normalized = value.trim();
    if (state.search == normalized) {
      return;
    }
    state = state.copyWith(search: normalized);
  }

  void setSortBy(FlashcardSortBy value) {
    if (state.sortBy == value) {
      return;
    }
    state = state.copyWith(sortBy: value);
  }

  void setSortDirection(FlashcardSortDirection value) {
    if (state.sortDirection == value) {
      return;
    }
    state = state.copyWith(sortDirection: value);
  }
}

class FlashcardSubmitResult {
  const FlashcardSubmitResult._({
    required this.isSuccess,
    this.formErrorMessage,
  });

  const FlashcardSubmitResult.success() : this._(isSuccess: true);

  const FlashcardSubmitResult.failure({String? formErrorMessage})
    : this._(isSuccess: false, formErrorMessage: formErrorMessage);

  final bool isSuccess;
  final String? formErrorMessage;
}

@Riverpod(keepAlive: true)
class FlashcardController extends _$FlashcardController {
  late final FlashcardRepository _repository;
  late final AppErrorAdvisor _errorAdvisor;
  bool _isBootstrapCompleted = false;
  bool _isQueryListenerBound = false;
  int _queryRequestVersion = FlashcardConstants.defaultPage;
  late int _deckId;

  @override
  Future<FlashcardListingState> build(int deckId) async {
    _deckId = deckId;
    _repository = ref.read(flashcardRepositoryProvider);
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
        .read(flashcardQueryControllerProvider(_deckId).notifier)
        .setSearch(searchText);
  }

  void applySortBy(FlashcardSortBy value) {
    ref
        .read(flashcardQueryControllerProvider(_deckId).notifier)
        .setSortBy(value);
  }

  void applySortDirection(FlashcardSortDirection value) {
    ref
        .read(flashcardQueryControllerProvider(_deckId).notifier)
        .setSortDirection(value);
  }

  Future<void> refresh() async {
    final FlashcardListQuery query = ref.read(
      flashcardQueryControllerProvider(_deckId),
    );
    await _reloadForQuery(query: query, isRefresh: true);
  }

  Future<void> loadMore() async {
    final FlashcardListingState? currentListing = _currentListing;
    if (currentListing == null) {
      return;
    }
    if (!currentListing.hasNext) {
      return;
    }
    if (currentListing.isLoadingMore) {
      return;
    }

    final FlashcardListQuery query = ref.read(
      flashcardQueryControllerProvider(_deckId),
    );
    state = AsyncData<FlashcardListingState>(
      currentListing.copyWith(isLoadingMore: true),
    );

    try {
      final FlashcardPageResult nextPage = await _repository.getFlashcards(
        query: query,
        page: currentListing.page + 1,
      );
      if (_isQueryStale(query)) {
        return;
      }
      state = AsyncData<FlashcardListingState>(
        currentListing.appendPage(nextPage),
      );
    } catch (error) {
      if (_isQueryStale(query)) {
        return;
      }
      state = AsyncData<FlashcardListingState>(currentListing);
      _errorAdvisor.handle(error, fallback: AppErrorCode.flashcardLoadFailed);
    }
  }

  Future<FlashcardSubmitResult> submitCreateFlashcard(
    FlashcardUpsertInput input,
  ) async {
    final FlashcardUpsertInput normalized = _normalizeInput(input);
    if (!_isInputValid(normalized)) {
      _errorAdvisor.handle(
        const BadRequestAppException(),
        fallback: AppErrorCode.badRequest,
      );
      return const FlashcardSubmitResult.failure();
    }

    try {
      await _repository.createFlashcard(deckId: _deckId, input: normalized);
      await refresh();
      return const FlashcardSubmitResult.success();
    } catch (error) {
      final String? formErrorMessage = _resolveFormErrorMessage(error);
      if (formErrorMessage != null) {
        return FlashcardSubmitResult.failure(
          formErrorMessage: formErrorMessage,
        );
      }
      _errorAdvisor.handle(error, fallback: AppErrorCode.flashcardCreateFailed);
      return const FlashcardSubmitResult.failure();
    }
  }

  Future<FlashcardSubmitResult> submitUpdateFlashcard({
    required int flashcardId,
    required FlashcardUpsertInput input,
  }) async {
    final FlashcardUpsertInput normalized = _normalizeInput(input);
    if (!_isInputValid(normalized)) {
      _errorAdvisor.handle(
        const BadRequestAppException(),
        fallback: AppErrorCode.badRequest,
      );
      return const FlashcardSubmitResult.failure();
    }

    final FlashcardListingState? snapshot = _currentListing;
    if (snapshot != null) {
      final List<FlashcardItem> optimisticItems = snapshot.items.map((
        FlashcardItem item,
      ) {
        if (item.id != flashcardId) {
          return item;
        }
        return item.copyWith(
          frontText: normalized.frontText,
          backText: normalized.backText,
          updatedBy: FlashcardConstants.optimisticActorLabel,
          updatedAt: DateTime.now().toUtc(),
        );
      }).toList();
      state = AsyncData<FlashcardListingState>(
        snapshot.copyWith(items: optimisticItems),
      );
    }

    try {
      await _repository.updateFlashcard(
        deckId: _deckId,
        flashcardId: flashcardId,
        input: normalized,
      );
      await refresh();
      return const FlashcardSubmitResult.success();
    } catch (error) {
      if (snapshot != null) {
        state = AsyncData<FlashcardListingState>(snapshot);
      }
      final String? formErrorMessage = _resolveFormErrorMessage(error);
      if (formErrorMessage != null) {
        return FlashcardSubmitResult.failure(
          formErrorMessage: formErrorMessage,
        );
      }
      _errorAdvisor.handle(error, fallback: AppErrorCode.flashcardUpdateFailed);
      return const FlashcardSubmitResult.failure();
    }
  }

  Future<bool> deleteFlashcard(int flashcardId) async {
    final FlashcardListingState? snapshot = _currentListing;
    if (snapshot == null) {
      return false;
    }

    final List<FlashcardItem> optimisticItems = snapshot.items.where((
      FlashcardItem item,
    ) {
      return item.id != flashcardId;
    }).toList();
    state = AsyncData<FlashcardListingState>(
      snapshot.copyWith(items: optimisticItems),
    );

    try {
      await _repository.deleteFlashcard(
        deckId: _deckId,
        flashcardId: flashcardId,
      );
      await refresh();
      return true;
    } catch (error) {
      state = AsyncData<FlashcardListingState>(snapshot);
      _errorAdvisor.handle(error, fallback: AppErrorCode.flashcardDeleteFailed);
      return false;
    }
  }

  Future<FlashcardListingState> _loadInitial({
    required FlashcardListQuery query,
  }) async {
    try {
      final FlashcardPageResult page = await _repository.getFlashcards(
        query: query,
        page: FlashcardConstants.defaultPage,
      );
      return FlashcardListingState.fromPage(page);
    } catch (error) {
      _errorAdvisor.handle(error, fallback: AppErrorCode.flashcardLoadFailed);
      rethrow;
    }
  }

  Future<FlashcardListingState> _loadBootstrapListing() async {
    FlashcardListQuery query = ref.read(
      flashcardQueryControllerProvider(_deckId),
    );
    while (true) {
      final FlashcardListingState listing = await _loadInitial(query: query);
      if (!_isQueryStale(query)) {
        return listing;
      }
      query = ref.read(flashcardQueryControllerProvider(_deckId));
    }
  }

  void _bindQueryListener() {
    if (_isQueryListenerBound) {
      return;
    }
    _isQueryListenerBound = true;
    ref.listen<FlashcardListQuery>(flashcardQueryControllerProvider(_deckId), (
      FlashcardListQuery? previousQuery,
      FlashcardListQuery nextQuery,
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
    required FlashcardListQuery query,
    required bool isRefresh,
  }) async {
    final int requestVersion = _nextQueryRequestVersion();
    _setLoadingState(isRefresh: isRefresh);

    try {
      final FlashcardListingState listing = await _loadInitial(query: query);
      if (_shouldSkipCommit(query: query, requestVersion: requestVersion)) {
        return;
      }
      state = AsyncData<FlashcardListingState>(listing);
    } catch (error, stackTrace) {
      if (_shouldSkipCommit(query: query, requestVersion: requestVersion)) {
        return;
      }
      final FlashcardListingState? previousListing = _currentListing;
      if (previousListing != null) {
        state = AsyncData<FlashcardListingState>(previousListing);
        return;
      }
      state = AsyncError<FlashcardListingState>(error, stackTrace);
    }
  }

  void _setLoadingState({required bool isRefresh}) {
    final AsyncValue<FlashcardListingState> previousState = state;
    if (!previousState.hasValue && !previousState.hasError) {
      state = const AsyncLoading<FlashcardListingState>();
      return;
    }
    // ignore: invalid_use_of_internal_member
    state = const AsyncLoading<FlashcardListingState>().copyWithPrevious(
      previousState,
      isRefresh: isRefresh,
    );
  }

  int _nextQueryRequestVersion() {
    _queryRequestVersion++;
    return _queryRequestVersion;
  }

  bool _shouldSkipCommit({
    required FlashcardListQuery query,
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

  FlashcardUpsertInput _normalizeInput(FlashcardUpsertInput input) {
    return FlashcardUpsertInput(
      frontText: input.frontText.trim(),
      backText: input.backText.trim(),
    );
  }

  bool _isInputValid(FlashcardUpsertInput input) {
    if (input.frontText.length < FlashcardConstants.frontTextMinLength) {
      return false;
    }
    if (input.frontText.length > FlashcardConstants.frontTextMaxLength) {
      return false;
    }
    if (input.backText.length < FlashcardConstants.backTextMinLength) {
      return false;
    }
    if (input.backText.length > FlashcardConstants.backTextMaxLength) {
      return false;
    }
    return true;
  }

  FlashcardListingState? get _currentListing {
    final AsyncValue<FlashcardListingState> currentState = state;
    if (!currentState.hasValue) {
      return null;
    }
    return currentState.requireValue;
  }

  bool _isQueryStale(FlashcardListQuery expectedQuery) {
    final FlashcardListQuery currentQuery = ref.read(
      flashcardQueryControllerProvider(_deckId),
    );
    return currentQuery != expectedQuery;
  }

  String? _resolveFormErrorMessage(Object error) {
    final String? backendMessage = _errorAdvisor.extractBackendMessage(error);
    if (backendMessage == null) {
      return null;
    }
    return backendMessage;
  }
}
