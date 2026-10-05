import '../../domain/entities/poll_entity.dart';

class PollOptionModel extends PollOptionEntity {
  const PollOptionModel({
    required super.id,
    required super.pollId,
    required super.optionText,
    required super.voteCount,
  });

  factory PollOptionModel.fromJson(Map<String, dynamic> json) {
    final votes = json['votes'];
    int count = json['_count']?['votes'] ?? 0;
    if (votes is List) {
      count = votes.length;
    }

    return PollOptionModel(
      id: json['id'] ?? '',
      pollId: json['pollId'] ?? '',
      optionText: json['optionText'] ?? json['text'] ?? '',
      voteCount: count,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pollId': pollId,
      'optionText': optionText,
      'voteCount': voteCount,
    };
  }
}

class PollModel extends PollEntity {
  const PollModel({
    required super.id,
    required super.groupId,
    required super.creatorId,
    required super.question,
    required super.isClosed,
    required super.options,
    super.userVotedOptionId,
    required super.createdAt,
  });

  factory PollModel.fromJson(Map<String, dynamic> json) {
    final optionsList = json['options'] as List? ?? [];
    final parsedOptions = optionsList.map((item) => PollOptionModel.fromJson(item)).toList();

    return PollModel(
      id: json['id'] ?? '',
      groupId: json['groupId'] ?? json['tripId'] ?? '',
      creatorId: json['creatorId'] ?? '',
      question: json['question'] ?? '',
      isClosed: json['isClosed'] ?? false,
      options: parsedOptions,
      userVotedOptionId: json['userVotedOptionId'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'creatorId': creatorId,
      'question': question,
      'isClosed': isClosed,
      'options': options.map((opt) => (opt as PollOptionModel).toJson()).toList(),
      'userVotedOptionId': userVotedOptionId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
