import '../../domain/entities/auth_response_entity.dart';
import 'user_model.dart';

class AuthResponseModel extends AuthResponseEntity {
  const AuthResponseModel({
    required super.user,
    super.token,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> target =
        (json.containsKey('data') && json['data'] is Map<String, dynamic>)
            ? json['data'] as Map<String, dynamic>
            : json;

    final userJson = target['user'] is Map<String, dynamic>
        ? target['user'] as Map<String, dynamic>
        : <String, dynamic>{};

    return AuthResponseModel(
      user: UserModel.fromJson(userJson),
      token: target['token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': (user is UserModel
          ? (user as UserModel).toJson()
          : {
              'id': user.id,
              'email': user.email,
              if (user.username != null) 'username': user.username,
              if (user.fullName != null) 'fullName': user.fullName,
              if (user.phone != null) 'phone': user.phone,
              'isPremium': user.isPremium,
              if (user.createdAt != null)
                'createdAt': user.createdAt!.toIso8601String(),
            }),
      if (token != null) 'token': token,
    };
  }
}
