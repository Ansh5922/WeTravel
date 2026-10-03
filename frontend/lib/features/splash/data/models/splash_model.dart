import '../../domain/entities/splash_entity.dart';

class SplashModel extends SplashEntity {
  const SplashModel({super.id});

  factory SplashModel.fromJson(Map<String, dynamic> json) {
    return SplashModel(
      id: json['id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}
