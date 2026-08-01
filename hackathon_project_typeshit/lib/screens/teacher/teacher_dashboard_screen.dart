import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../user_database.dart';
import 'assignment_manager_screen.dart';
import 'resource_manager_screen.dart';
import 'suggestion_review_screen.dart';
import 'voice_report_review_screen.dart';
import '../class_feed_screen.dart';

// ---------------------------------------------------------------------------
// TEACHER DASHBOARD
// Landing page for teacher accounts: at-a-glance stats pulled from
// UserDatabase.instance, plus navigation into the teacher tools
// (Assignment Manager, Resource Manager, Suggestion Review, Voice Reports).
// ---------------------------------------------------------------------------

class TeacherDashboardScreen extends StatefulWidget {
  final String teacherName;

  const TeacherDashboardScreen({super.key, required this.teacherName});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
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
    final primary = Theme.of(context).colorScheme.primary;

    final totalAssignments = db.assignments.length;
    final totalStudentsAcrossAssignments = db.assignments.fold<int>(
      0,
      (sum, a) => sum + a.totalStudents,
    );
    final totalSubmitted = db.assignments.fold<int>(
      0,
      (sum, a) => sum + a.submittedCount,
    );
    final submissionRate = totalStudentsAcrossAssignments == 0
        ? 0
        : ((totalSubmitted / totalStudentsAcrossAssignments) * 100).round();
    final pendingSuggestions =
        db.suggestions.where((s) => s.status == SuggestionStatus.pending).length;
    final openVoiceReports =
        db.voiceReports.where((v) => v.status != VoiceStatus.resolved).length;
    final upcomingEvents = db.clubEvents
        .where((e) => e.date.isAfter(DateTime.now()))
        .length;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Welcome back, ${widget.teacherName}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.ink),
          ),
          const SizedBox(height: 4),
          Text(
            "Here's what's happening across your classes.",
            style: TextStyle(color: AppTheme.ink.withValues(alpha: .6)),
          ),
          const SizedBox(height: 20),

          // ---- Stats grid ----
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: [
              _StatCard(
                icon: Icons.assignment_outlined,
                label: 'Assignments',
                value: '$totalAssignments',
                color: AppTheme.primary,
              ),
              _StatCard(
                icon: Icons.fact_check_outlined,
                label: 'Submission Rate',
                value: '$submissionRate%',
                color: AppTheme.accent,
              ),
              _StatCard(
                icon: Icons.lightbulb_outline,
                label: 'Suggestions to Review',
                value: '$pendingSuggestions',
                color: AppTheme.warning,
              ),
              _StatCard(
                icon: Icons.mic_none_rounded,
                label: 'Open Voice Reports',
                value: '$openVoiceReports',
                color: AppTheme.success,
              ),
              _StatCard(
                icon: Icons.event_available_outlined,
                label: 'Upcoming Events',
                value: '$upcomingEvents',
                color: AppTheme.primary,
              ),
              _StatCard(
                icon: Icons.menu_book_outlined,
                label: 'Shared Resources',
                value: '${db.resources.length}',
                color: AppTheme.accent,
              ),
            ],
          ),

          const SizedBox(height: 24),
          const Text('Teacher Tools', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.ink)),
          const SizedBox(height: 12),

          _ToolTile(
            icon: Icons.dynamic_feed_rounded,
            title: 'Class Feed',
            subtitle: 'Post announcements and join class discussions',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ClassFeedScreen(
                  currentUser: AppUser(
                    name: widget.teacherName,
                    password: '',
                    role: 'Teacher',
                  ),
                ),
              ),
            ),
          ),
          _ToolTile(
            icon: Icons.task_alt,
            title: 'Assignment Manager',
            subtitle: 'Create, publish, and track submissions',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AssignmentManagerScreen()),
            ),
          ),
          _ToolTile(
            icon: Icons.folder_shared_outlined,
            title: 'Resource Manager',
            subtitle: 'Share notes, slides, and videos with students',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ResourceManagerScreen()),
            ),
          ),
          _ToolTile(
            icon: Icons.lightbulb_outline,
            title: 'Suggestion Review',
            subtitle: 'Approve or move student suggestions forward',
            trailingBadge: pendingSuggestions > 0 ? pendingSuggestions : null,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SuggestionReviewScreen()),
            ),
          ),
          _ToolTile(
            icon: Icons.record_voice_over_outlined,
            title: 'Student Voice Reports',
            subtitle: 'Review anonymous reports and update their status',
            trailingBadge: openVoiceReports > 0 ? openVoiceReports : null,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const VoiceReportReviewScreen()),
            ),
          ),

          const SizedBox(height: 24),
          const Text('Recent Assignments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.ink)),
          const SizedBox(height: 12),
          if (db.assignments.isEmpty)
            const Text('No assignments yet.')
          else
            ...db.assignments.take(3).map(
                  (a) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primary.withValues(alpha: .15),
                        child: const Icon(Icons.assignment, color: Colors.white),
                      ),
                      title: Text(a.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text('${a.subject} • ${a.submittedCount}/${a.totalStudents} submitted'),
                      trailing: _StatusChip(status: a.status),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 22),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final int? trailingBadge;

  const _ToolTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailingBadge,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(backgroundColor: primary.withOpacity(0.15), child: Icon(icon, color: primary)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: trailingBadge != null
            ? CircleAvatar(
                radius: 12,
                backgroundColor: Colors.redAccent,
                child: Text('$trailingBadge', style: const TextStyle(color: Colors.white, fontSize: 11)),
              )
            : const Icon(Icons.chevron_right),
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
