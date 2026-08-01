import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../user_database.dart'; // Provides AppUser from your existing project.

// -----------------------------------------------------------------------------
// CAMPUSCONNECT — CLASS FEED (ONE COMPLETE FILE)
// Shared between student and teacher dashboards.
// Open it with: ClassFeedScreen(currentUser: loggedInUser)
// -----------------------------------------------------------------------------

enum FeedType { question, discussion, announcement, resource }

extension FeedTypeText on FeedType {
  String get label => switch (this) {
        FeedType.question => 'Question', FeedType.discussion => 'Discussion',
        FeedType.announcement => 'Announcement', FeedType.resource => 'Resource',
      };
  IconData get icon => switch (this) {
        FeedType.question => Icons.help_outline_rounded, FeedType.discussion => Icons.forum_outlined,
        FeedType.announcement => Icons.campaign_outlined, FeedType.resource => Icons.menu_book_outlined,
      };
  Color get color => switch (this) {
        FeedType.question => const Color(0xFF0984E3), FeedType.discussion => const Color(0xFF00B894),
        FeedType.announcement => const Color(0xFFF39C12), FeedType.resource => const Color(0xFF6C5CE7),
      };
}

class FeedComment {
  FeedComment(this.author, this.role, this.text, this.time, {this.replyTo});
  final String author, role, text; final DateTime time; final String? replyTo;
}

class FeedPost {
  FeedPost({required this.id, required this.author, required this.role, required this.type, required this.title, required this.text, required this.time, this.subject, this.pinned = false, this.likes = 0, this.liked = false, List<FeedComment>? comments}) : comments = comments ?? [];
  final String id, author, role, title, text; final FeedType type; final DateTime time; final String? subject;
  bool pinned, liked; int likes; final List<FeedComment> comments;
}

class _FeedStore extends ChangeNotifier {
  final posts = <FeedPost>[
    FeedPost(id: '1', author: 'Jason', role: 'Teacher', type: FeedType.announcement, title: 'Physics Lab Report — due Friday', text: 'Please submit your observations, calculation sheet, labelled graph, and conclusion by Friday at 5:00 PM. Bring questions to tomorrow’s class.', subject: 'Physics', time: DateTime.now().subtract(const Duration(hours: 2)), pinned: true, likes: 18, comments: [FeedComment('Pranav', 'Student', 'Thank you, sir. Is the graph part compulsory?', DateTime.now().subtract(const Duration(hours: 1, minutes: 44))), FeedComment('Jason', 'Teacher', 'Yes, please include one labelled graph.', DateTime.now().subtract(const Duration(hours: 1, minutes: 30)), replyTo: 'Pranav')]),
    FeedPost(id: '2', author: 'Aanya', role: 'Student', type: FeedType.question, title: 'Can someone explain the quadratic formula step?', text: 'I understand the formula, but I get confused when substituting a negative value for b. Could somebody share a quick example?', subject: 'Mathematics', time: DateTime.now().subtract(const Duration(hours: 4)), likes: 7, comments: [FeedComment('Kushagr', 'Student', 'Remember that −b means you reverse the sign of b first.', DateTime.now().subtract(const Duration(hours: 3, minutes: 42)))]),
    FeedPost(id: '3', author: 'Jack', role: 'Teacher', type: FeedType.resource, title: 'Binary Search revision resource', text: 'I added a short revision sheet to the Computer Science resources. Use it before next week’s problem-solving session.', subject: 'Computer Science', time: DateTime.now().subtract(const Duration(days: 1)), likes: 13),
    FeedPost(id: '4', author: 'Adhvik', role: 'Student', type: FeedType.discussion, title: 'Study group for the science quiz?', text: 'Would anyone like to revise chapters 3 and 4 together after school on Wednesday? We can meet in the library.', subject: 'Science', time: DateTime.now().subtract(const Duration(days: 1, hours: 5)), likes: 9),
  ];
  bool roboticsRegistered = false;
  void like(FeedPost post) { post.liked = !post.liked; post.likes += post.liked ? 1 : -1; notifyListeners(); }
  void pin(FeedPost post) { post.pinned = !post.pinned; notifyListeners(); }
  void addPost(FeedPost post) { posts.insert(0, post); notifyListeners(); }
  void comment(FeedPost post, FeedComment comment) { post.comments.add(comment); notifyListeners(); }
  void club() { roboticsRegistered = !roboticsRegistered; notifyListeners(); }
}

class ClassFeedScreen extends StatefulWidget {
  const ClassFeedScreen({super.key, required this.currentUser});
  final AppUser currentUser;
  @override State<ClassFeedScreen> createState() => _ClassFeedScreenState();
}

class _ClassFeedScreenState extends State<ClassFeedScreen> {
  final _store = _FeedStore();
  final _search = TextEditingController();
  String _query = ''; FeedType? _filter;
  bool get _teacher => widget.currentUser.role == 'Teacher';
  @override void initState() { super.initState(); _search.addListener(() => setState(() => _query = _search.text)); }
  @override void dispose() { _search.dispose(); _store.dispose(); super.dispose(); }
  List<FeedPost> get _posts {
    final q = _query.trim().toLowerCase();
    final result = _store.posts.where((p) => (_filter == null || p.type == _filter) && (q.isEmpty || '${p.title} ${p.text} ${p.author} ${p.subject ?? ''}'.toLowerCase().contains(q))).toList();
    result.sort((a, b) => a.pinned != b.pinned ? (a.pinned ? -1 : 1) : b.time.compareTo(a.time));
    return result;
  }
  void _toast(String text, [Color color = const Color(0xFF00B894)]) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text, style: GoogleFonts.poppins(fontSize: 12)), backgroundColor: color, behavior: SnackBarBehavior.floating));

  @override Widget build(BuildContext context) => AnimatedBuilder(animation: _store, builder: (_, __) => Scaffold(
    backgroundColor: const Color(0xFFF5F6FA),
    floatingActionButton: FloatingActionButton.extended(heroTag: 'feedCreate', backgroundColor: const Color(0xFF00B894), foregroundColor: Colors.white, onPressed: _createPost, icon: const Icon(Icons.add_rounded), label: Text(_teacher ? 'Create post' : 'Ask or share', style: GoogleFonts.poppins(fontWeight: FontWeight.w600))),
    body: CustomScrollView(slivers: [_header(), SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 105), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _searchField(), const SizedBox(height: 11), _filters(), const SizedBox(height: 16), _composer(), const SizedBox(height: 19),
      _title(Icons.notifications_active_outlined, 'For you', action: 'View all', onTap: _notifications), const SizedBox(height: 9), _notificationsStrip(), const SizedBox(height: 20),
      _title(Icons.dynamic_feed_rounded, _filter == null ? 'Class feed' : '${_filter!.label} posts'), const SizedBox(height: 10),
      if (_posts.isEmpty) _empty() else ..._posts.map(_postCard),
    ])))],
  )));

  Widget _header() => SliverAppBar(expandedHeight: 164, pinned: true, elevation: 0, backgroundColor: const Color(0xFF00B894), leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white), onPressed: () => Navigator.maybePop(context)), actions: [IconButton(icon: const Icon(Icons.shield_outlined, color: Colors.white), tooltip: 'Safety Centre', onPressed: _safety), IconButton(icon: const Icon(Icons.notifications_none_rounded, color: Colors.white), onPressed: _notifications)], flexibleSpace: FlexibleSpaceBar(background: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF00B894), Color(0xFF2D3436)], begin: Alignment.topLeft, end: Alignment.bottomRight)), child: SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(20, 50, 20, 15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('📢 Class Feed', style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)), Text('Learn together. Ask, share and stay updated.', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)), const SizedBox(height: 13), Wrap(spacing: 8, children: [_headChip('🏫 9A General'), _headChip('💬 ${_store.posts.length} posts'), _headChip(_teacher ? '🧑‍🏫 Teacher view' : '🎓 Student view')])]))))));
  Widget _headChip(String value) => Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4), decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(16)), child: Text(value, style: GoogleFonts.poppins(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w500)));
  Widget _searchField() => TextField(controller: _search, style: GoogleFonts.poppins(fontSize: 13), decoration: InputDecoration(hintText: 'Search questions, announcements, people…', hintStyle: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF8B949E)), prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF00B894)), suffixIcon: _query.isEmpty ? null : IconButton(icon: const Icon(Icons.close_rounded), onPressed: _search.clear), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(vertical: 14)));
  Widget _filters() => SizedBox(height: 37, child: ListView(scrollDirection: Axis.horizontal, children: [null, ...FeedType.values].map((type) { final selected = _filter == type; final text = type?.label ?? 'All'; final icon = type?.icon ?? Icons.apps_rounded; return Padding(padding: const EdgeInsets.only(right: 8), child: FilterChip(selected: selected, showCheckmark: false, avatar: Icon(icon, size: 15, color: selected ? Colors.white : const Color(0xFF00B894)), label: Text(text, style: GoogleFonts.poppins(fontSize: 11, color: selected ? Colors.white : const Color(0xFF2D3436))), selectedColor: const Color(0xFF00B894), backgroundColor: Colors.white, side: BorderSide(color: selected ? Colors.transparent : const Color(0xFFE2E8F0)), onSelected: (_) => setState(() => _filter = type))); }).toList()));
  Widget _composer() => InkWell(onTap: _createPost, borderRadius: BorderRadius.circular(16), child: Ink(padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [_shadow]), child: Row(children: [CircleAvatar(backgroundColor: const Color(0xFF00B894).withOpacity(.12), child: Text(_initials(widget.currentUser.name), style: GoogleFonts.poppins(color: const Color(0xFF00B894), fontWeight: FontWeight.bold))), const SizedBox(width: 10), Expanded(child: Text(_teacher ? 'Share an update with 9A General…' : 'Ask a question or share a useful idea…', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF8B949E)))), const Icon(Icons.edit_note_rounded, color: Color(0xFF00B894))])));
  Widget _title(IconData icon, String value, {String? action, VoidCallback? onTap}) => Row(children: [Icon(icon, size: 18, color: const Color(0xFF00B894)), const SizedBox(width: 7), Text(value, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF2D3436))), const Spacer(), if (action != null) TextButton(onPressed: onTap, child: Text(action, style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF00B894), fontWeight: FontWeight.w600)))]);
  Widget _notificationsStrip() => SizedBox(height: 114, child: ListView(scrollDirection: Axis.horizontal, children: [_notice('📚', const Color(0xFF6C5CE7), 'Assignment due', 'Physics Lab Report\nDue in 2 days', _assignment), _notice('🤖', const Color(0xFF0984E3), 'Club open', 'AI & Robotics Workshop\n8 spots left', _club), _notice('📌', const Color(0xFFF39C12), 'New announcement', 'Jason pinned a post\n2 hours ago', () => setState(() => _filter = FeedType.announcement))]));
  Widget _notice(String emoji, Color color, String title, String subtitle, VoidCallback tap) => InkWell(onTap: tap, borderRadius: BorderRadius.circular(16), child: Ink(width: 190, padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(.15)), boxShadow: [_shadow]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Text(emoji, style: const TextStyle(fontSize: 20)), const SizedBox(width: 6), Text(title, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: color))]), const Spacer(), Text(subtitle, style: GoogleFonts.poppins(fontSize: 11, height: 1.35, color: const Color(0xFF4B5563)))])));
  Widget _postCard(FeedPost p) => InkWell(onTap: () => _comments(p), borderRadius: BorderRadius.circular(18), child: Ink(padding: const EdgeInsets.fromLTRB(15, 15, 15, 13), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: p.pinned ? Border.all(color: const Color(0xFFF4C542)) : null, boxShadow: [_shadow]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    if (p.pinned) Padding(padding: const EdgeInsets.only(bottom: 9), child: Row(children: [const Icon(Icons.push_pin_rounded, size: 15, color: Color(0xFFF39C12)), const SizedBox(width: 5), Text('PINNED BY TEACHER', style: GoogleFonts.poppins(fontSize: 9, color: const Color(0xFFB7791F), fontWeight: FontWeight.bold))])),
    Row(children: [CircleAvatar(backgroundColor: _roleColor(p.role).withOpacity(.13), child: Text(_initials(p.author), style: GoogleFonts.poppins(fontSize: 12, color: _roleColor(p.role), fontWeight: FontWeight.bold))), const SizedBox(width: 9), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Text(p.author, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold)), if (p.role == 'Teacher') ...[const SizedBox(width: 5), _teacherBadge()]]), Text('${p.role} • ${_time(p.time)}', style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey))])), PopupMenuButton<String>(padding: EdgeInsets.zero, icon: const Icon(Icons.more_horiz_rounded, color: Color(0xFF8B949E)), onSelected: (action) { if (action == 'pin') { _store.pin(p); _toast(p.pinned ? 'Post unpinned' : 'Post pinned to the top'); } else { _report(p); } }, itemBuilder: (_) => [if (_teacher) PopupMenuItem(value: 'pin', child: Text(p.pinned ? 'Unpin post' : 'Pin post')), const PopupMenuItem(value: 'report', child: Text('Report post'))])]),
    const SizedBox(height: 12), _type(p), const SizedBox(height: 7), Text(p.title, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF2D3436))), const SizedBox(height: 5), Text(p.text, maxLines: 4, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 12, height: 1.45, color: const Color(0xFF636E72))), const SizedBox(height: 12), const Divider(height: 1), Row(children: [_action(p.liked ? Icons.favorite_rounded : Icons.favorite_border_rounded, '${p.likes}', p.liked, () => _store.like(p)), _action(Icons.chat_bubble_outline_rounded, '${p.comments.length} ${p.comments.length == 1 ? 'reply' : 'replies'}', false, () => _comments(p)), const Spacer(), IconButton(icon: const Icon(Icons.share_outlined, color: Color(0xFF636E72), size: 20), onPressed: () => _toast('Post link copied — demo mode'))])
  ])));
  Widget _type(FeedPost p) => Row(children: [Icon(p.type.icon, size: 13, color: p.type.color), const SizedBox(width: 4), Text(p.type.label.toUpperCase(), style: GoogleFonts.poppins(fontSize: 9, color: p.type.color, fontWeight: FontWeight.bold)), if (p.subject != null) ...[const SizedBox(width: 6), Text('• ${p.subject}', style: GoogleFonts.poppins(fontSize: 9, color: Colors.grey))]]);
  Widget _action(IconData icon, String label, bool active, VoidCallback tap) => TextButton.icon(onPressed: tap, icon: Icon(icon, size: 18, color: active ? Colors.red : const Color(0xFF636E72)), label: Text(label, style: GoogleFonts.poppins(fontSize: 11, color: active ? Colors.red : const Color(0xFF636E72))), style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)));
  Widget _empty() => Padding(padding: const EdgeInsets.symmetric(vertical: 50), child: Center(child: Column(children: [const Icon(Icons.search_off_rounded, size: 48, color: Color(0xFFB2BEC3)), const SizedBox(height: 9), Text('No matching posts', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)), Text('Try a different word or filter.', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey))])));

  void _createPost() { final title = TextEditingController(); final text = TextEditingController(); FeedType type = _teacher ? FeedType.announcement : FeedType.question; String subject = 'General'; showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (sheet) => StatefulBuilder(builder: (context, setSheet) => Padding(padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom), child: Container(padding: const EdgeInsets.fromLTRB(20, 18, 20, 24), decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(25))), child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Expanded(child: Text(_teacher ? 'Create class post' : 'Create a post', style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.bold))), IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(sheet))]), Text('Keep it helpful, respectful and school-related.', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)), const SizedBox(height: 15), Wrap(spacing: 7, runSpacing: 7, children: (_teacher ? [FeedType.announcement, FeedType.resource, FeedType.discussion] : [FeedType.question, FeedType.discussion, FeedType.resource]).map((x) => ChoiceChip(label: Text(x.label, style: GoogleFonts.poppins(fontSize: 11)), selected: type == x, onSelected: (_) => setSheet(() => type = x))).toList()), const SizedBox(height: 12), _field(title, 'Title (example: Need help with question 4)', 1), const SizedBox(height: 9), _field(text, 'Write your post…', 4), const SizedBox(height: 9), DropdownButtonFormField(value: subject, decoration: _input('Subject'), items: const ['General','Mathematics','Physics','Science','Computer Science','English'].map((v) => DropdownMenuItem(value: v, child: Text(v, style: GoogleFonts.poppins(fontSize: 12)))).toList(), onChanged: (v) => setSheet(() => subject = v!)), const SizedBox(height: 14), SizedBox(width: double.infinity, child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00B894), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 13)), onPressed: () { if (title.text.trim().isEmpty || text.text.trim().isEmpty) { _toast('Please add a title and post text.', Colors.red); return; } if (_blocked('${title.text} ${text.text}')) { _toast('🚫 Post blocked by the community safety filter.', Colors.red); return; } _store.addPost(FeedPost(id: DateTime.now().microsecondsSinceEpoch.toString(), author: widget.currentUser.name, role: widget.currentUser.role, type: type, title: title.text.trim(), text: text.text.trim(), time: DateTime.now(), subject: subject == 'General' ? null : subject)); Navigator.pop(sheet); _toast(type == FeedType.announcement ? 'Announcement posted to 9A General' : 'Your post is now live'); }, icon: const Icon(Icons.send_rounded), label: Text('Publish post', style: GoogleFonts.poppins(fontWeight: FontWeight.bold))))])))))).whenComplete(() { title.dispose(); text.dispose(); }); }
  Widget _field(TextEditingController c, String hint, int lines) => TextField(controller: c, maxLines: lines, style: GoogleFonts.poppins(fontSize: 12), decoration: _input(hint));
  InputDecoration _input(String hint) => InputDecoration(hintText: hint, hintStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey), filled: true, fillColor: const Color(0xFFF5F6FA), border: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide.none), contentPadding: const EdgeInsets.all(13));
  void _comments(FeedPost p) {
    final c = TextEditingController();
    String? reply;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheet) => StatefulBuilder(
        builder: (context, setSheet) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
          child: Container(
            height: MediaQuery.sizeOf(context).height * .76,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
            child: Column(
              children: [
                Row(children: [
                  Expanded(child: Text('Replies (${p.comments.length})', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold))),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(sheet)),
                ]),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(p.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF636E72))),
                ),
                const Divider(height: 20),
                Expanded(
                  child: AnimatedBuilder(
                    animation: _store,
                    builder: (_, __) => p.comments.isEmpty
                        ? Center(child: Text('No replies yet. Be the first to help!', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)))
                        : ListView(
                            children: p.comments.map((x) => InkWell(
                                  onTap: () => setSheet(() => reply = x.author),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(radius: 16, backgroundColor: _roleColor(x.role).withOpacity(.12), child: Text(_initials(x.author), style: GoogleFonts.poppins(fontSize: 9, color: _roleColor(x.role), fontWeight: FontWeight.bold))),
                                        const SizedBox(width: 9),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(children: [
                                                Text(x.author, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold)),
                                                if (x.role == 'Teacher') ...[const SizedBox(width: 4), _teacherBadge()],
                                                const Spacer(),
                                                Text(_time(x.time), style: GoogleFonts.poppins(fontSize: 9, color: Colors.grey)),
                                              ]),
                                              if (x.replyTo != null) Text('↪ Replying to ${x.replyTo}', style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF00B894))),
                                              Text(x.text, style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF4B5563))),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )).toList(),
                          ),
                  ),
                ),
                if (reply != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => setSheet(() => reply = null),
                      child: Text('Replying to $reply  ×', style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF00B894))),
                    ),
                  ),
                Row(children: [
                  Expanded(child: TextField(controller: c, style: GoogleFonts.poppins(fontSize: 12), decoration: _input('Write a helpful reply…'))),
                  IconButton(
                    icon: const Icon(Icons.send_rounded, color: Color(0xFF00B894)),
                    onPressed: () {
                      if (c.text.trim().isEmpty) return;
                      if (_blocked(c.text)) { _toast('🚫 Reply blocked by the safety filter.', Colors.red); return; }
                      _store.comment(p, FeedComment(widget.currentUser.name, widget.currentUser.role, c.text.trim(), DateTime.now(), replyTo: reply));
                      c.clear();
                      setSheet(() => reply = null);
                    },
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    ).whenComplete(c.dispose);
  }
  void _report(FeedPost p) { String reason = 'Inappropriate or unsafe content'; showDialog(context: context, builder: (d) => StatefulBuilder(builder: (context, setD) => AlertDialog(title: Text('Report post', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)), content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Reports are sent privately to teachers and administrators.', style: GoogleFonts.poppins(fontSize: 12)), ...['Inappropriate or unsafe content','Bullying or harassment','Spam','Not school-related'].map((x) => RadioListTile(value: x, groupValue: reason, dense: true, contentPadding: EdgeInsets.zero, title: Text(x, style: GoogleFonts.poppins(fontSize: 11)), onChanged: (v) => setD(() => reason = v!)))]), actions: [TextButton(onPressed: () => Navigator.pop(d), child: const Text('Cancel')), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white), onPressed: () { Navigator.pop(d); _toast('Thanks — your report has been sent safely.'); }, child: const Text('Report'))]))); }
  void _notifications() => _bottom('Feed notifications', [ _note(Icons.assignment_late_outlined, 'Physics Lab Report is due in 2 days', const Color(0xFF6C5CE7), _assignment), _note(Icons.groups_2_outlined, 'AI & Robotics Workshop has 8 spots left', const Color(0xFF0984E3), _club), _note(Icons.push_pin_outlined, 'Jason pinned a new announcement', const Color(0xFFF39C12), () { Navigator.pop(context); setState(() => _filter = FeedType.announcement); }) ]);
  void _safety() => _bottom('SafeSpace Centre', [Text('This class feed is a school-only space designed for respectful learning.', style: GoogleFonts.poppins(fontSize: 12, height: 1.45, color: const Color(0xFF636E72))), const SizedBox(height: 14), _safetyItem(Icons.block_rounded, 'Community safety filter', 'Blocks harmful or inappropriate language before it is posted.'), _safetyItem(Icons.flag_outlined, 'Private reporting', 'Report unsafe posts. Reports go only to teachers and administrators.'), _safetyItem(Icons.school_outlined, 'School-focused community', 'Keep discussions helpful, respectful, and related to school.'), const SizedBox(height: 10), SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: () { Navigator.pop(context); _toast('Safety guidelines understood. Thanks for helping keep CampusConnect safe.'); }, icon: const Icon(Icons.verified_user_outlined), label: Text('I understand', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)), style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF00B894), side: const BorderSide(color: Color(0xFF00B894)))))]);
  Widget _safetyItem(IconData icon, String title, String text) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [CircleAvatar(radius: 17, backgroundColor: const Color(0xFF00B894).withOpacity(.12), child: Icon(icon, size: 18, color: const Color(0xFF00B894))), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold)), Text(text, style: GoogleFonts.poppins(fontSize: 11, height: 1.35, color: const Color(0xFF636E72)))]))]));
  Widget _note(IconData icon, String text, Color color, VoidCallback action) => InkWell(onTap: action, child: Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Row(children: [CircleAvatar(radius: 18, backgroundColor: color.withOpacity(.12), child: Icon(icon, color: color, size: 19)), const SizedBox(width: 10), Expanded(child: Text(text, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500))), const Icon(Icons.chevron_right, color: Colors.grey)])));
  void _assignment() => _details('📚', 'Physics Lab Report', 'Physics • Due Friday at 5:00 PM', 'Submit observations, calculations, one graph, and a conclusion.', 'Open assignment', () => _toast('Assignment opened — connect this button to Assignment Management.'));
  void _club() => _details('🤖', 'AI & Robotics Workshop', 'Tech Club • Lab 4B • 8 spots left', 'Hands-on introduction to building projects with Flutter and Python.', _store.roboticsRegistered ? 'Cancel registration' : 'Apply now', () { _store.club(); _toast(_store.roboticsRegistered ? 'You are registered for AI & Robotics Workshop!' : 'Workshop registration cancelled'); });
  void _details(String emoji, String title, String label, String text, String button, VoidCallback action) => _bottom(title, [Text(emoji, style: const TextStyle(fontSize: 31)), const SizedBox(height: 8), Text(label, style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF00B894), fontWeight: FontWeight.w600)), const SizedBox(height: 11), Text(text, style: GoogleFonts.poppins(fontSize: 12, height: 1.45, color: const Color(0xFF636E72))), const SizedBox(height: 18), SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () { Navigator.pop(context); action(); }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00B894), foregroundColor: Colors.white), child: Text(button, style: GoogleFonts.poppins(fontWeight: FontWeight.bold))))]);
  void _bottom(String title, List<Widget> body) => showModalBottomSheet(context: context, backgroundColor: Colors.transparent, builder: (_) => Container(padding: const EdgeInsets.fromLTRB(20, 18, 20, 28), decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(25))), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.bold)), const SizedBox(height: 10), ...body])));
}

BoxShadow get _shadow => BoxShadow(color: Colors.black.withOpacity(.045), blurRadius: 10, offset: const Offset(0, 3));
String _initials(String x) => x.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).map((p) => p[0]).take(2).join().toUpperCase();
Color _roleColor(String x) => x == 'Teacher' ? const Color(0xFF6C5CE7) : const Color(0xFF00B894);
bool _blocked(String x) => const ['spam','hate','abuse','idiot'].any((word) => x.toLowerCase().contains(word));
String _time(DateTime x) { final d = DateTime.now().difference(x); return d.inMinutes < 1 ? 'now' : d.inMinutes < 60 ? '${d.inMinutes}m ago' : d.inHours < 24 ? '${d.inHours}h ago' : '${d.inDays}d ago'; }
Widget _teacherBadge() => Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1), decoration: BoxDecoration(color: const Color(0xFF6C5CE7).withOpacity(.1), borderRadius: BorderRadius.circular(5)), child: Text('TEACHER', style: GoogleFonts.poppins(fontSize: 7, fontWeight: FontWeight.bold, color: const Color(0xFF6C5CE7))));
