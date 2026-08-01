import 'package:flutter/material.dart';
import '../../user_database.dart';

// ---------------------------------------------------------------------------
// SUGGESTION REVIEW (Teacher)
// Move student suggestions through pending -> underReview -> approved ->
// implemented. Reads/writes UserDatabase.instance.suggestions.
// ---------------------------------------------------------------------------

class SuggestionReviewScreen extends StatefulWidget {
  const SuggestionReviewScreen({super.key});

  @override
  State<SuggestionReviewScreen> createState() => _SuggestionReviewScreenState();
}

class _SuggestionReviewScreenState extends State<SuggestionReviewScreen> {
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

  Color _colorFor(SuggestionStatus status) => switch (status) {
        SuggestionStatus.pending => Colors.grey,
        SuggestionStatus.underReview => Colors.orange,
        SuggestionStatus.approved => Colors.green,
        SuggestionStatus.implemented => Colors.indigo,
      };

  @override
  Widget build(BuildContext context) {
    // Sort with pending/underReview first so teachers see what needs action.
    final suggestions = [...UserDatabase.instance.suggestions]
      ..sort((a, b) => a.status.index.compareTo(b.status.index));

    return Scaffold(
      appBar: AppBar(title: const Text('Suggestion Review')),
      body: suggestions.isEmpty
          ? const Center(child: Text('No suggestions submitted yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                final s = suggestions[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(s.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                            Chip(
                              label: Text(
                                s.status.name.toUpperCase(),
                                style: const TextStyle(fontSize: 10, color: Colors.white),
                              ),
                              backgroundColor: _colorFor(s.status),
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(s.description),
                        const SizedBox(height: 4),
                        Text(
                          'By ${s.authorName} • ${s.upvotes} upvotes',
                          style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7)),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: DropdownButton<SuggestionStatus>(
                            value: s.status,
                            underline: const SizedBox(),
                            items: SuggestionStatus.values
                                .map((status) => DropdownMenuItem(
                                      value: status,
                                      child: Text(status.name.toUpperCase(), style: const TextStyle(fontSize: 12)),
                                    ))
                                .toList(),
                            onChanged: (status) {
                              if (status != null) {
                                UserDatabase.instance.setSuggestionStatus(s.id, status);
                              }
                            },
                          ),
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
