/// Entity representing user travel preferences for AI group itinerary personalization and profile display.
class UserTravelPreferences {
  final String userName;
  final String userHeadline;
  final String userBio;
  final String avatarUrl;
  final String travelStyle;
  final String budgetComfort;
  final List<String> interests;
  final String foodPreference;
  final String thingsToAvoid;
  final String availability;
  final List<String> specialRequirements;
  final String additionalNotes;

  const UserTravelPreferences({
    this.userName = 'Rashi Meena',
    this.userHeadline = 'Travel Enthusiast',
    this.userBio = 'Good food. New places. Better vibes.',
    this.avatarUrl = 'assets/images/avatar_user.jpg',
    this.travelStyle = 'Relaxed',
    this.budgetComfort = '₹20k – ₹30k',
    this.interests = const ['Food', 'Culture'],
    this.foodPreference = 'Vegetarian',
    this.thingsToAvoid = 'Early starts',
    this.availability = 'All days',
    this.specialRequirements = const ['No alcohol'],
    this.additionalNotes = '',
  });

  UserTravelPreferences copyWith({
    String? userName,
    String? userHeadline,
    String? userBio,
    String? avatarUrl,
    String? travelStyle,
    String? budgetComfort,
    List<String>? interests,
    String? foodPreference,
    String? thingsToAvoid,
    String? availability,
    List<String>? specialRequirements,
    String? additionalNotes,
  }) {
    return UserTravelPreferences(
      userName: userName ?? this.userName,
      userHeadline: userHeadline ?? this.userHeadline,
      userBio: userBio ?? this.userBio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      travelStyle: travelStyle ?? this.travelStyle,
      budgetComfort: budgetComfort ?? this.budgetComfort,
      interests: interests ?? this.interests,
      foodPreference: foodPreference ?? this.foodPreference,
      thingsToAvoid: thingsToAvoid ?? this.thingsToAvoid,
      availability: availability ?? this.availability,
      specialRequirements: specialRequirements ?? this.specialRequirements,
      additionalNotes: additionalNotes ?? this.additionalNotes,
    );
  }
}
