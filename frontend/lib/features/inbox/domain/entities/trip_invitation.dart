enum InvitationStatus {
  pending,
  accepted,
  declined,
}

class TripInvitation {
  final String id;
  final String tripId;
  final String title;
  final String destination;
  final String dateRange;
  final String budgetRange;
  final int travelersCount;
  final String imageAsset;
  final String invitedBy;
  final String organizerAvatar;
  final String organizerRole;
  final String timeAgo;
  final String tripDuration;
  final String tripType;
  final String tripExpectations;
  final int matchPercentage;
  final List<String> matchedPreferences;
  final List<String> memberAvatars;
  final InvitationStatus status;
  final String? category;

  const TripInvitation({
    required this.id,
    required this.tripId,
    required this.title,
    required this.destination,
    required this.dateRange,
    required this.budgetRange,
    required this.travelersCount,
    required this.imageAsset,
    required this.invitedBy,
    required this.organizerAvatar,
    this.organizerRole = 'Controller',
    required this.timeAgo,
    this.tripDuration = '4 days',
    this.tripType = 'Relaxed',
    this.tripExpectations = 'Looking for a chill weekend. Mostly beaches and cafes. Avoid crowded party areas.',
    this.matchPercentage = 82,
    this.matchedPreferences = const ['Beaches', 'Relaxed travel', 'Local food'],
    required this.memberAvatars,
    this.status = InvitationStatus.pending,
    this.category,
  });

  TripInvitation copyWith({
    String? id,
    String? tripId,
    String? title,
    String? destination,
    String? dateRange,
    String? budgetRange,
    int? travelersCount,
    String? imageAsset,
    String? invitedBy,
    String? organizerAvatar,
    String? organizerRole,
    String? timeAgo,
    String? tripDuration,
    String? tripType,
    String? tripExpectations,
    int? matchPercentage,
    List<String>? matchedPreferences,
    List<String>? memberAvatars,
    InvitationStatus? status,
    String? category,
  }) {
    return TripInvitation(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      title: title ?? this.title,
      destination: destination ?? this.destination,
      dateRange: dateRange ?? this.dateRange,
      budgetRange: budgetRange ?? this.budgetRange,
      travelersCount: travelersCount ?? this.travelersCount,
      imageAsset: imageAsset ?? this.imageAsset,
      invitedBy: invitedBy ?? this.invitedBy,
      organizerAvatar: organizerAvatar ?? this.organizerAvatar,
      organizerRole: organizerRole ?? this.organizerRole,
      timeAgo: timeAgo ?? this.timeAgo,
      tripDuration: tripDuration ?? this.tripDuration,
      tripType: tripType ?? this.tripType,
      tripExpectations: tripExpectations ?? this.tripExpectations,
      matchPercentage: matchPercentage ?? this.matchPercentage,
      matchedPreferences: matchedPreferences ?? this.matchedPreferences,
      memberAvatars: memberAvatars ?? this.memberAvatars,
      status: status ?? this.status,
      category: category ?? this.category,
    );
  }

  /// Initial mock invitations matching the design screenshot
  static List<TripInvitation> get initialInvitations => [
        const TripInvitation(
          id: 'inv-1',
          tripId: 'trip-goa-01',
          title: 'Goa Weekend Escape',
          destination: 'Goa, India',
          dateRange: '12 Oct - 15 Oct 2026',
          tripDuration: '4 days',
          budgetRange: '₹20K - ₹30K',
          travelersCount: 4,
          tripType: 'Relaxed',
          imageAsset: 'assets/images/trip_goa.jpg',
          invitedBy: 'Shifa',
          organizerAvatar: 'assets/images/avatar_neha.jpg',
          organizerRole: 'Controller',
          timeAgo: '2h ago',
          tripExpectations:
              'Looking for a chill weekend. Mostly beaches and cafes. Avoid crowded party areas.',
          matchPercentage: 82,
          matchedPreferences: ['Beaches', 'Relaxed travel', 'Local food'],
          status: InvitationStatus.pending,
          category: 'Vacation',
          memberAvatars: [
            'assets/images/avatar_user.jpg',
            'assets/images/avatar_1.jpg',
            'assets/images/avatar_2.jpg',
            'assets/images/avatar_devansh.jpg',
          ],
        ),
        const TripInvitation(
          id: 'inv-2',
          tripId: 'trip-kerala-02',
          title: 'Kerala Escape',
          destination: 'Kerala, India',
          dateRange: '5 Nov - 10 Nov 2026',
          tripDuration: '6 days',
          budgetRange: '₹25K - ₹40K',
          travelersCount: 5,
          tripType: 'Nature & Food',
          imageAsset: 'assets/images/trip_kerala.jpg',
          invitedBy: 'Ananya',
          organizerAvatar: 'assets/images/avatar_1.jpg',
          organizerRole: 'Controller',
          timeAgo: '5h ago',
          tripExpectations:
              'Backwater cruises, traditional spice plantations, and Ayurvedic wellness retreat.',
          matchPercentage: 90,
          matchedPreferences: ['Backwaters', 'Ayurveda', 'Spicy cuisine'],
          status: InvitationStatus.pending,
          category: 'Nature',
          memberAvatars: [
            'assets/images/avatar_neha.jpg',
            'assets/images/avatar_1.jpg',
            'assets/images/avatar_user.jpg',
            'assets/images/avatar_devansh.jpg',
            'assets/images/avatar_2.jpg',
          ],
        ),
        const TripInvitation(
          id: 'inv-3',
          tripId: 'trip-manali-03',
          title: 'Manali Adventure',
          destination: 'Manali, India',
          dateRange: '20 Dec - 25 Dec 2026',
          tripDuration: '6 days',
          budgetRange: '₹15K - ₹25K',
          travelersCount: 4,
          tripType: 'Snow & Trek',
          imageAsset: 'assets/images/trip_manali.jpg',
          invitedBy: 'Priya',
          organizerAvatar: 'assets/images/avatar_2.jpg',
          organizerRole: 'Controller',
          timeAgo: '1d ago',
          tripExpectations:
              'Skiing in Solang Valley, local Himachali food, cafes in Old Manali, and cozy bonfires.',
          matchPercentage: 78,
          matchedPreferences: ['Snow activities', 'Mountain cafes', 'Trekking'],
          status: InvitationStatus.pending,
          category: 'Adventure',
          memberAvatars: [
            'assets/images/avatar_2.jpg',
            'assets/images/avatar_user.jpg',
            'assets/images/avatar_neha.jpg',
            'assets/images/avatar_devansh.jpg',
          ],
        ),
        const TripInvitation(
          id: 'inv-4',
          tripId: 'trip-udaipur-04',
          title: 'Udaipur Royal Heritage',
          destination: 'Udaipur, Rajasthan',
          dateRange: '18 Jan - 22 Jan 2027',
          tripDuration: '5 days',
          budgetRange: '₹30K - ₹45K',
          travelersCount: 6,
          tripType: 'Heritage',
          imageAsset: 'assets/images/hero_coast.jpg',
          invitedBy: 'Devansh',
          organizerAvatar: 'assets/images/avatar_devansh.jpg',
          organizerRole: 'Controller',
          timeAgo: '3d ago',
          tripExpectations:
              'Palace tours, lakeside sunset dinners, and vintage car museum visits.',
          matchPercentage: 85,
          matchedPreferences: ['Palaces', 'Lake views', 'Rajasthani thali'],
          status: InvitationStatus.accepted,
          category: 'Cultural',
          memberAvatars: [
            'assets/images/avatar_devansh.jpg',
            'assets/images/avatar_user.jpg',
            'assets/images/avatar_1.jpg',
          ],
        ),
        const TripInvitation(
          id: 'inv-5',
          tripId: 'trip-ladakh-05',
          title: 'Ladakh Bike Expedition',
          destination: 'Leh Ladakh, India',
          dateRange: '10 Jun - 18 Jun 2027',
          tripDuration: '9 days',
          budgetRange: '₹40K - ₹60K',
          travelersCount: 4,
          tripType: 'High Altitude',
          imageAsset: 'assets/images/trip_manali.jpg',
          invitedBy: 'Rohan',
          organizerAvatar: 'assets/images/avatar_user.jpg',
          organizerRole: 'Controller',
          timeAgo: '1w ago',
          tripExpectations:
              'Pangong Tso camping, Khardung La pass ride, and monastery tours.',
          matchPercentage: 92,
          matchedPreferences: ['Motorbiking', 'High passes', 'Star gazing'],
          status: InvitationStatus.accepted,
          category: 'Adventure',
          memberAvatars: [
            'assets/images/avatar_devansh.jpg',
            'assets/images/avatar_2.jpg',
          ],
        ),
        const TripInvitation(
          id: 'inv-6',
          tripId: 'trip-rishikesh-06',
          title: 'Rishikesh River Rafting',
          destination: 'Rishikesh, Uttarakhand',
          dateRange: '2 Mar - 5 Mar 2027',
          tripDuration: '4 days',
          budgetRange: '₹10K - ₹15K',
          travelersCount: 3,
          tripType: 'River Adventure',
          imageAsset: 'assets/images/trip_goa.jpg',
          invitedBy: 'Sameer',
          organizerAvatar: 'assets/images/avatar_devansh.jpg',
          organizerRole: 'Organizer',
          timeAgo: '2w ago',
          tripExpectations:
              'Grade 4 rafting, cliff jumping, Ganga Aarti, and riverside camping.',
          matchPercentage: 70,
          matchedPreferences: ['Rafting', 'Camping', 'Riverside cafes'],
          status: InvitationStatus.declined,
          category: 'Adventure',
          memberAvatars: [
            'assets/images/avatar_1.jpg',
            'assets/images/avatar_user.jpg',
          ],
        ),
      ];
}
