import 'package:equatable/equatable.dart';

enum InboxInviteStatus {
  pending,
  accepted,
  rejected,
}

class InboxInviteEntity extends Equatable {
  final String id;
  final String groupId;
  final String groupName;
  final String invitedById;
  final String inviterUsername;
  final String inviterFullName;
  final String? inviterAvatarUrl;
  final String inviteType; // 'friend', 'email', 'whatsapp', 'link'
  final String inviteToken;
  final String? coverImageUrl;
  final DateTime? tripStartDate;
  final DateTime? tripEndDate;
  final int membersCount;
  final DateTime? expiresAt;
  final InboxInviteStatus status;

  const InboxInviteEntity({
    required this.id,
    required this.groupId,
    required this.groupName,
    required this.invitedById,
    required this.inviterUsername,
    required this.inviterFullName,
    this.inviterAvatarUrl,
    required this.inviteType,
    required this.inviteToken,
    this.coverImageUrl,
    this.tripStartDate,
    this.tripEndDate,
    this.membersCount = 1,
    this.expiresAt,
    required this.status,
  });

  InboxInviteEntity copyWith({
    String? id,
    String? groupId,
    String? groupName,
    String? invitedById,
    String? inviterUsername,
    String? inviterFullName,
    String? inviterAvatarUrl,
    String? inviteType,
    String? inviteToken,
    String? coverImageUrl,
    DateTime? tripStartDate,
    DateTime? tripEndDate,
    int? membersCount,
    DateTime? expiresAt,
    InboxInviteStatus? status,
  }) {
    return InboxInviteEntity(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      invitedById: invitedById ?? this.invitedById,
      inviterUsername: inviterUsername ?? this.inviterUsername,
      inviterFullName: inviterFullName ?? this.inviterFullName,
      inviterAvatarUrl: inviterAvatarUrl ?? this.inviterAvatarUrl,
      inviteType: inviteType ?? this.inviteType,
      inviteToken: inviteToken ?? this.inviteToken,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      tripStartDate: tripStartDate ?? this.tripStartDate,
      tripEndDate: tripEndDate ?? this.tripEndDate,
      membersCount: membersCount ?? this.membersCount,
      expiresAt: expiresAt ?? this.expiresAt,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        id,
        groupId,
        groupName,
        invitedById,
        inviterUsername,
        inviterFullName,
        inviterAvatarUrl,
        inviteType,
        inviteToken,
        coverImageUrl,
        tripStartDate,
        tripEndDate,
        membersCount,
        expiresAt,
        status,
      ];
}
