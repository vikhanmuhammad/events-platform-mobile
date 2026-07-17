class User {
  final String id;
  final String email;
  final String password_hash;
  final String name;
  final String? avatarUrl;
  final String? bio;
  final String? locationName;
  final double? latitude;
  final double? longitude;
  final List<String>? interests;

  User({
    required this.id,
    required this.email,
    required this.password_hash,
    required this.name,
    this.avatarUrl,
    this.bio,
    this.locationName,
    this.latitude,
    this.longitude,
    this.interests,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      password_hash: json['password_hash'] ?? '',
      name: json['name'] ?? '',
      avatarUrl: json['avatar_url'],
      bio: json['bio'],
      locationName: json['location_name'],
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      interests: List<String>.from(json['interests'] ?? []),
    );
  }
}
