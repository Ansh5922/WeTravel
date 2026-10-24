import 'package:equatable/equatable.dart';

class PollOptionEntity extends Equatable {
  final String id;
  final String pollId;
  final String optionText;
  final int voteCount;
  final List<String> voterUserIds;

  const PollOptionEntity({
    required this.id,
    required this.pollId,
    required this.optionText,
    required this.voteCount,
    this.voterUserIds = const [],
  });

  @override
  List<Object?> get props => [id, pollId, optionText, voteCount, voterUserIds];
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

  int get totalVotes => options.fold<int>(0, (sum, opt) => sum + opt.voteCount);

  double percentageFor(PollOptionEntity opt) {
    if (totalVotes == 0) return 0.0;
    return (opt.voteCount / totalVotes) * 100.0;
  }

  String? getUserVotedOptionId(String? currentUserId) {
    if (userVotedOptionId != null && userVotedOptionId!.isNotEmpty) {
      return userVotedOptionId;
    }
    if (currentUserId == null || currentUserId.isEmpty) return null;
    for (final opt in options) {
      if (opt.voterUserIds.contains(currentUserId)) {
        return opt.id;
      }
    }
    return null;
  }

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
