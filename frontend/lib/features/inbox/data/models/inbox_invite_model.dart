import '../../domain/entities/inbox_invite_entity.dart';

class InboxInviteModel extends InboxInviteEntity {
  const InboxInviteModel({
    required super.id,
    required super.groupId,
    required super.groupName,
    required super.invitedById,
    required super.inviterUsername,
    required super.inviterFullName,
    required super.inviteType,
    required super.inviteToken,
    super.coverImageUrl,
    super.tripStartDate,
    super.tripEndDate,
    super.membersCount = 1,
    super.expiresAt,
    required super.status,
  });

  factory InboxInviteModel.fromJson(Map<String, dynamic> json) {
    final groupObj = json['group'] as Map<String, dynamic>? ?? {};
    final inviterObj = json['inviter'] as Map<String, dynamic>? ?? {};

    final statusStr = json['status']?.toString().toLowerCase() ?? 'pending';
    InboxInviteStatus status = InboxInviteStatus.pending;
    if (statusStr == 'accepted') {
      status = InboxInviteStatus.accepted;
    } else if (statusStr == 'rejected' || statusStr == 'declined') {
      status = InboxInviteStatus.rejected;
    }

    DateTime? expiresAt;
    if (json['expiresAt'] != null) {
      try {
        expiresAt = DateTime.parse(json['expiresAt'].toString());
      } catch (_) {}
    }

    DateTime? tripStartDate;
    if (groupObj['tripStartDate'] != null) {
      try {
        tripStartDate = DateTime.parse(groupObj['tripStartDate'].toString());
      } catch (_) {}
    }

    DateTime? tripEndDate;
    if (groupObj['tripEndDate'] != null) {
      try {
        tripEndDate = DateTime.parse(groupObj['tripEndDate'].toString());
      } catch (_) {}
    }

    final membersList = groupObj['members'] as List<dynamic>?;
    final int membersCount = membersList != null && membersList.isNotEmpty ? membersList.length : 1;

    return InboxInviteModel(
      id: json['id']?.toString() ?? '',
      groupId: json['groupId']?.toString() ?? groupObj['id']?.toString() ?? '',
      groupName: groupObj['name']?.toString() ?? 'Trip Invitation',
      invitedById: json['invitedBy']?.toString() ?? inviterObj['id']?.toString() ?? '',
      inviterUsername: inviterObj['username']?.toString() ?? '',
      inviterFullName: inviterObj['fullName']?.toString() ?? inviterObj['username']?.toString() ?? 'A Friend',
      inviteType: json['inviteType']?.toString() ?? 'friend',
      inviteToken: json['inviteToken']?.toString() ?? '',
      coverImageUrl: groupObj['coverImageUrl']?.toString(),
      tripStartDate: tripStartDate,
      tripEndDate: tripEndDate,
      membersCount: membersCount,
      expiresAt: expiresAt,
      status: status,
    );
  }
}
