import 'package:equatable/equatable.dart';

class PollOptionVoterEntity extends Equatable {
  final String id;
  final String fullName;
  final String username;
  final String? avatarUrl;

  const PollOptionVoterEntity({
    required this.id,
    required this.fullName,
    required this.username,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, fullName, username, avatarUrl];
}

class PollOptionEntity extends Equatable {
  final String id;
  final String pollId;
  final String optionText;
  final int voteCount;
  final List<String> voterUserIds;
  final List<PollOptionVoterEntity> voters;

  const PollOptionEntity({
    required this.id,
    required this.pollId,
    required this.optionText,
    required this.voteCount,
    this.voterUserIds = const [],
    this.voters = const [],
  });

  @override
  List<Object?> get props => [id, pollId, optionText, voteCount, voterUserIds, voters];
}

class PollEntity extends Equatable {
  final String id;
  final String groupId;
  final String creatorId;
  final String question;
  final bool isClosed;
  final bool isAnonymous;
  final List<PollOptionEntity> options;
  final String? userVotedOptionId;
  final DateTime createdAt;

  const PollEntity({
    required this.id,
    required this.groupId,
    required this.creatorId,
    required this.question,
    required this.isClosed,
    this.isAnonymous = false,
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
        isAnonymous,
        options,
        userVotedOptionId,
        createdAt,
      ];
}
