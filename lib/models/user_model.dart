class UserModel {
  final String id;
  final String email;
  final String name;
  final int skillLevel; // 1-10
  final String preferredPosition;
  final String location;
  final List<String> availability;
  final String? avatarUrl;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.skillLevel,
    required this.preferredPosition,
    required this.location,
    required this.availability,
    this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      skillLevel: json['skill_level'] as int,
      preferredPosition: json['preferred_position'] as String,
      location: json['location'] as String,
      availability: List<String>.from(json['availability'] ?? []),
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'skill_level': skillLevel,
      'preferred_position': preferredPosition,
      'location': location,
      'availability': availability,
      'avatar_url': avatarUrl,
    };
  }
}
