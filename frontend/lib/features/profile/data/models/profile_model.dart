import '../../domain/entities/profile_entity.dart';

/// Data Transfer Object for deserializing Profile JSON payloads from Node.js backend.
class ProfileModel extends ProfileEntity {
  const ProfileModel({
    super.id,
    super.userId,
    super.travelStyle,
    super.dietaryPreference,
    super.budget,
    super.budgetTier,
    super.pacePreference,
    super.rawPreferenceNotes,
    super.createdAt,
    super.updatedAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> target =
        (json.containsKey('data') && json['data'] is Map<String, dynamic>)
            ? (json['data'] as Map<String, dynamic>)['profile'] is Map<String, dynamic>
                ? (json['data'] as Map<String, dynamic>)['profile'] as Map<String, dynamic>
                : json['data'] as Map<String, dynamic>
            : (json.containsKey('profile') && json['profile'] is Map<String, dynamic>)
                ? json['profile'] as Map<String, dynamic>
                : json;

    return ProfileModel(
      id: target['id']?.toString(),
      userId: target['userId']?.toString(),
      travelStyle: target['travelStyle'] as String?,
      dietaryPreference: target['dietaryPreference'] as String?,
      budget: target['budget'] != null ? (target['budget'] as num).toDouble() : null,
      budgetTier: target['budgetTier'] as String?,
      pacePreference: target['pacePreference'] as String?,
      rawPreferenceNotes: target['rawPreferenceNotes'] as String?,
      createdAt: target['createdAt'] != null
          ? DateTime.tryParse(target['createdAt'].toString())
          : null,
      updatedAt: target['updatedAt'] != null
          ? DateTime.tryParse(target['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'userId': userId,
      if (travelStyle != null) 'travelStyle': travelStyle,
      if (dietaryPreference != null) 'dietaryPreference': dietaryPreference,
      if (budget != null) 'budget': budget,
      if (budgetTier != null) 'budgetTier': budgetTier,
      if (pacePreference != null) 'pacePreference': pacePreference,
      if (rawPreferenceNotes != null) 'rawPreferenceNotes': rawPreferenceNotes,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  ProfileModel copyWith({
    String? id,
    String? userId,
    String? travelStyle,
    String? dietaryPreference,
    double? budget,
    String? budgetTier,
    String? pacePreference,
    String? rawPreferenceNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      travelStyle: travelStyle ?? this.travelStyle,
      dietaryPreference: dietaryPreference ?? this.dietaryPreference,
      budget: budget ?? this.budget,
      budgetTier: budgetTier ?? this.budgetTier,
      pacePreference: pacePreference ?? this.pacePreference,
      rawPreferenceNotes: rawPreferenceNotes ?? this.rawPreferenceNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
