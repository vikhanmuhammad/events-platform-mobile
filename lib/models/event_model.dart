import 'user_model.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final String category;
  final DateTime startTime;
  final String locationName;
  final double latitude;
  final double longitude;
  final String? imageUrl;
  final String creatorId;
  final User? creator;
  final int attendeeCount;
  final String userRsvpStatus;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.startTime,
    required this.locationName,
    required this.latitude,
    required this.longitude,
    this.imageUrl,
    required this.creatorId,
    this.creator,
    this.attendeeCount = 0,
    this.userRsvpStatus = 'NOT_RESPONDED',
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      startTime: DateTime.parse(
          json['start_time'] ?? DateTime.now().toIso8601String()),
      locationName: json['location_name'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      imageUrl: json['image_url'],
      creatorId: json['creator_id'] ?? '',
      creator: json['creator'] != null ? User.fromJson(json['creator']) : null,
      attendeeCount: (json['attendee_count'] as num?)?.toInt() ?? 0,
      userRsvpStatus: json['user_rsvp_status'] ?? 'NOT_RESPONDED',
    );
  }
}
