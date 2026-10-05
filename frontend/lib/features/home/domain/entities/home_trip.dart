import 'package:equatable/equatable.dart';

class HomeTripMemberEntity extends Equatable {
  final String id;
  final String userId;
  final String role;
  final String username;
  final String fullName;

  const HomeTripMemberEntity({
    required this.id,
    required this.userId,
    required this.role,
    required this.username,
    required this.fullName,
  });

  @override
  List<Object?> get props => [id, userId, role, username, fullName];
}

class HomeTripEntity extends Equatable {
  final String id;
  final String title;
  final String status; // 'planning', 'ongoing', 'completed'
  final String statusLabel; // 'Planning', 'Upcoming', 'Ongoing', 'Completed'
  final String dateText;
  final int memberCount;
  final String location;
  final String? coverImageUrl;
  final List<HomeTripMemberEntity> members;

  const HomeTripEntity({
    required this.id,
    required this.title,
    required this.status,
    required this.statusLabel,
    required this.dateText,
    required this.memberCount,
    required this.location,
    this.coverImageUrl,
    required this.members,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        status,
        statusLabel,
        dateText,
        memberCount,
        location,
        coverImageUrl,
        members,
      ];
}
