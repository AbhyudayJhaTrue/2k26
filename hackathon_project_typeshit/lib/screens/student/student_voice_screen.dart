import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../user_database.dart';

class StudentVoiceScreen extends StatefulWidget {
  const StudentVoiceScreen({super.key});

  @override
  State<StudentVoiceScreen> createState() => _StudentVoiceScreenState();
}

class _StudentVoiceScreenState extends State<StudentVoiceScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  VoiceCategory _category = VoiceCategory.general;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Student Voice (Anonymous)'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<VoiceCategory>(
              value: _category,
              isExpanded: true,
              items: VoiceCategory.values.map((c) => DropdownMenuItem(value: c, child: Text(c.name.toUpperCase()))).toList(),
              onChanged: (val) => setState(() => _category = val!),
            ),
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Title')),
            const SizedBox(height: 8),
            TextField(controller: _contentController, maxLines: 4, decoration: const InputDecoration(labelText: 'Describe your concern...')),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
                onPressed: () {
                  if (_titleController.text.isNotEmpty) {
                    UserDatabase.instance.addVoiceReport(_titleController.text, _contentController.text, _category);
                    _titleController.clear();
                    _contentController.clear();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report submitted anonymously.')));
                  }
                },
                child: const Text('Submit Report', style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
}