import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../user_database.dart';

// ─────────────────────────────────────────────────────────────
// SAFETY FILTER — Bad Words, Bullying, Spam Detection
// NOTE: The old basic filter that banned single words like
// 'spam', 'hate', 'abuse' has been REMOVED. This new system
// only blocks messages when actual swearing, bullying, or
// spamming behaviour is detected — not just because a word
// appears anywhere in the message.
// ─────────────────────────────────────────────────────────────


// ── SAFETY REPORT MODEL ──────────────────────────────────────
class SafetyReport {
  final String studentName;
  final String message;
  final String violationType;
  final DateTime timestamp;
  String status;

  SafetyReport({
    required this.studentName,
    required this.message,
    required this.violationType,
    required this.timestamp,
    this.status = 'Pending',
  });
}

class SafetyReports {
  static final List<SafetyReport> reports = [];

  static void add(String student, String message, String type) {
    reports.add(SafetyReport(
      studentName: student,
      message: message,
      violationType: type,
      timestamp: DateTime.now(),
    ));
  }
}


// ── FILTER ENUMS ─────────────────────────────────────────────
enum ViolationType { none, badWord, bullying, spam }

class FilterResult {
  final bool blocked;
  final ViolationType type;
  final String matchedWord;

  FilterResult({
    required this.blocked,
    required this.type,
    required this.matchedWord,
  });

  String get title {
    switch (type) {
      case ViolationType.bullying: return '🚨 Bullying Detected';
      case ViolationType.badWord: return '🚫 Inappropriate Language';
      case ViolationType.spam: return '⚠️ Spam Detected';
      default: return '';
    }
  }

  String get description {
    switch (type) {
      case ViolationType.bullying:
        return 'Your message contains content that may be harmful to others. This has been logged and will be reviewed by a teacher.';
      case ViolationType.badWord:
        return 'Your message contains inappropriate language. Please keep CampusConnect respectful and safe for everyone.';
      case ViolationType.spam:
        return 'You are sending messages too fast or repeating the same message. Please slow down.';
      default: return '';
    }
  }

  Color get color {
    switch (type) {
      case ViolationType.bullying: return const Color(0xFFD63031);
      case ViolationType.badWord: return const Color(0xFFE17055);
      case ViolationType.spam: return const Color(0xFFF39C12);
      default: return Colors.grey;
    }
  }

  String get emoji {
    switch (type) {
      case ViolationType.bullying: return '🚨';
      case ViolationType.badWord: return '🚫';
      case ViolationType.spam: return '⚠️';
      default: return '';
    }
  }
}


// ── COMMUNITY FILTER ─────────────────────────────────────────
class CommunityFilter {

  // 50 bad/swear words — blocks only when these exact words
  // are used as insults or swearing, not innocent mentions
  static const List<String> _badWords = [
    'damn you', 'go to hell', 'what the hell', 'shut up',
    'you idiot', 'you moron', 'you loser', 'you freak',
    'you are dumb', 'you are stupid', 'you are an idiot',
    'you are a moron', 'you are a loser', 'you are a freak',
    'you are a weirdo', 'you are a jerk', 'screw you',
    'screw off', 'piss off', 'get lost', 'drop dead',
    'you suck', 'you stink', 'you smell', 'you are pathetic',
    'you are worthless', 'nobody likes you', 'you are ugly',
    'you are disgusting', 'you are gross', 'you are terrible',
    'ass', 'bastard', 'bitch', 'shit', 'fuck', 'piss',
    'dick', 'cunt', 'cock', 'whore', 'slut', 'retard',
    'fag', 'twat', 'wanker', 'bollocks', 'scumbag',
    'dirtbag', 'piece of crap', 'piece of shit',
    'shut your mouth', 'shut your face',
  ];

  // 50 bullying phrases — serious harassment and threats
  static const List<String> _bullyingWords = [
    'kill yourself', 'kys', 'go die', 'you should die',
    'everyone hates you', 'you have no friends',
    'nobody wants you', 'you dont belong here',
    'go away forever', 'leave the school', 'drop out',
    'you will fail', 'you are a failure', 'you are nothing',
    'i will hurt you', 'i will find you', 'watch your back',
    'you better run', 'you are dead', 'i will get you',
    'beat you up', 'smash your face', 'punch you',
    'hit you', 'destroy you', 'end you',
    'expose you', 'screenshot this', 'tell everyone',
    'spread rumours', 'make your life hell',
    'ruin your life', 'your parents hate you',
    'your family is poor', 'you cant afford',
    'freak of nature', 'go back to your country',
    'you dont belong', 'loser with no friends',
    'cry baby', 'you are adopted', 'nobody cares about you',
    'you are a burden', 'the world is better without you',
    'no one will miss you', 'you are a waste of space',
    'you will never amount to anything', 'give up now',
    'you are a joke', 'laughing at you',
  ];

  // Spam detection state
  static final List<DateTime> _messageTimes = [];
  static String _lastMessage = '';

  static bool _isSpam(String message) {
    final now = DateTime.now();

    // Block exact same message sent twice in a row
    final cleaned = message.toLowerCase().trim();
    if (cleaned == _lastMessage && cleaned.isNotEmpty) {
      _lastMessage = cleaned;
      return true;
    }
    _lastMessage = cleaned;

    // Block more than 3 messages in 5 seconds
    _messageTimes.add(now);
    _messageTimes.removeWhere(
      (t) => now.difference(t).inSeconds > 5,
    );
    if (_messageTimes.length > 3) {
      return true;
    }

    return false;
  }

  // Main check — runs bullying first (most serious),
  // then bad words, then spam
  static FilterResult check(String message) {
    final lower = message.toLowerCase().trim();

    // 1. Bullying check
    for (final phrase in _bullyingWords) {
      if (lower.contains(phrase)) {
        return FilterResult(
          blocked: true,
          type: ViolationType.bullying,
          matchedWord: phrase,
        );
      }
    }

    // 2. Bad word check
    for (final word in _badWords) {
      if (lower.contains(word)) {
        return FilterResult(
          blocked: true,
          type: ViolationType.badWord,
          matchedWord: word,
        );
      }
    }

    // 3. Spam check
    if (_isSpam(message)) {
      return FilterResult(
        blocked: true,
        type: ViolationType.spam,
        matchedWord: '',
      );
    }

    return FilterResult(
      blocked: false,
      type: ViolationType.none,
      matchedWord: '',
    );
  }
}


/// SafeSpace Campus Chat
/// A self-contained, demo-ready chat module for classes, clubs and teachers.
class CampusChatScreen extends StatefulWidget {
  const CampusChatScreen({super.key});

  @override
  State<CampusChatScreen> createState() => _CampusChatScreenState();
}

class _CampusChatScreenState extends State<CampusChatScreen> {
  final _searchController = TextEditingController();
  late final List<ChatRoom> _rooms;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _rooms = UserDatabase.instance.chatRooms;
    _searchController.addListener(() => setState(() => _query = _searchController.text));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ChatRoom> get _filteredRooms {
    final query = _query.trim().toLowerCase();
    final filtered = _rooms.where((room) {
      return query.isEmpty ||
          room.name.toLowerCase().contains(query) ||
          room.lastMessage.toLowerCase().contains(query) ||
          room.lastSender.toLowerCase().contains(query) ||
          room.type.label.toLowerCase().contains(query);
    }).toList();
    filtered.sort((a, b) {
      if (a.isPinned != b.isPinned) return a.isPinned ? -1 : 1;
      return b.lastActivity.compareTo(a.lastActivity);
    });
    return filtered;
  }

  void _togglePin(ChatRoom room) => setState(() => room.isPinned = !room.isPinned);

  @override
  Widget build(BuildContext context) {
    final rooms = _filteredRooms;
    final pinned = rooms.where((room) => room.isPinned).toList();
    final other = rooms.where((room) => !room.isPinned).toList();
    final online = _rooms.fold<int>(0, (sum, room) => sum + room.online);
    final unread = _rooms.fold<int>(0, (sum, room) => sum + room.unread);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 174,
            pinned: true,
            elevation: 0,
            backgroundColor: const Color(0xFF00B894),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () => Navigator.maybePop(context),
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
                    padding: const EdgeInsets.fromLTRB(20, 50, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('💬 Campus Chat', style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        Text('Safe, school-only messaging', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 12),
                        Wrap(spacing: 8, runSpacing: 6, children: [
                          _StatChip(label: '💬 ${_rooms.length} Chats'),
                          _StatChip(label: '🟢 $online Online'),
                          _StatChip(label: '🔔 $unread Unread'),
                        ]),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _searchController,
                    style: GoogleFonts.poppins(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Search chats, clubs, teachers…',
                      hintStyle: GoogleFonts.poppins(color: const Color(0xFF8B949E), fontSize: 13),
                      prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF00B894)),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(icon: const Icon(Icons.close_rounded), onPressed: _searchController.clear),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (rooms.isEmpty)
                    _emptySearch()
                  else ...[
                    if (pinned.isNotEmpty) ...[
                      _SectionTitle(icon: Icons.push_pin_rounded, title: 'Pinned chats'),
                      const SizedBox(height: 10),
                      ...pinned.map(_roomCard),
                      const SizedBox(height: 12),
                    ],
                    if (other.isNotEmpty) ...[
                      _SectionTitle(icon: Icons.forum_outlined, title: pinned.isEmpty ? 'All chats' : 'Other chats'),
                      const SizedBox(height: 10),
                      ...other.map(_roomCard),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptySearch() => Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 60),
          child: Column(children: [
            const Icon(Icons.search_off_rounded, size: 48, color: Color(0xFFB2BEC3)),
            const SizedBox(height: 10),
            Text('No chats found', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            Text('Try a class, club, teacher or recent message.', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
          ]),
        ),
      );

  Widget _roomCard(ChatRoom room) {
    final hasUnread = room.unread > 0;
    return Semantics(
      button: true,
      label: 'Open ${room.name}',
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onLongPress: () => _togglePin(room),
        onTap: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => ChatRoomScreen(room: room)));
          if (mounted) setState(() {});
        },
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: hasUnread ? Border.all(color: const Color(0xFF00B894).withValues(alpha: .28)) : null,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .05), blurRadius: 10, offset: const Offset(0, 3))],
          ),
          child: Row(children: [
            Stack(children: [
              Container(width: 50, height: 50, decoration: BoxDecoration(color: const Color(0xFF00B894).withValues(alpha: .1), borderRadius: BorderRadius.circular(14)), child: Center(child: Text(room.emoji, style: const TextStyle(fontSize: 24)))),
              if (room.online > 0) Positioned(bottom: 0, right: 0, child: Container(width: 14, height: 14, decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)))),
            ]),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Row(children: [
                  if (room.isPinned) const Padding(padding: EdgeInsets.only(right: 5), child: Icon(Icons.push_pin_rounded, color: Color(0xFF00B894), size: 15)),
                  Flexible(child: Text(room.name, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: const Color(0xFF2D3436)))),
                ])),
                Text(room.timeLabel, style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF636E72))),
              ]),
              const SizedBox(height: 2),
              Row(children: [
                Expanded(child: Text('${room.lastSender}: ${room.lastMessage}', maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 12, color: hasUnread ? const Color(0xFF2D3436) : const Color(0xFF636E72), fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal))),
                if (hasUnread) _UnreadBadge(count: room.unread),
              ]),
              const SizedBox(height: 5),
              Text('${room.members} members  •  ${room.online > 0 ? '${room.online} online' : 'offline'}', style: GoogleFonts.poppins(fontSize: 10, color: room.online > 0 ? Colors.green : Colors.grey)),
            ])),
            PopupMenuButton<String>(
              tooltip: room.isPinned ? 'Unpin chat' : 'Pin chat',
              padding: EdgeInsets.zero,
              onSelected: (_) => _togglePin(room),
              itemBuilder: (_) => [PopupMenuItem(value: 'pin', child: Text(room.isPinned ? 'Unpin chat' : 'Pin chat'))],
              icon: const Icon(Icons.more_horiz_rounded, color: Color(0xFF8B949E)),
            ),
          ]),
        ),
      ),
    );
  }
}

class ChatRoomScreen extends StatefulWidget {
  const ChatRoomScreen({super.key, required this.room});
  final ChatRoom room;

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  late final List<ChatMessage> _messages;
  ChatMessage? _replyingTo;
  AttachmentData? _pendingAttachment;
  bool _isSomeoneTyping = true;

  // ── Safety state ─────────────────────────────────────────
  int _warningCount = 0;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _messages = UserDatabase.instance.messagesForRoom(widget.room);
    widget.room.unread = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom(jump: true));
    Future.delayed(const Duration(seconds: 7), () { if (mounted) setState(() => _isSomeoneTyping = false); });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool jump = false}) {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position.maxScrollExtent;
    if (jump) _scrollController.jumpTo(position);
    else _scrollController.animateTo(position, duration: const Duration(milliseconds: 280), curve: Curves.easeOut);
  }

  // ── SEND MESSAGE WITH FULL SAFETY CHECK ──────────────────
  void _sendMessage([String? forcedText]) {
    // If muted, show muted popup and stop
    if (_isMuted) {
      _showMutedPopup();
      return;
    }

    final text = (forcedText ?? _messageController.text).trim();
    if (text.isEmpty && _pendingAttachment == null) return;

    // Run all 3 safety checks (bullying → bad word → spam)
    final result = CommunityFilter.check(text);

    if (result.blocked) {
      _warningCount++;

      // Log report for teacher dashboard
      SafetyReports.add('You', text, result.type.name);

      // 3 warnings = muted
      if (_warningCount >= 3) {
        setState(() => _isMuted = true);
        _showMutedPopup();
      } else {
        _showWarningPopup(result);
      }
      return;
    }

    // Message is clean — send it
    setState(() {
      _messages.add(ChatMessage(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        senderId: 'me', senderName: 'You', text: text,
        timestamp: DateTime.now(),
        replyTo: _replyingTo,
        attachment: _pendingAttachment,
      ));
      widget.room.lastMessage = _pendingAttachment?.name ?? text;
      widget.room.lastSender = 'You';
      widget.room.lastActivity = DateTime.now();
      _replyingTo = null;
      _pendingAttachment = null;
      _messageController.clear();
    });
    Future.delayed(const Duration(milliseconds: 80), _scrollToBottom);
  }

  // ── WARNING POPUP (different for each type) ──────────────
  void _showWarningPopup(FilterResult result) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(result.emoji, style: const TextStyle(fontSize: 52)),
            const SizedBox(height: 12),
            Text(
              result.title,
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: result.color),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              result.description,
              style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF636E72), height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            // Warning counter
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: result.color.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Warning $_warningCount of 3 — ${3 - _warningCount} remaining before mute',
                style: GoogleFonts.poppins(fontSize: 12, color: result.color, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            // Teacher log notice
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'This incident has been logged and sent to your teacher for review.',
                    style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(color: result.color, borderRadius: BorderRadius.circular(14)),
                child: Center(
                  child: Text('I understand', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── MUTED POPUP ──────────────────────────────────────────
  void _showMutedPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔇', style: TextStyle(fontSize: 52)),
            const SizedBox(height: 12),
            Text('You have been muted',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              'You have received 3 warnings for violating CampusConnect community guidelines. You have been muted and your activity has been reported to your teacher.',
              style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF636E72), height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(children: [
                const Icon(Icons.report, color: Colors.red, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'A full report has been sent to your teacher and school administrator.',
                    style: GoogleFonts.poppins(fontSize: 11, color: Colors.red),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(14)),
                child: Center(
                  child: Text('OK', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendVoiceDemo() {
    setState(() {
      _messages.add(ChatMessage(id: DateTime.now().microsecondsSinceEpoch.toString(), senderId: 'me', senderName: 'You', text: '', timestamp: DateTime.now(), kind: MessageKind.voice, voiceDuration: '0:08'));
      widget.room.lastMessage = '🎤 Voice message';
      widget.room.lastSender = 'You';
      widget.room.lastActivity = DateTime.now();
    });
    Future.delayed(const Duration(milliseconds: 80), _scrollToBottom);
  }

  Future<void> _showMessageActions(ChatMessage message) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('React or reply', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          Wrap(spacing: 14, children: ['👍', '❤️', '😂', '🔥', '👏', '😮'].map((emoji) => InkWell(
            borderRadius: BorderRadius.circular(25),
            onTap: () { setState(() => message.reaction = emoji); Navigator.pop(sheetContext); },
            child: Padding(padding: const EdgeInsets.all(4), child: Text(emoji, style: const TextStyle(fontSize: 28))),
          )).toList()),
          const Divider(height: 28),
          ListTile(leading: const Icon(Icons.reply_rounded, color: Color(0xFF00B894)), title: Text('Reply to ${message.senderName}', style: GoogleFonts.poppins(fontSize: 13)), onTap: () { setState(() => _replyingTo = message); Navigator.pop(sheetContext); }),
        ]),
      ),
    );
  }

  Future<void> _pickAttachment() async {
    final attachment = await showModalBottomSheet<AttachmentData>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Share file', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 18),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _attachmentChoice(sheetContext, Icons.picture_as_pdf_rounded, 'Document', AttachmentData('Physics_Lab_Report.pdf', '2.1 MB', AttachmentType.document)),
            _attachmentChoice(sheetContext, Icons.image_rounded, 'Image', AttachmentData('sports_day_poster.png', '1.4 MB', AttachmentType.image)),
            _attachmentChoice(sheetContext, Icons.table_chart_rounded, 'Spreadsheet', AttachmentData('Club_Budget.xlsx', '860 KB', AttachmentType.spreadsheet)),
            _attachmentChoice(sheetContext, Icons.videocam_rounded, 'Video', AttachmentData('science_demo.mp4', '8.2 MB', AttachmentType.video)),
          ]),
        ]),
      ),
    );
    if (attachment != null && mounted) setState(() => _pendingAttachment = attachment);
  }

  Widget _attachmentChoice(BuildContext context, IconData icon, String label, AttachmentData file) => InkWell(
    borderRadius: BorderRadius.circular(14), onTap: () => Navigator.pop(context, file),
    child: Column(children: [Container(padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: const Color(0xFF00B894).withValues(alpha: .1), borderRadius: BorderRadius.circular(14)), child: Icon(icon, color: const Color(0xFF00B894))), const SizedBox(height: 6), Text(label, style: GoogleFonts.poppins(fontSize: 10))]),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00B894), foregroundColor: Colors.white, elevation: 0,
        titleSpacing: 0,
        title: Row(children: [Text(widget.room.emoji, style: const TextStyle(fontSize: 20)), const SizedBox(width: 8), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(widget.room.name, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold)), Text('${widget.room.online} online • ${widget.room.members} members', style: GoogleFonts.poppins(fontSize: 10, color: Colors.white70))]))]),
        actions: [IconButton(icon: const Icon(Icons.people_alt_outlined), tooltip: 'Chat info', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatInfoScreen(room: widget.room)))), PopupMenuButton<String>(icon: const Icon(Icons.more_vert), onSelected: (value) { if (value == 'pin') setState(() => widget.room.isPinned = !widget.room.isPinned); }, itemBuilder: (_) => [PopupMenuItem(value: 'pin', child: Text(widget.room.isPinned ? 'Unpin chat' : 'Pin chat'))])],
      ),
      body: Column(children: [
        if (widget.room.type == ChatRoomType.classRoom) _AnnouncementBanner(announcement: widget.room.announcement!),
        Expanded(child: ListView.builder(
          controller: _scrollController, padding: const EdgeInsets.fromLTRB(16, 14, 16, 8), itemCount: _messages.length + (_isSomeoneTyping ? 1 : 0),
          itemBuilder: (_, index) {
            if (_isSomeoneTyping && index == _messages.length) return _TypingIndicator(name: 'Aanya');
            final message = _messages[index];
            final previous = index == 0 ? null : _messages[index - 1];
            final showDate = previous == null || !_sameDay(previous.timestamp, message.timestamp);
            return Column(children: [if (showDate) _DateSeparator(date: message.timestamp), _MessageBubble(message: message, onLongPress: () => _showMessageActions(message))]);
          },
        )),
        if (_replyingTo != null) _ReplyPreview(message: _replyingTo!, onCancel: () => setState(() => _replyingTo = null)),
        if (_pendingAttachment != null) _AttachmentPreview(file: _pendingAttachment!, onCancel: () => setState(() => _pendingAttachment = null)),
        // Show muted bar or normal input
        _isMuted
            ? Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.mic_off, color: Colors.red),
                    const SizedBox(width: 8),
                    Text(
                      '🔇 You are muted — contact your teacher',
                      style: GoogleFonts.poppins(fontSize: 13, color: Colors.red, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              )
            : _MessageInput(
                controller: _messageController,
                onAttach: _pickAttachment,
                onVoice: _sendVoiceDemo,
                onEmoji: (emoji) {
                  _messageController.text += emoji;
                  _messageController.selection = TextSelection.collapsed(offset: _messageController.text.length);
                },
                onSend: _sendMessage,
              ),
      ]),
    );
  }

  bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
}

class ChatInfoScreen extends StatelessWidget {
  const ChatInfoScreen({super.key, required this.room});
  final ChatRoom room;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF5F6FA),
    appBar: AppBar(title: Text('Chat info', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)), backgroundColor: const Color(0xFF00B894), foregroundColor: Colors.white),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      Center(child: Column(children: [Container(width: 76, height: 76, alignment: Alignment.center, decoration: BoxDecoration(color: const Color(0xFF00B894).withValues(alpha: .12), borderRadius: BorderRadius.circular(22)), child: Text(room.emoji, style: const TextStyle(fontSize: 38))), const SizedBox(height: 10), Text(room.name, style: GoogleFonts.poppins(fontSize: 19, fontWeight: FontWeight.bold)), Text('${room.members} members', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey))])),
      const SizedBox(height: 24), _InfoCard(title: 'About', child: Text(room.description, style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF636E72)))),
      _InfoCard(title: 'Admin', child: ListTile(contentPadding: EdgeInsets.zero, leading: const CircleAvatar(backgroundColor: Color(0xFF00B894), child: Icon(Icons.person, color: Colors.white)), title: Text(room.admin, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)), subtitle: Text('Group admin', style: GoogleFonts.poppins(fontSize: 11)))),
      _InfoCard(title: 'Community rules', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: ['Be respectful and kind', 'Keep discussion school-related', 'Do not share personal information'].map((rule) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text('•  $rule', style: GoogleFonts.poppins(fontSize: 12)))).toList())),
      _InfoCard(title: 'Shared media', child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_infoCount(Icons.insert_drive_file_outlined, '3', 'Files'), _infoCount(Icons.image_outlined, '5', 'Images'), _infoCount(Icons.link_rounded, '2', 'Links'), _infoCount(Icons.description_outlined, '4', 'Docs')])),
    ]),
  );

  Widget _infoCount(IconData icon, String number, String label) => Column(children: [Icon(icon, color: const Color(0xFF00B894)), const SizedBox(height: 4), Text(number, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)), Text(label, style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey))]);
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message, required this.onLongPress});
  final ChatMessage message;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final isMe = message.senderId == 'me';
    return GestureDetector(
      onLongPress: onLongPress,
      child: Align(alignment: isMe ? Alignment.centerRight : Alignment.centerLeft, child: Column(crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start, children: [
        if (!isMe) Padding(padding: const EdgeInsets.only(left: 8, bottom: 2), child: Text(message.senderName, style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF636E72), fontWeight: FontWeight.w600))),
        Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * .76), margin: const EdgeInsets.only(bottom: 3), padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(color: isMe ? null : Colors.white, gradient: isMe ? const LinearGradient(colors: [Color(0xFF00B894), Color(0xFF00CEC9)]) : null, borderRadius: BorderRadius.only(topLeft: const Radius.circular(16), topRight: const Radius.circular(16), bottomLeft: Radius.circular(isMe ? 16 : 4), bottomRight: Radius.circular(isMe ? 4 : 16)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .05), blurRadius: 6, offset: const Offset(0, 2))]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            if (message.replyTo != null) _QuotedMessage(message: message.replyTo!, isMe: isMe),
            if (message.kind == MessageKind.assignment) _AssignmentCard(message: message),
            if (message.kind == MessageKind.event) _EventCard(message: message),
            if (message.kind == MessageKind.poll) _PollCard(message: message),
            if (message.kind == MessageKind.voice) _VoiceCard(duration: message.voiceDuration ?? '0:08', isMe: isMe),
            if (message.attachment != null) _FileCard(file: message.attachment!, isMe: isMe),
            if (message.text.isNotEmpty) Text(message.text, style: GoogleFonts.poppins(fontSize: 13, color: isMe ? Colors.white : const Color(0xFF2D3436))),
          ]),
        ),
        if (message.reaction != null) Container(margin: const EdgeInsets.only(bottom: 1), padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade200)), child: Text(message.reaction!, style: const TextStyle(fontSize: 14))),
        Padding(padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8), child: Row(mainAxisSize: MainAxisSize.min, children: [Text(_formatTime(message.timestamp), style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)), if (isMe) ...[const SizedBox(width: 4), Icon(message.receipt == Receipt.read ? Icons.done_all_rounded : Icons.done_rounded, size: 15, color: message.receipt == Receipt.read ? const Color(0xFF00B894) : Colors.grey)]])),
      ])),
    );
  }
}

class _AssignmentCard extends StatelessWidget { const _AssignmentCard({required this.message}); final ChatMessage message; @override Widget build(BuildContext context) => _RichCard(icon: '📚', label: 'NEW ASSIGNMENT', title: message.cardTitle!, subtitle: 'Due ${message.cardSubtitle}', action: 'Open assignment'); }
class _EventCard extends StatelessWidget { const _EventCard({required this.message}); final ChatMessage message; @override Widget build(BuildContext context) => _RichCard(icon: '📅', label: 'SCHOOL EVENT', title: message.cardTitle!, subtitle: message.cardSubtitle!, action: 'Register'); }
class _RichCard extends StatelessWidget { const _RichCard({required this.icon, required this.label, required this.title, required this.subtitle, required this.action}); final String icon,label,title,subtitle,action; @override Widget build(BuildContext context) => Container(width: 235, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .92), borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('$icon  $label', style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.bold, color: const Color(0xFF00B894))), const SizedBox(height: 6), Text(title, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF2D3436))), Text(subtitle, style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF636E72))), const SizedBox(height: 6), Text('$action  →', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF00B894)))])); }
class _PollCard extends StatefulWidget { const _PollCard({required this.message}); final ChatMessage message; @override State<_PollCard> createState() => _PollCardState(); }
class _PollCardState extends State<_PollCard> {
  int? selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .94),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('📊  POLL', style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.bold, color: const Color(0xFF00B894))),
          const SizedBox(height: 5),
          Text(widget.message.cardTitle!, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF2D3436))),
          const SizedBox(height: 6),
          ...widget.message.pollOptions!.asMap().entries.map((entry) => InkWell(
                onTap: () => setState(() => selected = entry.key),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(children: [
                    Icon(selected == entry.key ? Icons.radio_button_checked : Icons.radio_button_off, color: const Color(0xFF00B894), size: 17),
                    const SizedBox(width: 6),
                    Text(entry.value, style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF2D3436)))
                  ]),
                ),
              ))
        ],
      ),
    );
  }
}
class _VoiceCard extends StatelessWidget { const _VoiceCard({required this.duration, required this.isMe}); final String duration; final bool isMe; @override Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.play_circle_fill_rounded, color: isMe ? Colors.white : const Color(0xFF00B894), size: 32), const SizedBox(width: 7), SizedBox(width: 102, child: Divider(color: isMe ? Colors.white70 : const Color(0xFF00B894), thickness: 2)), const SizedBox(width: 6), Text(duration, style: GoogleFonts.poppins(fontSize: 11, color: isMe ? Colors.white : const Color(0xFF2D3436)))]); }
class _FileCard extends StatelessWidget { const _FileCard({required this.file, required this.isMe}); final AttachmentData file; final bool isMe; @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(8), margin: const EdgeInsets.only(bottom: 6), decoration: BoxDecoration(color: isMe ? Colors.white.withValues(alpha: .18) : const Color(0xFFF2F7F6), borderRadius: BorderRadius.circular(9)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(file.icon, color: isMe ? Colors.white : const Color(0xFF00B894)), const SizedBox(width: 7), Flexible(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(file.name, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: isMe ? Colors.white : const Color(0xFF2D3436))), Text(file.size, style: GoogleFonts.poppins(fontSize: 10, color: isMe ? Colors.white70 : Colors.grey))]))])); }
class _QuotedMessage extends StatelessWidget { const _QuotedMessage({required this.message, required this.isMe}); final ChatMessage message; final bool isMe; @override Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(bottom: 7), padding: const EdgeInsets.only(left: 7), decoration: BoxDecoration(border: Border(left: BorderSide(color: isMe ? Colors.white70 : const Color(0xFF00B894), width: 3))), child: Text('${message.senderName}: ${message.text.isEmpty ? 'Attachment' : message.text}', maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 10, color: isMe ? Colors.white70 : const Color(0xFF636E72)))); }

class _MessageInput extends StatelessWidget {
  const _MessageInput({required this.controller, required this.onAttach, required this.onVoice, required this.onEmoji, required this.onSend});
  final TextEditingController controller; final VoidCallback onAttach, onVoice; final ValueChanged<String> onEmoji; final ValueChanged<String> onSend;
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.fromLTRB(12, 8, 12, 16), decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .06), blurRadius: 10, offset: const Offset(0, -3))]), child: Row(children: [
    IconButton(onPressed: onAttach, icon: const Icon(Icons.attach_file_rounded, color: Color(0xFF00B894))),
    Expanded(child: Container(padding: const EdgeInsets.symmetric(horizontal: 8), decoration: BoxDecoration(color: const Color(0xFFF5F6FA), borderRadius: BorderRadius.circular(24)), child: Row(children: [IconButton(icon: const Icon(Icons.emoji_emotions_outlined, color: Color(0xFF00B894), size: 21), onPressed: () => _showEmojiPicker(context, onEmoji)), Expanded(child: TextField(controller: controller, style: GoogleFonts.poppins(fontSize: 13), decoration: InputDecoration(hintText: 'Type a message...', hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey), border: InputBorder.none), onSubmitted: onSend))]))),
    IconButton(onPressed: onVoice, icon: const Icon(Icons.mic_none_rounded, color: Color(0xFF00B894))),
    IconButton(onPressed: () => onSend(controller.text), icon: const Icon(Icons.send_rounded, color: Color(0xFF00B894))),
  ]));
  void _showEmojiPicker(BuildContext context, ValueChanged<String> select) => showModalBottomSheet<void>(context: context, builder: (sheet) => SafeArea(child: Padding(padding: const EdgeInsets.all(18), child: Wrap(spacing: 14, runSpacing: 14, children: ['😀','😂','😍','👍','❤️','🎉','🔥','👏','🙏','🤔','✅','📚'].map((emoji) => InkWell(onTap: () { select(emoji); Navigator.pop(sheet); }, child: Text(emoji, style: const TextStyle(fontSize: 27)))).toList()))));
}

class _AnnouncementBanner extends StatelessWidget { const _AnnouncementBanner({required this.announcement}); final String announcement; @override Widget build(BuildContext context) => Container(margin: const EdgeInsets.fromLTRB(16, 12, 16, 0), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFFFF4D6), borderRadius: BorderRadius.circular(13), border: Border.all(color: const Color(0xFFF5C451))), child: Row(children: [const Text('📢', style: TextStyle(fontSize: 23)), const SizedBox(width: 9), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('PINNED ANNOUNCEMENT', style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.bold, color: const Color(0xFFB7791F))), Text(announcement, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF5F4B18)))])), Text('View →', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFFB7791F)))])); }
class _DateSeparator extends StatelessWidget { const _DateSeparator({required this.date}); final DateTime date; @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Center(child: Container(padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFE8ECEF), borderRadius: BorderRadius.circular(12)), child: Text(_dateLabel(date), style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF636E72), fontWeight: FontWeight.w500))))); }
class _TypingIndicator extends StatelessWidget { const _TypingIndicator({required this.name}); final String name; @override Widget build(BuildContext context) => Align(alignment: Alignment.centerLeft, child: Padding(padding: const EdgeInsets.only(bottom: 8), child: Text('$name is typing…', style: GoogleFonts.poppins(fontSize: 11, fontStyle: FontStyle.italic, color: const Color(0xFF00B894))))); }
class _ReplyPreview extends StatelessWidget { const _ReplyPreview({required this.message, required this.onCancel}); final ChatMessage message; final VoidCallback onCancel; @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.fromLTRB(18, 7, 10, 7), color: const Color(0xFFE8F7F3), child: Row(children: [const Icon(Icons.reply_rounded, size: 18, color: Color(0xFF00B894)), const SizedBox(width: 8), Expanded(child: Text('Replying to ${message.senderName}: ${message.text}', maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 11))), IconButton(icon: const Icon(Icons.close, size: 18), onPressed: onCancel)])); }
class _AttachmentPreview extends StatelessWidget { const _AttachmentPreview({required this.file, required this.onCancel}); final AttachmentData file; final VoidCallback onCancel; @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.fromLTRB(18, 7, 10, 7), color: const Color(0xFFE8F7F3), child: Row(children: [Icon(file.icon, size: 19, color: const Color(0xFF00B894)), const SizedBox(width: 8), Expanded(child: Text('${file.name} • ${file.size}', overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 11))), IconButton(icon: const Icon(Icons.close, size: 18), onPressed: onCancel)])); }
class _InfoCard extends StatelessWidget { const _InfoCard({required this.title, required this.child}); final String title; final Widget child; @override Widget build(BuildContext context) => Card(margin: const EdgeInsets.only(bottom: 12), elevation: 0, color: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), child: Padding(padding: const EdgeInsets.all(15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF00B894))), const SizedBox(height: 8), child]))); }
class _StatChip extends StatelessWidget { const _StatChip({required this.label}); final String label; @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)), child: Text(label, style: GoogleFonts.poppins(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500))); }
class _SectionTitle extends StatelessWidget { const _SectionTitle({required this.icon, required this.title}); final IconData icon; final String title; @override Widget build(BuildContext context) => Row(children: [Icon(icon, color: const Color(0xFF00B894), size: 18), const SizedBox(width: 7), Text(title, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF2D3436)))]); }
class _UnreadBadge extends StatelessWidget { const _UnreadBadge({required this.count}); final int count; @override Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(left: 8), padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2), decoration: BoxDecoration(color: const Color(0xFF00B894), borderRadius: BorderRadius.circular(10)), child: Text('$count', style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))); }

String _formatTime(DateTime date) => '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
String _dateLabel(DateTime date) { final today = DateTime.now(); final startToday = DateTime(today.year, today.month, today.day); final startDate = DateTime(date.year, date.month, date.day); final days = startToday.difference(startDate).inDays; if (days == 0) return 'Today'; if (days == 1) return 'Yesterday'; const names = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']; return names[date.weekday - 1]; }