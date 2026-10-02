import '../../domain/entities/polls_entity.dart';

class PollsModel extends PollsEntity {
  const PollsModel({super.id});

  factory PollsModel.fromJson(Map<String, dynamic> json) {
    return PollsModel(
      id: json['id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}
