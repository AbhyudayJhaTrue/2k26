import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/assignment.dart';
import '../../models/student.dart';
import '../../models/calendar_event.dart';
import '../../models/discovery_quest.dart';
import '../../models/class_feed_post.dart';
import '../../user_database.dart' hide Assignment;
import '../teacher_admin_shell.dart';
import 'assignment_screen.dart';
import 'student_voice_screen.dart';
import 'suggestion_hub.dart';
import 'discovery_quest_screen.dart';
import 'campus_chat_screen.dart';
import 'research_hub_screen.dart';
import '../class_feed_screen.dart';
import 'notices_and_calendar_screen.dart';

class StudentDashboard extends StatelessWidget {
  final String studentName;

  const StudentDashboard({super.key, required this.studentName});

  // ---------------------------------------------------------------------
  // Sample content shown on the dashboard.
  // The only thing pulled from the real login database is the student's
  // name. Everything else here (grade, XP, assignments, events, quests,
  // announcements) is placeholder content for the demo — swap it out for
  // real data once you have a backend for it.
  // ---------------------------------------------------------------------

  Student get _student => Student(
        name: studentName,
        grade: 'Grade 10',
        className: 'Class B',
        avatarInitials: _initialsFrom(studentName),
        xp: 1240,
        badges: const ['Explorer', 'Team Player', 'Top Scorer'],
      );

  String _initialsFrom(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    final first = parts.first[0];
    final second = parts.length > 1 && parts.last.isNotEmpty ? parts.last[0] : '';
    return (first + second).toUpperCase();
  }

  List<Assignment> get _assignments => [
        Assignment(
          id: 'a1',
          title: 'Algebra Worksheet 5',
          subject: 'Mathematics',
          dueDate: DateTime.now().add(const Duration(days: 1)),
          status: 'pending',
          description: 'Complete questions 1-20 covering quadratic equations.',
        ),
        Assignment(
          id: 'a2',
          title: 'Lab Report: Photosynthesis',
          subject: 'Biology',
          dueDate: DateTime.now().add(const Duration(days: 3)),
          status: 'pending',
          description: 'Write up your findings from the photosynthesis experiment.',
        ),
        Assignment(
          id: 'a3',
          title: 'Essay: Industrial Revolution',
          subject: 'History',
          dueDate: DateTime.now().add(const Duration(days: 5)),
          status: 'pending',
          description: 'A 1000-word essay on the causes of the Industrial Revolution.',
        ),
        Assignment(
          id: 'a4',
          title: 'Chemistry Lab Safety Quiz',
          subject: 'Chemistry',
          dueDate: DateTime.now().subtract(const Duration(days: 2)),
          status: 'submitted',
          description: 'Short quiz on lab safety procedures, submitted last week.',
        ),
        Assignment(
          id: 'a5',
          title: 'Short Story: A Journey',
          subject: 'English',
          dueDate: DateTime.now().subtract(const Duration(days: 6)),
          status: 'graded',
          description: 'Creative writing piece on the theme of a journey.',
          grade: 'A-',
          feedback: 'Vivid imagery and strong pacing — great work!',
        ),
        Assignment(
          id: 'a6',
          title: 'Loops & Functions Exercise',
          subject: 'Computer Science',
          dueDate: DateTime.now().subtract(const Duration(days: 9)),
          status: 'graded',
          description: 'Practice exercises on loops and functions in Python.',
          grade: 'B+',
          feedback: 'Good logic, but watch your edge cases next time.',
        ),
      ];

  List<CalendarEvent> get _calendarEvents => [
        CalendarEvent(
          title: 'Mid-Term Exams Begin',
          type: 'exam',
          date: DateTime.now().add(const Duration(days: 4)),
        ),
        CalendarEvent(
          title: 'Sports Day',
          type: 'sports',
          date: DateTime.now().add(const Duration(days: 7)),
        ),
        CalendarEvent(
          title: 'Founders Day Holiday',
          type: 'holiday',
          date: DateTime.now().add(const Duration(days: 10)),
        ),
      ];

  List<DiscoveryQuest> get _discoveryQuests => UserDatabase.discoveryQuests;

  List<ClassFeedPost> get _classFeedPosts => const [
        ClassFeedPost(
          authorName: 'Mr. Anderson',
          content:
              'Reminder: mid-term exams start next week. Please check the syllabus and revise chapters 1-6.',
          isPinned: true,
        ),
        ClassFeedPost(
          authorName: 'Ms. Lee',
          content: 'Great job on the group projects, everyone! Results will be shared soon.',
          isPinned: false,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final student = _student;
    final assignments = _assignments;
    final pendingAssignments = assignments.where((a) => a.status == 'pending').toList();
    final upcomingEvents = _calendarEvents.take(3).toList();

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good morning, ${student.name}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${student.grade} • ${student.className}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _xpChip('⚡ ${student.xp} XP'),
                    const SizedBox(width: 8),
                    _xpChip('🏆 ${student.badges.length} Badges'),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CampusChatScreen()),
                    ),
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text('Open Campus Chat'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _sectionTitle('Quick Actions'),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.05,
            children: [
              _quickAction(context, '📚', 'Assignments', () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AssignmentScreen(assignments: assignments),
                  ),
                );
              }),
              _quickAction(context, '🏫', 'Campus Map', () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const CampusMapScreen()),
                );
              }),
              _quickAction(context, '💡', 'Suggestions', () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const SuggestionHubScreen()),
                );
              }),
              _quickAction(context, '🎤', 'Student Voice', () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const StudentVoiceScreen()),
                );
              }),
              _quickAction(context, '🔬', 'Research', () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ResearchHubScreen()),
                );
              }),
              _quickAction(context, '🏆', 'Quests', () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => DiscoveryQuestScreen(currentUserName: studentName),
                  ),
                );
              }),
              _quickAction(context, '💬', 'Chat', () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const CampusChatScreen()),
                );
              }),
              _quickAction(context, '📢', 'Feed', () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ClassFeedScreen(
                      currentUser: AppUser(
                        name: studentName,
                        password: '',
                        role: 'Student',
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 24),
          _sectionTitle('My Report Card'),
          const SizedBox(height: 12),
          _reportCardSummary(context, student, assignments),
          const SizedBox(height: 24),
          _sectionTitle('Campus Map'),
          const SizedBox(height: 12),
          _campusMapCard(context),
          const SizedBox(height: 24),
          _sectionTitle('Pending Assignments'),
          const SizedBox(height: 12),
          ...pendingAssignments.map((a) => _assignmentCard(a)),
          const SizedBox(height: 24),
          _sectionTitle('Discovery Quest Progress'),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => DiscoveryQuestScreen(currentUserName: studentName),
              ),
            ),
            child: _questProgressCard(),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionTitle('Upcoming Events'),
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SchoolCalendarScreen()),
                ),
                child: Text('See all', style: TextStyle(fontSize: 12, color: AppTheme.primary, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...upcomingEvents.map((e) => _eventCard(e.title, e.type, e.date)),
          const SizedBox(height: 24),
          _sectionTitle('Latest Announcement'),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ClassFeedScreen(
                  currentUser: AppUser(
                    name: studentName,
                    password: '',
                    role: 'Student',
                  ),
                ),
              ),
            ),
            child: _announcementCard(),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ─── WIDGETS ──────────────────────────────────────────────

  Widget _xpChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primary.withValues(alpha: .12)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _reportCardSummary(BuildContext context, Student student, List<Assignment> assignments) {
    final graded = assignments.where((a) => a.grade != null).toList();
    final overall = _computeOverallGrade(graded);
    final recentSubjects = graded.take(3)
        .map((a) => '${a.subject}: ${a.grade}')
        .toList();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Report Card Snapshot',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Your latest progress and grades in one place.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      overall,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Overall grade',
                      style: TextStyle(fontSize: 11, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (recentSubjects.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: recentSubjects.map((subject) => _detailChip(subject)).toList(),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              _detailChip('Attendance: 97%'),
              const SizedBox(width: 8),
              _detailChip('${graded.length} graded subjects'),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => MyReportCardScreen(student: student.name),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('View full report card'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _campusMapCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Campus Map',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Tap to explore the interactive campus map with zoom and plot details.',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CampusMapScreen()),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              minimumSize: const Size(130, 44),
            ),
            child: const Text('Open map'),
          ),
        ],
      ),
    );
  }

  String _computeOverallGrade(List<Assignment> graded) {
    if (graded.isEmpty) return 'N/A';
    final total = graded
        .map((a) => _gradeValue(a.grade!))
        .fold<double>(0, (sum, value) => sum + value);
    return _gradeLetter(total / graded.length);
  }

  double _gradeValue(String grade) {
    const values = {
      'A+': 98.0,
      'A': 95.0,
      'A-': 91.0,
      'B+': 88.0,
      'B': 84.0,
      'B-': 80.0,
      'C+': 77.0,
      'C': 73.0,
      'C-': 70.0,
      'D': 65.0,
      'F': 50.0,
    };
    return values[grade] ?? 75.0;
  }

  String _gradeLetter(double score) {
    if (score >= 94) return 'A+';
    if (score >= 90) return 'A';
    if (score >= 86) return 'A-';
    if (score >= 82) return 'B+';
    if (score >= 78) return 'B';
    if (score >= 74) return 'B-';
    if (score >= 70) return 'C+';
    return 'C';
  }

  Widget _detailChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.black87),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _quickAction(BuildContext context, String emoji, String label, VoidCallback onTap) {
    return HoverScale(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppTheme.cardShadow,
        ),
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.muted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _assignmentCard(Assignment a) {
    final isUrgent = a.dueDate.difference(DateTime.now()).inDays <= 1;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: isUrgent ? Colors.red : const Color(0xFF00B894),
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: const Color(0xFF2D3436),
                  ),
                ),
                Text(
                  a.subject,
                  style: TextStyle(
                    fontSize: 11,
                    color: const Color(0xFF636E72),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isUrgent ? Colors.red.shade50 : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isUrgent ? '⚠️ Due Tomorrow' : 'Due in ${a.dueDate.difference(DateTime.now()).inDays}d',
                  style: TextStyle(
                    fontSize: 10,
                    color: isUrgent ? Colors.red : Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _questProgressCard() {
    final quests = _discoveryQuests;
    final completed = quests.where((q) => q.completed).length;
    final total = quests.length;
    final progress = total > 0 ? completed / total : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '🏆 Discovery Quests',
                style: TextStyle(
                  color: AppTheme.card,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Text(
                '$completed/$total Complete',
                style: TextStyle(
                  color: AppTheme.card.withValues(alpha: .75),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.toDouble(),
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '⚡ ${_student.xp} XP Earned',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _eventCard(String title, String type, DateTime date) {
    final icons = {
      'exam': '📝',
      'holiday': '🎉',
      'sports': '⚽',
      'event': '🌟',
      'club': '👥',
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(icons[type] ?? '📅', style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: const Color(0xFF2D3436),
              ),
            ),
          ),
          Text(
            '${date.day}/${date.month}',
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFF00B894),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _announcementCard() {
    final post = _classFeedPosts.firstWhere((p) => p.isPinned);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.success.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 14,
                backgroundColor: Color(0xFF00B894),
                child: Text('T', style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
              const SizedBox(width: 8),
              Text(
                post.authorName,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: const Color(0xFF2D3436),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF00B894).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '📌 Pinned',
                  style: TextStyle(
                    fontSize: 9,
                    color: const Color(0xFF00B894),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            post.content,
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFF636E72),
            ),
          ),
        ],
      ),
    );
  }
}