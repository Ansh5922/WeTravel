import '../../domain/entities/trips_entity.dart';

class TripsModel extends TripsEntity {
  const TripsModel({super.id});

  factory TripsModel.fromJson(Map<String, dynamic> json) {
    return TripsModel(
      id: json['id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}
