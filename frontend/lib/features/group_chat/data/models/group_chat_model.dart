import '../../domain/entities/group_chat_entity.dart';

class GroupChatModel extends GroupChatEntity {
  const GroupChatModel({super.id});

  factory GroupChatModel.fromJson(Map<String, dynamic> json) {
    return GroupChatModel(
      id: json['id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}
