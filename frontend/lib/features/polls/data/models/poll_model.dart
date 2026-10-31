import '../../domain/entities/poll_entity.dart';

class PollOptionVoterModel extends PollOptionVoterEntity {
  const PollOptionVoterModel({
    required super.id,
    required super.fullName,
    required super.username,
    super.avatarUrl,
  });

  factory PollOptionVoterModel.fromJson(Map<String, dynamic> json) {
    return PollOptionVoterModel(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      avatarUrl: json['avatarUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'username': username,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
    };
  }
}

class PollOptionModel extends PollOptionEntity {
  const PollOptionModel({
    required super.id,
    required super.pollId,
    required super.optionText,
    required super.voteCount,
    super.voterUserIds,
    super.voters,
  });

  factory PollOptionModel.fromJson(Map<String, dynamic> json) {
    final votes = json['votes'];
    int count = json['voteCount'] ?? json['_count']?['votes'] ?? 0;
    final List<String> voterIds = [];
    final List<PollOptionVoterModel> voterModels = [];

    if (json['voters'] is List) {
      for (final v in json['voters']) {
        if (v is Map<String, dynamic>) {
          voterModels.add(PollOptionVoterModel.fromJson(v));
          if (v['id'] != null) voterIds.add(v['id'].toString());
        }
      }
    }

    if (votes is List) {
      if (count == 0) count = votes.length;
      for (final v in votes) {
        if (v is Map) {
          if (v['userId'] != null && !voterIds.contains(v['userId'].toString())) {
            voterIds.add(v['userId'].toString());
          }
          if (v['user'] is Map && voterModels.isEmpty) {
            voterModels.add(PollOptionVoterModel.fromJson(Map<String, dynamic>.from(v['user'])));
          }
        }
      }
    }

    return PollOptionModel(
      id: json['id']?.toString() ?? '',
      pollId: json['pollId']?.toString() ?? '',
      optionText: json['optionText']?.toString() ?? json['text']?.toString() ?? '',
      voteCount: count,
      voterUserIds: voterIds,
      voters: voterModels,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pollId': pollId,
      'optionText': optionText,
      'voteCount': voteCount,
      'voterUserIds': voterUserIds,
      'voters': voters.map((v) => (v as PollOptionVoterModel).toJson()).toList(),
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
    super.isAnonymous = false,
    required super.options,
    super.userVotedOptionId,
    required super.createdAt,
  });

  factory PollModel.fromJson(Map<String, dynamic> json) {
    final optionsList = json['options'] as List? ?? [];
    final parsedOptions = optionsList.map((item) => PollOptionModel.fromJson(item)).toList();
    final isClosed = json['isClosed'] == true || json['status'] == 'closed';
    final isAnonymous = json['isAnonymous'] == true;

    return PollModel(
      id: json['id']?.toString() ?? '',
      groupId: json['groupId']?.toString() ?? json['tripId']?.toString() ?? '',
      creatorId: json['creatorId']?.toString() ?? json['createdBy']?.toString() ?? '',
      question: json['question']?.toString() ?? '',
      isClosed: isClosed,
      isAnonymous: isAnonymous,
      options: parsedOptions,
      userVotedOptionId: json['userVotedOptionId']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
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
      'isAnonymous': isAnonymous,
      'options': options.map((opt) => (opt as PollOptionModel).toJson()).toList(),
      'userVotedOptionId': userVotedOptionId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
