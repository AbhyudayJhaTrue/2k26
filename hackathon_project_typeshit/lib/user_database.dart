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

class ResearchResource {
  final String id;
  final String title;
  final String description;
  final String subject;
  final String type; // article, video, book, journal, website, research_paper, government
  final String source;
  final String difficulty; // Beginner, Intermediate, Advanced
  final String readTime;
  final String url;
  final bool teacherApproved;
  bool isBookmarked;

  ResearchResource({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.type,
    required this.source,
    required this.difficulty,
    required this.readTime,
    required this.url,
    this.teacherApproved = false,
    this.isBookmarked = false,
  });
}

enum ChatRoomType {
  classRoom('Class'),
  club('Club'),
  teacher('Teacher');

  const ChatRoomType(this.label);
  final String label;
}

enum MessageKind { text, assignment, event, poll, voice }
enum Receipt { sent, delivered, read }
enum AttachmentType { document, image, spreadsheet, video }

class ChatRoom {
  ChatRoom({
    required this.name,
    required this.emoji,
    required this.type,
    required this.members,
    required this.online,
    required this.lastMessage,
    required this.lastSender,
    required this.lastActivity,
    required this.description,
    required this.admin,
    this.unread = 0,
    this.isPinned = false,
    this.announcement,
  });

  final String name, emoji, description, admin;
  final ChatRoomType type;
  final int members, online;
  String lastMessage, lastSender;
  DateTime lastActivity;
  int unread;
  bool isPinned;
  final String? announcement;

  String get timeLabel {
    final difference = DateTime.now().difference(lastActivity);
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }
}

class ChatMessage {
  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.timestamp,
    this.kind = MessageKind.text,
    this.receipt = Receipt.read,
    this.reaction,
    this.replyTo,
    this.attachment,
    this.cardTitle,
    this.cardSubtitle,
    this.pollOptions,
    this.voiceDuration,
  });

  final String id, senderId, senderName, text;
  final DateTime timestamp;
  final MessageKind kind;
  final Receipt receipt;
  String? reaction;
  final ChatMessage? replyTo;
  final AttachmentData? attachment;
  final String? cardTitle, cardSubtitle, voiceDuration;
  final List<String>? pollOptions;
}

class AttachmentData {
  const AttachmentData(this.name, this.size, this.type);
  final String name, size;
  final AttachmentType type;

  IconData get icon => switch (type) {
        AttachmentType.document => Icons.picture_as_pdf_rounded,
        AttachmentType.image => Icons.image_rounded,
        AttachmentType.spreadsheet => Icons.table_chart_rounded,
        AttachmentType.video => Icons.videocam_rounded,
      };
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

  final List<ResearchResource> researchResources = [
    ResearchResource(
      id: 'rr1',
      title: 'Introduction to Photosynthesis',
      description:
          'A clear, illustrated breakdown of how plants convert light energy '
          'into chemical energy, covering the light and dark reactions.',
      subject: 'Biology',
      type: 'article',
      source: 'Khan Academy',
      difficulty: 'Beginner',
      readTime: '8 min read',
      url: 'khanacademy.org/photosynthesis',
      teacherApproved: true,
    ),
    ResearchResource(
      id: 'rr2',
      title: 'The French Revolution Explained',
      description:
          'A documentary-style video covering the causes, key events, and '
          'lasting impact of the French Revolution.',
      subject: 'History',
      type: 'video',
      source: 'CrashCourse',
      difficulty: 'Intermediate',
      readTime: '14 min watch',
      url: 'youtube.com/crashcourse-french-revolution',
      teacherApproved: true,
    ),
    ResearchResource(
      id: 'rr3',
      title: 'Quantum Mechanics: A Primer',
      description:
          'An accessible textbook chapter introducing wave-particle duality, '
          'the uncertainty principle, and the Schrödinger equation.',
      subject: 'Physics',
      type: 'book',
      source: 'MIT OpenCourseWare',
      difficulty: 'Advanced',
      readTime: '25 min read',
      url: 'ocw.mit.edu/quantum-primer',
      teacherApproved: true,
    ),
    ResearchResource(
      id: 'rr4',
      title: 'Machine Learning Foundations',
      description:
          'A peer-reviewed journal article surveying supervised and '
          'unsupervised learning techniques with real-world examples.',
      subject: 'Computer Science',
      type: 'journal',
      source: 'IEEE Xplore',
      difficulty: 'Advanced',
      readTime: '20 min read',
      url: 'ieee.org/ml-foundations',
      teacherApproved: false,
    ),
    ResearchResource(
      id: 'rr5',
      title: 'Climate Change: The Science',
      description:
          'An official government explainer on greenhouse gases, global '
          'temperature trends, and mitigation strategies.',
      subject: 'Geography',
      type: 'government',
      source: 'NASA Climate',
      difficulty: 'Intermediate',
      readTime: '10 min read',
      url: 'climate.nasa.gov',
      teacherApproved: true,
    ),
    ResearchResource(
      id: 'rr6',
      title: 'Algebra II Practice Portal',
      description:
          'An interactive website with worked examples and practice problems '
          'covering quadratics, polynomials, and functions.',
      subject: 'Mathematics',
      type: 'website',
      source: 'Purplemath',
      difficulty: 'Intermediate',
      readTime: '15 min',
      url: 'purplemath.com/algebra-ii',
      teacherApproved: true,
    ),
    ResearchResource(
      id: 'rr7',
      title: 'Organic Chemistry Reaction Mechanisms',
      description:
          'A detailed research paper walking through common reaction '
          'mechanisms with annotated diagrams.',
      subject: 'Chemistry',
      type: 'research_paper',
      source: 'ScienceDirect',
      difficulty: 'Advanced',
      readTime: '30 min read',
      url: 'sciencedirect.com/organic-mechanisms',
      teacherApproved: false,
    ),
    ResearchResource(
      id: 'rr8',
      title: 'Shakespeare in Context',
      description:
          'An article exploring the historical and cultural backdrop of '
          "Shakespeare's major plays.",
      subject: 'English',
      type: 'article',
      source: 'British Library',
      difficulty: 'Beginner',
      readTime: '6 min read',
      url: 'bl.uk/shakespeare-in-context',
      teacherApproved: true,
    ),
  ];

  final List<ChatRoom> chatRooms = [
    ChatRoom(
      name: '9A General',
      emoji: '🏫',
      type: ChatRoomType.classRoom,
      members: 28,
      online: 14,
      lastMessage: 'Show off 😂',
      lastSender: 'Abhyudhay',
      lastActivity: DateTime.now().subtract(const Duration(minutes: 2)),
      unread: 2,
      isPinned: true,
      description: 'The official chat for Class 9A.',
      admin: 'Mr. Jason',
      announcement: 'Physics homework is due this Friday.',
    ),
    ChatRoom(
      name: 'Computer Science Club',
      emoji: '💻',
      type: ChatRoomType.club,
      members: 12,
      online: 5,
      lastMessage: 'Anyone done the Python task?',
      lastSender: 'Pranav',
      lastActivity: DateTime.now().subtract(const Duration(minutes: 15)),
      isPinned: true,
      description: 'Build, learn, and share great technology projects.',
      admin: 'Mr. Jack',
    ),
    ChatRoom(
      name: 'Math Help',
      emoji: '📐',
      type: ChatRoomType.club,
      members: 8,
      online: 2,
      lastMessage: 'Quadratic formula explained',
      lastSender: 'Aanya',
      lastActivity: DateTime.now().subtract(const Duration(hours: 1)),
      unread: 5,
      description: 'A friendly place to ask and answer mathematics questions.',
      admin: 'Aanya',
    ),
    ChatRoom(
      name: 'Mr. Jack',
      emoji: '👨‍🏫',
      type: ChatRoomType.teacher,
      members: 2,
      online: 1,
      lastMessage: 'Great work on the lab report!',
      lastSender: 'Mr. Jack',
      lastActivity: DateTime.now().subtract(const Duration(hours: 2)),
      unread: 1,
      description: 'Private school communication with your teacher.',
      admin: 'Mr. Jack',
    ),
    ChatRoom(
      name: 'Mr. Jason',
      emoji: '🧑‍🏫',
      type: ChatRoomType.teacher,
      members: 2,
      online: 0,
      lastMessage: 'Check your feedback on the diagram',
      lastSender: 'Mr. Jason',
      lastActivity: DateTime.now().subtract(const Duration(days: 1)),
      description: 'Private school communication with your teacher.',
      admin: 'Mr. Jason',
    ),
  ];

  /// Demo message history for a chat room. Every named sender here
  /// corresponds to an existing account in [kUserDatabase].
  List<ChatMessage> messagesForRoom(ChatRoom room) {
    final now = DateTime.now();
    return [
      ChatMessage(
        id: '1',
        senderId: 'aanya',
        senderName: 'Aanya',
        text: 'Hi everyone! Has anyone started the physics report?',
        timestamp: now.subtract(const Duration(days: 1, hours: 3)),
      ),
      ChatMessage(
        id: '2',
        senderId: 'me',
        senderName: 'You',
        text: 'I have the observations, I can share them.',
        timestamp: now.subtract(const Duration(days: 1, hours: 2, minutes: 56)),
        receipt: Receipt.read,
      ),
      if (room.type == ChatRoomType.classRoom)
        ChatMessage(
          id: '3',
          senderId: 'teacher',
          senderName: 'Mr. Jason',
          text: '',
          timestamp: now.subtract(const Duration(hours: 3)),
          kind: MessageKind.assignment,
          cardTitle: 'Physics Lab Report',
          cardSubtitle: 'Friday, 8 August',
        ),
      if (room.type == ChatRoomType.classRoom)
        ChatMessage(
          id: '4',
          senderId: 'teacher',
          senderName: 'Mr. Jason',
          text: '',
          timestamp: now.subtract(const Duration(hours: 2, minutes: 40)),
          kind: MessageKind.event,
          cardTitle: 'Sports Day',
          cardSubtitle: '9 August • School Ground',
        ),
      if (room.type != ChatRoomType.teacher)
        ChatMessage(
          id: '5',
          senderId: 'teacher',
          senderName: room.type == ChatRoomType.club ? 'Mr. Jack' : 'Mr. Jason',
          text: '',
          timestamp: now.subtract(const Duration(minutes: 35)),
          kind: MessageKind.poll,
          cardTitle: 'Which revision session works best?',
          pollOptions: const ['Monday', 'Tuesday', 'Wednesday'],
        ),
      ChatMessage(
        id: '6',
        senderId: 'pranav',
        senderName: 'Pranav',
        text: room.lastMessage,
        timestamp: now.subtract(const Duration(minutes: 10)),
        attachment: room.type == ChatRoomType.classRoom
            ? const AttachmentData('Physics_Lab_Report.pdf', '2.1 MB', AttachmentType.document)
            : null,
      ),
    ];
  }

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

  void toggleBookmarkResource(String resourceId) {
    final resource = researchResources.firstWhere((r) => r.id == resourceId);
    resource.isBookmarked = !resource.isBookmarked;
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

  void addAssignment(Assignment assignment) {}

  void updateAssignment(Assignment assignment) {}

  void deleteAssignment(String id) {}

  void addResource(LearningResource learningResource) {}

  void deleteResource(String id) {}

  void setSuggestionStatus(String id, SuggestionStatus status) {}

  void setVoiceReportStatus(String id, VoiceStatus status) {}
}
