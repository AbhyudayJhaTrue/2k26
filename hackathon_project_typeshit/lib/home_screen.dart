import 'package:flutter/material.dart';
import 'models/assignment.dart';
import 'screens/student/assignment_screen.dart';
import 'screens/student/club_events_screen.dart';
import 'screens/student/student_dashboard.dart';
import 'screens/student/student_voice_screen.dart';
import 'screens/student/suggestion_hub.dart';

// ---------------------------------------------------------------------------
// HOME SCREEN
// A simple dashboard landing page with quick action cards for the new screens.
// ---------------------------------------------------------------------------

class HomeScreen extends StatelessWidget {
  final String name;
  final String role;

  const HomeScreen({
    super.key,
    required this.name,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final bool isStudent = role == 'Student';

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1F1147), // deep indigo
              Color(0xFF6C5CE7), // vivid purple
              Color(0xFF00CEC9), // teal accent
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- Top bar ----
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hello $name",
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          role,
                          style: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withAlpha(204),
                          ),
                        ),
                      ],
                    ),
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white.withAlpha(51),
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                  ],
                ),
              ),

              // ---- Quick action cards ----
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(20),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Quick Actions',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: isStudent
                            ? GridView.count(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 1.1,
                                children: [
                                  _buildActionCard(
                                    context,
                                    icon: Icons.task_alt,
                                    label: 'Assignments',
                                    onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const AssignmentScreen(assignments: <Assignment>[]),
                                      ),
                                    ),
                                  ),
                                  _buildActionCard(
                                    context,
                                    icon: Icons.event,
                                    label: 'Clubs & Events',
                                    onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const ClubsEventsScreen(),
                                      ),
                                    ),
                                  ),
                                  _buildActionCard(
                                    context,
                                    icon: Icons.lightbulb,
                                    label: 'Suggestion Hub',
                                    onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const SuggestionHubScreen(),
                                      ),
                                    ),
                                  ),
                                  _buildActionCard(
                                    context,
                                    icon: Icons.mic,
                                    label: 'Student Voice',
                                    onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const StudentVoiceScreen(),
                                      ),
                                    ),
                                  ),
                                  _buildActionCard(
                                    context,
                                    icon: Icons.dashboard,
                                    label: 'Dashboard',
                                    onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => StudentDashboard(studentName: name),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: Text(
                                    'Student-only features are locked for your role. Teachers and admins cannot access the student area.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white.withOpacity(0.9),
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                        ),
                      ],
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
  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(31),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withAlpha(46)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white24,
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const Spacer(),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }}