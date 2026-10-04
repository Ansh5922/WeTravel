import '../../domain/entities/friends_entity.dart';

class FriendsModel extends FriendsEntity {
  const FriendsModel({super.id});

  factory FriendsModel.fromJson(Map<String, dynamic> json) {
    return FriendsModel(
      id: json['id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}
