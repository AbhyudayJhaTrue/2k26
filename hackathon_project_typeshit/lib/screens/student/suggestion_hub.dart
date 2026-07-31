import 'package:flutter/material.dart';
import '../../user_database.dart';


class SuggestionHubScreen extends StatefulWidget {
  const SuggestionHubScreen({super.key});

  @override
  State<SuggestionHubScreen> createState() => _SuggestionHubScreenState();
}

class _SuggestionHubScreenState extends State<SuggestionHubScreen> {
  @override
  void initState() {
    super.initState();
    UserDatabase.instance.addListener(_onDbChange);
  }

  @override
  void dispose() {
    UserDatabase.instance.removeListener(_onDbChange);
    super.dispose();
  }

  void _onDbChange() => setState(() {});

  void _showAddDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Suggestion'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
            TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                UserDatabase.instance.addSuggestion(titleController.text, descController.text);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = UserDatabase.instance.suggestions;

    return Scaffold(
      appBar: AppBar(title: const Text('Suggestion Hub')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final item = suggestions[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(item.description),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.thumb_up, color: item.isUpvoted ? Theme.of(context).colorScheme.primary : Colors.grey),
                    onPressed: () => UserDatabase.instance.toggleUpvoteSuggestion(item.id),
                  ),
                  Text('${item.upvotes}', style: const TextStyle(fontSize: 10)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}