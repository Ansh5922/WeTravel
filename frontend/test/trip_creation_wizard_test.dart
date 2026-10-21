import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/trips/domain/entities/trip_member.dart';
import 'package:frontend/features/trips/domain/entities/trip_review_draft.dart';
import 'package:frontend/features/friends/domain/entities/friend_entity.dart';

void main() {
  group('Trip Creation Wizard Entity & Data Mapping Tests', () {
    test('TripReviewDraft dynamic initial values are accurate and not hardcoded', () {
      final draft = TripReviewDraft.initial();

      expect(draft.destination, isEmpty);
      expect(draft.nights, equals(3));
      expect(draft.days, equals(4));
      expect(draft.startDate.isAfter(DateTime.now()), isTrue);
      expect(draft.endDate.isAfter(draft.startDate), isTrue);
      expect(draft.selectedMembers, isEmpty);
      expect(draft.invitedEmails, isEmpty);
      expect(draft.invitedPhones, isEmpty);
    });

    test('TripReviewDraft formattedDates displays correct range and night count', () {
      final draft = TripReviewDraft(
        destination: 'Manali, HP',
        startDate: DateTime(2026, 11, 10),
        endDate: DateTime(2026, 11, 15),
        budget: '₹35k (₹20K – ₹50K)',
        tripStyle: 'Adventure',
      );

      expect(draft.destination, equals('Manali, HP'));
      expect(draft.nights, equals(5));
      expect(draft.days, equals(6));
      expect(draft.formattedDates, contains('Nov 10–15 · 5 nights'));
      expect(draft.formattedDuration, equals('6 days'));
    });

    test('TripMember.fromFriendEntity correctly maps backend FriendEntity to trip candidate', () {
      const friend = FriendEntity(
        id: 'friendship_99',
        userId: 'user_uuid_123',
        username: 'ananya_v',
        fullName: 'Ananya Verma',
        avatarUrl: 'https://cdn.wetravel.app/avatars/ananya.jpg',
      );

      final member = TripMember.fromFriendEntity(friend, isSelected: true);

      expect(member.id, equals('user_uuid_123'));
      expect(member.name, equals('Ananya Verma'));
      expect(member.email, equals('@ananya_v'));
      expect(member.avatarUrl, equals('https://cdn.wetravel.app/avatars/ananya.jpg'));
      expect(member.isSelected, isTrue);
    });

    test('TripReviewDraft copyWith updates invites and members cleanly', () {
      final initialDraft = TripReviewDraft.initial();
      final member = TripMember(
        id: 'user_456',
        name: 'Rashi Shah',
        email: '@rashi',
      );

      final updated = initialDraft.copyWith(
        destination: 'Goa, India',
        selectedMembers: [member],
        invitedEmails: ['travelbuddy@gmail.com'],
        invitedPhones: ['+919876543210'],
        coverImageUrl: 'https://images.unsplash.com/photo-beach',
      );

      expect(updated.destination, equals('Goa, India'));
      expect(updated.selectedMembers.length, equals(1));
      expect(updated.invitedEmails, contains('travelbuddy@gmail.com'));
      expect(updated.invitedPhones, contains('+919876543210'));
      expect(updated.coverImageUrl, contains('photo-beach'));
    });
  });
}
