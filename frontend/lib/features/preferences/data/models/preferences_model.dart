import '../../domain/entities/preferences_entity.dart';

class PreferencesModel extends PreferencesEntity {
  const PreferencesModel({super.id});

  factory PreferencesModel.fromJson(Map<String, dynamic> json) {
    return PreferencesModel(
      id: json['id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}
