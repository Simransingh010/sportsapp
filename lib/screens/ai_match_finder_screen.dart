import 'package:flutter/material.dart';
import '../services/gemini_service.dart';
import '../services/supabase_service.dart';
import '../models/user_model.dart';
import '../models/game_model.dart';
import '../widgets/game_card.dart';

class AIMatchFinderScreen extends StatefulWidget {
  const AIMatchFinderScreen({super.key});

  @override
  State<AIMatchFinderScreen> createState() => _AIMatchFinderScreenState();
}

class _AIMatchFinderScreenState extends State<AIMatchFinderScreen> {
  final GeminiService _geminiService = GeminiService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _recommendations = [];
  UserModel? _user;
  List<GameModel> _games = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDataAndFindMatches();
  }

  Future<void> _loadDataAndFindMatches() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // 1. Get current user
      final authUser = SupabaseService.currentUser;
      if (authUser == null) {
        // Fallback for demo/unauthenticated
        _user = UserModel(
          id: 'temp',
          email: 'demo@example.com',
          name: 'Guest Player',
          skillLevel: 5,
          preferredPosition: 'Midfielder',
          location: 'San José',
          availability: ['Saturday', 'Sunday'],
        );
      } else {
        _user = await SupabaseService.getUserProfile(authUser.id);
        // Handle case where profile doesn't exist yet
         if (_user == null) {
            _user = UserModel(
            id: authUser.id,
            email: authUser.email ?? '',
            name: 'Player',
            skillLevel: 5,
            preferredPosition: 'Any',
            location: 'San José',
            availability: ['Saturday', 'Sunday'],
          );
         }
      }

      // 2. Get available games
      _games = await SupabaseService.getAvailableGames();

      if (_games.isEmpty) {
        if (mounted) {
           setState(() {
            _isLoading = false;
            _error = "No upcoming games found to match with.";
           });
        }
        return;
      }

      // 3. Get recommendations from AI
      final recommendations = await _geminiService.findBestMatches(
        _user!,
        _games,
      );
      
      if (mounted) {
        setState(() {
          _recommendations = recommendations;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Error finding matches: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D1B1E),
              Color(0xFF1A3A2E),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'AI Match Finder',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // AI Info Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF00FF88).withOpacity(0.2),
                        const Color(0xFF1A3A2E).withOpacity(0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF00FF88)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00FF88),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.psychology,
                          color: Color(0xFF0D1B1E),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI Match Optimizer',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Analyzing your profile vs available games...',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Recommended Games
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recommended for You',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (_isLoading)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF00FF88),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Content
              Expanded(
                child: _buildContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF00FF88),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.info_outline, color: Colors.white70, size: 48),
              const SizedBox(height: 16),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadDataAndFindMatches,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (_recommendations.isEmpty) {
      return const Center(
        child: Text(
          'No specific recommendations found.',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _recommendations.length,
      itemBuilder: (context, index) {
        final rec = _recommendations[index];
        // Safely parse gameIndex
        final gameIndex = rec['gameIndex'] as int?;
        if (gameIndex == null || gameIndex < 0 || gameIndex >= _games.length) {
          return const SizedBox.shrink(); 
        }

        final game = _games[gameIndex];
        final matchScore = rec['matchScore'] ?? 0;
        final reason = rec['reason'] ?? 'Good fit';

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Stack(
            children: [
              GameCard(game: game),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00FF88),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 14,
                        color: Color(0xFF0D1B1E),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$matchScore% Match',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D1B1E),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // AI Reason overlay at bottom
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: Color(0xFF00FF88), size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          reason,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
