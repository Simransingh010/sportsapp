import 'package:flutter/material.dart';
import 'ai_match_finder_screen.dart';
import 'ai_coach_screen.dart';
import '../models/game_model.dart';
import '../services/supabase_service.dart';
import '../services/gemini_service.dart';
import '../widgets/game_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<GameModel> _games = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  Future<void> _loadGames() async {
    try {
      final games = await SupabaseService.getAvailableGames();
      if (mounted) {
        setState(() {
          _games = games;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading games: $e')),
        );
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
          child: _buildBody(),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A3A2E).withOpacity(0.95),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          backgroundColor: Colors.transparent,
          selectedItemColor: const Color(0xFF00FF88),
          unselectedItemColor: Colors.white.withOpacity(0.5),
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'My Games',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildExploreTab();
      case 2:
        return _buildMyGamesTab();
      case 3:
        return const Center(child: Text('Profile - Coming Soon', style: TextStyle(color: Colors.white)));
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    return RefreshIndicator(
      onRefresh: _loadGames,
      color: const Color(0xFF00FF88),
      backgroundColor: const Color(0xFF1A3A2E),
      child: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pura Vida,',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                          const Text(
                            'Player', // Using generic name until we have profile
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Your Next Match Card (Placeholder logic for now)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2A5A4E), Color(0xFF1A3A2E)],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Your Next Match',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00FF88),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'READY',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0D1B1E),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Find a Game',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Join a match nearby',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const AIMatchFinderScreen(),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.search, size: 18),
                                label: const Text('Find Match'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // AI Features Section
                  const Text(
                    'AI Features',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildAIFeatureCard(
                          'AI Match\nFinder',
                          Icons.psychology,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AIMatchFinderScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildAIFeatureCard(
                          'AI Coach',
                          Icons.sports,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AICoachScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Discover Games Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Discover Games',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      TextButton(
                        onPressed: _loadGames,
                        child: const Text(
                          'Refresh',
                          style: TextStyle(color: Color(0xFF00FF88)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Games List
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF00FF88)),
              ),
            )
          else if (_games.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    'No upcoming games found.\nBe the first to create one!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: GameCard(game: _games[index]),
                    );
                  },
                  childCount: _games.length,
                ),
              ),
            ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  Widget _buildAIFeatureCard(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
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
          border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF00FF88), size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Local demo state
  List<GameModel> _demoGames = [];

  Widget _buildMyGamesTab() {
    // If we have local demo games, show them immediately (Demo View)
    if (_demoGames.isNotEmpty) {
      return _buildGamesList(_demoGames);
    }

    return FutureBuilder<List<GameModel>>(
      future: SupabaseService.currentUser == null 
          ? Future.value([]) 
          : SupabaseService.getPastGames(SupabaseService.currentUser!.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF00FF88)));
        }
        
        final hasData = snapshot.hasData && snapshot.data!.isNotEmpty;
        if (!hasData) {
           return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.history, size: 64, color: Colors.white24),
                const SizedBox(height: 16),
                const Text(
                  'No Game History Yet',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Join your first match to see it here!',
                  style: TextStyle(color: Colors.white.withOpacity(0.5)),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => setState(() => _selectedIndex = 0),
                  child: const Text('Find Games'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () async {
                    if (SupabaseService.currentUser != null) {
                        try {
                           await SupabaseService.seedPastGames(SupabaseService.currentUser!.id);
                           setState(() {}); // Refresh UI
                           ScaffoldMessenger.of(context).showSnackBar(
                             const SnackBar(content: Text('Db data seeded! Pull to refresh if needed.')),
                           );
                        } catch (e) {
                           ScaffoldMessenger.of(context).showSnackBar(
                             SnackBar(content: Text('Error seeding: $e')),
                           );
                        }
                    } else {
                       // Fallback: Seed local demo data
                       setState(() {
                         _demoGames = [
                            GameModel(
                              id: 'demo_1',
                              title: 'Hackathon Warmup Match',
                              location: 'Downtown Sports Complex',
                              dateTime: DateTime.now().subtract(const Duration(days: 2)),
                              skillLevel: 7,
                              maxPlayers: 14,
                              currentPlayers: 14,
                              costPerPlayer: 5.00,
                              organizerId: 'demo_org',
                              participants: ['demo_user'],
                              description: 'High intensity match.',
                            ),
                            GameModel(
                              id: 'demo_2',
                              title: 'Sunday Morning League',
                              location: 'Riverside Field',
                              dateTime: DateTime.now().subtract(const Duration(days: 5)),
                              skillLevel: 8,
                              maxPlayers: 22,
                              currentPlayers: 22,
                              costPerPlayer: 10.00,
                              organizerId: 'demo_org',
                              participants: ['demo_user'],
                              description: 'League match, very competitive.',
                            ),
                            GameModel(
                              id: 'demo_3',
                              title: 'Casual Friday Kickabout',
                              location: 'Community Park',
                              dateTime: DateTime.now().subtract(const Duration(days: 8)),
                              skillLevel: 4,
                              maxPlayers: 10,
                              currentPlayers: 8,
                              costPerPlayer: 0.00,
                              organizerId: 'demo_org',
                              participants: ['demo_user'],
                              description: 'Friendly game.',
                            ),
                         ];
                       });
                       ScaffoldMessenger.of(context).showSnackBar(
                             const SnackBar(content: Text('Demo Mode: Local data seeded!')),
                           );
                    }
                  },
                  child: const Text('Demo: Seed Past Games', style: TextStyle(color: Colors.white30)),
                ),
              ],
            ),
          );
        }

        return _buildGamesList(snapshot.data!);
      },
    );
  }

  Widget _buildGamesList(List<GameModel> games) {
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: games.length,
          itemBuilder: (context, index) {
            final game = games[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A3A2E).withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF2A4A3E)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        game.dateString, // Assuming getter or format manually
                        style: const TextStyle(color: Color(0xFF00FF88), fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('COMPLETED', style: TextStyle(color: Colors.white70, fontSize: 10)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    game.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    game.location,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showMatchReport(context, game),
                      icon: const Icon(Icons.article),
                      label: const Text('Generate Match Report'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2A5A4E),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
  }

  Future<void> _showMatchReport(BuildContext context, GameModel game) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          color: Color(0xFF1A3A2E),
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xFF00FF88)),
                SizedBox(height: 16),
                Text('AI Reporter writing story...', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // Mock participants for now as we don't have full user objects in GameModel usually
      // In a real app we'd fetch them. For Hackathon, we'll use a placeholder list
      // or if SupabaseService.getGame fetched them.
      // Let's rely on the service to handle basic info or just pass empty for now
      // and let the service hallucinate/improvise based on game details if list is empty.
      
      final summary = await GeminiService().generateGameSummary(game, []);
      
      if (mounted) {
        Navigator.pop(context); // Close loader
        
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: const BoxDecoration(
              color: Color(0xFF0D1B1E),
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              children: [
                // Handle
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      const Icon(Icons.newspaper, color: Color(0xFF00FF88), size: 32),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Match Report',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A3A2E),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF2A4A3E)),
                          ),
                          child: Text(
                            summary,
                            style: const TextStyle(
                              fontSize: 16,
                              height: 1.6,
                              color: Colors.white,
                              fontFamily: 'serif', // Newspaper feel
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Center(
                          child: Text(
                            'Generated by Gemini 2.0 Flash',
                            style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loader
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Widget _buildExploreTab() {
    return const Center(
      child: Text(
        'Explore Tab - Coming Soon',
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }
}

extension GameDateExt on GameModel {
    String get dateString {
        // Simple manual format if needed, or use intl if available
        // Assuming toLocal() is safe
        final dt = dateTime.toLocal();
        return '${dt.day}/${dt.month} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}'; 
    }
}
