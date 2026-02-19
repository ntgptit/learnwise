import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnwise/core/model/audit_metadata.dart';
import 'package:learnwise/features/flashcards/model/flashcard_models.dart';
import 'package:learnwise/features/flashcards/repository/flashcard_repository_provider.dart';
import 'package:learnwise/features/flashcards/repository/flashcard_repository.dart';
import 'package:learnwise/features/flashcards/viewmodel/flashcard_viewmodel.dart';

class FakeFlashcardRepository implements FlashcardRepository {
  int getFlashcardsCalls = 0;
  final List<FlashcardListQuery> capturedQueries = <FlashcardListQuery>[];
  final List<int> capturedPages = <int>[];
  final List<Completer<FlashcardPageResult>> _pendingResponses =
      <Completer<FlashcardPageResult>>[];

  Completer<FlashcardPageResult> dequeuePendingResponse() {
    if (_pendingResponses.isEmpty) {
      throw StateError('No pending response to dequeue');
    }
    return _pendingResponses.removeAt(0);
  }

  @override
  Future<FlashcardPageResult> getFlashcards({
    required FlashcardListQuery query,
    required int page,
  }) {
    getFlashcardsCalls++;
    capturedQueries.add(query);
    capturedPages.add(page);
    final Completer<FlashcardPageResult> completer =
        Completer<FlashcardPageResult>();
    _pendingResponses.add(completer);
    return completer.future;
  }

  @override
  Future<FlashcardItem> createFlashcard({
    required int deckId,
    required FlashcardUpsertInput input,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteFlashcard({
    required int deckId,
    required int flashcardId,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<FlashcardItem> updateFlashcard({
    required int deckId,
    required int flashcardId,
    required FlashcardUpsertInput input,
  }) async {
    throw UnimplementedError();
  }
}

void main() {
  group('FlashcardController', () {
    test('uses deckId from provider family in list query', () async {
      const int deckId = 77;
      final FakeFlashcardRepository fakeRepository = FakeFlashcardRepository();
      final ProviderContainer container = ProviderContainer(
        overrides: [
          flashcardRepositoryProvider.overrideWithValue(fakeRepository),
        ],
      );
      addTearDown(container.dispose);

      final Future<FlashcardListingState> initialFuture = container.read(
        flashcardControllerProvider(deckId).future,
      );
      fakeRepository.dequeuePendingResponse().complete(
        _buildPageResult(items: <FlashcardItem>[_item(1)]),
      );
      await initialFuture;

      expect(fakeRepository.getFlashcardsCalls, 1);
      expect(fakeRepository.capturedQueries.first.deckId, deckId);
    });

    test('keeps previous data while query is reloading', () async {
      const int deckId = 42;
      final FakeFlashcardRepository fakeRepository = FakeFlashcardRepository();
      final ProviderContainer container = ProviderContainer(
        overrides: [
          flashcardRepositoryProvider.overrideWithValue(fakeRepository),
        ],
      );
      addTearDown(container.dispose);

      final Future<FlashcardListingState> initialFuture = container.read(
        flashcardControllerProvider(deckId).future,
      );
      fakeRepository.dequeuePendingResponse().complete(
        _buildPageResult(items: <FlashcardItem>[_item(1)]),
      );
      await initialFuture;

      container
          .read(flashcardQueryControllerProvider(deckId).notifier)
          .setSearch('jvm');
      await Future<void>.delayed(Duration.zero);

      final AsyncValue<FlashcardListingState> reloadingState = container.read(
        flashcardControllerProvider(deckId),
      );
      expect(reloadingState.isLoading, true);
      expect(reloadingState.hasValue, true);
      expect(reloadingState.requireValue.items.map((item) => item.id), <int>[
        1,
      ]);

      fakeRepository.dequeuePendingResponse().complete(
        _buildPageResult(items: const <FlashcardItem>[]),
      );
      final FlashcardListingState searchListing = await container.read(
        flashcardControllerProvider(deckId).future,
      );
      expect(searchListing.items, isEmpty);
    });

    test('does not reload when normalized query does not change', () async {
      const int deckId = 9;
      final FakeFlashcardRepository fakeRepository = FakeFlashcardRepository();
      final ProviderContainer container = ProviderContainer(
        overrides: [
          flashcardRepositoryProvider.overrideWithValue(fakeRepository),
        ],
      );
      addTearDown(container.dispose);

      final Future<FlashcardListingState> initialFuture = container.read(
        flashcardControllerProvider(deckId).future,
      );
      fakeRepository.dequeuePendingResponse().complete(
        _buildPageResult(items: <FlashcardItem>[_item(1)]),
      );
      await initialFuture;
      expect(fakeRepository.getFlashcardsCalls, 1);

      final FlashcardQueryController queryController = container.read(
        flashcardQueryControllerProvider(deckId).notifier,
      );
      queryController.setSearch('   ');
      queryController.setSortBy(FlashcardSortBy.createdAt);
      queryController.setSortDirection(FlashcardSortDirection.desc);
      await Future<void>.delayed(Duration.zero);

      expect(fakeRepository.getFlashcardsCalls, 1);
    });
  });
}

FlashcardPageResult _buildPageResult({required List<FlashcardItem> items}) {
  return FlashcardPageResult(
    items: items,
    page: 0,
    size: 20,
    totalElements: items.length,
    totalPages: 1,
    hasNext: false,
    hasPrevious: false,
    search: '',
    sortBy: FlashcardSortBy.createdAt,
    sortDirection: FlashcardSortDirection.desc,
  );
}

FlashcardItem _item(int id) {
  return FlashcardItem(
    id: id,
    deckId: 1,
    frontText: 'Front $id',
    backText: 'Back $id',
    frontLangCode: null,
    backLangCode: null,
    pronunciation: '',
    note: '',
    isBookmarked: false,
    audit: AuditMetadata(
      createdBy: 'tester',
      updatedBy: 'tester',
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
    ),
  );
}
