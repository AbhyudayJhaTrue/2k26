import 'package:flutter/material.dart';
import '../../models/assignment.dart';
import '../../theme/app_theme.dart';

class AssignmentScreen extends StatefulWidget {
  final List<Assignment> assignments;

  const AssignmentScreen({super.key, required this.assignments});

  @override
  State<AssignmentScreen> createState() => _AssignmentScreenState();
}

class _AssignmentScreenState extends State<AssignmentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  late List<Assignment> _assignments;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _assignments = List.of(widget.assignments);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Assignment> get pending =>
      _assignments.where((a) => a.status == 'pending').toList();
  List<Assignment> get submitted =>
      _assignments.where((a) => a.status == 'submitted').toList();
  List<Assignment> get graded =>
      _assignments.where((a) => a.status == 'graded').toList();

  void _markAsSubmitted(Assignment a) {
    setState(() {
      final index = _assignments.indexOf(a);
      _assignments[index] = Assignment(
        id: a.id,
        title: a.title,
        subject: a.subject,
        dueDate: a.dueDate,
        status: 'submitted',
        description: a.description,
        grade: a.grade,
        feedback: a.feedback,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = _assignments.length;
    final gradedCount = graded.length;
    final submittedCount = submitted.length;
    final pendingCount = pending.length;
    final completionPercent = total == 0
        ? '0'
        : ((gradedCount + submittedCount) / total * 100).toStringAsFixed(0);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            floating: false,
            backgroundColor: const Color(0xFF00B894),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF00B894), Color(0xFF2D3436)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40),
                        const Text(
                          'My Assignments',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Assignments overview',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _statChip('📝 $pendingCount Pending', Colors.orange),
                            const SizedBox(width: 8),
                            _statChip('📤 $submittedCount Submitted', Colors.blue),
                            const SizedBox(width: 8),
                            _statChip('✅ $gradedCount Graded', Colors.green),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              tabs: [
                Tab(text: 'Pending ($pendingCount)'),
                Tab(text: 'Submitted ($submittedCount)'),
                Tab(text: 'Graded ($gradedCount)'),
              ],
            ),
          ),
        ],
        body: Column(
          children: [
            // ── PROGRESS SECTION ──────────────────────────
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Row(
                children: [
                  // Circular progress
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: total == 0
                              ? 0
                              : (gradedCount + submittedCount) / total,
                          strokeWidth: 8,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF00B894)),
                        ),
                        Center(
                          child: Text(
                            '$completionPercent%',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3436),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Overall Progress',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF2D3436),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${gradedCount + submittedCount} of $total assignments completed',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF636E72),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: total == 0
                                ? 0
                                : (gradedCount + submittedCount) / total,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFF00B894)),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── TABS CONTENT ──────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildList(pending, isPending: true),
                  _buildList(submitted),
                  _buildList(graded, isGraded: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<Assignment> list,
      {bool isPending = false, bool isGraded = false}) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            const Text(
              'Nothing here!',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF636E72),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final a = list[index];
        return _assignmentCard(a, isPending: isPending, isGraded: isGraded);
      },
    );
  }

  Widget _assignmentCard(Assignment a,
      {bool isPending = false, bool isGraded = false}) {
    final daysLeft = a.dueDate.difference(DateTime.now()).inDays;
    final isUrgent = daysLeft <= 1 && isPending;

    final subjectColors = {
      'English': const Color(0xFF6C5CE7),
      'Mathematics': const Color(0xFF0984E3),
      'Physics': const Color(0xFFE17055),
      'Biology': const Color(0xFF00B894),
      'History': const Color(0xFFFDCB6E),
      'Computer Science': const Color(0xFF00CEC9),
      'Chemistry': const Color(0xFFE84393),
    };

    final color = subjectColors[a.subject] ?? const Color(0xFF00B894);

    return GestureDetector(
      onTap: () => _openDetail(a, isPending: isPending),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          children: [
            // Top color bar
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: color,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Subject chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: color.withValues(alpha: .1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          a.subject,
                          style: TextStyle(
                            fontSize: 11,
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      // Status chip
                      _statusChip(a.status),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    a.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    a.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF636E72),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 13,
                            color:
                                isUrgent ? Colors.red : const Color(0xFF636E72),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isPending
                                ? (daysLeft < 0
                                    ? 'Overdue!'
                                    : daysLeft == 0
                                        ? 'Due Today!'
                                        : 'Due in $daysLeft days')
                                : 'Due: ${a.dueDate.day}/${a.dueDate.month}/${a.dueDate.year}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isUrgent
                                  ? Colors.red
                                  : const Color(0xFF636E72),
                              fontWeight: isUrgent
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      if (isGraded && a.grade != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: .1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Grade: ${a.grade}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF00B894),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (isPending)
                        GestureDetector(
                          onTap: () => _markAsSubmitted(a),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF00B894),
                                  Color(0xFF00CEC9),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Submit ✓',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDetail(Assignment a, {bool isPending = false}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.all(24),
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Title
              Text(
                a.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3436),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _statusChip(a.status),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00B894).withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      a.subject,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF00B894),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _detailRow('📅 Due Date',
                  '${a.dueDate.day}/${a.dueDate.month}/${a.dueDate.year}'),
              const SizedBox(height: 12),
              _detailSection('📋 Description', a.description),
              if (a.grade != null) ...[
                const SizedBox(height: 12),
                _detailRow('🏆 Grade', a.grade!),
              ],
              if (a.feedback != null) ...[
                const SizedBox(height: 12),
                _detailSection('💬 Teacher Feedback', a.feedback!),
              ],
              const SizedBox(height: 24),
              if (isPending)
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _markAsSubmitted(a);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00B894), Color(0xFF00CEC9)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Text(
                        '✓ Mark as Submitted',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3436),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF636E72),
          ),
        ),
      ],
    );
  }

  Widget _detailSection(String label, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3436),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F6FA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            content,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF636E72),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _statusChip(String status) {
    final colors = {
      'pending': Colors.orange,
      'submitted': Colors.blue,
      'graded': Colors.green,
    };
    final labels = {
      'pending': '⏳ Pending',
      'submitted': '📤 Submitted',
      'graded': '✅ Graded',
    };
    final color = colors[status] ?? Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        labels[status] ?? status,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _statChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}