class GameSummaryModel {
  final String id;
  final String gameId;
  final String summary;
  final List<String> highlights;
  final DateTime createdAt;

  GameSummaryModel({
    required this.id,
    required this.gameId,
    required this.summary,
    required this.highlights,
    required this.createdAt,
  });

  factory GameSummaryModel.fromJson(Map<String, dynamic> json) {
    return GameSummaryModel(
      id: json['id'] as String,
      gameId: json['game_id'] as String,
      summary: json['summary'] as String,
      highlights: List<String>.from(json['highlights'] ?? []),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'game_id': gameId,
      'summary': summary,
      'highlights': highlights,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
