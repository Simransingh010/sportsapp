import 'package:flutter/material.dart';
import '../models/game_model.dart';
import '../services/supabase_service.dart';

class CreateEditGameScreen extends StatefulWidget {
  final GameModel? game;

  const CreateEditGameScreen({super.key, this.game});

  @override
  State<CreateEditGameScreen> createState() => _CreateEditGameScreenState();
}

class _CreateEditGameScreenState extends State<CreateEditGameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _costController = TextEditingController();
  DateTime? _dateTime;
  int _skillLevel = 5;
  int _maxPlayers = 10;
  bool _isSaving = false;

  bool get _isEditing => widget.game != null;

  @override
  void initState() {
    super.initState();
    final game = widget.game;
    if (game != null) {
      _titleController.text = game.title;
      _locationController.text = game.location;
      _descriptionController.text = game.description ?? '';
      _costController.text = game.costPerPlayer.toStringAsFixed(2);
      _dateTime = game.dateTime;
      _skillLevel = game.skillLevel;
      _maxPlayers = game.maxPlayers;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _costController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _dateTime ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dateTime ?? now),
    );
    if (time == null) return;

    setState(() {
      _dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _saveGame() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_dateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date and time.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final cost = double.tryParse(_costController.text.trim()) ?? 0.0;
      final organizerId = SupabaseService.currentUser?.id ?? 'demo_org';
      final game = GameModel(
        id: widget.game?.id ?? 'game_${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text.trim(),
        location: _locationController.text.trim(),
        dateTime: _dateTime!,
        skillLevel: _skillLevel,
        maxPlayers: _maxPlayers,
        currentPlayers: widget.game?.currentPlayers ?? 0,
        costPerPlayer: cost,
        organizerId: organizerId,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        participants: widget.game?.participants ?? [],
      );

      if (_isEditing) {
        await SupabaseService.updateGame(game);
      } else {
        await SupabaseService.createGame(game);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving game: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Game' : 'Create Game'),
        backgroundColor: const Color(0xFF0D1B1E),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  controller: _titleController,
                  label: 'Game Title',
                  icon: Icons.sports_soccer,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _locationController,
                  label: 'Location',
                  icon: Icons.location_on,
                ),
                const SizedBox(height: 16),
                _buildDateTimeSelector(),
                const SizedBox(height: 16),
                _buildSkillSlider(),
                const SizedBox(height: 16),
                _buildMaxPlayersStepper(),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _costController,
                  label: 'Cost per Player (₡)',
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _descriptionController,
                  label: 'Description (optional)',
                  icon: Icons.notes,
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveGame,
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF0D1B1E),
                            ),
                          )
                        : Text(_isEditing ? 'Save Changes' : 'Create Game'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF00FF88)),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Required field';
        }
        return null;
      },
    );
  }

  Widget _buildDateTimeSelector() {
    final dateLabel = _dateTime == null
        ? 'Select date & time'
        : '${_dateTime!.toLocal()}'.split('.').first;
    return InkWell(
      onTap: _pickDateTime,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A3A2E).withOpacity(0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2A4A3E)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Color(0xFF00FF88)),
            const SizedBox(width: 12),
            Text(
              dateLabel,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Skill Level: $_skillLevel',
          style: const TextStyle(color: Colors.white),
        ),
        Slider(
          value: _skillLevel.toDouble(),
          min: 1,
          max: 10,
          divisions: 9,
          activeColor: const Color(0xFF00FF88),
          label: '$_skillLevel',
          onChanged: (value) => setState(() => _skillLevel = value.round()),
        ),
      ],
    );
  }

  Widget _buildMaxPlayersStepper() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Max Players: $_maxPlayers',
          style: const TextStyle(color: Colors.white),
        ),
        Row(
          children: [
            IconButton(
              onPressed: _maxPlayers > 2
                  ? () => setState(() => _maxPlayers -= 2)
                  : null,
              icon: const Icon(Icons.remove_circle_outline, color: Color(0xFF00FF88)),
            ),
            IconButton(
              onPressed: _maxPlayers < 30
                  ? () => setState(() => _maxPlayers += 2)
                  : null,
              icon: const Icon(Icons.add_circle_outline, color: Color(0xFF00FF88)),
            ),
          ],
        ),
      ],
    );
  }
}
