/// Frontend entity representing a trip preview on the Home screen.
class TripSummaryItem {
  final String id;
  final String title;
  final String statusLabel; // e.g. "Upcoming", "Planning"
  final String dateText;
  final int memberCount;
  final String location;
  final String imagePath;
  final List<String> avatars;

  const TripSummaryItem({
    required this.id,
    required this.title,
    required this.statusLabel,
    required this.dateText,
    required this.memberCount,
    required this.location,
    required this.imagePath,
    required this.avatars,
  });

  /// Initial static mock data matching the screenshot
  static List<TripSummaryItem> initialMockTrips() {
    return const [
      TripSummaryItem(
        id: 'trip-1',
        title: 'Goa Getaway',
        statusLabel: 'Upcoming',
        dateText: '12 – 15 Oct 2026',
        memberCount: 4,
        location: 'Goa, India',
        imagePath: 'assets/images/trip_goa.jpg',
        avatars: [
          'assets/images/avatar_1.jpg',
          'assets/images/avatar_2.jpg',
          'assets/images/avatar_user.jpg',
        ],
      ),
      TripSummaryItem(
        id: 'trip-2',
        title: 'Kerala Escape',
        statusLabel: 'Planning',
        dateText: 'May 2026',
        memberCount: 3,
        location: 'Kerala, India',
        imagePath: 'assets/images/trip_kerala.jpg',
        avatars: [
          'assets/images/avatar_2.jpg',
          'assets/images/avatar_user.jpg',
          'assets/images/avatar_1.jpg',
        ],
      ),
    ];
  }
}
