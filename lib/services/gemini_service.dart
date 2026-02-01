import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../models/game_model.dart';
import '../models/game_summary_model.dart';

class GeminiService {
  late final GenerativeModel _model;
  
  GeminiService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    _model = GenerativeModel(
      model: 'gemini-3-flash-preview',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
      ),
    );
  }

  /// Helper to clean and parse JSON from AI response
  dynamic _parseJson(String text) {
    try {
      // First try direct parsing
      return jsonDecode(text);
    } catch (e) {
      // Try to find JSON block
      final jsonStart = text.indexOf('{');
      final jsonEnd = text.lastIndexOf('}') + 1;
      if (jsonStart != -1 && jsonEnd > jsonStart) {
        final jsonText = text.substring(jsonStart, jsonEnd);
        return jsonDecode(jsonText);
      }
      throw FormatException('No valid JSON found in response');
    }
  }

  // AI Feature 1: Smart Match Finder
  Future<List<Map<String, dynamic>>> findBestMatches(
    UserModel user,
    List<GameModel> availableGames,
  ) async {
    if (availableGames.isEmpty) return [];

    final prompt = '''
You are an AI assistant for a drop-in sports app. Analyze the player profile and valid available games to recommend the top 3 best-matched games.

Player Profile:
- Name: ${user.name}
- Skill Level: ${user.skillLevel}/10
- Preferred Position: ${user.preferredPosition}
- Location: ${user.location}
- Availability: ${user.availability.join(', ')}

Available Games:
${availableGames.asMap().entries.map((entry) {
      final idx = entry.key;
      final game = entry.value;
      return '''
Game Index $idx:
- Title: ${game.title}
- Location: ${game.location}
- Date/Time: ${game.dateTime}
- Skill Level: ${game.skillLevel}/10
- Spots: ${game.spotsLeft}/${game.maxPlayers}
- Cost: \$${game.costPerPlayer}
''';
    }).join('\n')}

Provide recommendations in this exact JSON format:
{
  "recommendations": [
    {
      "gameIndex": 0,
      "matchScore": 95,
      "reason": "Perfect skill match and convenient location"
    }
  ]
}

Only recommend games that are actually in the provided list. Return ONLY valid JSON.
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text;
      
      if (text == null) return [];

      final data = _parseJson(text);
      if (data is Map && data.containsKey('recommendations')) {
        return List<Map<String, dynamic>>.from(data['recommendations']);
      }
      
      return [];
    } catch (e) {
      print('Error in findBestMatches: $e');
      return [];
    }
  }

  // AI Feature 2: AI Game Coach
  Future<List<String>> getCoachingTips(
    UserModel user,
    GameModel? upcomingGame,
    List<GameModel> pastGames,
  ) async {
    final gameContext = upcomingGame != null
        ? '''
Upcoming Game Context:
- Title: ${upcomingGame.title}
- Skill Level: ${upcomingGame.skillLevel}/10
- Location: ${upcomingGame.location}
- Type: ${upcomingGame.description ?? 'Standard Match'}
'''
        : 'No upcoming game scheduled. Focus on general improvement.';

    final hasHistory = pastGames.isNotEmpty;
    final historyContext = hasHistory
        ? pastGames.map((g) => '- Played on ${g.dateTime.toLocal().toString().split(' ')[0]} at ${g.location} (Skill Level: ${g.skillLevel})').join('\n')
        : 'No recent games recorded.';

    final performanceNote = hasHistory
        ? 'Analyze their recent game frequency and opponents skill levels.'
        : 'No recent history. Encourage them to play their first game.';

    final prompt = '''
You are a professional soccer coach. Provide 5 personalized, actionable coaching tips for this player.

Player Profile:
- Name: ${user.name}
- Skill Level: ${user.skillLevel}/10
- Preferred Position: ${user.preferredPosition}

Recent History (Last 5 Games):
$historyContext
$performanceNote

$gameContext

Provide tips as a JSON array of strings:
{
  "tips": [
    "Tip 1 here",
    "Tip 2 here"
  ]
}

Return ONLY valid JSON.
''';
    
    // Debug log to verify context
    print('DEBUG: AI Coach Prompt Context:\nHistory: $historyContext');


    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text;
      
      if (text == null) return [];

      final data = _parseJson(text);
      if (data is Map && data.containsKey('tips')) {
        return List<String>.from(data['tips']);
      }
      
      return [];
    } catch (e) {
      print('Error in getCoachingTips: $e');
      return ['Keep practicing and stay consistent!'];
    }
  }

  // AI Feature 3: Smart Scheduling Assistant
  Future<Map<String, dynamic>> suggestOptimalSchedule(
    UserModel user,
    List<GameModel> pastGames,
  ) async {
    // If no history, use preferences
    final historyContext = pastGames.isNotEmpty 
        ? pastGames.map((g) => '- ${g.dateTime.weekday} at ${g.dateTime.hour}:00').join('\n')
        : 'No past games recorded.';

    final prompt = '''
You are a scheduling AI assistant. Analyze the player's preferences and history to suggest optimal playing times.

Player Profile:
- Name: ${user.name}
- Stated Availability: ${user.availability.join(', ')}

Past Games Played:
$historyContext

Provide scheduling recommendations in JSON format:
{
  "bestDays": ["Monday", "Wednesday"],
  "bestTimes": ["18:00", "19:00"],
  "reasoning": "Based on your stated availability and past attendance..."
}

Return ONLY valid JSON.
''';

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text;
      
      if (text == null) return {};

      final data = _parseJson(text);
      return Map<String, dynamic>.from(data);
    } catch (e) {
      print('Error in suggestOptimalSchedule: $e');
      return {
        'bestDays': user.availability,
        'bestTimes': ['18:00', '19:00'],
        'reasoning': 'Based on your default availability settings.',
      };
    }
  }

  // AI Feature 4: Game Summary Generator
  // Note: changing return type to Future<String> to keep it simple, 
  // but could return GameSummaryModel if we parse it.
  Future<String> generateGameSummary(
    GameModel game,
    List<UserModel> participants,
  ) async {
    final prompt = '''
You are a sports journalist. Write an engaging post-game summary for this pickup soccer game.

Game Details:
- Title: ${game.title}
- Location: ${game.location}
- Date: ${game.dateTime}
- Skill Level: ${game.skillLevel}/10
- Players: ${participants.length}

Participants:
${participants.map((p) => '- ${p.name} (${p.preferredPosition}, Skill: ${p.skillLevel}/10)').join('\n')}

Write a 2-3 paragraph engaging summary highlighting the match atmosphere, key moments (invent some plausible ones based on player stats), and player performances. Make it exciting and personal.

Return ONLY the plain text summary.
''';

    // We can use a separate model instance or config for text-only response if needed,
    // but the default one set to JSON might try to force JSON. 
    // Let's override config if possible or just use a text prompt request.
    // For simplicity with the single configured model, we'll ask for JSON with a text field.

    final jsonPrompt = '''
$prompt

Response format:
{
  "summary": "The full summary text here..."
}
''';

    try {
      final response = await _model.generateContent([Content.text(jsonPrompt)]);
      final text = response.text;
      
      if (text == null) return 'Game summary unavailable.';

      final data = _parseJson(text);
      if (data is Map && data.containsKey('summary')) {
        return data['summary'].toString();
      }
      return text; // Fallback if it returns raw text
    } catch (e) {
      print('Error in generateGameSummary: $e');
      return 'An exciting match took place!';
    }
  }
}
