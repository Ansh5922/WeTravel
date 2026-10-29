import 'package:equatable/equatable.dart';

class TripGroupMemberEntity extends Equatable {
  final String id;
  final String userId;
  final String role; // 'admin' | 'member'
  final String email;
  final String username;
  final String fullName;
  final String? avatarUrl;
  final String? dietaryPreference;
  final String? travelStyle;
  final String? pacePreference;
  final String? budgetTier;
  final dynamic healthConstraints;
  final dynamic climateSensitivities;

  const TripGroupMemberEntity({
    required this.id,
    required this.userId,
    required this.role,
    required this.email,
    required this.username,
    required this.fullName,
    this.avatarUrl,
    this.dietaryPreference,
    this.travelStyle,
    this.pacePreference,
    this.budgetTier,
    this.healthConstraints,
    this.climateSensitivities,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        role,
        email,
        username,
        fullName,
        avatarUrl,
        dietaryPreference,
        travelStyle,
        pacePreference,
        budgetTier,
        healthConstraints,
        climateSensitivities,
      ];
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
  final Map<String, dynamic>? groupStats;

  const GroupConsensusEntity({
    required this.id,
    required this.groupId,
    this.computedBudgetRange,
    this.hardConstraints = const [],
    this.isLockedByAdmin = false,
    this.groupStats,
  });

  String get dominantTravelStyle {
    final style = groupStats?['travel_styles']?['dominant_style']?.toString();
    if (style != null && style.isNotEmpty) {
      return style[0].toUpperCase() + style.substring(1);
    }
    return 'Relaxed';
  }

  String get majorityPace {
    final pace = groupStats?['pace']?['majority_pace']?.toString();
    if (pace != null && pace.isNotEmpty) {
      return pace[0].toUpperCase() + pace.substring(1);
    }
    return 'Moderate';
  }

  String get budgetDisplay {
    final budget = groupStats?['budget'];
    if (budget is Map<String, dynamic>) {
      final avg = budget['group_avg'];
      final curr = budget['currency'] ?? '₹';
      final currSign = curr == 'INR' ? '₹' : (curr == 'USD' ? '\$' : '$curr ');
      if (avg != null && avg.toString().toLowerCase() != 'null' && avg.toString().trim().isNotEmpty) {
        return '$currSign$avg';
      }
    }
    if (computedBudgetRange != null &&
        computedBudgetRange!.isNotEmpty &&
        !computedBudgetRange!.toLowerCase().contains('null')) {
      return computedBudgetRange!;
    }
    return 'Flexible';
  }

  List<String> get dietaryRestrictions {
    final list = groupStats?['dietary']?['restrictions'] as List<dynamic>?;
    return list?.map((e) => e.toString()).toList() ?? [];
  }

  List<String> get climateSensitivities {
    final list = groupStats?['climate']?['sensitivities'] as List<dynamic>?;
    return list?.map((e) => e.toString()).toList() ?? [];
  }

  @override
  List<Object?> get props => [
        id,
        groupId,
        computedBudgetRange,
        hardConstraints,
        isLockedByAdmin,
        groupStats,
      ];
}

