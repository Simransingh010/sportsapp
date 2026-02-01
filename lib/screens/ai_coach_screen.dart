import 'package:flutter/material.dart';
import '../services/gemini_service.dart';
import '../services/supabase_service.dart';
import '../models/user_model.dart';
import '../models/game_model.dart';

class AICoachScreen extends StatefulWidget {
  const AICoachScreen({super.key});

  @override
  State<AICoachScreen> createState() => _AICoachScreenState();
}

class _AICoachScreenState extends State<AICoachScreen> {
  final GeminiService _geminiService = GeminiService();
  bool _isLoading = true;
  List<String> _coachingTips = [];
  UserModel? _user;
  GameModel? _upcomingGame;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDataAndGetTips();
  }

  Future<void> _loadDataAndGetTips() async {
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

      // 2. Find upcoming game (closest future game where user is participant)
      // For now, let's just grab the soonest game in the DB to give ANY context if they haven't joined one
      final allGames = await SupabaseService.getAvailableGames();
      
      // Try to find one they are participating in
      try {
        _upcomingGame = allGames.firstWhere(
          (g) => g.participants.contains(_user!.id),
        );
      } catch (e) {
        // If not joined any, just pick the next available one as "Potential Upcoming Game" context
        if (allGames.isNotEmpty) {
           _upcomingGame = allGames.first; 
        }
      }

      // 3. Get Past Games for Context
      final pastGames = authUser != null 
          ? await SupabaseService.getPastGames(authUser.id)
          : <GameModel>[];

      // 4. Get AI Tips
      final tips = await _geminiService.getCoachingTips(_user!, _upcomingGame, pastGames);
      
      if (mounted) {
        setState(() {
          _coachingTips = tips;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Error getting tips: $e';
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
                      'AI Coach',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Player Profile Card
              if (_user != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A3A2E).withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF2A4A3E)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00FF88), Color(0xFF00D9FF)],
                            ),
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _user!.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_user!.preferredPosition} • Skill ${_user!.skillLevel}/10',
                                style: const TextStyle(
                                  fontSize: 14,
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

              // Upcoming Game Card
              if (_upcomingGame != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF00FF88).withOpacity(0.2),
                          const Color(0xFF1A3A2E).withOpacity(0.6),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Next Game Context',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _upcomingGame!.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Skill Level: ${_upcomingGame!.skillLevel}/10',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF00FF88),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Coaching Tips Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Personalized Tips',
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

              // Refresh Button
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _loadDataAndGetTips,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Get New Tips'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
     if (_isLoading && _coachingTips.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF00FF88)));
    }

    if (_error != null) {
      return Center(child: Text(_error!, style: const TextStyle(color: Colors.red)));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _coachingTips.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A3A2E).withOpacity(0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2A4A3E)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00FF88).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00FF88),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _coachingTips[index],
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
