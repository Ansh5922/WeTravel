import 'package:equatable/equatable.dart';

abstract class MemoryEvent extends Equatable {
  const MemoryEvent();

  @override
  List<Object?> get props => [];
}

class MemoriesFetchRequested extends MemoryEvent {
  final String tripId;
  const MemoriesFetchRequested({required this.tripId});

  @override
  List<Object?> get props => [tripId];
}

class MemoryHighlightsFetchRequested extends MemoryEvent {
  final String tripId;
  const MemoryHighlightsFetchRequested({required this.tripId});

  @override
  List<Object?> get props => [tripId];
}

class MemoryUploadRequested extends MemoryEvent {
  final String tripId;
  final List<Map<String, dynamic>> photos;

  const MemoryUploadRequested({
    required this.tripId,
    required this.photos,
  });

  @override
  List<Object?> get props => [tripId, photos];
}

class MemoryToggleHighlightRequested extends MemoryEvent {
  final String tripId;
  final String memoryId;

  const MemoryToggleHighlightRequested({
    required this.tripId,
    required this.memoryId,
  });

  @override
  List<Object?> get props => [tripId, memoryId];
}

class MemoryDeleteRequested extends MemoryEvent {
  final String tripId;
  final String memoryId;

  const MemoryDeleteRequested({
    required this.tripId,
    required this.memoryId,
  });

  @override
  List<Object?> get props => [tripId, memoryId];
}
