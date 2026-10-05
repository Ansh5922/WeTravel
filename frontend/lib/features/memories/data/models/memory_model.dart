import '../../domain/entities/memory_entity.dart';

class MemoryModel extends MemoryEntity {
  const MemoryModel({
    required super.id,
    required super.tripId,
    required super.uploaderId,
    required super.imageUrl,
    super.caption,
    super.dayNumber,
    super.isHighlight,
    required super.uploaderUsername,
    required super.uploaderFullName,
    required super.createdAt,
  });

  factory MemoryModel.fromJson(Map<String, dynamic> json) {
    final uploader = json['uploader'] ?? {};
    return MemoryModel(
      id: json['id'] ?? '',
      tripId: json['groupId'] ?? json['tripId'] ?? '',
      uploaderId: json['uploaderId'] ?? uploader['id'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      caption: json['caption'],
      dayNumber: json['dayNumber'] is int ? json['dayNumber'] : int.tryParse(json['dayNumber']?.toString() ?? ''),
      isHighlight: json['isHighlight'] ?? false,
      uploaderUsername: uploader['username'] ?? 'User',
      uploaderFullName: uploader['fullName'] ?? uploader['username'] ?? 'WeTravel Member',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tripId': tripId,
      'uploaderId': uploaderId,
      'imageUrl': imageUrl,
      'caption': caption,
      'dayNumber': dayNumber,
      'isHighlight': isHighlight,
      'uploader': {
        'username': uploaderUsername,
        'fullName': uploaderFullName,
      },
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
