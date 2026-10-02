import '../../domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({super.id});

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}
