import 'package:equatable/equatable.dart';

class TripGroupMemberEntity extends Equatable {
  final String id;
  final String userId;
  final String role; // 'admin' | 'member'
  final String email;
  final String username;
  final String fullName;

  const TripGroupMemberEntity({
    required this.id,
    required this.userId,
    required this.role,
    required this.email,
    required this.username,
    required this.fullName,
  });

  @override
  List<Object?> get props => [id, userId, role, email, username, fullName];
}

class TripEntity extends Equatable {
  final String id;
  final String name;
  final String createdBy;
  final String status; // 'planning' | 'ongoing' | 'completed'
  final DateTime? tripStartDate;
  final DateTime? tripEndDate;
  final String? coverImageUrl;
  final List<TripGroupMemberEntity> members;
  final DateTime createdAt;

  const TripEntity({
    required this.id,
    required this.name,
    required this.createdBy,
    required this.status,
    this.tripStartDate,
    this.tripEndDate,
    this.coverImageUrl,
    required this.members,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        createdBy,
        status,
        tripStartDate,
        tripEndDate,
        coverImageUrl,
        members,
        createdAt,
      ];
}

class GroupConsensusEntity extends Equatable {
  final String id;
  final String groupId;
  final String? computedBudgetRange;
  final List<String> hardConstraints;
  final bool isLockedByAdmin;

  const GroupConsensusEntity({
    required this.id,
    required this.groupId,
    this.computedBudgetRange,
    this.hardConstraints = const [],
    this.isLockedByAdmin = false,
  });

  @override
  List<Object?> get props => [
        id,
        groupId,
        computedBudgetRange,
        hardConstraints,
        isLockedByAdmin,
      ];
}
