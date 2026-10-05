import 'package:intl/intl.dart';
import '../../domain/entities/home_trip.dart';

class HomeTripMemberModel extends HomeTripMemberEntity {
  const HomeTripMemberModel({
    required super.id,
    required super.userId,
    required super.role,
    required super.username,
    required super.fullName,
  });

  factory HomeTripMemberModel.fromJson(Map<String, dynamic> json) {
    final userData = json['user'] as Map<String, dynamic>? ?? {};
    return HomeTripMemberModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? userData['id']?.toString() ?? '',
      role: json['role']?.toString() ?? 'member',
      username: userData['username']?.toString() ?? '',
      fullName: userData['fullName']?.toString() ?? userData['username']?.toString() ?? 'Traveler',
    );
  }
}

class HomeTripModel extends HomeTripEntity {
  const HomeTripModel({
    required super.id,
    required super.title,
    required super.status,
    required super.statusLabel,
    required super.dateText,
    required super.memberCount,
    required super.location,
    super.coverImageUrl,
    required super.members,
  });

  factory HomeTripModel.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['status']?.toString() ?? 'planning';
    final membersList = (json['members'] as List<dynamic>?)
            ?.map((m) => HomeTripMemberModel.fromJson(m as Map<String, dynamic>))
            .toList() ??
        [];

    final startDateStr = json['tripStartDate']?.toString();
    final endDateStr = json['tripEndDate']?.toString();
    String formattedDate = 'Flexible Dates';

    if (startDateStr != null && startDateStr.isNotEmpty) {
      try {
        final start = DateTime.parse(startDateStr);
        if (endDateStr != null && endDateStr.isNotEmpty) {
          final end = DateTime.parse(endDateStr);
          if (start.month == end.month && start.year == end.year) {
            formattedDate = '${start.day} – ${end.day} ${DateFormat('MMM yyyy').format(end)}';
          } else {
            formattedDate = '${DateFormat('d MMM').format(start)} – ${DateFormat('d MMM yyyy').format(end)}';
          }
        } else {
          formattedDate = DateFormat('d MMM yyyy').format(start);
        }
      } catch (_) {
        formattedDate = startDateStr;
      }
    }

    String statusLabel = 'Planning';
    if (rawStatus.toLowerCase() == 'planning') {
      statusLabel = 'Planning';
    } else if (rawStatus.toLowerCase() == 'ongoing') {
      statusLabel = 'Ongoing';
    } else if (rawStatus.toLowerCase() == 'completed') {
      statusLabel = 'Completed';
    } else {
      statusLabel = 'Upcoming';
    }

    return HomeTripModel(
      id: json['id']?.toString() ?? '',
      title: json['name']?.toString() ?? 'Untitled Trip',
      status: rawStatus,
      statusLabel: statusLabel,
      dateText: formattedDate,
      memberCount: membersList.length,
      location: json['destination']?.toString() ?? json['location']?.toString() ?? 'Popular Destination',
      coverImageUrl: json['coverImageUrl']?.toString(),
      members: membersList,
    );
  }
}
