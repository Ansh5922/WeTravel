import 'package:equatable/equatable.dart';

class PollOptionEntity extends Equatable {
  final String id;
  final String pollId;
  final String optionText;
  final int voteCount;

  const PollOptionEntity({
    required this.id,
    required this.pollId,
    required this.optionText,
    required this.voteCount,
  });

  @override
  List<Object?> get props => [id, pollId, optionText, voteCount];
}

class PollEntity extends Equatable {
  final String id;
  final String groupId;
  final String creatorId;
  final String question;
  final bool isClosed;
  final List<PollOptionEntity> options;
  final String? userVotedOptionId;
  final DateTime createdAt;

  const PollEntity({
    required this.id,
    required this.groupId,
    required this.creatorId,
    required this.question,
    required this.isClosed,
    required this.options,
    this.userVotedOptionId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        groupId,
        creatorId,
        question,
        isClosed,
        options,
        userVotedOptionId,
        createdAt,
      ];
}
