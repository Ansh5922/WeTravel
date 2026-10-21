import '../../domain/entities/profile_entity.dart';

/// Data Transfer Object for deserializing Profile JSON payloads from Node.js backend.
class ProfileModel extends ProfileEntity {
  const ProfileModel({
    super.id,
    super.userId,
    super.age,
    super.travelStyle,
    super.dietaryPreference,
    super.budget,
    super.budgetTier,
    super.pacePreference,
    super.healthConstraints,
    super.climateSensitivities,
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
      userId: target['userId']?.toString() ?? target['user_id']?.toString(),
      age: target['age'] != null ? (target['age'] as num).toInt() : null,
      travelStyle: (target['travelStyle'] ?? target['travel_style']) as String?,
      dietaryPreference: (target['dietaryPreference'] ?? target['dietary_preference']) as String?,
      budget: target['budget'] != null ? (target['budget'] as num).toDouble() : null,
      budgetTier: (target['budgetTier'] ?? target['budget_tier']) as String?,
      pacePreference: (target['pacePreference'] ?? target['pace_preference']) as String?,
      healthConstraints: target['healthConstraints'] is Map<String, dynamic>
          ? target['healthConstraints'] as Map<String, dynamic>
          : (target['health_constraints'] is Map<String, dynamic>
              ? target['health_constraints'] as Map<String, dynamic>
              : null),
      climateSensitivities: target['climateSensitivities'] is Map<String, dynamic>
          ? target['climateSensitivities'] as Map<String, dynamic>
          : (target['climate_sensitivities'] is Map<String, dynamic>
              ? target['climate_sensitivities'] as Map<String, dynamic>
              : null),
      rawPreferenceNotes: (target['rawPreferenceNotes'] ?? target['raw_preference_notes']) as String?,
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
      if (age != null) 'age': age,
      if (travelStyle != null) 'travelStyle': travelStyle,
      if (dietaryPreference != null) 'dietaryPreference': dietaryPreference,
      if (budget != null) 'budget': budget,
      if (budgetTier != null) 'budgetTier': budgetTier,
      if (pacePreference != null) 'pacePreference': pacePreference,
      if (healthConstraints != null) 'healthConstraints': healthConstraints,
      if (climateSensitivities != null) 'climateSensitivities': climateSensitivities,
      if (rawPreferenceNotes != null) 'rawPreferenceNotes': rawPreferenceNotes,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  @override
  ProfileModel copyWith({
    String? id,
    String? userId,
    int? age,
    String? travelStyle,
    String? dietaryPreference,
    double? budget,
    String? budgetTier,
    String? pacePreference,
    Map<String, dynamic>? healthConstraints,
    Map<String, dynamic>? climateSensitivities,
    String? rawPreferenceNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      age: age ?? this.age,
      travelStyle: travelStyle ?? this.travelStyle,
      dietaryPreference: dietaryPreference ?? this.dietaryPreference,
      budget: budget ?? this.budget,
      budgetTier: budgetTier ?? this.budgetTier,
      pacePreference: pacePreference ?? this.pacePreference,
      healthConstraints: healthConstraints ?? this.healthConstraints,
      climateSensitivities: climateSensitivities ?? this.climateSensitivities,
      rawPreferenceNotes: rawPreferenceNotes ?? this.rawPreferenceNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
