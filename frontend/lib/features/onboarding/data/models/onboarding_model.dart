import '../../domain/entities/onboarding_entity.dart';

class OnboardingModel extends OnboardingEntity {
  const OnboardingModel({super.id});

  factory OnboardingModel.fromJson(Map<String, dynamic> json) {
    return OnboardingModel(
      id: json['id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}
