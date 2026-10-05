import '../../domain/entities/itinerary_entity.dart';

class ItineraryItemModel extends ItineraryItemEntity {
  const ItineraryItemModel({
    required super.id,
    required super.dayNumber,
    required super.timeSlot,
    super.startTime,
    super.endTime,
    required super.activityName,
    super.description,
    super.location,
    super.transitMode,
    required super.estimatedCost,
    super.isMissed,
  });

  factory ItineraryItemModel.fromJson(Map<String, dynamic> json) {
    return ItineraryItemModel(
      id: json['id']?.toString() ?? '',
      dayNumber: (json['dayNumber'] is num) ? (json['dayNumber'] as num).toInt() : 1,
      timeSlot: json['timeSlot']?.toString() ?? json['startTime']?.toString() ?? '09:00',
      startTime: json['startTime']?.toString(),
      endTime: json['endTime']?.toString(),
      activityName: json['activityName']?.toString() ?? 'Activity',
      description: json['description']?.toString(),
      location: json['location']?.toString(),
      transitMode: json['transitMode']?.toString(),
      estimatedCost: (json['estimatedCost'] is num) ? (json['estimatedCost'] as num).toDouble() : 0.0,
      isMissed: json['isMissed'] == true,
    );
  }
}

class ItineraryModel extends ItineraryEntity {
  const ItineraryModel({
    required super.id,
    required super.groupId,
    required super.generatedBy,
    super.variantType,
    required super.version,
    super.summary,
    super.totalCostPerPerson,
    super.isSelected,
    required super.items,
  });

  factory ItineraryModel.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List<dynamic>?)
            ?.map((i) => ItineraryItemModel.fromJson(i as Map<String, dynamic>))
            .toList() ??
        [];

    return ItineraryModel(
      id: json['id']?.toString() ?? '',
      groupId: json['groupId']?.toString() ?? '',
      generatedBy: json['generatedBy']?.toString() ?? 'ai',
      variantType: json['variantType']?.toString(),
      version: (json['version'] is num) ? (json['version'] as num).toInt() : 1,
      summary: json['summary']?.toString(),
      totalCostPerPerson: (json['totalCostPerPerson'] is num)
          ? (json['totalCostPerPerson'] as num).toDouble()
          : null,
      isSelected: json['isSelected'] == true,
      items: itemsList,
    );
  }
}
