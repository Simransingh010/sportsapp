import 'package:flutter/material.dart';
import '../models/game_model.dart';
import '../services/supabase_service.dart';
import 'create_edit_game_screen.dart';

class OrganizerGamesScreen extends StatefulWidget {
  const OrganizerGamesScreen({super.key});

  @override
  State<OrganizerGamesScreen> createState() => _OrganizerGamesScreenState();
}

class _OrganizerGamesScreenState extends State<OrganizerGamesScreen> {
  bool _isLoading = true;
  String? _error;
  List<GameModel> _games = [];

  @override
  void initState() {
    super.initState();
    _loadOrganizerGames();
  }

  Future<void> _loadOrganizerGames() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final organizerId = SupabaseService.currentUser?.id ?? 'demo_org';
      final games = await SupabaseService.getGamesByOrganizer(organizerId);
      if (mounted) {
        setState(() {
          _games = games;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error loading games: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _openCreate() async {
    final didSave = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const CreateEditGameScreen()),
    );
    if (didSave == true) {
      _loadOrganizerGames();
    }
  }

  Future<void> _openEdit(GameModel game) async {
    final didSave = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => CreateEditGameScreen(game: game)),
    );
    if (didSave == true) {
      _loadOrganizerGames();
    }
  }

  Future<void> _cancelGame(GameModel game) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel game?'),
        content: const Text('This will remove the game for all players.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Cancel Game')),
        ],
      ),
    );

    if (confirm == true) {
      await SupabaseService.deleteGame(game.id);
      _loadOrganizerGames();
    }
  }

  void _manageParticipants(GameModel game) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0D1B1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        if (game.participants.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Text('No participants yet.', style: TextStyle(color: Colors.white70)),
          );
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Participants',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...game.participants.map((participantId) {
              return ListTile(
                title: Text(participantId, style: const TextStyle(color: Colors.white)),
                trailing: IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                  onPressed: () async {
                    await SupabaseService.removeParticipant(game.id, participantId);
                    if (mounted) {
                      Navigator.pop(context);
                      _loadOrganizerGames();
                    }
                  },
                ),
              );
            }),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Organizer Games'),
        backgroundColor: const Color(0xFF0D1B1E),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreate,
        backgroundColor: const Color(0xFF00FF88),
        child: const Icon(Icons.add, color: Color(0xFF0D1B1E)),
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF00FF88)));
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.white70, size: 48),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _loadOrganizerGames, child: const Text('Try Again')),
            ],
          ),
        ),
      );
    }

    if (_games.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.event_busy, size: 64, color: Colors.white24),
            const SizedBox(height: 16),
            const Text(
              'No games created yet',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to create your first game.',
              style: TextStyle(color: Colors.white.withOpacity(0.5)),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrganizerGames,
      color: const Color(0xFF00FF88),
      backgroundColor: const Color(0xFF1A3A2E),
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _games.length,
        itemBuilder: (context, index) {
          final game = _games[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${game.location} • ${game.dateTime.toLocal()}'.split('.').first,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Players: ${game.currentPlayers}/${game.maxPlayers} • Skill ${game.skillLevel}/10',
                    style: const TextStyle(color: Color(0xFF00FF88)),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _openEdit(game),
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Edit'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _manageParticipants(game),
                        icon: const Icon(Icons.group, size: 16),
                        label: const Text('Participants'),
                      ),
                      TextButton.icon(
                        onPressed: () => _cancelGame(game),
                        icon: const Icon(Icons.cancel, size: 16, color: Colors.redAccent),
                        label: const Text('Cancel', style: TextStyle(color: Colors.redAccent)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
