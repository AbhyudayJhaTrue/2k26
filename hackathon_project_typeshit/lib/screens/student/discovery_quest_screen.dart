import 'dart:math' as math;


import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


import '../../user_database.dart';
import '../../models/discovery_quest.dart';


/// A polished, self-contained Discovery Quest screen.
///
/// This is compatible with the existing [DiscoveryQuest] and [QuestTask]
/// models. Completion is held locally by this screen, so it never mutates
/// `DummyData` or unexpectedly changes another screen using that same data.
class DiscoveryQuestScreen extends StatefulWidget {
  final String? currentUserName;
  const DiscoveryQuestScreen({super.key, this.currentUserName});


  @override
  State<DiscoveryQuestScreen> createState() => _DiscoveryQuestScreenState();
}


enum QuestDifficulty { easy, medium, hard }


extension QuestDifficultyDetails on QuestDifficulty {
  String get label => switch (this) {
        QuestDifficulty.easy => 'Easy',
        QuestDifficulty.medium => 'Medium',
        QuestDifficulty.hard => 'Hard',
      };


  Color get color => switch (this) {
        QuestDifficulty.easy => const Color(0xFF00B894),
        QuestDifficulty.medium => const Color(0xFFF39C12),
        QuestDifficulty.hard => const Color(0xFFE17055),
      };


  IconData get icon => switch (this) {
        QuestDifficulty.easy => Icons.sentiment_satisfied_alt_outlined,
        QuestDifficulty.medium => Icons.bolt_outlined,
        QuestDifficulty.hard => Icons.local_fire_department_outlined,
      };
}


class QuestMetadata {
  const QuestMetadata({
    required this.difficulty,
    required this.estimatedMinutes,
    required this.daysUntilDeadline,
    required this.categoryIcon,
    required this.categoryLabel,
    required this.avatarReward,
  });


  final QuestDifficulty difficulty;
  final int estimatedMinutes;
  final int daysUntilDeadline;
  final IconData categoryIcon;
  final String categoryLabel;
  final String avatarReward;


  String get estimatedTime {
    if (estimatedMinutes >= 60) {
      final hours = estimatedMinutes ~/ 60;
      final minutes = estimatedMinutes % 60;
      return minutes == 0 ? '$hours hr' : '$hours hr $minutes min';
    }
    return '$estimatedMinutes min';
  }


  String deadlineLabel({required bool completed}) {
    if (completed) return 'Completed';
    if (daysUntilDeadline <= 0) return 'Ends today';
    if (daysUntilDeadline == 1) return 'Ends tomorrow';
    return 'Due in $daysUntilDeadline days';
  }


  Color deadlineColor({required bool completed}) {
    if (completed) return const Color(0xFF00B894);
    if (daysUntilDeadline <= 1) return const Color(0xFFE17055);
    if (daysUntilDeadline <= 3) return const Color(0xFFF39C12);
    return const Color(0xFF0984E3);
  }
}


class LeaderboardEntry {
  const LeaderboardEntry({
    required this.name,
    required this.initials,
    required this.xp,
    required this.badges,
    required this.rankChange,
    required this.weeklyXp,
    this.isCurrentUser = false,
  });


  final String name;
  final String initials;
  final int xp;
  final int badges;
  final int rankChange;
  final int weeklyXp;
  final bool isCurrentUser;
}


class _DiscoveryQuestScreenState extends State<DiscoveryQuestScreen>
    with SingleTickerProviderStateMixin {
  static const _primary = Color(0xFF6C5CE7);
  static const _ink = Color(0xFF2D3436);
  static const _muted = Color(0xFF636E72);
  static const _success = Color(0xFF00B894);
  static const _surface = Color(0xFFF5F6FA);


  late final TabController _tabController;
  late final ConfettiController _confettiController;
  late final List<DiscoveryQuest> _quests;
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _completedTaskIds = <String>{};


  int _xp = 1250;
  int _weeklyXp = 120;
  final int _streakDays = 7;
  String _selectedFilter = 'All';


  static const List<String> _filters = <String>[
    'All',
    'Active',
    'Completed',
    'Easy',
    'Medium',
    'Hard',
  ];


  static const Map<String, QuestMetadata> _subjectMetadata =
      <String, QuestMetadata>{
    'Geography': QuestMetadata(
      difficulty: QuestDifficulty.easy,
      estimatedMinutes: 15,
      daysUntilDeadline: 3,
      categoryIcon: Icons.public_outlined,
      categoryLabel: 'Geography',
      avatarReward: 'Explorer avatar',
    ),
    'History': QuestMetadata(
      difficulty: QuestDifficulty.medium,
      estimatedMinutes: 45,
      daysUntilDeadline: 1,
      categoryIcon: Icons.menu_book_outlined,
      categoryLabel: 'Reading',
      avatarReward: 'Historian avatar',
    ),
    'Computer Science': QuestMetadata(
      difficulty: QuestDifficulty.hard,
      estimatedMinutes: 120,
      daysUntilDeadline: 2,
      categoryIcon: Icons.code_outlined,
      categoryLabel: 'Coding',
      avatarReward: 'Code wizard avatar',
    ),
    'Biology': QuestMetadata(
      difficulty: QuestDifficulty.medium,
      estimatedMinutes: 45,
      daysUntilDeadline: 4,
      categoryIcon: Icons.science_outlined,
      categoryLabel: 'Science',
      avatarReward: 'Lab expert avatar',
    ),
    'Physics': QuestMetadata(
      difficulty: QuestDifficulty.hard,
      estimatedMinutes: 120,
      daysUntilDeadline: 0,
      categoryIcon: Icons.rocket_launch_outlined,
      categoryLabel: 'Science',
      avatarReward: 'Rocket avatar',
    ),
    'Mathematics': QuestMetadata(
      difficulty: QuestDifficulty.medium,
      estimatedMinutes: 45,
      daysUntilDeadline: 3,
      categoryIcon: Icons.functions_outlined,
      categoryLabel: 'Maths',
      avatarReward: 'Problem solver avatar',
    ),
  };


  static const QuestMetadata _fallbackMetadata = QuestMetadata(
    difficulty: QuestDifficulty.medium,
    estimatedMinutes: 45,
    daysUntilDeadline: 3,
    categoryIcon: Icons.auto_awesome_outlined,
    categoryLabel: 'Discovery',
    avatarReward: 'Trailblazer avatar',
  );


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _quests = List<DiscoveryQuest>.unmodifiable(UserDatabase.discoveryQuests);


    // Respect any tasks already marked complete in dummy/loaded data while
    // ensuring a completed quest is displayed consistently.
    for (final quest in _quests) {
      for (var index = 0; index < quest.tasks.length; index++) {
        if (quest.completed || quest.tasks[index].completed) {
          _completedTaskIds.add(_taskId(quest, index));
        }
      }
    }
  }


  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    _confettiController.dispose();
    super.dispose();
  }


  String get _levelLabel => switch (_levelNumber) {
        1 => 'Beginner Researcher',
        2 => 'Junior Researcher',
        3 => 'Advanced Researcher',
        4 => 'Expert Researcher',
        _ => 'Master Researcher',
      };


  int get _levelNumber {
    if (_xp >= 1500) return 5;
    if (_xp >= 1200) return 4;
    if (_xp >= 900) return 3;
    if (_xp >= 600) return 2;
    return 1;
  }


  int get _currentLevelStart => switch (_levelNumber) {
        1 => 0,
        2 => 600,
        3 => 900,
        4 => 1200,
        _ => 1500,
      };


  int? get _nextLevelXp => switch (_levelNumber) {
        1 => 600,
        2 => 900,
        3 => 1200,
        4 => 1500,
        _ => null,
      };


  int get _xpToNextLevel {
    final next = _nextLevelXp;
    return next == null ? 0 : math.max(0, next - _xp);
  }


  double get _levelProgress {
    final next = _nextLevelXp;
    if (next == null) return 1;
    return ((_xp - _currentLevelStart) / (next - _currentLevelStart))
        .clamp(0.0, 1.0);
  }


  int get _completedQuestCount =>
      _quests.where(_isQuestCompleted).length;


  int get _completedTaskCount => _quests.fold<int>(
        0,
        (total, quest) =>
            total + _completedTaskCountForQuest(quest),
      );


  List<String> get _earnedBadges => _quests
      .where(_isQuestCompleted)
      .map((quest) => quest.badge)
      .toList(growable: false);


  String _taskId(DiscoveryQuest quest, int taskIndex) =>
      '${quest.title}::$taskIndex';


  bool _isTaskCompleted(DiscoveryQuest quest, int taskIndex) =>
      quest.completed ||
      quest.tasks[taskIndex].completed ||
      _completedTaskIds.contains(_taskId(quest, taskIndex));


  bool _isQuestCompleted(DiscoveryQuest quest) {
    if (quest.completed) return true;
    if (quest.tasks.isEmpty) return false;
    return List<bool>.generate(
      quest.tasks.length,
      (index) => _isTaskCompleted(quest, index),
    ).every((completed) => completed);
  }


  int _completedTaskCountForQuest(DiscoveryQuest quest) {
    return List<bool>.generate(
      quest.tasks.length,
      (index) => _isTaskCompleted(quest, index),
    ).where((completed) => completed).length;
  }


  double _questProgress(DiscoveryQuest quest) {
    if (quest.tasks.isEmpty) return 0;
    return _completedTaskCountForQuest(quest) / quest.tasks.length;
  }


  /// Splits quest XP exactly. The first few tasks receive any remainder,
  /// so a 100 XP quest with 3 tasks always awards 100 XP—not 99 or 102.
  int _xpForTask(DiscoveryQuest quest, int taskIndex) {
    if (quest.tasks.isEmpty) return 0;
    final baseReward = quest.xpReward ~/ quest.tasks.length;
    final remainder = quest.xpReward % quest.tasks.length;
    return baseReward + (taskIndex < remainder ? 1 : 0);
  }


  QuestMetadata _metadataFor(DiscoveryQuest quest) =>
      _subjectMetadata[quest.subject] ?? _fallbackMetadata;


  Color _subjectColor(DiscoveryQuest quest) {
    return switch (quest.subject) {
      'Geography' => const Color(0xFF00B894),
      'History' => const Color(0xFFF39C12),
      'Computer Science' => const Color(0xFF00CEC9),
      'Biology' => const Color(0xFF27AE60),
      'Physics' => const Color(0xFFE17055),
      'Mathematics' => const Color(0xFF0984E3),
      _ => _primary,
    };
  }


  List<DiscoveryQuest> get _filteredQuests {
    final query = _searchController.text.trim().toLowerCase();
    return _quests.where((quest) {
      final metadata = _metadataFor(quest);
      final isCompleted = _isQuestCompleted(quest);
      final matchesQuery = query.isEmpty ||
          '${quest.title} ${quest.description} ${quest.subject} '
                  '${metadata.categoryLabel} ${metadata.difficulty.label}'
              .toLowerCase()
              .contains(query);
      final matchesFilter = switch (_selectedFilter) {
        'Active' => !isCompleted,
        'Completed' => isCompleted,
        'Easy' => metadata.difficulty == QuestDifficulty.easy,
        'Medium' => metadata.difficulty == QuestDifficulty.medium,
        'Hard' => metadata.difficulty == QuestDifficulty.hard,
        _ => true,
      };
      return matchesQuery && matchesFilter;
    }).toList(growable: false);
  }


  List<LeaderboardEntry> get _leaderboard {
    final students = kUserDatabase.where((user) => user.role == 'Student').toList();
    final current = widget.currentUserName?.trim();

    // sample order and fallback values used for demo leaderboard
    final names = <String>['Pranav', 'Adhvik', 'Aanya', 'Abhyudhay', 'Kushagr', 'Rohan'];
    if (current != null && current.isNotEmpty && !names.contains(current)) {
      names.insert(0, current);
    }

    final sampleXp = {
      'Pranav': _xp,
      'Adhvik': 1100,
      'Aanya': 1050,
      'Abhyudhay': 980,
      'Kushagr': 870,
      'Rohan': 760,
    };
    final sampleWeekly = {
      'Pranav': _weeklyXp,
      'Adhvik': 90,
      'Aanya': 75,
      'Abhyudhay': 60,
      'Kushagr': 40,
      'Rohan': 35,
    };
    final sampleBadges = {
      'Pranav': _earnedBadges.length,
      'Adhvik': 2,
      'Aanya': 2,
      'Abhyudhay': 2,
      'Kushagr': 1,
      'Rohan': 1,
    };
    final sampleRankChange = {
      'Pranav': 0,
      'Adhvik': 1,
      'Aanya': -1,
      'Abhyudhay': 1,
      'Kushagr': 0,
      'Rohan': -1,
    };

    final entries = <LeaderboardEntry>[];
    for (final name in names.take(6)) {
      final isCurrent = current != null && name == current;
      entries.add(LeaderboardEntry(
        name: students.firstWhere((user) => user.name == name, orElse: () => students.first).name,
        initials: _initials(name),
        xp: isCurrent ? _xp : (sampleXp[name] ?? 500),
        badges: sampleBadges[name] ?? 1,
        rankChange: sampleRankChange[name] ?? 0,
        weeklyXp: isCurrent ? _weeklyXp : (sampleWeekly[name] ?? 30),
        isCurrentUser: isCurrent,
      ));
    }

    entries.sort((a, b) => b.xp.compareTo(a.xp));
    return entries;
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.map((part) => part.isEmpty ? '' : part[0]).where((ch) => ch.isNotEmpty).take(2).join().toUpperCase();
  }

  void _showAccountDetails(LeaderboardEntry entry) {
    final account = kUserDatabase.firstWhere(
      (user) => user.name.toLowerCase() == entry.name.toLowerCase(),
      orElse: () => AppUser(name: entry.name, password: '', role: 'Student'),
    );

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          '${entry.name} Profile',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${account.name}', style: GoogleFonts.poppins(fontSize: 14)),
            const SizedBox(height: 8),
            Text('Role: ${account.role}', style: GoogleFonts.poppins(fontSize: 14)),
            const SizedBox(height: 8),
            Text('XP: ${entry.xp}', style: GoogleFonts.poppins(fontSize: 14)),
            const SizedBox(height: 8),
            Text('Weekly XP: ${entry.weeklyXp}', style: GoogleFonts.poppins(fontSize: 14)),
            const SizedBox(height: 8),
            Text('Badges: ${entry.badges}', style: GoogleFonts.poppins(fontSize: 14)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }


  void _confirmTask(DiscoveryQuest quest, int taskIndex) {
    if (_isTaskCompleted(quest, taskIndex)) return;
    final task = quest.tasks[taskIndex];
    final xpGain = _xpForTask(quest, taskIndex);
    final metadata = _metadataFor(quest);


    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Complete task?',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: _ink),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.description,
              style: GoogleFonts.poppins(fontSize: 13, color: _muted),
            ),
            const SizedBox(height: 16),
            _infoPanel(
              icon: Icons.bolt_rounded,
              color: _success,
              child: Text(
                '+$xpGain XP will be added',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _success,
                ),
              ),
            ),
            const SizedBox(height: 8),
            _infoPanel(
              icon: metadata.difficulty.icon,
              color: metadata.difficulty.color,
              child: Text(
                '${metadata.difficulty.label} quest · ${metadata.estimatedTime}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: metadata.difficulty.color,
                ),
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Not yet'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _completeTask(quest, taskIndex);
            },
            icon: const Icon(Icons.check_rounded),
            label: const Text('Complete'),
            style: FilledButton.styleFrom(
              backgroundColor: _success,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }


  Widget _infoPanel({
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(child: child),
        ],
      ),
    );
  }


  void _completeTask(DiscoveryQuest quest, int taskIndex) {
    if (!mounted || _isTaskCompleted(quest, taskIndex)) return;


    final xpGain = _xpForTask(quest, taskIndex);
    final wasQuestCompleted = _isQuestCompleted(quest);
    setState(() {
      _completedTaskIds.add(_taskId(quest, taskIndex));
      _xp += xpGain;
      _weeklyXp += xpGain;
    });


    final questCompletedNow = !wasQuestCompleted && _isQuestCompleted(quest);
    if (questCompletedNow) {
      _showQuestComplete(quest);
      return;
    }


    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: _success,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Text(
            '+$xpGain XP earned — nice work!',
            style: GoogleFonts.poppins(fontSize: 12),
          ),
        ),
      );
  }


  void _showQuestComplete(DiscoveryQuest quest) {
    _confettiController.play();
    final metadata = _metadataFor(quest);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 12),
            Text(
              'Quest complete!',
              style: GoogleFonts.poppins(
                color: _ink,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              quest.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 13, color: _muted),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: <Color>[_success, Color(0xFF00CEC9)],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  Text(quest.badge, style: const TextStyle(fontSize: 36)),
                  const SizedBox(height: 6),
                  Text(
                    'Badge earned!',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '+${quest.xpReward} XP · ${metadata.avatarReward}',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: _ink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
                child: const Text('Awesome!'),
              ),
            ),
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      body: Stack(
        children: [
          NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) =>
                <Widget>[_buildAppBar(context)],
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildQuestList(),
                _buildLeaderboard(),
                _buildBadges(),
                _buildProgress(),
              ],
            ),
          ),
          IgnorePointer(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const <Color>[
                  _success,
                  Color(0xFF00CEC9),
                  _primary,
                  Colors.orange,
                  Colors.pink,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  SliverAppBar _buildAppBar(BuildContext context) {
    final canGoBack = Navigator.of(context).canPop();
    final nextLevel = _nextLevelXp;
    final percentage = (_levelProgress * 100).round();


    return SliverAppBar(
      expandedHeight: 270,
      pinned: true,
      backgroundColor: _primary,
      leading: IconButton(
        tooltip: 'Back',
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: canGoBack ? () => Navigator.of(context).maybePop() : null,
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[_primary, _ink],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🏆 Discovery Quest',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Level $_levelNumber · $_levelLabel',
                    style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Semantics(
                        label: 'Level $_levelNumber, $percentage percent complete',
                        child: SizedBox(
                          width: 68,
                          height: 68,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CircularProgressIndicator(
                                value: _levelProgress,
                                strokeWidth: 6,
                                backgroundColor: Colors.white24,
                                valueColor:
                                    const AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                              Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'L$_levelNumber',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '$percentage%',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white70,
                                        fontSize: 9,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$_xp XP',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: _levelProgress,
                                backgroundColor: Colors.white24,
                                valueColor:
                                    const AlwaysStoppedAnimation<Color>(Colors.white),
                                minHeight: 8,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              nextLevel == null
                                  ? 'You have reached the highest level!'
                                  : '$_xpToNextLevel XP until Level ${_levelNumber + 1}',
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Semantics(
                    label: '$_streakDays day learning streak',
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Text(
                        '🔥 $_streakDays Day Streak · Keep it going!',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottom: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        indicatorColor: Colors.white,
        indicatorWeight: 3,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white60,
        labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12),
        tabs: const <Widget>[
          Tab(text: 'Quests'),
          Tab(text: 'Leaderboard'),
          Tab(text: 'Badges'),
          Tab(text: 'Progress'),
        ],
      ),
    );
  }


  Widget _buildQuestList() {
    final matching = _filteredQuests;
    final active = matching.where((quest) => !_isQuestCompleted(quest)).toList();
    final completed = matching.where(_isQuestCompleted).toList();


    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        TextField(
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Search quests…',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: _searchController.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Clear search',
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: _primary.withValues(alpha: 0.08)),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Filter quests',
          style: GoogleFonts.poppins(
            color: _muted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _filters
              .map(
                (filter) => ChoiceChip(
                  label: Text(filter),
                  selected: _selectedFilter == filter,
                  onSelected: (_) => setState(() => _selectedFilter = filter),
                  selectedColor: _primary,
                  labelStyle: GoogleFonts.poppins(
                    color: _selectedFilter == filter ? Colors.white : _muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  side: BorderSide(
                    color: _selectedFilter == filter
                        ? _primary
                        : _primary.withValues(alpha: 0.12),
                  ),
                ),
              )
              .toList(growable: false),
        ),
        const SizedBox(height: 22),
        if (matching.isEmpty)
          _emptyQuestState()
        else ...[
          if (active.isNotEmpty) ...[
            _sectionLabel('🔥 Active Quests', subtitle: '${active.length} ready for you'),
            const SizedBox(height: 10),
            ...active.map(_questCard),
          ],
          if (completed.isNotEmpty) ...[
            const SizedBox(height: 10),
            _sectionLabel(
              '✅ Completed Quests',
              subtitle: 'Great work — keep your streak alive',
            ),
            const SizedBox(height: 10),
            ...completed.map(_questCard),
          ],
        ],
      ],
    );
  }


  Widget _emptyQuestState() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(Icons.travel_explore_rounded, color: _primary, size: 42),
          const SizedBox(height: 10),
          Text(
            'No quests found',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: _ink),
          ),
          const SizedBox(height: 4),
          Text(
            'Try a different search or filter.',
            style: GoogleFonts.poppins(color: _muted, fontSize: 12),
          ),
        ],
      ),
    );
  }


  Widget _questCard(DiscoveryQuest quest) {
    final metadata = _metadataFor(quest);
    final color = _subjectColor(quest);
    final completed = _isQuestCompleted(quest);
    final completedTasks = _completedTaskCountForQuest(quest);
    final taskTotal = quest.tasks.length;


    return Semantics(
      button: true,
      label: '${quest.title}, ${metadata.difficulty.label}, '
          '${metadata.deadlineLabel(completed: completed)}',
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: () => _openQuestDetail(quest),
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 5,
                  decoration: BoxDecoration(
                    color: completed ? _success : color,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _categoryChip(metadata, color),
                          const Spacer(),
                          _deadlineChip(metadata, completed),
                        ],
                      ),
                      const SizedBox(height: 11),
                      Text(
                        quest.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: _ink,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        quest.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(color: _muted, fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _metaItem(
                            icon: metadata.difficulty.icon,
                            label: metadata.difficulty.label,
                            color: metadata.difficulty.color,
                          ),
                          _metaItem(
                            icon: Icons.schedule_outlined,
                            label: metadata.estimatedTime,
                            color: _muted,
                          ),
                          _metaItem(
                            icon: Icons.task_alt_outlined,
                            label: '$completedTasks/$taskTotal tasks',
                            color: completed ? _success : _muted,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: _questProgress(quest),
                          minHeight: 8,
                          backgroundColor: color.withValues(alpha: 0.12),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            completed ? _success : color,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _rewardPreview(quest, metadata, completed),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _categoryChip(QuestMetadata metadata, Color color) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(metadata.categoryIcon, color: color, size: 15),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                metadata.categoryLabel,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _deadlineChip(QuestMetadata metadata, bool completed) {
    final color = metadata.deadlineColor(completed: completed);
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        metadata.deadlineLabel(completed: completed),
        style: GoogleFonts.poppins(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }


  Widget _metaItem({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 15),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }


  Widget _rewardPreview(
    DiscoveryQuest quest,
    QuestMetadata metadata,
    bool completed,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: completed ? _success.withValues(alpha: 0.08) : _surface,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 10,
        runSpacing: 5,
        children: [
          Text(
            completed ? 'Completed' : 'Earn',
            style: GoogleFonts.poppins(
              color: completed ? _success : _muted,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${quest.badge} Badge',
            style: GoogleFonts.poppins(color: _ink, fontSize: 11),
          ),
          Text(
            '⚡ ${quest.xpReward} XP',
            style: GoogleFonts.poppins(color: _primary, fontSize: 11),
          ),
          Text(
            '🎁 ${metadata.avatarReward}',
            style: GoogleFonts.poppins(color: _muted, fontSize: 11),
          ),
        ],
      ),
    );
  }


  void _openQuestDetail(DiscoveryQuest quest) {
    final metadata = _metadataFor(quest);
    final color = _subjectColor(quest);
    final completed = _isQuestCompleted(quest);


    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.86,
        minChildSize: 0.5,
        maxChildSize: 0.96,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: ListView(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(metadata.categoryIcon, color: color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            quest.title,
                            style: GoogleFonts.poppins(
                              color: _ink,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${metadata.categoryLabel} · ${quest.subject}',
                            style: GoogleFonts.poppins(color: color, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  quest.description,
                  style: GoogleFonts.poppins(color: _muted, fontSize: 13, height: 1.5),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _detailPill(
                      icon: metadata.difficulty.icon,
                      label: metadata.difficulty.label,
                      color: metadata.difficulty.color,
                    ),
                    _detailPill(
                      icon: Icons.schedule_outlined,
                      label: metadata.estimatedTime,
                      color: _muted,
                    ),
                    _detailPill(
                      icon: Icons.event_outlined,
                      label: metadata.deadlineLabel(completed: completed),
                      color: metadata.deadlineColor(completed: completed),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _rewardPreview(quest, metadata, completed),
                const SizedBox(height: 22),
                _sectionLabel(
                  'Tasks (${_completedTaskCountForQuest(quest)}/${quest.tasks.length})',
                  subtitle: completed ? 'Quest complete!' : 'Tap a task when you finish it',
                ),
                const SizedBox(height: 12),
                if (quest.tasks.isEmpty)
                  Text(
                    'This quest does not have any tasks yet.',
                    style: GoogleFonts.poppins(color: _muted, fontSize: 12),
                  )
                else
                  ...List<Widget>.generate(
                    quest.tasks.length,
                    (index) => _taskTile(quest, index, sheetContext),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _detailPill({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }


  Widget _taskTile(
    DiscoveryQuest quest,
    int taskIndex,
    BuildContext sheetContext,
  ) {
    final task = quest.tasks[taskIndex];
    final completed = _isTaskCompleted(quest, taskIndex);
    final xpGain = _xpForTask(quest, taskIndex);


    return Semantics(
      button: !completed,
      label: '${task.description}. '
          '${completed ? 'Completed' : 'Worth $xpGain XP'}',
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: completed ? _success.withValues(alpha: 0.08) : _surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: completed ? _success.withValues(alpha: 0.28) : Colors.transparent,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: completed
                ? null
                : () {
                    Navigator.of(sheetContext).pop();
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) _confirmTask(quest, taskIndex);
                    });
                  },
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: completed ? _success : Colors.grey.shade200,
                    ),
                    child: Icon(
                      completed ? Icons.check_rounded : Icons.circle_outlined,
                      color: completed ? Colors.white : Colors.grey,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      task.description,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: completed ? _success : _ink,
                        decoration:
                            completed ? TextDecoration.lineThrough : TextDecoration.none,
                      ),
                    ),
                  ),
                  if (!completed) ...[
                    const SizedBox(width: 8),
                    Text(
                      '+$xpGain XP',
                      style: GoogleFonts.poppins(
                        color: _primary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildLeaderboard() {
    final entries = _leaderboard;
    final currentRank = entries.indexWhere((entry) => entry.isCurrentUser) + 1;
    final topThree = entries.take(3).toList(growable: false);


    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      children: [
        _leaderboardMotivation(currentRank),
        const SizedBox(height: 22),
        _sectionLabel('🏆 Top Researchers', subtitle: 'This week’s top learners'),
        const SizedBox(height: 16),
        if (topThree.length >= 3)
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: _podiumItem(topThree[1], 2, 86)),
              const SizedBox(width: 8),
              Expanded(child: _podiumItem(topThree[0], 1, 112)),
              const SizedBox(width: 8),
              Expanded(child: _podiumItem(topThree[2], 3, 68)),
            ],
          ),
        const SizedBox(height: 24),
        _sectionLabel('📊 Full Rankings', subtitle: 'Your rank updates as you earn XP'),
        const SizedBox(height: 10),
        ...entries.asMap().entries.map(
              (entry) => _leaderboardRow(entry.key + 1, entry.value),
            ),
      ],
    );
  }


  Widget _leaderboardMotivation(int rank) {
    final message = _xpToNextLevel == 0
        ? 'You are a Master Researcher — incredible work!'
        : 'Only $_xpToNextLevel XP behind Level ${_levelNumber + 1}!';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[_primary, Color(0xFFA29BFE)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Text('🚀', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You’re #$rank this week',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  '$message +$_weeklyXp XP this week.',
                  style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _podiumItem(LeaderboardEntry entry, int rank, double height) {
    final color = switch (rank) {
      1 => const Color(0xFFFFD700),
      2 => const Color(0xFFC0C0C0),
      _ => const Color(0xFFCD7F32),
    };
    final medal = switch (rank) {
      1 => '🥇',
      2 => '🥈',
      _ => '🥉',
    };


    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 21,
          child: entry.isCurrentUser
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: _success,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'You',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : null,
        ),
        CircleAvatar(
          radius: rank == 1 ? 27 : 22,
          backgroundColor: color.withValues(alpha: 0.20),
          child: Text(
            entry.initials,
            style: GoogleFonts.poppins(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: rank == 1 ? 15 : 12,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(medal, style: const TextStyle(fontSize: 17)),
        Text(
          entry.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            color: _ink,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
        Text(
          '${entry.xp} XP',
          style: GoogleFonts.poppins(color: _muted, fontSize: 10),
        ),
        const SizedBox(height: 5),
        Container(
          width: double.infinity,
          height: height,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            border: Border.all(color: color.withValues(alpha: 0.40)),
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: GoogleFonts.poppins(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }


  Widget _leaderboardRow(int rank, LeaderboardEntry entry) {
    final changeColor = entry.rankChange > 0
        ? _success
        : entry.rankChange < 0
            ? Colors.redAccent
            : _muted;

    return GestureDetector(
      onTap: () => _showAccountDetails(entry),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: entry.isCurrentUser ? _primary.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: entry.isCurrentUser
                ? _primary.withValues(alpha: 0.25)
                : Colors.transparent,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Row(
            children: [
              SizedBox(
                width: 30,
                child: Text(
                  '#$rank',
                  style: GoogleFonts.poppins(
                    color: _ink,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              CircleAvatar(
                radius: 20,
                backgroundColor: _primary.withValues(alpha: 0.14),
                child: Text(
                  entry.initials,
                  style: GoogleFonts.poppins(
                    color: _primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            entry.name,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              color: _ink,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        if (entry.isCurrentUser) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: _success,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'You',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      '+${entry.weeklyXp} XP this week · 🏅 ${entry.badges} badges',
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(color: _muted, fontSize: 10),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${entry.xp} XP',
                    style: GoogleFonts.poppins(
                      color: _primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        entry.rankChange > 0
                            ? Icons.arrow_upward_rounded
                            : entry.rankChange < 0
                                ? Icons.arrow_downward_rounded
                                : Icons.remove_rounded,
                        color: changeColor,
                        size: 13,
                      ),
                      Text(
                        entry.rankChange == 0
                            ? 'Same'
                            : entry.rankChange > 0
                                ? '+${entry.rankChange}'
                                : '${entry.rankChange}',
                        style: GoogleFonts.poppins(color: changeColor, fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildBadges() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      children: [
        _sectionLabel('🏅 Your Badges', subtitle: 'Every completed quest unlocks one'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: <Color>[_primary, Color(0xFFA29BFE)]),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Wrap(
            alignment: WrapAlignment.spaceAround,
            spacing: 18,
            runSpacing: 10,
            children: [
              _badgeStat('$_completedQuestCount', 'Earned'),
              _badgeStat('${_quests.length - _completedQuestCount}', 'Remaining'),
              _badgeStat('${_quests.length}', 'Total Quests'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 650 ? 3 : 2;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _quests.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.05,
              ),
              itemBuilder: (context, index) {
                final quest = _quests[index];
                final earned = _isQuestCompleted(quest);
                return _badgeCard(quest, earned);
              },
            );
          },
        ),
      ],
    );
  }


  Widget _badgeCard(DiscoveryQuest quest, bool earned) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: earned ? Colors.white : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: earned ? _primary.withValues(alpha: 0.25) : Colors.transparent,
        ),
        boxShadow: earned
            ? [
                BoxShadow(
                  color: _primary.withValues(alpha: 0.10),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            earned ? quest.badge.split(' ').first : '🔒',
            style: TextStyle(fontSize: 34, color: earned ? null : Colors.grey),
          ),
          const SizedBox(height: 7),
          Text(
            quest.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: earned ? _ink : Colors.grey,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            earned ? '✅ Earned' : '🔐 Locked',
            style: GoogleFonts.poppins(
              color: earned ? _success : Colors.grey,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildProgress() {
    final totalTasks = _quests.fold<int>(0, (total, quest) => total + quest.tasks.length);
    final nextLevel = _nextLevelXp;


    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      children: [
        _sectionLabel('📊 Your Progress', subtitle: 'Small steps become big wins'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: <Color>[_primary, _ink],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            children: [
              Wrap(
                alignment: WrapAlignment.spaceAround,
                spacing: 22,
                runSpacing: 16,
                children: [
                  _progressStat('$_xp', 'Total XP', '⚡'),
                  _progressStat('$_completedQuestCount', 'Quests Done', '🏆'),
                  _progressStat('${_earnedBadges.length}', 'Badges', '🏅'),
                  _progressStat('$_completedTaskCount/$totalTasks', 'Tasks Done', '✅'),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                nextLevel == null
                    ? 'Level $_levelNumber · Master Researcher'
                    : '$_xpToNextLevel XP until Level ${_levelNumber + 1}',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _levelProgress,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 10,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _sectionLabel('📋 Quest Breakdown', subtitle: 'Keep an eye on every challenge'),
        const SizedBox(height: 12),
        ..._quests.map(_progressQuestCard),
      ],
    );
  }


  Widget _progressQuestCard(DiscoveryQuest quest) {
    final completedTasks = _completedTaskCountForQuest(quest);
    final taskTotal = quest.tasks.length;
    final completed = _isQuestCompleted(quest);
    final metadata = _metadataFor(quest);
    final color = _subjectColor(quest);


    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
              Expanded(
                child: Text(
                  quest.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: _ink,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '$completedTasks/$taskTotal tasks',
                style: GoogleFonts.poppins(color: _muted, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 9),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _questProgress(quest),
              backgroundColor: color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(completed ? _success : color),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            completed
                ? '✅ Complete · ${quest.badge} earned'
                : '${metadata.deadlineLabel(completed: false)} · ⚡ ${quest.xpReward} XP',
            style: GoogleFonts.poppins(
              color: completed ? _success : _muted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }


  Widget _sectionLabel(String title, {String? subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            color: _ink,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.poppins(color: _muted, fontSize: 11),
          ),
        ],
      ],
    );
  }


  Widget _badgeStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }


  Widget _progressStat(String value, String label, String emoji) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 3),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 9),
        ),
      ],
    );
  }
}