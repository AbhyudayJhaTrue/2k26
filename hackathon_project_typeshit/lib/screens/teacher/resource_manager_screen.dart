import 'package:flutter/material.dart';
import '../../user_database.dart';

// ---------------------------------------------------------------------------
// RESOURCE MANAGER (Teacher)
// Share learning resources (notes, slides, videos, links) with students.
// Reads/writes UserDatabase.instance.resources.
// ---------------------------------------------------------------------------

class ResourceManagerScreen extends StatefulWidget {
  const ResourceManagerScreen({super.key});

  @override
  State<ResourceManagerScreen> createState() => _ResourceManagerScreenState();
}

class _ResourceManagerScreenState extends State<ResourceManagerScreen> {
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
    final subjectController = TextEditingController();
    final authorController = TextEditingController();
    final sizeController = TextEditingController();
    ResourceType type = ResourceType.pdf;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Share a Resource'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
                TextField(controller: subjectController, decoration: const InputDecoration(labelText: 'Subject')),
                TextField(
                  controller: authorController,
                  decoration: const InputDecoration(labelText: 'Author (e.g. your name)'),
                ),
                TextField(
                  controller: sizeController,
                  decoration: const InputDecoration(labelText: 'Size / Duration (e.g. 2.4 MB or 12 min)'),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<ResourceType>(
                  value: type,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: ResourceType.values
                      .map((t) => DropdownMenuItem(value: t, child: Text(t.name.toUpperCase())))
                      .toList(),
                  onChanged: (val) => setDialogState(() => type = val!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isEmpty || subjectController.text.trim().isEmpty) {
                  return;
                }
                UserDatabase.instance.addResource(
                  LearningResource(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: titleController.text.trim(),
                    subject: subjectController.text.trim(),
                    type: type,
                    author: authorController.text.trim().isEmpty ? 'You' : authorController.text.trim(),
                    sizeOrDuration: sizeController.text.trim().isEmpty ? '—' : sizeController.text.trim(),
                  ),
                );
                Navigator.pop(ctx);
              },
              child: const Text('Share'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(LearningResource resource) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Resource?'),
        content: Text('"${resource.title}" will no longer be visible to students.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () {
              UserDatabase.instance.deleteResource(resource.id);
              Navigator.pop(ctx);
            },
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(ResourceType type) => switch (type) {
        ResourceType.pdf => Icons.picture_as_pdf_rounded,
        ResourceType.doc => Icons.description_rounded,
        ResourceType.slides => Icons.slideshow_rounded,
        ResourceType.video => Icons.play_circle_fill_rounded,
        ResourceType.link => Icons.link_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final resources = UserDatabase.instance.resources;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('Resource Manager')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: resources.isEmpty
          ? const Center(child: Text('No resources shared yet. Tap + to add one.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: resources.length,
              itemBuilder: (context, index) {
                final r = resources[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: primary.withOpacity(0.15),
                      child: Icon(_iconFor(r.type), color: primary),
                    ),
                    title: Text(r.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text('${r.subject} • ${r.author} • ${r.sizeOrDuration}'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                      onPressed: () => _confirmDelete(r),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
