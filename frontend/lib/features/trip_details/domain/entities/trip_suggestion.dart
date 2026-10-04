/// Entity representing a collaborative group trip idea/suggestion.
class TripSuggestion {
  final String id;
  final String title;
  final int estimatedCost;
  final int approvalsCount;
  final int totalMembers;
  final int commentsCount;
  final String imageUrl;
  final bool isApprovedByMe;

  const TripSuggestion({
    required this.id,
    required this.title,
    required this.estimatedCost,
    required this.approvalsCount,
    required this.totalMembers,
    required this.commentsCount,
    required this.imageUrl,
    this.isApprovedByMe = true,
  });

  TripSuggestion copyWith({
    String? id,
    String? title,
    int? estimatedCost,
    int? approvalsCount,
    int? totalMembers,
    int? commentsCount,
    String? imageUrl,
    bool? isApprovedByMe,
  }) {
    return TripSuggestion(
      id: id ?? this.id,
      title: title ?? this.title,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      approvalsCount: approvalsCount ?? this.approvalsCount,
      totalMembers: totalMembers ?? this.totalMembers,
      commentsCount: commentsCount ?? this.commentsCount,
      imageUrl: imageUrl ?? this.imageUrl,
      isApprovedByMe: isApprovedByMe ?? this.isApprovedByMe,
    );
  }
}
