import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/itinerary/data/models/itinerary_model.dart';
import 'package:frontend/features/itinerary/domain/entities/itinerary_entity.dart';
import 'package:frontend/features/itinerary/domain/repositories/itinerary_repository.dart';
import 'package:frontend/features/itinerary/domain/usecases/generate_itinerary_usecase.dart';
import 'package:frontend/features/itinerary/domain/usecases/get_itineraries_usecase.dart';
import 'package:frontend/features/itinerary/domain/usecases/get_itinerary_detail_usecase.dart';
import 'package:frontend/features/itinerary/domain/usecases/select_itinerary_usecase.dart';
import 'package:frontend/features/itinerary/presentation/bloc/itinerary_bloc.dart';
import 'package:frontend/features/itinerary/presentation/bloc/itinerary_event.dart';
import 'package:frontend/features/itinerary/presentation/bloc/itinerary_state.dart';

class FakeItineraryRepository implements ItineraryRepository {
  List<ItineraryEntity>? listToReturn;
  ItineraryEntity? detailToReturn;
  Exception? exceptionToThrow;

  @override
  Future<List<ItineraryEntity>> getItineraries(String tripId) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return listToReturn ??
        const [
          ItineraryEntity(
            id: 'itin_1',
            groupId: 'trip_10',
            generatedBy: 'ai',
            variantType: 'Relaxed',
            version: 1,
            isSelected: true,
            items: [],
          ),
        ];
  }

  @override
  Future<ItineraryEntity> getItineraryById(String tripId, String itineraryId) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return detailToReturn ??
        const ItineraryEntity(
          id: 'itin_1',
          groupId: 'trip_10',
          generatedBy: 'ai',
          variantType: 'Relaxed',
          version: 1,
          isSelected: true,
          items: [],
        );
  }

  @override
  Future<List<ItineraryEntity>> generateItineraries({
    required String tripId,
    required String origin,
    required String destination,
    required String startDate,
    required String endDate,
    int? memberCount,
    Map<String, dynamic>? constraints,
  }) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return listToReturn ??
        const [
          ItineraryEntity(
            id: 'itin_gen_1',
            groupId: 'trip_10',
            generatedBy: 'ai',
            variantType: 'Balanced AI',
            version: 1,
            isSelected: false,
            items: [],
          ),
        ];
  }

  @override
  Future<ItineraryEntity> selectItinerary(String tripId, String itineraryId) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return const ItineraryEntity(
      id: 'itin_1',
      groupId: 'trip_10',
      generatedBy: 'ai',
      variantType: 'Relaxed',
      version: 1,
      isSelected: true,
      items: [],
    );
  }
}

void main() {
  group('ItineraryModel JSON Parsing', () {
    test('fromJson parses full backend itinerary payload', () {
      final json = {
        'id': 'itin_500',
        'groupId': 'trip_10',
        'generatedBy': 'ai',
        'variantType': 'Adventure Focused',
        'version': 2,
        'isSelected': true,
        'items': [
          {
            'id': 'item_1',
            'dayNumber': 1,
            'timeSlot': '08:00 AM',
            'activityName': 'Scuba Diving at Grand Island',
            'estimatedCost': 2500.0,
          }
        ]
      };

      final model = ItineraryModel.fromJson(json);

      expect(model.id, 'itin_500');
      expect(model.variantType, 'Adventure Focused');
      expect(model.version, 2);
      expect(model.isSelected, isTrue);
      expect(model.items.length, 1);
      expect(model.items.first.activityName, 'Scuba Diving at Grand Island');
      expect(model.items.first.estimatedCost, 2500.0);
    });
  });

  group('ItineraryBloc Unit Tests', () {
    late FakeItineraryRepository fakeRepository;
    late ItineraryBloc itineraryBloc;

    setUp(() {
      fakeRepository = FakeItineraryRepository();
      itineraryBloc = ItineraryBloc(
        getItinerariesUseCase: GetItinerariesUseCase(fakeRepository),
        getItineraryDetailUseCase: GetItineraryDetailUseCase(fakeRepository),
        generateItineraryUseCase: GenerateItineraryUseCase(fakeRepository),
        selectItineraryUseCase: SelectItineraryUseCase(fakeRepository),
      );
    });

    tearDown(() {
      itineraryBloc.close();
    });

    test('initial state is ItineraryInitialState', () {
      expect(itineraryBloc.state, isA<ItineraryInitialState>());
    });

    test('ItinerariesFetchRequested emits ItinerariesLoadedState', () async {
      itineraryBloc.add(const ItinerariesFetchRequested('trip_10'));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(itineraryBloc.state, isA<ItinerariesLoadedState>());
      final loaded = itineraryBloc.state as ItinerariesLoadedState;
      expect(loaded.itineraries.length, 1);
      expect(loaded.selectedItinerary?.variantType, 'Relaxed');
    });

    test('ItineraryGenerateRequested triggers AI generation and emits itineraries', () async {
      itineraryBloc.add(const ItineraryGenerateRequested(
        tripId: 'trip_10',
        origin: 'Mumbai',
        destination: 'Goa',
        startDate: '2026-10-12',
        endDate: '2026-10-15',
      ));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(itineraryBloc.state, isA<ItinerariesLoadedState>());
      final loaded = itineraryBloc.state as ItinerariesLoadedState;
      expect(loaded.successMessage, contains('Generated'));
    });
  });
}
