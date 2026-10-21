import '../../../friends/domain/entities/friend_entity.dart';

/// Entity representing a friend candidate for trip invitation.
class TripMember {
  final String id;
  final String name;
  final String email;
  final String avatarAsset;
  final String? avatarUrl;
  bool isSelected;

  TripMember({
    required this.id,
    required this.name,
    required this.email,
    this.avatarAsset = 'assets/images/avatar_user.jpg',
    this.avatarUrl,
    this.isSelected = false,
  });

  factory TripMember.fromFriendEntity(FriendEntity friend, {bool isSelected = false}) {
    return TripMember(
      id: friend.userId,
      name: friend.fullName.trim().isNotEmpty ? friend.fullName : friend.username,
      email: '@${friend.username}',
      avatarAsset: 'assets/images/avatar_user.jpg',
      avatarUrl: friend.avatarUrl,
      isSelected: isSelected,
    );
  }

  TripMember copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarAsset,
    String? avatarUrl,
    bool? isSelected,
  }) {
    return TripMember(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarAsset: avatarAsset ?? this.avatarAsset,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  /// Initial list matching the design screenshot
  static List<TripMember> get initialSuggestedFriends => [
        TripMember(
          id: '1',
          name: 'Rashi Shah',
          email: 'rashishah@gmail.com',
          avatarAsset: 'assets/images/avatar_user.jpg',
          isSelected: true,
        ),
        TripMember(
          id: '2',
          name: 'Ananya Verma',
          email: 'ananya@live.com',
          avatarAsset: 'assets/images/avatar_1.jpg',
          isSelected: true,
        ),
        TripMember(
          id: '3',
          name: 'Priya Singh',
          email: 'priya@outlook.com',
          avatarAsset: 'assets/images/avatar_2.jpg',
          isSelected: false,
        ),
        TripMember(
          id: '4',
          name: 'Devansh Mehta',
          email: 'devansh@gmail.com',
          avatarAsset: 'assets/images/avatar_devansh.jpg',
          isSelected: false,
        ),
        TripMember(
          id: '5',
          name: 'Neha Gupta',
          email: 'neha@icloud.com',
          avatarAsset: 'assets/images/avatar_neha.jpg',
          isSelected: false,
        ),
      ];
}
