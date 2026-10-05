import '../../domain/entities/preferences_entity.dart';

class PreferencesModel extends PreferencesEntity {
  const PreferencesModel({
    super.id,
    super.travelStyle,
    super.dietaryPreference,
    super.budget,
    super.budgetTier,
    super.pacePreference,
    super.rawPreferenceNotes,
  });

  factory PreferencesModel.fromJson(Map<String, dynamic> json) {
    final dataObj = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;
    final profObj = (dataObj['profile'] is Map<String, dynamic>)
        ? dataObj['profile'] as Map<String, dynamic>
        : dataObj;

    return PreferencesModel(
      id: profObj['id']?.toString(),
      travelStyle: profObj['travelStyle']?.toString(),
      dietaryPreference: profObj['dietaryPreference']?.toString(),
      budget: (profObj['budget'] is num) ? (profObj['budget'] as num).toDouble() : null,
      budgetTier: profObj['budgetTier']?.toString(),
      pacePreference: profObj['pacePreference']?.toString(),
      rawPreferenceNotes: profObj['rawPreferenceNotes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (travelStyle != null && travelStyle!.trim().isNotEmpty) 'travelStyle': travelStyle!.trim(),
      if (dietaryPreference != null && dietaryPreference!.trim().isNotEmpty) 'dietaryPreference': dietaryPreference!.trim(),
      if (budget != null) 'budget': budget,
      if (budgetTier != null && budgetTier!.trim().isNotEmpty) 'budgetTier': budgetTier!.trim(),
      if (pacePreference != null && pacePreference!.trim().isNotEmpty) 'pacePreference': pacePreference!.trim(),
      if (rawPreferenceNotes != null && rawPreferenceNotes!.trim().isNotEmpty) 'rawPreferenceNotes': rawPreferenceNotes!.trim(),
    };
  }
}
