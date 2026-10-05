import 'package:equatable/equatable.dart';

class ItineraryItemEntity extends Equatable {
  final String id;
  final int dayNumber;
  final String timeSlot;
  final String? startTime;
  final String? endTime;
  final String activityName;
  final String? description;
  final String? location;
  final String? transitMode;
  final double estimatedCost;
  final bool isMissed;

  const ItineraryItemEntity({
    required this.id,
    required this.dayNumber,
    required this.timeSlot,
    this.startTime,
    this.endTime,
    required this.activityName,
    this.description,
    this.location,
    this.transitMode,
    required this.estimatedCost,
    this.isMissed = false,
  });

  @override
  List<Object?> get props => [
        id,
        dayNumber,
        timeSlot,
        startTime,
        endTime,
        activityName,
        description,
        location,
        transitMode,
        estimatedCost,
        isMissed,
      ];
}

class ItineraryEntity extends Equatable {
  final String id;
  final String groupId;
  final String generatedBy;
  final String? variantType;
  final int version;
  final String? summary;
  final double? totalCostPerPerson;
  final bool isSelected;
  final List<ItineraryItemEntity> items;

  const ItineraryEntity({
    required this.id,
    required this.groupId,
    required this.generatedBy,
    this.variantType,
    required this.version,
    this.summary,
    this.totalCostPerPerson,
    this.isSelected = false,
    required this.items,
  });

  @override
  List<Object?> get props => [
        id,
        groupId,
        generatedBy,
        variantType,
        version,
        summary,
        totalCostPerPerson,
        isSelected,
        items,
      ];
}
