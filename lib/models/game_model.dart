class GameModel {
  final String id;
  final String title;
  final String location;
  final DateTime dateTime;
  final int skillLevel; // 1-10
  final int maxPlayers;
  final int currentPlayers;
  final double costPerPlayer;
  final String organizerId;
  final String? description;
  final List<String> participants;

  GameModel({
    required this.id,
    required this.title,
    required this.location,
    required this.dateTime,
    required this.skillLevel,
    required this.maxPlayers,
    required this.currentPlayers,
    required this.costPerPlayer,
    required this.organizerId,
    this.description,
    required this.participants,
  });

  factory GameModel.fromJson(Map<String, dynamic> json) {
    return GameModel(
      id: json['id'] as String,
      title: json['title'] as String,
      location: json['location'] as String,
      dateTime: DateTime.parse(json['date_time'] as String),
      skillLevel: json['skill_level'] as int? ?? 5,
      maxPlayers: json['max_players'] as int? ?? 10,
      currentPlayers: json['current_players'] as int? ?? 0,
      costPerPlayer: (json['cost_per_player'] as num?)?.toDouble() ?? 0.0,
      organizerId: json['organizer_id'] as String? ?? 'system',
      description: json['description'] as String?,
      participants: (json['participants'] as List?)?.map((e) => e as String).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'location': location,
      'date_time': dateTime.toIso8601String(),
      'skill_level': skillLevel,
      'max_players': maxPlayers,
      'current_players': currentPlayers,
      'cost_per_player': costPerPlayer,
      'organizer_id': organizerId,
      'description': description,
      'participants': participants,
    };
  }

  bool get isFull => currentPlayers >= maxPlayers;
  
  int get spotsLeft => maxPlayers - currentPlayers;
}
