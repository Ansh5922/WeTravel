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
  final String inviteType; // 'friend', 'email', 'whatsapp', 'link'
  final String inviteToken;
  final DateTime? expiresAt;
  final InboxInviteStatus status;

  const InboxInviteEntity({
    required this.id,
    required this.groupId,
    required this.groupName,
    required this.invitedById,
    required this.inviterUsername,
    required this.inviterFullName,
    required this.inviteType,
    required this.inviteToken,
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
    String? inviteType,
    String? inviteToken,
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
      inviteType: inviteType ?? this.inviteType,
      inviteToken: inviteToken ?? this.inviteToken,
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
        inviteType,
        inviteToken,
        expiresAt,
        status,
      ];
}
