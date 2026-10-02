import '../../domain/entities/auth_entity.dart';

class AuthModel extends AuthEntity {
  const AuthModel({super.id});

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      id: json['id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}
