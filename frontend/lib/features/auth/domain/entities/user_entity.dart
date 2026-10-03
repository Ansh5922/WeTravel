class UserEntity {
  final String id;
  final String email;
  final String? username;
  final String? fullName;
  final String? phone;
  final bool isPremium;
  final DateTime? createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    this.username,
    this.fullName,
    this.phone,
    this.isPremium = false,
    this.createdAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          username == other.username &&
          fullName == other.fullName &&
          phone == other.phone &&
          isPremium == other.isPremium &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      id.hashCode ^
      email.hashCode ^
      username.hashCode ^
      fullName.hashCode ^
      phone.hashCode ^
      isPremium.hashCode ^
      createdAt.hashCode;

  @override
  String toString() {
    return 'UserEntity(id: $id, email: $email, username: $username, fullName: $fullName, isPremium: $isPremium, createdAt: $createdAt)';
  }
}
