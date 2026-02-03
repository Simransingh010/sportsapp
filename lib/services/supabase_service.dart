import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/user_model.dart';
import '../models/game_model.dart';
import '../models/game_summary_model.dart';

class SupabaseService {
  static SupabaseClient? _client;

  static Future<void> initialize() async {
    await dotenv.load();
    
    final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
    final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );

    _client = Supabase.instance.client;
  }

  static SupabaseClient get client {
    if (_client == null) {
      throw Exception('SupabaseService not initialized');
    }
    return _client!;
  }

  // Auth methods
  static Future<AuthResponse> signUp(String email, String password) async {
    return await client.auth.signUp(
      email: email,
      password: password,
    );
  }

  static Future<AuthResponse> signIn(String email, String password) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  static User? get currentUser => client.auth.currentUser;

  // User methods
  static Future<UserModel?> getUserProfile(String userId) async {
    try {
      final response = await client
          .from('users')
          .select()
          .eq('id', userId)
          .single();
      
      return UserModel.fromJson(response);
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  static Future<void> updateUserProfile(UserModel user) async {
    await client.from('users').upsert(user.toJson());
  }

  // Game methods
  static Future<List<GameModel>> getAvailableGames() async {
    try {
      final response = await client
          .from('games')
          .select()
          .gte('date_time', DateTime.now().toIso8601String())
          .order('date_time');

      return (response as List)
          .map((json) => GameModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting games: $e');
      return [];
    }
  }

  static Future<List<GameModel>> getPastGames(String userId) async {
    try {
      // Logic: Get games where date < now AND participants contains user
      // Note: Supabase 'contains' filter for array column
      final response = await client
          .from('games')
          .select()
          .lt('date_time', DateTime.now().toIso8601String())
          .contains('participants', [userId])
          .order('date_time', ascending: false)
          .limit(5);

      return (response as List)
          .map((json) => GameModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting past games: $e');
      return [];
    }
  }

  static Future<GameModel?> getGame(String gameId) async {
    try {
      final response = await client
          .from('games')
          .select()
          .eq('id', gameId)
          .single();

      return GameModel.fromJson(response);
    } catch (e) {
      print('Error getting game: $e');
      return null;
    }
  }

  static Future<void> joinGame(String gameId, String userId) async {
    final game = await getGame(gameId);
    if (game != null && !game.isFull) {
      final updatedParticipants = [...game.participants, userId];
      await client.from('games').update({
        'participants': updatedParticipants,
        'current_players': game.currentPlayers + 1,
      }).eq('id', gameId);
    }
  }

  static Future<void> leaveGame(String gameId, String userId) async {
    final game = await getGame(gameId);
    if (game != null) {
      final updatedParticipants = game.participants.where((id) => id != userId).toList();
      await client.from('games').update({
        'participants': updatedParticipants,
        'current_players': game.currentPlayers - 1,
      }).eq('id', gameId);
    }
  }

  static Future<void> removeParticipant(String gameId, String participantId) async {
    final game = await getGame(gameId);
    if (game != null && game.participants.contains(participantId)) {
      final updatedParticipants = game.participants.where((id) => id != participantId).toList();
      await client.from('games').update({
        'participants': updatedParticipants,
        'current_players': game.currentPlayers - 1,
      }).eq('id', gameId);
    }
  }

  static Future<List<GameModel>> getGamesByOrganizer(String organizerId) async {
    try {
      final response = await client
          .from('games')
          .select()
          .eq('organizer_id', organizerId)
          .order('date_time');

      return (response as List)
          .map((json) => GameModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting organizer games: $e');
      return [];
    }
  }

  static Future<void> createGame(GameModel game) async {
    await client.from('games').insert(game.toJson());
  }

  static Future<void> updateGame(GameModel game) async {
    await client.from('games').update(game.toJson()).eq('id', game.id);
  }

  static Future<void> deleteGame(String gameId) async {
    await client.from('games').delete().eq('id', gameId);
  }

  // Game summary methods
  static Future<GameSummaryModel?> getGameSummary(String gameId) async {
    try {
      final response = await client
          .from('game_summaries')
          .select()
          .eq('game_id', gameId)
          .single();

      return GameSummaryModel.fromJson(response);
    } catch (e) {
      print('Error getting game summary: $e');
      return null;
    }
  }

  static Future<void> saveGameSummary(GameSummaryModel summary) async {
    await client.from('game_summaries').insert(summary.toJson());
  }

  // Debug/Demo method
  static Future<void> seedPastGames(String userId) async {
    final pastGames = [
      {
        'title': 'Hackathon Warmup Match',
        'location': 'Downtown Sports Complex',
        'date_time': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'skill_level': 7,
        'max_players': 14,
        'current_players': 14,
        'cost_per_player': 5.00,
        'description': 'High intensity match.',
        'participants': [userId], // Add user as participant
      },
      {
        'title': 'Sunday Morning League',
        'location': 'Riverside Field',
        'date_time': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        'skill_level': 8,
        'max_players': 22,
        'current_players': 22,
        'cost_per_player': 10.00,
        'description': 'League match, very competitive.',
        'participants': [userId],
      },
      {
        'title': 'Casual Friday Kickabout',
        'location': 'Community Park',
        'date_time': DateTime.now().subtract(const Duration(days: 8)).toIso8601String(),
        'skill_level': 4,
        'max_players': 10,
        'current_players': 8,
        'cost_per_player': 0.00,
        'description': 'Friendly game for beginners.',
        'participants': [userId],
      },
    ];

    for (final game in pastGames) {
      await client.from('games').insert(game);
    }
  }
}
