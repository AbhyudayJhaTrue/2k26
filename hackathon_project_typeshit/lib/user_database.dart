// ---------------------------------------------------------------------------
// USER DATABASE (hackathon demo only)
// This is a hardcoded, in-memory "database" — perfect for a quick demo,
// but NOT secure for real use (passwords should never be stored in plain
// text or shipped inside app code in a real product).
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';
import 'models/discovery_quest.dart';

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
  AppUser(name: "Pranav",    password: "1234", role: "Student"),
  AppUser(name: "Kushagr",   password: "1234", role: "Student"),
  AppUser(name: "Adhvik",    password: "1234", role: "Student"),
  AppUser(name: "Aanya",     password: "1234", role: "Student"),
  AppUser(name: "Abhyudhay", password: "1234", role: "Student"),
  AppUser(name: "Rohan",     password: "1234", role: "Student"),

  // ---- Teachers ----
  AppUser(name: "Jason", password: "1234", role: "Teacher"),
  AppUser(name: "Jack",  password: "1234", role: "Teacher"),

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

// ---------------------------------------------------------------------------
// SHARED DATA MODELS
// All features read/write through UserDatabase.instance — one database.
// ---------------------------------------------------------------------------

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

// ---------------------------------------------------------------------------
// USER DATABASE SINGLETON
// ---------------------------------------------------------------------------

class UserDatabase extends ChangeNotifier {
  static final UserDatabase instance = UserDatabase._internal();
  UserDatabase._internal();

  // --- MOCK DATA STORE ---

  static const List<DiscoveryQuest> discoveryQuests = [
    DiscoveryQuest(
      title: 'World Geography Explorer',
      description:
          'Put your geography knowledge to the test by identifying capitals, '
          'landmarks, and physical features from around the globe.',
      subject: 'Geography',
      badge: '🌍 Explorer',
      xpReward: 150,
      tasks: [
        QuestTask(description: 'Name 10 capital cities from memory'),
        QuestTask(description: 'Locate 5 mountain ranges on a blank map'),
        QuestTask(description: 'Label the 7 continents and their major rivers'),
      ],
    ),
    DiscoveryQuest(
      title: 'History Time Traveller',
      description:
          'Journey through key moments in world history — from ancient '
          'civilisations to the modern era.',
      subject: 'History',
      badge: '📜 Historian',
      xpReward: 200,
      tasks: [
        QuestTask(description: 'Write a short timeline of World War II'),
        QuestTask(description: 'Research one ancient civilisation and present 3 facts'),
        QuestTask(description: 'Identify causes of the Industrial Revolution'),
      ],
    ),
    DiscoveryQuest(
      title: 'Code Wizard Challenge',
      description:
          'Level up your programming skills by solving real coding problems '
          'across data structures and algorithms.',
      subject: 'Computer Science',
      badge: '🧙 Code Wizard',
      xpReward: 300,
      tasks: [
        QuestTask(description: 'Implement a binary search algorithm'),
        QuestTask(description: 'Write a recursive function to compute Fibonacci numbers'),
        QuestTask(description: 'Solve 3 problems on sorting algorithms'),
        QuestTask(description: 'Build a simple to-do app with state management'),
      ],
    ),
    DiscoveryQuest(
      title: 'Biology Lab Expert',
      description:
          'Explore the living world — from cell biology to ecosystems — '
          'through hands-on lab tasks and research activities.',
      subject: 'Biology',
      badge: '🔬 Lab Expert',
      xpReward: 200,
      tasks: [
        QuestTask(description: 'Label a diagram of an animal cell'),
        QuestTask(description: 'Conduct a photosynthesis experiment and record results'),
        QuestTask(description: 'Research food chains in a chosen ecosystem'),
      ],
    ),
    DiscoveryQuest(
      title: 'Physics Rocket Scientist',
      description:
          'Master the laws of motion, energy, and electromagnetism through '
          'problem sets and practical experiments.',
      subject: 'Physics',
      badge: '🚀 Rocket Scientist',
      xpReward: 300,
      tasks: [
        QuestTask(description: "Apply Newton's three laws to real-world scenarios"),
        QuestTask(description: 'Calculate kinetic and potential energy for 5 problems'),
        QuestTask(description: 'Draw and explain a circuit diagram'),
        QuestTask(description: 'Complete the optics worksheet on lenses and mirrors'),
      ],
    ),
    DiscoveryQuest(
      title: 'Mathematics Problem Solver',
      description:
          'Sharpen your algebra, geometry, and statistics skills through '
          'structured problem-solving sessions.',
      subject: 'Mathematics',
      badge: '📐 Problem Solver',
      xpReward: 200,
      tasks: [
        QuestTask(description: 'Solve 10 quadratic equations'),
        QuestTask(description: 'Complete the coordinate geometry worksheet'),
        QuestTask(description: 'Calculate mean, median, and mode for 3 data sets'),
      ],
    ),
  ];

  final List<ClubEvent> clubEvents = [
    ClubEvent(
      id: 'e1',
      title: 'AI & Robotics Workshop',
      description:
          'Hands-on introduction to building neural networks with Flutter and Python.',
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
    ClubEvent(
      id: 'e3',
      title: 'Art & Illustration Workshop',
      description: 'Explore watercolour, sketching, and digital art techniques.',
      category: ClubCategory.arts,
      date: DateTime.now().add(const Duration(days: 5)),
      location: 'Art Room 1',
      organizer: 'Arts Society',
      capacity: 20,
      registeredCount: 11,
    ),
    ClubEvent(
      id: 'e4',
      title: 'Debate & Public Speaking',
      description: 'Sharpen your argumentation skills. Open to all students.',
      category: ClubCategory.academic,
      date: DateTime.now().add(const Duration(days: 10)),
      location: 'Hall B',
      organizer: 'Debate Club',
      capacity: 40,
      registeredCount: 28,
    ),
    ClubEvent(
      id: 'e5',
      title: 'Community Clean-Up Drive',
      description: 'Volunteer for the neighbourhood clean-up and earn service hours.',
      category: ClubCategory.service,
      date: DateTime.now().add(const Duration(days: 14)),
      location: 'School Gate (meet-up)',
      organizer: 'Student Council',
      capacity: 50,
      registeredCount: 33,
    ),
  ];

  final List<Suggestion> suggestions = [
    Suggestion(
      id: 's1',
      title: 'Extend Library Hours during Exams',
      description:
          'Keep the main library open until 9 PM on weekdays during exam week.',
      authorName: 'Alex M.',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      upvotes: 42,
      status: SuggestionStatus.underReview,
    ),
    Suggestion(
      id: 's2',
      title: 'Add Water Refill Stations near the Gym',
      description:
          'Would help students stay hydrated after PE and after-school sports.',
      authorName: 'Anonymous',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      upvotes: 31,
      status: SuggestionStatus.approved,
    ),
    Suggestion(
      id: 's3',
      title: 'More Vegetarian Options in the Canteen',
      description: 'Currently only 2 vegetarian items on the daily menu.',
      authorName: 'Anonymous',
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
      upvotes: 19,
      status: SuggestionStatus.pending,
    ),
  ];

  final List<VoiceReport> voiceReports = [
    VoiceReport(
      id: 'v1',
      title: 'Broken AC in Room 204',
      content:
          'The air conditioner has been making loud noises and cooling poorly.',
      category: VoiceCategory.maintenance,
      timestamp: DateTime.now().subtract(const Duration(hours: 12)),
      status: VoiceStatus.reviewing,
    ),
    VoiceReport(
      id: 'v2',
      title: 'Flickering Lights in East Stairwell',
      content: 'Lights in the east stairwell have been flickering for a week.',
      category: VoiceCategory.maintenance,
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      status: VoiceStatus.submitted,
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
    Assignment(
      id: 'a2',
      title: 'Binary Search Trees – Problem Set',
      subject: 'Computer Science',
      dueDate: DateTime.now().add(const Duration(days: 4)),
      totalStudents: 28,
      submittedCount: 19,
    ),
    Assignment(
      id: 'a3',
      title: 'Quadratic Equations Worksheet',
      subject: 'Mathematics',
      dueDate: DateTime.now().add(const Duration(days: 6)),
      totalStudents: 30,
      submittedCount: 12,
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
    LearningResource(
      id: 'r2',
      title: 'Sorting Algorithms – Slide Deck',
      subject: 'Computer Science',
      type: ResourceType.slides,
      author: 'Mr. Jason',
      sizeOrDuration: '3.1 MB',
    ),
    LearningResource(
      id: 'r3',
      title: 'Recursion Explained',
      subject: 'Computer Science',
      type: ResourceType.video,
      author: 'Mr. Jack',
      sizeOrDuration: '12 min',
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

  void addVoiceReport(
      String title, String content, VoiceCategory category) {
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
