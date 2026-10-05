import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/memories/data/models/memory_model.dart';
import 'package:frontend/features/memories/domain/entities/memory_entity.dart';
import 'package:frontend/features/memories/domain/repositories/memory_repository.dart';
import 'package:frontend/features/memories/domain/usecases/memory_usecases.dart';
import 'package:frontend/features/memories/presentation/bloc/memory_bloc.dart';
import 'package:frontend/features/memories/presentation/bloc/memory_event.dart';
import 'package:frontend/features/memories/presentation/bloc/memory_state.dart';

class FakeMemoryRepository implements MemoryRepository {
  List<MemoryEntity>? memoriesToReturn;
  List<MemoryEntity>? highlightsToReturn;
  Exception? exceptionToThrow;

  @override
  Future<List<MemoryEntity>> getMemoriesTimeline(String tripId) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return memoriesToReturn ??
        [
          MemoryEntity(
            id: 'mem_1',
            tripId: tripId,
            uploaderId: 'usr_1',
            imageUrl: 'https://images.unsplash.com/photo-beach',
            caption: 'Sunset at Beach',
            dayNumber: 1,
            isHighlight: true,
            uploaderUsername: 'rashi',
            uploaderFullName: 'Rashi',
            createdAt: DateTime.now(),
          )
        ];
  }

  @override
  Future<List<MemoryEntity>> getHighlights(String tripId) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return highlightsToReturn ??
        [
          MemoryEntity(
            id: 'mem_1',
            tripId: tripId,
            uploaderId: 'usr_1',
            imageUrl: 'https://images.unsplash.com/photo-beach',
            caption: 'Sunset at Beach',
            dayNumber: 1,
            isHighlight: true,
            uploaderUsername: 'rashi',
            uploaderFullName: 'Rashi',
            createdAt: DateTime.now(),
          )
        ];
  }

  @override
  Future<List<MemoryEntity>> uploadMemories({
    required String tripId,
    required List<Map<String, dynamic>> photos,
  }) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return [
      MemoryEntity(
        id: 'mem_2',
        tripId: tripId,
        uploaderId: 'usr_1',
        imageUrl: photos.first['imageUrl'] ?? 'https://images.unsplash.com/photo-new',
        caption: photos.first['caption'],
        dayNumber: 2,
        isHighlight: false,
        uploaderUsername: 'rashi',
        uploaderFullName: 'Rashi',
        createdAt: DateTime.now(),
      )
    ];
  }

  @override
  Future<MemoryEntity> toggleHighlight(String tripId, String memoryId) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return MemoryEntity(
      id: memoryId,
      tripId: tripId,
      uploaderId: 'usr_1',
      imageUrl: 'https://images.unsplash.com/photo-beach',
      caption: 'Sunset at Beach',
      dayNumber: 1,
      isHighlight: false,
      uploaderUsername: 'rashi',
      uploaderFullName: 'Rashi',
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<void> deleteMemory(String tripId, String memoryId) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
  }
}

void main() {
  group('MemoryModel JSON Parsing', () {
    test('MemoryModel.fromJson parses photo payload', () {
      final json = {
        'id': 'mem_10',
        'groupId': 'trip_1',
        'uploaderId': 'usr_2',
        'imageUrl': 'https://example.com/photo.jpg',
        'caption': 'Villa pool',
        'dayNumber': 3,
        'isHighlight': true,
        'createdAt': '2026-10-05T12:00:00.000Z',
        'uploader': {'id': 'usr_2', 'username': 'sam', 'fullName': 'Sam'}
      };

      final model = MemoryModel.fromJson(json);

      expect(model.id, 'mem_10');
      expect(model.imageUrl, 'https://example.com/photo.jpg');
      expect(model.dayNumber, 3);
      expect(model.isHighlight, isTrue);
    });
  });

  group('MemoryBloc Unit Tests', () {
    late FakeMemoryRepository fakeRepository;
    late MemoryBloc memoryBloc;

    setUp(() {
      fakeRepository = FakeMemoryRepository();
      memoryBloc = MemoryBloc(
        getMemoriesTimelineUseCase: GetMemoriesTimelineUseCase(fakeRepository),
        getMemoryHighlightsUseCase: GetMemoryHighlightsUseCase(fakeRepository),
        uploadMemoriesUseCase: UploadMemoriesUseCase(fakeRepository),
        toggleMemoryHighlightUseCase: ToggleMemoryHighlightUseCase(fakeRepository),
        deleteMemoryUseCase: DeleteMemoryUseCase(fakeRepository),
      );
    });

    tearDown(() {
      memoryBloc.close();
    });

    test('initial state is MemoryInitialState', () {
      expect(memoryBloc.state, isA<MemoryInitialState>());
    });

    test('MemoriesFetchRequested success emits MemoriesLoadedState', () async {
      memoryBloc.add(const MemoriesFetchRequested(tripId: 'trip_1'));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(memoryBloc.state, isA<MemoriesLoadedState>());
      final loaded = memoryBloc.state as MemoriesLoadedState;
      expect(loaded.memories.length, 1);
      expect(loaded.highlights.length, 1);
    });
  });
}
