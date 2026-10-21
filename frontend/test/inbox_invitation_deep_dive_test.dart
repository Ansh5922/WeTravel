import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/inbox/domain/entities/inbox_invite_entity.dart';
import 'package:frontend/features/inbox/domain/entities/trip_invitation.dart';

void main() {
  group('Group 5: Inbox & Invitation Deep Dives Tests', () {
    test('TripInvitation.fromInboxInvite maps backend fields accurately', () {
      final backendInvite = InboxInviteEntity(
        id: 'invite_101',
        groupId: 'trip_777',
        groupName: 'Kerala Backwaters Tour',
        invitedById: 'user_host_1',
        inviterUsername: 'arjun_k',
        inviterFullName: 'Arjun Kapoor',
        inviteType: 'friend',
        inviteToken: 'token_kerala_xyz',
        expiresAt: DateTime(2026, 12, 31),
        status: InboxInviteStatus.pending,
      );

      final invitation = TripInvitation.fromInboxInvite(backendInvite);

      expect(invitation.id, equals('invite_101'));
      expect(invitation.tripId, equals('trip_777'));
      expect(invitation.title, equals('Kerala Backwaters Tour'));
      expect(invitation.destination, equals('Kerala Backwaters Tour'));
      expect(invitation.invitedBy, equals('Arjun Kapoor'));
      expect(invitation.status, equals(InvitationStatus.pending));
    });

    test('TripInvitation copyWith updates status to accepted and preserves tripId', () {
      const original = TripInvitation(
        id: 'inv_1',
        tripId: 'trip_55',
        title: 'Manali Expedition',
        destination: 'Manali, HP',
        dateRange: '10 Nov - 15 Nov 2026',
        budgetRange: '₹25k - ₹40k',
        travelersCount: 3,
        imageAsset: 'assets/images/trip_manali.jpg',
        invitedBy: 'Priya Singh',
        organizerAvatar: 'assets/images/avatar_user.jpg',
        timeAgo: '1d ago',
        memberAvatars: ['assets/images/avatar_user.jpg'],
      );

      final accepted = original.copyWith(status: InvitationStatus.accepted);

      expect(accepted.status, equals(InvitationStatus.accepted));
      expect(accepted.tripId, equals('trip_55'));
      expect(accepted.destination, equals('Manali, HP'));
      expect(accepted.invitedBy, equals('Priya Singh'));
    });

    test('TripInvitation supports optional coverImageUrl and inviterAvatarUrl', () {
      const invitation = TripInvitation(
        id: 'inv_2',
        tripId: 'trip_88',
        title: 'Goa Coastal Retreat',
        destination: 'Goa, India',
        dateRange: '5 Dec - 9 Dec 2026',
        budgetRange: '₹30k',
        travelersCount: 4,
        imageAsset: 'assets/images/trip_goa.jpg',
        coverImageUrl: 'https://images.unsplash.com/photo-goa',
        invitedBy: 'Rashi Shah',
        organizerAvatar: 'assets/images/avatar_user.jpg',
        inviterAvatarUrl: 'https://cdn.wetravel.app/rashi.png',
        timeAgo: '3h ago',
        memberAvatars: [],
      );

      expect(invitation.coverImageUrl, equals('https://images.unsplash.com/photo-goa'));
      expect(invitation.inviterAvatarUrl, equals('https://cdn.wetravel.app/rashi.png'));
    });
  });
}
