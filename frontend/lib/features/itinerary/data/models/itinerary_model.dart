import '../../domain/entities/itinerary_entity.dart';

class ItineraryModel extends ItineraryEntity {
  const ItineraryModel({super.id});

  factory ItineraryModel.fromJson(Map<String, dynamic> json) {
    return ItineraryModel(
      id: json['id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}
