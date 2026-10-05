import 'package:equatable/equatable.dart';

class MemoryEntity extends Equatable {
  final String id;
  final String tripId;
  final String uploaderId;
  final String imageUrl;
  final String? caption;
  final int? dayNumber;
  final bool isHighlight;
  final String uploaderUsername;
  final String uploaderFullName;
  final DateTime createdAt;

  const MemoryEntity({
    required this.id,
    required this.tripId,
    required this.uploaderId,
    required this.imageUrl,
    this.caption,
    this.dayNumber,
    this.isHighlight = false,
    required this.uploaderUsername,
    required this.uploaderFullName,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        tripId,
        uploaderId,
        imageUrl,
        caption,
        dayNumber,
        isHighlight,
        uploaderUsername,
        uploaderFullName,
        createdAt,
      ];
}
