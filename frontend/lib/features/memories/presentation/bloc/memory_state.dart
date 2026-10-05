import 'package:equatable/equatable.dart';
import '../../domain/entities/memory_entity.dart';

abstract class MemoryState extends Equatable {
  const MemoryState();

  @override
  List<Object?> get props => [];
}

class MemoryInitialState extends MemoryState {}

class MemoryLoadingState extends MemoryState {}

class MemoriesLoadedState extends MemoryState {
  final List<MemoryEntity> memories;
  final List<MemoryEntity> highlights;
  final String? successMessage;

  const MemoriesLoadedState({
    required this.memories,
    this.highlights = const [],
    this.successMessage,
  });

  MemoriesLoadedState copyWith({
    List<MemoryEntity>? memories,
    List<MemoryEntity>? highlights,
    String? successMessage,
  }) {
    return MemoriesLoadedState(
      memories: memories ?? this.memories,
      highlights: highlights ?? this.highlights,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [memories, highlights, successMessage];
}

class MemoryErrorState extends MemoryState {
  final String message;
  const MemoryErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}
