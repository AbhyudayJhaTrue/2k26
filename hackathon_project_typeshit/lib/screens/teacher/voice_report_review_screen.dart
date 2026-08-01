import 'package:flutter/material.dart';
import '../../user_database.dart';

// ---------------------------------------------------------------------------
// STUDENT VOICE REPORT REVIEW (Teacher)
// Review anonymous student voice reports and move them through
// submitted -> reviewing -> resolved. Reads/writes
// UserDatabase.instance.voiceReports.
// ---------------------------------------------------------------------------

class VoiceReportReviewScreen extends StatefulWidget {
  const VoiceReportReviewScreen({super.key});

  @override
  State<VoiceReportReviewScreen> createState() => _VoiceReportReviewScreenState();
}

class _VoiceReportReviewScreenState extends State<VoiceReportReviewScreen> {
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

  Color _colorFor(VoiceStatus status) => switch (status) {
        VoiceStatus.submitted => Colors.redAccent,
        VoiceStatus.reviewing => Colors.orange,
        VoiceStatus.resolved => Colors.green,
      };

  String _categoryLabel(VoiceCategory category) => switch (category) {
        VoiceCategory.bullying => 'Bullying',
        VoiceCategory.mentalHealth => 'Mental Health',
        VoiceCategory.maintenance => 'Maintenance',
        VoiceCategory.personal => 'Personal',
        VoiceCategory.general => 'General',
      };

  @override
  Widget build(BuildContext context) {
    final reports = [...UserDatabase.instance.voiceReports]
      ..sort((a, b) => a.status.index.compareTo(b.status.index));

    return Scaffold(
      appBar: AppBar(title: const Text('Student Voice Reports')),
      body: reports.isEmpty
          ? const Center(child: Text('No reports submitted yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final r = reports[index];
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
                              child: Text(r.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                            Chip(
                              label: Text(
                                r.status.name.toUpperCase(),
                                style: const TextStyle(fontSize: 10, color: Colors.white),
                              ),
                              backgroundColor: _colorFor(r.status),
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(r.content),
                        const SizedBox(height: 6),
                        Chip(
                          label: Text(_categoryLabel(r.category), style: const TextStyle(fontSize: 11)),
                          visualDensity: VisualDensity.compact,
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: DropdownButton<VoiceStatus>(
                            value: r.status,
                            underline: const SizedBox(),
                            items: VoiceStatus.values
                                .map((status) => DropdownMenuItem(
                                      value: status,
                                      child: Text(status.name.toUpperCase(), style: const TextStyle(fontSize: 12)),
                                    ))
                                .toList(),
                            onChanged: (status) {
                              if (status != null) {
                                UserDatabase.instance.setVoiceReportStatus(r.id, status);
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
