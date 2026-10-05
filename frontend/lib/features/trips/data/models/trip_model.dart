import '../../domain/entities/trip_entity.dart';

class TripGroupMemberModel extends TripGroupMemberEntity {
  const TripGroupMemberModel({
    required super.id,
    required super.userId,
    required super.role,
    required super.email,
    required super.username,
    required super.fullName,
  });

  factory TripGroupMemberModel.fromJson(Map<String, dynamic> json) {
    final userData = (json['user'] is Map<String, dynamic>)
        ? json['user'] as Map<String, dynamic>
        : {};

    return TripGroupMemberModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? userData['id']?.toString() ?? '',
      role: json['role']?.toString() ?? 'member',
      email: userData['email']?.toString() ?? '',
      username: userData['username']?.toString() ?? '',
      fullName: userData['fullName']?.toString() ?? userData['username']?.toString() ?? 'Traveler',
    );
  }
}

class TripModel extends TripEntity {
  const TripModel({
    required super.id,
    required super.name,
    required super.createdBy,
    required super.status,
    super.tripStartDate,
    super.tripEndDate,
    super.coverImageUrl,
    required super.members,
    required super.createdAt,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    final membersList = (json['members'] as List<dynamic>?)
            ?.map((m) => TripGroupMemberModel.fromJson(m as Map<String, dynamic>))
            .toList() ??
        [];

    DateTime? startDate;
    if (json['tripStartDate'] != null) {
      try {
        startDate = DateTime.parse(json['tripStartDate'].toString());
      } catch (_) {}
    }

    DateTime? endDate;
    if (json['tripEndDate'] != null) {
      try {
        endDate = DateTime.parse(json['tripEndDate'].toString());
      } catch (_) {}
    }

    DateTime createdAt = DateTime.now();
    if (json['createdAt'] != null) {
      try {
        createdAt = DateTime.parse(json['createdAt'].toString());
      } catch (_) {}
    }

    return TripModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Untitled Trip',
      createdBy: json['createdBy']?.toString() ?? '',
      status: json['status']?.toString() ?? 'planning',
      tripStartDate: startDate,
      tripEndDate: endDate,
      coverImageUrl: json['coverImageUrl']?.toString(),
      members: membersList,
      createdAt: createdAt,
    );
  }
}

class GroupConsensusModel extends GroupConsensusEntity {
  const GroupConsensusModel({
    required super.id,
    required super.groupId,
    super.computedBudgetRange,
    super.hardConstraints,
    super.isLockedByAdmin,
  });

  factory GroupConsensusModel.fromJson(Map<String, dynamic> json) {
    final constraintsList = (json['hardConstraints'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    return GroupConsensusModel(
      id: json['id']?.toString() ?? '',
      groupId: json['groupId']?.toString() ?? '',
      computedBudgetRange: json['computedBudgetRange']?.toString(),
      hardConstraints: constraintsList,
      isLockedByAdmin: json['isLockedByAdmin'] == true,
    );
  }
}
