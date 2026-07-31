// ---------------------------------------------------------------------------
// USER DATABASE (hackathon demo only)
// This is a hardcoded, in-memory "database" — perfect for a quick demo,
// but NOT secure for real use (passwords should never be stored in plain
// text or shipped inside app code in a real product).
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';

class AppUser {
  final String name;
  final String password;
  final String role; // "Student", "Teacher", or "Admin"

  const AppUser({
    required this.name,
    required this.password,
    required this.role,
  });
}

const List<AppUser> kUserDatabase = [
  // ---- Students ----
  AppUser(name: "Pranav", password: "1234", role: "Student"),
  AppUser(name: "Kushagr", password: "1234", role: "Student"),
  AppUser(name: "Adhvik", password: "1234", role: "Student"),

  // ---- Teachers ----
  AppUser(name: "Jason", password: "1234", role: "Teacher"),
  AppUser(name: "Jack", password: "1234", role: "Teacher"),

  // ---- Admin ----
  AppUser(name: "Abhyuday", password: "1234", role: "Admin"),
];

/// Checks name + password + role against the database.
/// Returns the matching AppUser if valid, otherwise null.
AppUser? validateLogin({
  required String name,
  required String password,
  required String role,
}) {
  for (final user in kUserDatabase) {
    if (user.name.trim().toLowerCase() == name.trim().toLowerCase() &&
        user.password == password &&
        user.role == role) {
      return user;
    }
  }
  return null;
}

enum ClubCategory { all, academic, sports, arts, tech, service }

class ClubEvent {
  final String id;
  final String title;
  final String description;
  final ClubCategory category;
  final DateTime date;
  final String location;
  final String organizer;
  final int capacity;
  int registeredCount;
  bool isRegistered;

  ClubEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.date,
    required this.location,
    required this.organizer,
    required this.capacity,
    required this.registeredCount,
    this.isRegistered = false,
  });
}

enum SuggestionStatus { pending, underReview, approved, implemented }

class Suggestion {
  final String id;
  final String title;
  final String description;
  final String authorName;
  final DateTime createdAt;
  int upvotes;
  bool isUpvoted;
  SuggestionStatus status;

  Suggestion({
    required this.id,
    required this.title,
    required this.description,
    required this.authorName,
    required this.createdAt,
    this.upvotes = 0,
    this.isUpvoted = false,
    this.status = SuggestionStatus.pending,
  });
}

enum VoiceCategory { bullying, mentalHealth, maintenance, personal, general }
enum VoiceStatus { submitted, reviewing, resolved }

class VoiceReport {
  final String id;
  final String title;
  final String content;
  final VoiceCategory category;
  final DateTime timestamp;
  final VoiceStatus status;

  VoiceReport({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.timestamp,
    this.status = VoiceStatus.submitted,
  });
}

enum AssignmentStatus { draft, published, closed }

class Assignment {
  final String id;
  final String title;
  final String subject;
  final DateTime dueDate;
  final int totalStudents;
  int submittedCount;
  AssignmentStatus status;

  Assignment({
    required this.id,
    required this.title,
    required this.subject,
    required this.dueDate,
    required this.totalStudents,
    required this.submittedCount,
    this.status = AssignmentStatus.published,
  });
}

enum ResourceType { pdf, doc, slides, video, link }

class LearningResource {
  final String id;
  final String title;
  final String subject;
  final ResourceType type;
  final String author;
  final String sizeOrDuration;

  LearningResource({
    required this.id,
    required this.title,
    required this.subject,
    required this.type,
    required this.author,
    required this.sizeOrDuration,
  });
}

// -----------------------------------------------------------------------------
// USER DATABASE SINGLETON
// -----------------------------------------------------------------------------

class UserDatabase extends ChangeNotifier {
  static final UserDatabase instance = UserDatabase._internal();
  UserDatabase._internal();

  // --- MOCK DATA STORE ---
  final List<ClubEvent> clubEvents = [
    ClubEvent(
      id: 'e1',
      title: 'AI & Robotics Workshop',
      description: 'Hands-on introduction to building neural networks with Flutter and Python.',
      category: ClubCategory.tech,
      date: DateTime.now().add(const Duration(days: 3)),
      location: 'Lab 4B',
      organizer: 'Tech Club',
      capacity: 30,
      registeredCount: 22,
    ),
    ClubEvent(
      id: 'e2',
      title: 'Inter-House Football League',
      description: 'Annual football championship. Support your house team!',
      category: ClubCategory.sports,
      date: DateTime.now().add(const Duration(days: 7)),
      location: 'Main Sports Ground',
      organizer: 'Sports Committee',
      capacity: 100,
      registeredCount: 85,
    ),
  ];

  final List<Suggestion> suggestions = [
    Suggestion(
      id: 's1',
      title: 'Extend Library Hours during Exams',
      description: 'Keep the main library open until 9 PM on weekdays during exam week.',
      authorName: 'Alex M.',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      upvotes: 42,
      status: SuggestionStatus.underReview,
    ),
  ];

  final List<VoiceReport> voiceReports = [
    VoiceReport(
      id: 'v1',
      title: 'Broken AC in Room 204',
      content: 'The air conditioner has been making loud noises and cooling poorly.',
      category: VoiceCategory.maintenance,
      timestamp: DateTime.now().subtract(const Duration(hours: 12)),
      status: VoiceStatus.reviewing,
    ),
  ];

  final List<Assignment> assignments = [
    Assignment(
      id: 'a1',
      title: 'Calculus Problem Set #4',
      subject: 'Mathematics',
      dueDate: DateTime.now().add(const Duration(days: 2)),
      totalStudents: 32,
      submittedCount: 18,
    ),
  ];

  final List<LearningResource> resources = [
    LearningResource(
      id: 'r1',
      title: 'Organic Chemistry Lecture Notes',
      subject: 'Chemistry',
      type: ResourceType.pdf,
      author: 'Dr. Smith',
      sizeOrDuration: '2.4 MB',
    ),
  ];

  // --- DATABASE ACTIONS ---

  void toggleEventRegistration(String eventId) {
    final event = clubEvents.firstWhere((e) => e.id == eventId);
    if (event.isRegistered) {
      event.isRegistered = false;
      event.registeredCount--;
    } else {
      if (event.registeredCount < event.capacity) {
        event.isRegistered = true;
        event.registeredCount++;
      }
    }
    notifyListeners();
  }

  void toggleUpvoteSuggestion(String suggestionId) {
    final suggestion = suggestions.firstWhere((s) => s.id == suggestionId);
    if (suggestion.isUpvoted) {
      suggestion.isUpvoted = false;
      suggestion.upvotes--;
    } else {
      suggestion.isUpvoted = true;
      suggestion.upvotes++;
    }
    notifyListeners();
  }

  void addSuggestion(String title, String description) {
    suggestions.insert(
      0,
      Suggestion(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: description,
        authorName: 'Anonymous Student',
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void addVoiceReport(String title, String content, VoiceCategory category) {
    voiceReports.insert(
      0,
      VoiceReport(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        content: content,
        category: category,
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();
  }
}