import 'package:flutter/material.dart';
import '../../user_database.dart';

// ---------------------------------------------------------------------------
// ASSIGNMENT MANAGER (Teacher)
// Create, edit, publish/close, and delete assignments. Shows live submission
// progress pulled from UserDatabase.instance.assignments.
// ---------------------------------------------------------------------------

class AssignmentManagerScreen extends StatefulWidget {
  const AssignmentManagerScreen({super.key});

  @override
  State<AssignmentManagerScreen> createState() => _AssignmentManagerScreenState();
}

class _AssignmentManagerScreenState extends State<AssignmentManagerScreen> {
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

  void _openEditor({Assignment? existing}) {
    final titleController = TextEditingController(text: existing?.title ?? '');
    final subjectController = TextEditingController(text: existing?.subject ?? '');
    final totalStudentsController =
        TextEditingController(text: existing != null ? '${existing.totalStudents}' : '');
    DateTime dueDate = existing?.dueDate ?? DateTime.now().add(const Duration(days: 7));
    AssignmentStatus status = existing?.status ?? AssignmentStatus.draft;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(existing == null ? 'New Assignment' : 'Edit Assignment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: subjectController,
                  decoration: const InputDecoration(labelText: 'Subject'),
                ),
                TextField(
                  controller: totalStudentsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Total Students'),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Due: ${dueDate.day}/${dueDate.month}/${dueDate.year}'),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: dueDate,
                          firstDate: DateTime.now().subtract(const Duration(days: 365)),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setDialogState(() => dueDate = picked);
                        }
                      },
                      child: const Text('Change'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<AssignmentStatus>(
                  value: status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: AssignmentStatus.values
                      .map((s) => DropdownMenuItem(value: s, child: Text(s.name.toUpperCase())))
                      .toList(),
                  onChanged: (val) => setDialogState(() => status = val!),
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
                final totalStudents = int.tryParse(totalStudentsController.text.trim()) ??
                    existing?.totalStudents ??
                    0;

                if (existing == null) {
                  UserDatabase.instance.addAssignment(
                    Assignment(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: titleController.text.trim(),
                      subject: subjectController.text.trim(),
                      dueDate: dueDate,
                      totalStudents: totalStudents,
                      submittedCount: 0,
                      status: status,
                    ),
                  );
                } else {
                  UserDatabase.instance.updateAssignment(
                    Assignment(
                      id: existing.id,
                      title: titleController.text.trim(),
                      subject: subjectController.text.trim(),
                      dueDate: dueDate,
                      totalStudents: totalStudents,
                      submittedCount: existing.submittedCount,
                      status: status,
                    ),
                  );
                }
                Navigator.pop(ctx);
              },
              child: Text(existing == null ? 'Create' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(Assignment assignment) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Assignment?'),
        content: Text('This will remove "${assignment.title}" for all students.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () {
              UserDatabase.instance.deleteAssignment(assignment.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final assignments = UserDatabase.instance.assignments;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(title: const Text('Assignment Manager')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(),
        backgroundColor: primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: assignments.isEmpty
          ? const Center(child: Text('No assignments yet. Tap + to create one.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: assignments.length,
              itemBuilder: (context, index) {
                final a = assignments[index];
                final progress = a.totalStudents == 0 ? 0.0 : a.submittedCount / a.totalStudents;

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
                              child: Text(
                                a.title,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            _StatusChip(status: a.status),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${a.subject} • Due ${a.dueDate.day}/${a.dueDate.month}/${a.dueDate.year}',
                          style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7)),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress.clamp(0.0, 1.0),
                            minHeight: 8,
                            backgroundColor: Colors.grey.withOpacity(0.2),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${a.submittedCount}/${a.totalStudents} submitted',
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () => _openEditor(existing: a),
                              icon: const Icon(Icons.edit, size: 18),
                              label: const Text('Edit'),
                            ),
                            TextButton.icon(
                              onPressed: () => _confirmDelete(a),
                              icon: Icon(Icons.delete_outline, size: 18, color: Theme.of(context).colorScheme.error),
                              label: Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.error)),
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

class _StatusChip extends StatelessWidget {
  final AssignmentStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final Color color = switch (status) {
      AssignmentStatus.draft => Colors.grey,
      AssignmentStatus.published => Colors.green,
      AssignmentStatus.closed => Colors.redAccent,
    };
    return Chip(
      label: Text(status.name.toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.white)),
      backgroundColor: color,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}
