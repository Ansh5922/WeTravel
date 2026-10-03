import '../../domain/entities/home_entity.dart';

class HomeModel extends HomeEntity {
  const HomeModel({super.id});

  factory HomeModel.fromJson(Map<String, dynamic> json) {
    return HomeModel(
      id: json['id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}
