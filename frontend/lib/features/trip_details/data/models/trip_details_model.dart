import '../../domain/entities/trip_details_entity.dart';

class TripDetailsModel extends TripDetailsEntity {
  const TripDetailsModel({super.id});

  factory TripDetailsModel.fromJson(Map<String, dynamic> json) {
    return TripDetailsModel(
      id: json['id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}
