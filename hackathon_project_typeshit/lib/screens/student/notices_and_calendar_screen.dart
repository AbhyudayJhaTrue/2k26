import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// =============================================================================
// NOTICES & CALENDAR — ONE FILE, TWO SCREENS
//
// Entry points (both are standalone screens):
//   DigitalNoticeBoardScreen()   — shows competitions, workshops, news, etc.
//   SchoolCalendarScreen()       — shows full monthly calendar + event list
//
// Both screens import each other so you can navigate between them in-app.
// =============================================================================

// ─── SHARED DATA MODELS ───────────────────────────────────────────────────────

enum NoticeCategory { all, competition, workshop, scholarship, olympiad, trip, news }

extension NoticeCategoryUI on NoticeCategory {
  String get label => switch (this) {
        NoticeCategory.all => 'All',
        NoticeCategory.competition => 'Competition',
        NoticeCategory.workshop => 'Workshop',
        NoticeCategory.scholarship => 'Scholarship',
        NoticeCategory.olympiad => 'Olympiad',
        NoticeCategory.trip => 'School Trip',
        NoticeCategory.news => 'School News',
      };
  String get emoji => switch (this) {
        NoticeCategory.all => '📋',
        NoticeCategory.competition => '🏅',
        NoticeCategory.workshop => '🛠',
        NoticeCategory.scholarship => '🎓',
        NoticeCategory.olympiad => '🧪',
        NoticeCategory.trip => '🚌',
        NoticeCategory.news => '📰',
      };
  Color get color => switch (this) {
        NoticeCategory.all => const Color(0xFF6C5CE7),
        NoticeCategory.competition => const Color(0xFFE17055),
        NoticeCategory.workshop => const Color(0xFF0984E3),
        NoticeCategory.scholarship => const Color(0xFF00B894),
        NoticeCategory.olympiad => const Color(0xFF6C5CE7),
        NoticeCategory.trip => const Color(0xFFF39C12),
        NoticeCategory.news => const Color(0xFF2D3436),
      };
}

class NoticeItem {
  const NoticeItem({
    required this.title,
    required this.body,
    required this.category,
    required this.date,
    this.deadline,
    this.tag,
  });
  final String title, body;
  final NoticeCategory category;
  final DateTime date;
  final DateTime? deadline;
  final String? tag; // e.g. 'NEW', 'URGENT', 'OPEN'
}

enum CalEventType { exam, holiday, sports, event, club, trip }

extension CalEventTypeUI on CalEventType {
  String get emoji => switch (this) {
        CalEventType.exam => '📝',
        CalEventType.holiday => '🎉',
        CalEventType.sports => '⚽',
        CalEventType.event => '🌟',
        CalEventType.club => '👥',
        CalEventType.trip => '🚌',
      };
  Color get color => switch (this) {
        CalEventType.exam => const Color(0xFFE17055),
        CalEventType.holiday => const Color(0xFF00B894),
        CalEventType.sports => const Color(0xFF0984E3),
        CalEventType.event => const Color(0xFF6C5CE7),
        CalEventType.club => const Color(0xFFF39C12),
        CalEventType.trip => const Color(0xFFE84393),
      };
}

class CalEvent {
  const CalEvent({
    required this.title,
    required this.type,
    required this.date,
    this.description,
    this.location,
  });
  final String title;
  final CalEventType type;
  final DateTime date;
  final String? description, location;
}

// ─── SHARED DEMO DATA ─────────────────────────────────────────────────────────

final _now = DateTime.now();

final List<NoticeItem> _notices = [
  NoticeItem(
    title: 'National Science Olympiad 2026',
    body: 'Open to all Grade 8–10 students. Register with your Science teacher by Friday. Top 3 winners represent the school at the district level.',
    category: NoticeCategory.olympiad,
    date: _now.subtract(const Duration(hours: 3)),
    deadline: _now.add(const Duration(days: 4)),
    tag: 'NEW',
  ),
  NoticeItem(
    title: 'AI & Robotics Workshop',
    body: 'Hands-on session covering Flutter and Python basics. Lab 4B, 3:30 PM next Wednesday. Only 8 spots left — register through Club Events.',
    category: NoticeCategory.workshop,
    date: _now.subtract(const Duration(hours: 6)),
    deadline: _now.add(const Duration(days: 3)),
    tag: 'OPEN',
  ),
  NoticeItem(
    title: 'Central Board Merit Scholarship',
    body: 'Applications open for the annual merit scholarship. Eligibility: 85%+ aggregate, Grade 9–11. Submit your form to the admin office by the 30th.',
    category: NoticeCategory.scholarship,
    date: _now.subtract(const Duration(days: 1)),
    deadline: _now.add(const Duration(days: 10)),
    tag: 'OPEN',
  ),
  NoticeItem(
    title: 'Inter-School Coding Competition',
    body: 'Represent the school at CodeStorm 2026. Teams of 2–3. Problems span algorithms, data structures, and web development. Selection round next Monday.',
    category: NoticeCategory.competition,
    date: _now.subtract(const Duration(days: 1, hours: 4)),
    deadline: _now.add(const Duration(days: 6)),
    tag: 'NEW',
  ),
  NoticeItem(
    title: 'Heritage Singapore Study Trip',
    body: 'One-day trip to National Museum and Chinatown Heritage Centre on 15 August. Consent forms and payment due by 8 August. Limited to 40 students.',
    category: NoticeCategory.trip,
    date: _now.subtract(const Duration(days: 2)),
    deadline: _now.add(const Duration(days: 7)),
  ),
  NoticeItem(
    title: 'School Sports Day — Confirmed Dates',
    body: 'Sports Day will be held on 22 August at the main ground. All house captains must submit team lists to Mr. Rajan by 16 August.',
    category: NoticeCategory.news,
    date: _now.subtract(const Duration(days: 2, hours: 2)),
  ),
  NoticeItem(
    title: 'Maths Olympiad — Internal Selection Round',
    body: 'Grade 9 and 10 students interested in the National Maths Olympiad can sit the internal qualifier in Room 201 this Thursday at 2:00 PM.',
    category: NoticeCategory.olympiad,
    date: _now.subtract(const Duration(days: 3)),
    deadline: _now.add(const Duration(days: 2)),
    tag: 'URGENT',
  ),
  NoticeItem(
    title: 'Library Extended Hours — Exam Week',
    body: 'The school library will remain open until 7:00 PM on weekdays during exam week (18–22 August). Bring your student ID.',
    category: NoticeCategory.news,
    date: _now.subtract(const Duration(days: 3, hours: 6)),
  ),
  NoticeItem(
    title: 'Watercolour & Illustration Workshop',
    body: 'Art Society hosts a two-hour watercolour session in Art Room 1. All materials provided. Open to all students. Saturday, 10 AM.',
    category: NoticeCategory.workshop,
    date: _now.subtract(const Duration(days: 4)),
  ),
];

final List<CalEvent> _calEvents = [
  CalEvent(title: 'Mid-Term Exams Begin', type: CalEventType.exam, date: _now.add(const Duration(days: 4)), description: 'Mid-term examinations for all grades. Check individual timetables.', location: 'Respective classrooms'),
  CalEvent(title: 'AI & Robotics Workshop', type: CalEventType.club, date: _now.add(const Duration(days: 3)), description: 'Hands-on workshop in Lab 4B. 8 spots remaining.', location: 'Lab 4B'),
  CalEvent(title: 'Maths Olympiad Qualifier', type: CalEventType.exam, date: _now.add(const Duration(days: 2)), description: 'Internal selection round for National Maths Olympiad.', location: 'Room 201'),
  CalEvent(title: 'Coding Competition Selection', type: CalEventType.event, date: _now.add(const Duration(days: 6)), description: 'CodeStorm 2026 internal selection round.', location: 'Computer Lab'),
  CalEvent(title: 'Sports Day', type: CalEventType.sports, date: _now.add(const Duration(days: 22)), description: 'Annual inter-house sports day. All students participate.', location: 'Main Sports Ground'),
  CalEvent(title: 'Heritage Singapore Trip', type: CalEventType.trip, date: _now.add(const Duration(days: 15)), description: 'National Museum & Chinatown Heritage Centre.', location: 'National Museum, Singapore'),
  CalEvent(title: 'Founders Day Holiday', type: CalEventType.holiday, date: _now.add(const Duration(days: 10)), description: 'School closed for Founders Day.'),
  CalEvent(title: 'CS Club Weekly Meet', type: CalEventType.club, date: _now.add(const Duration(days: 1)), description: 'Weekly Computer Science Club session.', location: 'Lab 3'),
  CalEvent(title: 'Watercolour Workshop', type: CalEventType.event, date: _now.add(const Duration(days: 5)), description: 'Art Society watercolour workshop. All materials provided.', location: 'Art Room 1'),
  CalEvent(title: 'Mid-Term Exams End', type: CalEventType.exam, date: _now.add(const Duration(days: 9)), description: 'Last day of mid-term examinations.'),
  CalEvent(title: 'Science Olympiad Registration Deadline', type: CalEventType.event, date: _now.add(const Duration(days: 4)), description: 'Last day to register for the National Science Olympiad.'),
  CalEvent(title: 'Football League Finals', type: CalEventType.sports, date: _now.add(const Duration(days: 30)), description: 'Inter-house football championship final.', location: 'Main Sports Ground'),
];

// ─── SHARED HELPERS ───────────────────────────────────────────────────────────

String _timeAgo(DateTime t) {
  final d = DateTime.now().difference(t);
  if (d.inMinutes < 60) return '${d.inMinutes}m ago';
  if (d.inHours < 24) return '${d.inHours}h ago';
  return '${d.inDays}d ago';
}

String _daysLeft(DateTime d) {
  final diff = d.difference(DateTime.now()).inDays;
  if (diff == 0) return 'Due today';
  if (diff == 1) return 'Due tomorrow';
  if (diff < 0) return 'Closed';
  return 'Due in ${diff}d';
}

String _fmtDate(DateTime d) => '${d.day} ${_months[d.month - 1]}';
const _months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
const _weekdays = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];

BoxShadow get _shadow => BoxShadow(color: Colors.black.withOpacity(.045), blurRadius: 10, offset: const Offset(0, 3));

// =============================================================================
// SCREEN 1: DIGITAL NOTICE BOARD
// =============================================================================

class DigitalNoticeBoardScreen extends StatefulWidget {
  const DigitalNoticeBoardScreen({super.key});
  @override State<DigitalNoticeBoardScreen> createState() => _DigitalNoticeBoardScreenState();
}

class _DigitalNoticeBoardScreenState extends State<DigitalNoticeBoardScreen> {
  NoticeCategory _filter = NoticeCategory.all;
  final _search = TextEditingController();
  String _query = '';

  @override void initState() { super.initState(); _search.addListener(() => setState(() => _query = _search.text)); }
  @override void dispose() { _search.dispose(); super.dispose(); }

  List<NoticeItem> get _filtered {
    final q = _query.trim().toLowerCase();
    return _notices.where((n) =>
      (_filter == NoticeCategory.all || n.category == _filter) &&
      (q.isEmpty || '${n.title} ${n.body}'.toLowerCase().contains(q))
    ).toList();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF5F6FA),
    body: CustomScrollView(slivers: [
      _header(context),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _searchField(),
            const SizedBox(height: 12),
            _categoryRow(),
            const SizedBox(height: 20),
            _sectionLabel('📌 Pinned Highlights'),
            const SizedBox(height: 10),
            _pinStrip(),
            const SizedBox(height: 22),
            _sectionLabel(
              _filter == NoticeCategory.all ? '📋 All Notices' : '${_filter.emoji} ${_filter.label}',
              count: _filtered.length,
            ),
            const SizedBox(height: 10),
            if (_filtered.isEmpty) _empty() else ..._filtered.map(_noticeCard),
          ]),
        ),
      ),
    ]),
  );

  Widget _header(BuildContext context) => SliverAppBar(
    expandedHeight: 150,
    pinned: true,
    elevation: 0,
    backgroundColor: const Color(0xFF6C5CE7),
    leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white), onPressed: () => Navigator.maybePop(context)),
    actions: [
      TextButton.icon(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SchoolCalendarScreen())),
        icon: const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 18),
        label: Text('Calendar', style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
      ),
    ],
    flexibleSpace: FlexibleSpaceBar(
      background: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF6C5CE7), Color(0xFF2D3436)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        child: SafeArea(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 46, 20, 14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('📋 Digital Notice Board', style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            Text('Competitions, workshops, scholarships & school news.', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11)),
            const SizedBox(height: 10),
            Wrap(spacing: 8, children: [
              _chip('🏫 GIIS Singapore'),
              _chip('📢 ${_notices.length} notices'),
            ]),
          ]),
        )),
      ),
    ),
  );

  Widget _chip(String v) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(14)),
    child: Text(v, style: GoogleFonts.poppins(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w500)),
  );

  Widget _searchField() => TextField(
    controller: _search,
    style: GoogleFonts.poppins(fontSize: 13),
    decoration: InputDecoration(
      hintText: 'Search notices, competitions, workshops…',
      hintStyle: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF8B949E)),
      prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF6C5CE7)),
      suffixIcon: _query.isEmpty ? null : IconButton(icon: const Icon(Icons.close_rounded), onPressed: _search.clear),
      filled: true, fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(vertical: 14),
    ),
  );

  Widget _categoryRow() => SizedBox(
    height: 36,
    child: ListView(
      scrollDirection: Axis.horizontal,
      children: NoticeCategory.values.map((cat) {
        final sel = _filter == cat;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: FilterChip(
            selected: sel,
            showCheckmark: false,
            label: Text('${cat.emoji} ${cat.label}', style: GoogleFonts.poppins(fontSize: 11, color: sel ? Colors.white : const Color(0xFF2D3436))),
            selectedColor: cat.color,
            backgroundColor: Colors.white,
            side: BorderSide(color: sel ? Colors.transparent : const Color(0xFFE2E8F0)),
            onSelected: (_) => setState(() => _filter = cat),
          ),
        );
      }).toList(),
    ),
  );

  Widget _pinStrip() => SizedBox(
    height: 120,
    child: ListView(
      scrollDirection: Axis.horizontal,
      children: _notices.where((n) => n.tag != null).map((n) => InkWell(
        onTap: () => _showDetail(n),
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          width: 200,
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: n.category.color.withOpacity(.2)),
            boxShadow: [_shadow],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(n.category.emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              _tagBadge(n.tag!, n.category.color),
            ]),
            const Spacer(),
            Text(n.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF2D3436))),
            if (n.deadline != null) Text(_daysLeft(n.deadline!), style: GoogleFonts.poppins(fontSize: 10, color: n.category.color, fontWeight: FontWeight.w600)),
          ]),
        ),
      )).toList(),
    ),
  );

  Widget _noticeCard(NoticeItem n) => InkWell(
    onTap: () => _showDetail(n),
    borderRadius: BorderRadius.circular(16),
    child: Ink(
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [_shadow],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: n.category.color.withOpacity(.1), borderRadius: BorderRadius.circular(10)),
            child: Text(n.category.emoji, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(n.category.label.toUpperCase(), style: GoogleFonts.poppins(fontSize: 9, color: n.category.color, fontWeight: FontWeight.bold))),
              if (n.tag != null) _tagBadge(n.tag!, n.category.color),
            ]),
            Text(_timeAgo(n.date), style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
          ])),
        ]),
        const SizedBox(height: 10),
        Text(n.title, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF2D3436))),
        const SizedBox(height: 5),
        Text(n.body, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 12, height: 1.45, color: const Color(0xFF636E72))),
        if (n.deadline != null) ...[
          const SizedBox(height: 10),
          Row(children: [
            const Icon(Icons.timer_outlined, size: 14, color: Color(0xFFE17055)),
            const SizedBox(width: 4),
            Text(_daysLeft(n.deadline!), style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFFE17055), fontWeight: FontWeight.w600)),
            const Spacer(),
            Text('Read more →', style: GoogleFonts.poppins(fontSize: 11, color: n.category.color, fontWeight: FontWeight.w600)),
          ]),
        ],
      ]),
    ),
  );

  Widget _tagBadge(String tag, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(color: color.withOpacity(.12), borderRadius: BorderRadius.circular(6)),
    child: Text(tag, style: GoogleFonts.poppins(fontSize: 8, fontWeight: FontWeight.bold, color: color)),
  );

  Widget _sectionLabel(String text, {int? count}) => Row(children: [
    Text(text, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF2D3436))),
    if (count != null) ...[
      const SizedBox(width: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(color: const Color(0xFF6C5CE7).withOpacity(.1), borderRadius: BorderRadius.circular(10)),
        child: Text('$count', style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF6C5CE7), fontWeight: FontWeight.bold)),
      ),
    ],
  ]);

  Widget _empty() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 50),
    child: Center(child: Column(children: [
      const Icon(Icons.search_off_rounded, size: 48, color: Color(0xFFB2BEC3)),
      const SizedBox(height: 10),
      Text('No notices found', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      Text('Try a different filter or keyword.', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
    ])),
  );

  void _showDetail(NoticeItem n) => showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: .6,
      maxChildSize: .92,
      minChildSize: .4,
      builder: (_, scroll) => Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
        child: ListView(controller: scroll, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: n.category.color.withOpacity(.1), borderRadius: BorderRadius.circular(12)),
              child: Text(n.category.emoji, style: const TextStyle(fontSize: 26)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(n.category.label.toUpperCase(), style: GoogleFonts.poppins(fontSize: 10, color: n.category.color, fontWeight: FontWeight.bold)),
              Text(n.title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF2D3436))),
            ])),
            if (n.tag != null) _tagBadge(n.tag!, n.category.color),
          ]),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          Text(n.body, style: GoogleFonts.poppins(fontSize: 13, height: 1.6, color: const Color(0xFF4B5563))),
          const SizedBox(height: 16),
          if (n.deadline != null) _detailRow(Icons.timer_outlined, 'Deadline', _fmtDate(n.deadline!), const Color(0xFFE17055)),
          _detailRow(Icons.access_time_rounded, 'Posted', _timeAgo(n.date), const Color(0xFF8B949E)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: n.category.color, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.check_rounded),
              label: Text('Got it', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            ),
          ),
        ]),
      ),
    ),
  );

  Widget _detailRow(IconData icon, String label, String value, Color color) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(children: [
      Icon(icon, size: 16, color: color),
      const SizedBox(width: 8),
      Text('$label: ', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
      Text(value, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF2D3436))),
    ]),
  );
}

// =============================================================================
// SCREEN 2: SCHOOL CALENDAR
// =============================================================================

class SchoolCalendarScreen extends StatefulWidget {
  const SchoolCalendarScreen({super.key});
  @override State<SchoolCalendarScreen> createState() => _SchoolCalendarScreenState();
}

class _SchoolCalendarScreenState extends State<SchoolCalendarScreen> {
  late DateTime _focusedMonth;
  DateTime? _selectedDay;
  CalEventType? _typeFilter;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime(_now.year, _now.month, 1);
    _selectedDay = _now;
  }

  List<CalEvent> _eventsOnDay(DateTime day) => _calEvents
      .where((e) => e.date.year == day.year && e.date.month == day.month && e.date.day == day.day)
      .toList();

  List<CalEvent> get _upcomingFiltered {
    final all = _calEvents.where((e) => e.date.isAfter(_now.subtract(const Duration(days: 1)))).toList();
    all.sort((a, b) => a.date.compareTo(b.date));
    if (_typeFilter == null) return all;
    return all.where((e) => e.type == _typeFilter).toList();
  }

  List<CalEvent> get _selectedDayEvents {
    if (_selectedDay == null) return [];
    return _eventsOnDay(_selectedDay!);
  }

  // days in month grid
  List<DateTime?> _monthDays() {
    final first = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final last = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final startPad = (first.weekday - 1) % 7; // Mon = 0
    final days = <DateTime?>[];
    for (int i = 0; i < startPad; i++) days.add(null);
    for (int d = 1; d <= last.day; d++) days.add(DateTime(_focusedMonth.year, _focusedMonth.month, d));
    return days;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF5F6FA),
    body: CustomScrollView(slivers: [
      _header(context),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _calendarCard(),
            const SizedBox(height: 16),
            if (_selectedDayEvents.isNotEmpty) ...[
              _sectionLabel('📅 ${_fmtDate(_selectedDay!)}', count: _selectedDayEvents.length),
              const SizedBox(height: 10),
              ..._selectedDayEvents.map(_eventCard),
              const SizedBox(height: 6),
            ],
            const SizedBox(height: 10),
            _legendRow(),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: _sectionLabel('🗓 Upcoming Events')),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DigitalNoticeBoardScreen())),
                child: Text('Notices →', style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF6C5CE7), fontWeight: FontWeight.w600)),
              ),
            ]),
            const SizedBox(height: 8),
            _typeFilterRow(),
            const SizedBox(height: 10),
            if (_upcomingFiltered.isEmpty) _empty() else ..._upcomingFiltered.map(_upcomingTile),
          ]),
        ),
      ),
    ]),
  );

  Widget _header(BuildContext context) => SliverAppBar(
    expandedHeight: 150,
    pinned: true,
    elevation: 0,
    backgroundColor: const Color(0xFF0984E3),
    leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white), onPressed: () => Navigator.maybePop(context)),
    actions: [
      TextButton.icon(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DigitalNoticeBoardScreen())),
        icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 18),
        label: Text('Notices', style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
      ),
    ],
    flexibleSpace: FlexibleSpaceBar(
      background: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF0984E3), Color(0xFF6C5CE7)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        child: SafeArea(child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 46, 20, 14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('📅 School Calendar', style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            Text('Exams, holidays, events, clubs & more.', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11)),
            const SizedBox(height: 10),
            Wrap(spacing: 8, children: [
              _chip('🏫 GIIS Singapore'),
              _chip('🗓 ${_calEvents.length} events'),
            ]),
          ]),
        )),
      ),
    ),
  );

  Widget _chip(String v) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(14)),
    child: Text(v, style: GoogleFonts.poppins(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w500)),
  );

  Widget _calendarCard() => Container(
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [_shadow]),
    padding: const EdgeInsets.all(16),
    child: Column(children: [
      // Month nav
      Row(children: [
        IconButton(
          icon: const Icon(Icons.chevron_left_rounded),
          onPressed: () => setState(() { _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1); _selectedDay = null; }),
        ),
        Expanded(child: Text(
          '${_months[_focusedMonth.month - 1]} ${_focusedMonth.year}',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF2D3436)),
        )),
        IconButton(
          icon: const Icon(Icons.chevron_right_rounded),
          onPressed: () => setState(() { _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1); _selectedDay = null; }),
        ),
      ]),
      const SizedBox(height: 8),
      // Weekday labels
      Row(children: _weekdays.map((w) => Expanded(
        child: Text(w, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600)),
      )).toList()),
      const SizedBox(height: 8),
      // Day cells
      GridView.count(
        crossAxisCount: 7,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 4,
        crossAxisSpacing: 2,
        childAspectRatio: 1,
        children: _monthDays().map((day) {
          if (day == null) return const SizedBox();
          final isToday = day.year == _now.year && day.month == _now.month && day.day == _now.day;
          final isSelected = _selectedDay != null && day.year == _selectedDay!.year && day.month == _selectedDay!.month && day.day == _selectedDay!.day;
          final events = _eventsOnDay(day);
          final hasEvent = events.isNotEmpty;
          final dotColor = hasEvent ? events.first.type.color : null;

          return GestureDetector(
            onTap: () => setState(() => _selectedDay = day),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF0984E3) : isToday ? const Color(0xFF0984E3).withOpacity(.1) : null,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('${day.day}', style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : isToday ? const Color(0xFF0984E3) : const Color(0xFF2D3436),
                )),
                if (dotColor != null)
                  Container(width: 5, height: 5, margin: const EdgeInsets.only(top: 2), decoration: BoxDecoration(color: isSelected ? Colors.white : dotColor, shape: BoxShape.circle)),
              ]),
            ),
          );
        }).toList(),
      ),
    ]),
  );

  Widget _legendRow() => Wrap(
    spacing: 12,
    runSpacing: 6,
    children: CalEventType.values.map((t) => Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: t.color, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(t.name[0].toUpperCase() + t.name.substring(1), style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF636E72))),
    ])).toList(),
  );

  Widget _typeFilterRow() => SizedBox(
    height: 34,
    child: ListView(
      scrollDirection: Axis.horizontal,
      children: [null, ...CalEventType.values].map((t) {
        final sel = _typeFilter == t;
        final label = t == null ? 'All' : t.name[0].toUpperCase() + t.name.substring(1);
        final color = t?.color ?? const Color(0xFF6C5CE7);
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: FilterChip(
            selected: sel,
            showCheckmark: false,
            label: Text('${t?.emoji ?? '🗓'} $label', style: GoogleFonts.poppins(fontSize: 10, color: sel ? Colors.white : const Color(0xFF2D3436))),
            selectedColor: color,
            backgroundColor: Colors.white,
            side: BorderSide(color: sel ? Colors.transparent : const Color(0xFFE2E8F0)),
            onSelected: (_) => setState(() => _typeFilter = t),
          ),
        );
      }).toList(),
    ),
  );

  Widget _eventCard(CalEvent e) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: e.type.color.withOpacity(.07),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: e.type.color.withOpacity(.25)),
    ),
    child: Row(children: [
      Text(e.type.emoji, style: const TextStyle(fontSize: 22)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(e.title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: const Color(0xFF2D3436))),
        if (e.location != null) Text('📍 ${e.location}', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
        if (e.description != null) Text(e.description!, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF636E72))),
      ])),
    ]),
  );

  Widget _upcomingTile(CalEvent e) => InkWell(
    onTap: () => _showEventDetail(e),
    borderRadius: BorderRadius.circular(14),
    child: Ink(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [_shadow]),
      child: Row(children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(color: e.type.color.withOpacity(.1), borderRadius: BorderRadius.circular(12)),
          child: Center(child: Text(e.type.emoji, style: const TextStyle(fontSize: 22))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(e.title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: const Color(0xFF2D3436))),
          Text('${_fmtDate(e.date)} ${e.location != null ? '• ${e.location}' : ''}', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: e.type.color.withOpacity(.1), borderRadius: BorderRadius.circular(8)),
          child: Text(
            _daysLeft(e.date),
            style: GoogleFonts.poppins(fontSize: 10, color: e.type.color, fontWeight: FontWeight.bold),
          ),
        ),
      ]),
    ),
  );

  Widget _sectionLabel(String text, {int? count}) => Row(children: [
    Expanded(child: Text(text, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF2D3436)))),
    if (count != null) Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(color: const Color(0xFF0984E3).withOpacity(.1), borderRadius: BorderRadius.circular(10)),
      child: Text('$count', style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF0984E3), fontWeight: FontWeight.bold)),
    ),
  ]);

  Widget _empty() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 40),
    child: Center(child: Column(children: [
      const Icon(Icons.event_busy_rounded, size: 46, color: Color(0xFFB2BEC3)),
      const SizedBox(height: 8),
      Text('No events', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      Text('Try a different filter.', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
    ])),
  );

  void _showEventDetail(CalEvent e) => showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(e.type.emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(e.title, style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.bold, color: const Color(0xFF2D3436))),
            Text(_fmtDate(e.date), style: GoogleFonts.poppins(fontSize: 12, color: e.type.color, fontWeight: FontWeight.w600)),
          ])),
        ]),
        if (e.description != null) ...[
          const SizedBox(height: 14),
          Text(e.description!, style: GoogleFonts.poppins(fontSize: 13, height: 1.55, color: const Color(0xFF4B5563))),
        ],
        if (e.location != null) ...[
          const SizedBox(height: 10),
          Row(children: [
            const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF636E72)),
            const SizedBox(width: 4),
            Text(e.location!, style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF636E72))),
          ]),
        ],
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: e.type.color, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 13)),
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.calendar_today_rounded),
            label: Text('Add to my calendar', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          ),
        ),
      ]),
    ),
  );
}
