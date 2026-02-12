import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learnwise/core/model/audit_metadata.dart';
import 'package:learnwise/features/folders/model/folder_models.dart';
import 'package:learnwise/features/folders/repository/folder_repository.dart';
import 'package:learnwise/features/folders/viewmodel/folder_viewmodel.dart';

class FakeFolderRepository implements FolderRepository {
  int getFoldersCalls = 0;
  final List<FolderListQuery> capturedQueries = <FolderListQuery>[];
  final List<int> capturedPages = <int>[];
  final List<Completer<FolderPageResult>> _pendingResponses =
      <Completer<FolderPageResult>>[];

  Completer<FolderPageResult> dequeuePendingResponse() {
    if (_pendingResponses.isEmpty) {
      throw StateError('No pending response to dequeue');
    }
    return _pendingResponses.removeAt(0);
  }

  @override
  Future<FolderPageResult> getFolders({
    required FolderListQuery query,
    required int page,
  }) {
    getFoldersCalls++;
    capturedQueries.add(query);
    capturedPages.add(page);
    final Completer<FolderPageResult> completer = Completer<FolderPageResult>();
    _pendingResponses.add(completer);
    return completer.future;
  }

  @override
  Future<FolderItem> createFolder(FolderUpsertInput input) async {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteFolder(int folderId) async {
    throw UnimplementedError();
  }

  @override
  Future<FolderItem> updateFolder({
    required int folderId,
    required FolderUpsertInput input,
  }) async {
    throw UnimplementedError();
  }
}

void main() {
  group('FolderController', () {
    test('passes parentFolderId in query after enterFolder', () async {
      final FakeFolderRepository fakeRepository = FakeFolderRepository();
      final ProviderContainer container = ProviderContainer(
        overrides: [folderRepositoryProvider.overrideWithValue(fakeRepository)],
      );
      addTearDown(container.dispose);

      final Future<FolderListingState> initialFuture = container.read(
        folderControllerProvider.future,
      );
      fakeRepository.dequeuePendingResponse().complete(
        _buildPageResult(items: <FolderItem>[_item(1)]),
      );
      await initialFuture;

      final FolderController controller = container.read(
        folderControllerProvider.notifier,
      );
      controller.enterFolder(_item(42));
      await Future<void>.delayed(Duration.zero);

      expect(fakeRepository.getFoldersCalls, 2);
      final FolderListQuery secondQuery = fakeRepository.capturedQueries[1];
      expect(secondQuery.parentFolderId, 42);

      final Map<String, dynamic> queryParameters = secondQuery
          .toQueryParameters(page: 0);
      expect(queryParameters['parentFolderId'], 42);

      fakeRepository.dequeuePendingResponse().complete(
        _buildPageResult(items: <FolderItem>[_item(43)]),
      );
      await container.read(folderControllerProvider.future);
    });

    test(
      'passes parentFolderId in probe query for hasDirectChildren',
      () async {
        final FakeFolderRepository fakeRepository = FakeFolderRepository();
        final ProviderContainer container = ProviderContainer(
          overrides: [
            folderRepositoryProvider.overrideWithValue(fakeRepository),
          ],
        );
        addTearDown(container.dispose);

        final Future<FolderListingState> initialFuture = container.read(
          folderControllerProvider.future,
        );
        fakeRepository.dequeuePendingResponse().complete(
          _buildPageResult(items: <FolderItem>[_item(1)]),
        );
        await initialFuture;

        final FolderController controller = container.read(
          folderControllerProvider.notifier,
        );
        final Future<bool> hasChildrenFuture = controller.hasDirectChildren(88);

        expect(fakeRepository.getFoldersCalls, 2);
        final FolderListQuery probeQuery = fakeRepository.capturedQueries[1];
        expect(probeQuery.parentFolderId, 88);
        expect(probeQuery.size, 1);
        expect(fakeRepository.capturedPages[1], 0);

        fakeRepository.dequeuePendingResponse().complete(
          _buildPageResult(items: const <FolderItem>[]),
        );
        final bool hasChildren = await hasChildrenFuture;
        expect(hasChildren, false);
      },
    );

    test('keeps previous data while query is reloading', () async {
      final FakeFolderRepository fakeRepository = FakeFolderRepository();
      final ProviderContainer container = ProviderContainer(
        overrides: [folderRepositoryProvider.overrideWithValue(fakeRepository)],
      );
      addTearDown(container.dispose);

      final Future<FolderListingState> initialFuture = container.read(
        folderControllerProvider.future,
      );
      final Completer<FolderPageResult> initialResponse = fakeRepository
          .dequeuePendingResponse();
      initialResponse.complete(_buildPageResult(items: <FolderItem>[_item(1)]));
      final FolderListingState initialListing = await initialFuture;
      expect(initialListing.items.length, 1);

      container
          .read(folderQueryControllerProvider.notifier)
          .setSearch('algebra');
      await Future<void>.delayed(Duration.zero);

      final AsyncValue<FolderListingState> reloadingState = container.read(
        folderControllerProvider,
      );
      expect(reloadingState.isLoading, true);
      expect(reloadingState.hasValue, true);
      expect(
        reloadingState.requireValue.items.map((item) => item.id),
        <int>[1],
      );

      final Completer<FolderPageResult> searchResponse = fakeRepository
          .dequeuePendingResponse();
      searchResponse.complete(_buildPageResult(items: const <FolderItem>[]));
      final FolderListingState searchListing = await container.read(
        folderControllerProvider.future,
      );
      expect(searchListing.items, isEmpty);
    });

    test('ignores stale response when query changes quickly', () async {
      final FakeFolderRepository fakeRepository = FakeFolderRepository();
      final ProviderContainer container = ProviderContainer(
        overrides: [folderRepositoryProvider.overrideWithValue(fakeRepository)],
      );
      addTearDown(container.dispose);

      final Future<FolderListingState> initialFuture = container.read(
        folderControllerProvider.future,
      );
      fakeRepository.dequeuePendingResponse().complete(
        _buildPageResult(items: <FolderItem>[_item(1)]),
      );
      await initialFuture;

      container.read(folderQueryControllerProvider.notifier).setSearch('a');
      await Future<void>.delayed(Duration.zero);
      final Completer<FolderPageResult> firstSearchResponse = fakeRepository
          .dequeuePendingResponse();

      container.read(folderQueryControllerProvider.notifier).setSearch('ab');
      await Future<void>.delayed(Duration.zero);
      final Completer<FolderPageResult> secondSearchResponse = fakeRepository
          .dequeuePendingResponse();

      firstSearchResponse.complete(
        _buildPageResult(items: const <FolderItem>[]),
      );
      secondSearchResponse.complete(
        _buildPageResult(items: <FolderItem>[_item(9)]),
      );
      await Future<void>.delayed(Duration.zero);

      final AsyncValue<FolderListingState> latestState = container.read(
        folderControllerProvider,
      );
      expect(latestState.hasValue, true);
      expect(
        latestState.requireValue.items.map((item) => item.id),
        <int>[9],
      );
    });

    test('does not reload when normalized query does not change', () async {
      final FakeFolderRepository fakeRepository = FakeFolderRepository();
      final ProviderContainer container = ProviderContainer(
        overrides: [folderRepositoryProvider.overrideWithValue(fakeRepository)],
      );
      addTearDown(container.dispose);

      final Future<FolderListingState> initialFuture = container.read(
        folderControllerProvider.future,
      );
      fakeRepository.dequeuePendingResponse().complete(
        _buildPageResult(items: <FolderItem>[_item(1)]),
      );
      await initialFuture;
      expect(fakeRepository.getFoldersCalls, 1);

      final FolderQueryController queryController = container.read(
        folderQueryControllerProvider.notifier,
      );
      queryController.setSearch('   ');
      queryController.setSortBy(FolderSortBy.createdAt);
      queryController.setSortDirection(FolderSortDirection.desc);
      queryController.goToRoot();
      await Future<void>.delayed(Duration.zero);

      expect(fakeRepository.getFoldersCalls, 1);
    });
  });
}

FolderPageResult _buildPageResult({required List<FolderItem> items}) {
  return FolderPageResult(
    items: items,
    page: 0,
    size: 20,
    totalElements: items.length,
    totalPages: 1,
    hasNext: false,
    hasPrevious: false,
    search: '',
    sortBy: FolderSortBy.createdAt,
    sortDirection: FolderSortDirection.desc,
  );
}

FolderItem _item(int id) {
  return FolderItem(
    id: id,
    name: 'Folder $id',
    description: 'Description $id',
    colorHex: '#123456',
    parentFolderId: null,
    directFlashcardCount: 0,
    directDeckCount: 0,
    flashcardCount: 0,
    childFolderCount: 0,
    audit: AuditMetadata(
      createdBy: 'tester',
      updatedBy: 'tester',
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
    ),
  );
}
