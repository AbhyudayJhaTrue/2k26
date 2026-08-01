import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../user_database.dart';

class ClubsEventsScreen extends StatefulWidget {
  const ClubsEventsScreen({super.key});

  @override
  State<ClubsEventsScreen> createState() => _ClubsEventsScreenState();
}

class _ClubsEventsScreenState extends State<ClubsEventsScreen> {
  ClubCategory _selectedCategory = ClubCategory.all;

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

  @override
  Widget build(BuildContext context) {
    final db = UserDatabase.instance;
    final filteredEvents = _selectedCategory == ClubCategory.all
        ? db.clubEvents
        : db.clubEvents.where((e) => e.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Clubs & Events'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildCategoryFilters(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredEvents.length,
              itemBuilder: (context, index) {
                final event = filteredEvents[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(event.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(event.description, style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: .7))),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${event.registeredCount}/${event.capacity} Filled', style: const TextStyle(fontSize: 12)),
                            ElevatedButton(
                              onPressed: () => db.toggleEventRegistration(event.id),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: event.isRegistered ? Theme.of(context).colorScheme.error : AppTheme.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              child: Text(event.isRegistered ? 'Leave' : 'Register', style: const TextStyle(color: Colors.white)),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: ClubCategory.values.map((cat) {
          final isSelected = cat == _selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Text(cat.name.toUpperCase()),
              onSelected: (_) => setState(() => _selectedCategory = cat),
            ),
          );
        }).toList(),
      ),
    );
  }
}