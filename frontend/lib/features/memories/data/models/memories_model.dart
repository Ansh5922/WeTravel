import '../../domain/entities/memories_entity.dart';

class MemoriesModel extends MemoriesEntity {
  const MemoriesModel({super.id});

  factory MemoriesModel.fromJson(Map<String, dynamic> json) {
    return MemoriesModel(
      id: json['id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}
