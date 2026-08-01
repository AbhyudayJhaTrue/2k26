// ---------------------------------------------------------------------------
// TEACHER & ADMIN SHELL
// Integrated from combined_main.dart.
// Entry point: TeacherAdminShell(name: user.name, role: user.role)
// ---------------------------------------------------------------------------

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

// ═══ TOKENS ═══

const _indigo = Color(0xFF1F1147), _purple = Color(0xFF6C5CE7), _teal = Color(0xFF00CEC9);
const _green = Color(0xFF00B894), _amber = Color(0xFFFDA65D), _red = Color(0xFFE17055); 
const _bg = Color(0xFFF7F5FF), _ink = Color(0xFF2D2A45), _muted = Color(0xFF8E8AA8);

const _grad = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
  colors: [_indigo, _purple, _teal]);
const _gradSoft = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
  colors: [_purple, _teal]);

// ═══ ATOMS ═══

/// Soft elevated white surface - the base card for the whole app.
class Surface extends StatelessWidget {
 final Widget child;
 final EdgeInsets pad;
 final Color? tint;
 const Surface({super.key, required this.child, this.pad = const EdgeInsets.all(18), this.tint});

 @override
 Widget build(BuildContext c) => Container(
   clipBehavior: Clip.antiAlias,
   padding: pad,
   decoration: BoxDecoration(color: tint ?? Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [BoxShadow(color: _indigo.withOpacity(.06), blurRadius: 18, offset: const Offset(0, 6))]),
   child: child);
}

Widget _pill(String t, Color c, {bool solid = false}) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  decoration: BoxDecoration(color: solid ? c : c.withOpacity(.12), borderRadius: BorderRadius.circular(30)),
  child: Text(t, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
    color: solid ? Colors.white : c, letterSpacing: .2)));

Widget _label(String t) => Padding(padding: const EdgeInsets.fromLTRB(2, 26, 2, 12),
  child: Text(t.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800,
    color: _muted, letterSpacing: 1.1)));

Widget _avatar(String i, {double r = 20, Color? bg, Color? fg}) => CircleAvatar(radius: r,
  backgroundColor: bg ?? _purple.withOpacity(.13),
  child: Text(i, style: TextStyle(color: fg ?? _purple, fontWeight: FontWeight.w800, fontSize: r * .85)));

Widget _dot(Color c) => Container(width: 6, height: 6,
  decoration: BoxDecoration(color: c, shape: BoxShape.circle));

/// Gradient header shared by every screen.
class _Head extends StatelessWidget {
 final String title, sub;
 final Widget? trailing;
 const _Head(this.title, {this.sub = '', this.trailing});

 @override
 Widget build(BuildContext c) => Container(width: double.infinity,
   decoration: const BoxDecoration(gradient: _grad),
   padding: const EdgeInsets.fromLTRB(22, 26, 22, 26),
   child: SafeArea(bottom: false, child: Row(children: [
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(color: Colors.white, fontSize: 21,
        fontWeight: FontWeight.w800, letterSpacing: -.3)),
      if (sub.isNotEmpty) ...[const SizedBox(height: 4),
       Text(sub, style: TextStyle(color: Colors.white.withOpacity(.72), fontSize: 12.5))],
    ])),
    if (trailing != null) trailing!,
   ])));
}

/// Header + scrollable body.
class _Page extends StatelessWidget {
 final String title, sub;
 final Widget? trailing;
 final List<Widget> children;
 const _Page({required this.title, this.sub = '', this.trailing, required this.children});

 @override
 Widget build(BuildContext c) => Column(children: [
   _Head(title, sub: sub, trailing: trailing),
   Expanded(child: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 32), children: children)),
  ]);
}

class _Stat extends StatelessWidget {
 final String label, value;
 final IconData icon;
 final Color color;
 const _Stat(this.label, this.value, this.icon, this.color);

 @override
 Widget build(BuildContext c) => Surface(pad: const EdgeInsets.all(16),
   child: Column(crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center, children: [
    Container(padding: const EdgeInsets.all(9),
       decoration: BoxDecoration(color: color.withOpacity(.12), borderRadius: BorderRadius.circular(12)),
       child: Icon(icon, color: color, size: 19)),
    const Spacer(),
    Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: _ink, height: 1)),
    const SizedBox(height: 5),
    Text(label, style: const TextStyle(fontSize: 11.5, color: _muted, height: 1.2)),
   ]));
}

Widget _grid(List<_Stat> s, {double ratio = 1.32}) => GridView.count(crossAxisCount: 2,
  shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
  crossAxisSpacing: 14, mainAxisSpacing: 14, childAspectRatio: ratio, children: s);

/// Animated labelled progress bar.
class _Bar extends StatelessWidget {
 final String label;
 final double value;
 final Color color;
 const _Bar(this.label, this.value, this.color);

 @override
 Widget build(BuildContext c) => Padding(padding: const EdgeInsets.only(bottom: 14),
   child: Column(children: [
    Row(children: [
      Expanded(child: Text(label, style: const TextStyle(fontSize: 12.5, color: _ink, fontWeight: FontWeight.w600))),
      Text('${(value * 100).round()}%', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: color)),
    ]),
    const SizedBox(height: 7),
    TweenAnimationBuilder<double>(tween: Tween(begin: 0, end: value),
       duration: const Duration(milliseconds: 700), curve: Curves.easeOutCubic,
       builder: (_, v, __) => ClipRRect(borderRadius: BorderRadius.circular(20),
         child: LinearProgressIndicator(value: v, minHeight: 7,
            color: color, backgroundColor: color.withOpacity(.13)))),
   ]));
}

class _Drop extends StatelessWidget {
 final String value;
 final List<String> items;
 final ValueChanged<String?> onChanged;
 final bool light;
 const _Drop(this.value, this.items, this.onChanged, {this.light = false});

 @override
 Widget build(BuildContext c) {
  final fg = light ? Colors.white : _purple;
  final st = TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 13);
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
    decoration: BoxDecoration(
       color: light ? Colors.white.withOpacity(.16) : Colors.white,
       borderRadius: BorderRadius.circular(30),
       border: light ? null : Border.all(color: _purple.withOpacity(.22)),
       boxShadow: light ? null : [BoxShadow(color: _indigo.withOpacity(.05), blurRadius: 10, offset: const Offset(0, 3))]),
    child: DropdownButtonHideUnderline(child: DropdownButton<String>(
       value: value, isDense: true, dropdownColor: Colors.white, style: st,
       icon: Icon(Icons.expand_more_rounded, size: 18, color: fg),
       selectedItemBuilder: (_) => items.map((e) =>
         Align(alignment: Alignment.centerLeft, child: Text(e, style: st))).toList(),
       items: items.map((e) => DropdownMenuItem(value: e,
         child: Text(e, style: const TextStyle(color: _ink, fontSize: 13)))).toList(),
       onChanged: onChanged)));
 }
}

Widget _gradBtn(String t, IconData i, VoidCallback tap) => Container(
  decoration: BoxDecoration(gradient: _gradSoft, borderRadius: BorderRadius.circular(14),
    boxShadow: [BoxShadow(color: _purple.withOpacity(.3), blurRadius: 14, offset: const Offset(0, 5))]),
  child: Material(color: Colors.transparent, child: InkWell(
    borderRadius: BorderRadius.circular(14), onTap: tap,
    child: Padding(padding: const EdgeInsets.symmetric(vertical: 14),
       child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(i, color: Colors.white, size: 18), const SizedBox(width: 8),
        Text(t, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
       ])))));

/// Small count tile used by the status summary rows.
Widget _countTile(String label, int n, Color hue) => Expanded(child: Padding(
  padding: const EdgeInsets.only(right: 10),
  child: Surface(pad: const EdgeInsets.symmetric(vertical: 14), child: Column(children: [
   Text('$n', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: hue)),
   const SizedBox(height: 4),
   Text(label, textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 10.5, color: _muted, height: 1.2)),
  ]))));

/// Icon + title + timestamp row used by activity feeds.
Widget _feedTile(String text, String time, IconData icon, Color hue) => ListTile(
  dense: true, visualDensity: const VisualDensity(vertical: -1),
  leading: Container(padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(color: hue.withOpacity(.12), shape: BoxShape.circle),
    child: Icon(icon, size: 15, color: hue)),
  title: Text(text, style: const TextStyle(fontSize: 13, color: _ink)),
  trailing: Text(time, style: const TextStyle(fontSize: 11, color: _muted)));

// ═══ DATA (mirrors user_database.dart) ═══

const _students = ['Pranav', 'Kushagr', 'Adhvik'];

const _profiles = {
 'Pranav': {'a': .95, 'h': .90, 'q': .88, 'o': .91, 'xp': 1240, 's': 'Top Performer', 'miss': 0,
        'b': ['Star Researcher', 'Quest Champion']},
 'Kushagr': {'a': .72, 'h': .65, 'q': .60, 'o': .66, 'xp': 780, 's': 'Needs Support', 'miss': 2,
        'b': ['First Quest']},
 'Adhvik': {'a': .98, 'h': .95, 'q': .95, 'o': .96, 'xp': 1580, 's': 'Top Performer', 'miss': 0,
        'b': ['Star Researcher', 'Quest Champion', 'Perfect Score']},
};

Color _statusHue(String s) => s == 'Top Performer' ? _green : s == 'Needs Support' ? _red : _purple;

// ═══ SHELL ═══

enum _Sec { shared, teacher }

class _Nav {
 final String label;
 final IconData icon;
 final _Sec sec;
 final Widget Function(String) page;
 const _Nav(this.label, this.icon, this.sec, this.page);
}

List<_Nav> _nav(String me) => [
  _Nav('Campus Map', Icons.map_rounded, _Sec.shared, (_) => const CampusMapScreen()),
  _Nav('My Report Card', Icons.workspace_premium_rounded, _Sec.shared,
    (n) => MyReportCardScreen(student: n)),
  _Nav('Class Insights', Icons.insights_rounded, _Sec.teacher, (_) => const ClassInsightsScreen()),
  _Nav('Student Learning Profile', Icons.person_search_rounded, _Sec.teacher, (_) => const StudentLearningProfileScreen()),
  _Nav('AI Report Cards', Icons.auto_awesome_rounded, _Sec.teacher, (n) => ReportCardScreen(teacher: n)),
  _Nav('Suggestion Management', Icons.lightbulb_rounded, _Sec.teacher, (_) => const SuggestionManagementScreen()),
  _Nav('Student Voice Dashboard', Icons.volunteer_activism_rounded, _Sec.teacher, (_) => const StudentVoiceDashboardScreen()),
  _Nav('Teacher Chat', Icons.forum_rounded, _Sec.teacher, (n) => TeacherChatScreen(me: n)),
  _Nav('My Profile', Icons.account_circle_rounded, _Sec.teacher, (n) => TeacherProfileScreen(name: n)),
 ];

class TeacherAdminShell extends StatefulWidget {
 final String name, role;
 const TeacherAdminShell({super.key, required this.name, required this.role});
 @override
 State<TeacherAdminShell> createState() => _ShellState();
}

class _ShellState extends State<TeacherAdminShell> {
 late final List<_Nav> items = _nav(widget.name);
 late int sel = items.indexWhere((n) => n.sec == _Sec.teacher);

 /// Shared pages are open to every role.
 List<int> get visible => List.generate(items.length, (i) => i).toList();

 @override
 Widget build(BuildContext c) {
  final wide = MediaQuery.of(c).size.width >= 760;
  final body = AnimatedSwitcher(
    duration: const Duration(milliseconds: 260),
    transitionBuilder: (ch, a) => FadeTransition(opacity: a, child: SlideTransition(
       position: Tween(begin: const Offset(0, .015), end: Offset.zero).animate(a), child: ch)),
    child: KeyedSubtree(key: ValueKey(sel), child: items[sel].page(widget.name)));

  return Scaffold(
    body: wide
       ? Row(children: [
         _Rail(items: items, sel: sel, name: widget.name,
            role: widget.role, onTap: (i) => setState(() => sel = i)),
         Expanded(child: body)])
       : body,
    bottomNavigationBar: wide ? null : _bar());
 }

 Widget _bar() {
  final v = visible;
  return Container(
    decoration: BoxDecoration(color: Colors.white, boxShadow: [
      BoxShadow(color: _indigo.withOpacity(.08), blurRadius: 20, offset: const Offset(0, -4))]),
    child: NavigationBar(
       height: 66, backgroundColor: Colors.transparent, elevation: 0,
       indicatorColor: _purple.withOpacity(.14),
       labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
       selectedIndex: v.indexOf(sel).clamp(0, v.length - 1),
       onDestinationSelected: (i) => setState(() => sel = v[i]),
       destinations: v.map((i) => NavigationDestination(
         icon: Icon(items[i].icon, color: _muted, size: 22),
         selectedIcon: Icon(items[i].icon, color: _purple, size: 22),
         label: items[i].label, tooltip: items[i].label)).toList()));
 }
}

class _Rail extends StatelessWidget {
 final List<_Nav> items;
 final int sel;
 final String name, role;
 final ValueChanged<int> onTap;
 const _Rail({required this.items, required this.sel,
   required this.name, required this.role, required this.onTap});

 @override
 Widget build(BuildContext c) => Container(width: 264,
   decoration: BoxDecoration(color: Colors.white, boxShadow: [
    BoxShadow(color: _indigo.withOpacity(.07), blurRadius: 24, offset: const Offset(4, 0))]),
   child: Column(children: [
    Container(width: double.infinity,
       decoration: const BoxDecoration(gradient: _grad),
       padding: const EdgeInsets.fromLTRB(22, 44, 22, 26),
       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(shape: BoxShape.circle,
             border: Border.all(color: Colors.white.withOpacity(.35), width: 2)),
          child: _avatar(name[0], r: 24, bg: Colors.white.withOpacity(.18), fg: Colors.white)),
        const SizedBox(height: 14),
        Text(name, style: const TextStyle(color: Colors.white, fontSize: 18,
          fontWeight: FontWeight.w800, letterSpacing: -.2)),
        const SizedBox(height: 6),
        _pill(role, Colors.white.withOpacity(.22), solid: true),
       ])),
    Expanded(child: ListView(padding: const EdgeInsets.symmetric(vertical: 14), children: [
      _railLabel('Campus'),
      ..._section(_Sec.shared),
      const SizedBox(height: 8), _railLabel('Teacher Portal'),
      ..._section(_Sec.teacher),
    ])),
    Padding(padding: const EdgeInsets.fromLTRB(22, 0, 22, 18), child: Row(children: const [
      Icon(Icons.school_rounded, size: 15, color: _muted), SizedBox(width: 7),
      Text('CampusConnect', style: TextStyle(fontSize: 11.5, color: _muted, fontWeight: FontWeight.w600)),
    ])),
   ]));

 Widget _railLabel(String t) => Padding(padding: const EdgeInsets.fromLTRB(22, 8, 22, 8),
   child: Text(t.toUpperCase(), style: const TextStyle(fontSize: 10,
      fontWeight: FontWeight.w800, color: _muted, letterSpacing: 1.2)));

 List<Widget> _section(_Sec s) => items.asMap().entries.where((e) => e.value.sec == s).map((e) {
   final on = sel == e.key;
   return Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Material(color: Colors.transparent, child: InkWell(
        borderRadius: BorderRadius.circular(13), onTap: () => onTap(e.key),
        child: AnimatedContainer(duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(gradient: on ? _gradSoft : null,
             borderRadius: BorderRadius.circular(13),
             boxShadow: on ? [BoxShadow(color: _purple.withOpacity(.32),
               blurRadius: 14, offset: const Offset(0, 4))] : null),
          child: Row(children: [
            Icon(e.value.icon, size: 19, color: on ? Colors.white : _muted),
            const SizedBox(width: 13),
            Expanded(child: Text(e.value.label, style: TextStyle(fontSize: 13, height: 1.2,
              fontWeight: on ? FontWeight.w700 : FontWeight.w500,
              color: on ? Colors.white : _ink))),
          ])))));
  }).toList();
}

// ═══ 1 · CLASS INSIGHTS ═══

class ClassInsightsScreen extends StatefulWidget {
 const ClassInsightsScreen({super.key});
 @override
 State<ClassInsightsScreen> createState() => _CIState();
}

class _CIState extends State<ClassInsightsScreen> {
 String grade = 'Grade 9', section = 'Section A';

 @override
 Widget build(BuildContext c) => _Page(
   title: 'Class Insights',
   sub: '$grade · $section  ·  ${_students.length} students',
   children: [
    const SizedBox(height: 18),
    Row(children: [
      Expanded(child: _Drop(grade, const ['Grade 8', 'Grade 9', 'Grade 10'],
        (v) => setState(() => grade = v!))),
      const SizedBox(width: 12),
      Expanded(child: _Drop(section, const ['Section A', 'Section B', 'Section C'],
        (v) => setState(() => section = v!))),
    ]),
    _label('At a glance'),
    _grid(const [
      _Stat('Avg assignments', '88%', Icons.task_alt_rounded, _purple),
      _Stat('Homework rate', '83%', Icons.menu_book_rounded, _green),
      _Stat('Discovery Quest', '81%', Icons.explore_rounded, _amber),
      _Stat('Needs support', '1', Icons.error_outline_rounded, _red),
    ]),
    _label('Most active'),
    Surface(child: Row(children: [
      _avatar('A', r: 22, bg: _green.withOpacity(.14), fg: _green),
      const SizedBox(width: 14),
      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
       Text('Adhvik', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: _ink)),
       SizedBox(height: 3),
       Text('1580 XP · 3 badges · 96% overall', style: TextStyle(fontSize: 12, color: _muted)),
      ])),
      const Icon(Icons.workspace_premium_rounded, color: _amber, size: 26),
    ])),
    _label('Student breakdown'),
    ..._students.map((n) {
      final p = _profiles[n]!;
      final hue = _statusHue(p['s'] as String);
      return Padding(padding: const EdgeInsets.only(bottom: 14), child: Surface(
        child: Column(children: [
         Row(children: [
          _avatar(n[0], bg: hue.withOpacity(.14), fg: hue),
          const SizedBox(width: 13),
          Expanded(child: Text(n, style: const TextStyle(fontSize: 15,
             fontWeight: FontWeight.w700, color: _ink))),
          _pill(p['s'] as String, hue),
         ]),
         const SizedBox(height: 18),
         _Bar('Assignments', p['a'] as double, _purple),
         _Bar('Homework', p['h'] as double, _green),
         _Bar('Discovery Quest', p['q'] as double, _amber),
        ])));
    }),
   ]);
}

// ═══ 2 · STUDENT LEARNING PROFILE ═══

class StudentLearningProfileScreen extends StatefulWidget {
 const StudentLearningProfileScreen({super.key});
 @override
 State<StudentLearningProfileScreen> createState() => _SLPState();
}

class _SLPState extends State<StudentLearningProfileScreen> {
 String who = _students.first;

 static const _feed = {
  'Pranav': [['Submitted · History Essay', '2h ago', 0], ['Completed · Discovery Quest #4', '1d ago', 1]],
  'Kushagr': [['Missed · Science Worksheet', '1d ago', 2], ['Submitted · English Draft', '3d ago', 0]],
  'Adhvik': [['Badge earned · Perfect Score', '1h ago', 3], ['Completed · Discovery Quest #5', '6h ago', 1],
         ['Submitted · Math Assignment', '1d ago', 0]],
 };
 static const _fi = [Icons.task_alt_rounded, Icons.explore_rounded,
   Icons.error_outline_rounded, Icons.workspace_premium_rounded];
 static const _fh = [_purple, _amber, _red, _green];

 @override
 Widget build(BuildContext c) {
  final p = _profiles[who]!;
  final hue = _statusHue(p['s'] as String);

  return _Page(
    title: 'Learning Profile',
    sub: 'Grade 9 · Section A',
    trailing: _Drop(who, _students, (v) => setState(() => who = v!), light: true),
    children: [
      const SizedBox(height: 18),
      Surface(pad: const EdgeInsets.all(20), child: Column(children: [
       Row(children: [
        _avatar(who[0], r: 27, bg: hue.withOpacity(.14), fg: hue),
        const SizedBox(width: 15),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
         Text(who, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: _ink)),
         const SizedBox(height: 6),
         Row(children: [_pill(p['s'] as String, hue), const SizedBox(width: 7),
          _pill('⚡ ${p['xp']} XP', _amber)]),
        ])),
       ]),
       const SizedBox(height: 20),
       _Bar('Assignments', p['a'] as double, _purple),
       _Bar('Homework', p['h'] as double, _green),
       _Bar('Discovery Quest', p['q'] as double, _amber),
       _Bar('Overall', p['o'] as double, _indigo),
      ])),
      _label('Badges'),
      Wrap(spacing: 9, runSpacing: 9, children: (p['b'] as List).map((b) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(color: _amber.withOpacity(.11),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: _amber.withOpacity(.25))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
         const Icon(Icons.workspace_premium_rounded, size: 15, color: _amber),
         const SizedBox(width: 7),
         Text('$b', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _ink)),
        ]))).toList()),
      if ((p['miss'] as int) > 0) ...[
       _label('Needs attention'),
       Surface(tint: _red.withOpacity(.07), child: Row(children: [
        const Icon(Icons.error_outline_rounded, color: _red, size: 22),
        const SizedBox(width: 13),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
         Text('${p['miss']} missing assignments', style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w700, color: _ink)),
         const SizedBox(height: 3),
         const Text('Follow up with the student this week',
            style: TextStyle(fontSize: 12, color: _muted)),
        ])),
       ])),
      ],
      _label('Teacher feedback'),
      Surface(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
       Text(who == 'Kushagr'
         ? 'Please submit the Science worksheet - let\'s book a catch-up session this week to go over Chapter 5.'
         : 'Outstanding work. Your source evaluation in Discovery Quest is consistently strong - keep it up.',
         style: const TextStyle(fontSize: 13.5, height: 1.65, color: _ink)),
       const SizedBox(height: 14),
       Row(children: [_avatar('J', r: 12), const SizedBox(width: 9),
        const Text('Jason · 2 days ago', style: TextStyle(fontSize: 11.5, color: _muted))]),
      ])),
      _label('Recent activity'),
      Surface(pad: const EdgeInsets.symmetric(vertical: 6),
        child: Column(children: _feed[who]!.map((e) {
         final i = e[2] as int;
         return _feedTile('${e[0]}', '${e[1]}', _fi[i], _fh[i]);
        }).toList())),
    ]);
 }
}

// ═══ 3 · SUGGESTION MANAGEMENT ═══

class SuggestionManagementScreen extends StatefulWidget {
 const SuggestionManagementScreen({super.key});
 @override
 State<SuggestionManagementScreen> createState() => _SMState();
}

class _SMState extends State<SuggestionManagementScreen> {
 static const _opts = ['Under Review', 'Approved', 'Implemented'];

 final _list = [
  {'t': 'Start a Robotics Club', 'by': 'Pranav', 'v': 31, 's': 'Approved', 'r': ''},
  {'t': 'Add more books to the library', 'by': 'Anonymous', 'v': 24, 's': 'Under Review', 'r': ''},
  {'t': 'Reduce homework on weekends', 'by': 'Kushagr', 'v': 45, 's': 'Under Review', 'r': ''},
  {'t': 'Fix broken water fountain in Block B', 'by': 'Anonymous', 'v': 18, 's': 'Implemented',
   'r': 'Maintenance has resolved this - thanks for reporting.'},
  {'t': 'Inter-class quiz competitions', 'by': 'Adhvik', 'v': 29, 's': 'Approved', 'r': ''},
 ];

 final _ctrls = <int, TextEditingController>{};
 Color _hue(String s) => s == 'Implemented' ? _green : s == 'Approved' ? _purple : _amber;

 @override
 void dispose() {
  for (final c in _ctrls.values) { c.dispose(); }
  super.dispose();
 }

 void _send(int i) {
  final txt = _ctrls[i]!.text.trim();
  setState(() => _list[i]['r'] = txt);
  FocusScope.of(context).unfocus();
  if (txt.isEmpty) return;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: const Text('Response sent to student'), backgroundColor: _green,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
 }

 @override
 Widget build(BuildContext c) {
  final n = {for (final o in _opts) o: _list.where((x) => x['s'] == o).length};

  return _Page(
    title: 'Suggestion Management',
    sub: '${_list.length} suggestions · ${n['Under Review']} awaiting review',
    children: [
      const SizedBox(height: 18),
      Row(children: _opts.map((o) => _countTile(o, n[o]!, _hue(o))).toList()),
      _label('All suggestions'),
      ..._list.asMap().entries.map((e) {
       final s = e.value;
       final hue = _hue(s['s'] as String);
       _ctrls[e.key] ??= TextEditingController(text: s['r'] as String);

       return Padding(padding: const EdgeInsets.only(bottom: 14), child: Surface(
         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: Text(s['t'] as String, style: const TextStyle(fontSize: 14.5,
              fontWeight: FontWeight.w700, color: _ink, height: 1.35))),
            const SizedBox(width: 10),
            _pill(s['s'] as String, hue),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            const Icon(Icons.person_outline_rounded, size: 14, color: _muted),
            const SizedBox(width: 5),
            Text(s['by'] as String, style: const TextStyle(fontSize: 12, color: _muted)),
            const SizedBox(width: 16),
            const Icon(Icons.arrow_upward_rounded, size: 14, color: _muted),
            const SizedBox(width: 4),
            Text('${s['v']}', style: const TextStyle(fontSize: 12, color: _muted,
              fontWeight: FontWeight.w700)),
          ]),
          const Divider(height: 26),
          Row(children: [
            _Drop(s['s'] as String, _opts, (v) => setState(() => _list[e.key]['s'] = v!)),
            const Spacer(),
            IconButton(onPressed: () {}, tooltip: 'Forward to admin',
              icon: const Icon(Icons.forward_rounded, size: 19, color: _muted)),
          ]),
          const SizedBox(height: 8),
          TextField(controller: _ctrls[e.key], minLines: 1, maxLines: 3,
             style: const TextStyle(fontSize: 13),
             decoration: InputDecoration(
               hintText: 'Respond to the student…',
               hintStyle: const TextStyle(fontSize: 13, color: _muted),
               suffixIcon: IconButton(onPressed: () => _send(e.key),
                  icon: const Icon(Icons.send_rounded, size: 18, color: _purple)))),
         ])));
      }),
    ]);
 }
}

// ═══ 4 · STUDENT VOICE DASHBOARD ═══

class StudentVoiceDashboardScreen extends StatefulWidget {
 const StudentVoiceDashboardScreen({super.key});
 @override
 State<StudentVoiceDashboardScreen> createState() => _SVState();
}

class _SVState extends State<StudentVoiceDashboardScreen> {
 static const _opts = ['Pending', 'Under Review', 'Resolved'];

 final _reports = [
  {'id': '#001', 't': 'Bullying', 'd': 'A student is being teased repeatedly in the cafeteria.', 's': 'Pending', 'w': '1h ago'},
  {'id': '#002', 't': 'Mental Health', 'd': 'Feeling very overwhelmed with exam pressure lately.', 's': 'Under Review', 'w': '3h ago'},
  {'id': '#003', 't': 'Maintenance', 'd': 'Broken chair in Room 204 is a safety hazard.', 's': 'Resolved', 'w': '1d ago'},
  {'id': '#004', 't': 'Personal', 'd': 'Struggling to keep up with the current curriculum pace.', 's': 'Under Review', 'w': '2d ago'},
  {'id': '#005', 't': 'Bullying', 'd': 'Verbal harassment reported near the sports field.', 's': 'Resolved', 'w': '3d ago'},
 ];

 static const _meta = {
  'Bullying': [Icons.shield_rounded, _red],
  'Mental Health': [Icons.favorite_rounded, _purple],
  'Maintenance': [Icons.build_rounded, _amber],
  'Personal': [Icons.psychology_rounded, _teal],
 };

 Color _hue(String s) => s == 'Resolved' ? _green : s == 'Under Review' ? _purple : _amber;

 @override
 Widget build(BuildContext c) {
  final n = {for (final o in _opts) o: _reports.where((r) => r['s'] == o).length};

  return _Page(
    title: 'Student Voice',
    sub: '${n['Pending']} pending · ${n['Under Review']} in review',
    children: [
      const SizedBox(height: 18),
      Container(padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [_purple.withOpacity(.09), _teal.withOpacity(.09)]),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _purple.withOpacity(.18))),
        child: Row(children: [
         Container(padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(color: _purple.withOpacity(.13), shape: BoxShape.circle),
            child: const Icon(Icons.lock_rounded, color: _purple, size: 17)),
         const SizedBox(width: 13),
         const Expanded(child: Text(
            'All reports are fully anonymous. Student identities are never revealed.',
            style: TextStyle(fontSize: 12.5, color: _ink, height: 1.45))),
        ])),
      const SizedBox(height: 16),
      Row(children: _opts.map((o) => _countTile(o, n[o]!, _hue(o))).toList()),
      _label('Anonymous reports'),
      ..._reports.asMap().entries.map((e) {
       final r = e.value;
       final m = _meta[r['t']]!;
       final tHue = m[1] as Color;

       return Padding(padding: const EdgeInsets.only(bottom: 14), child: Surface(
         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(color: tHue.withOpacity(.12),
                borderRadius: BorderRadius.circular(11)),
              child: Icon(m[0] as IconData, size: 17, color: tHue)),
            const SizedBox(width: 11),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
             Text(r['t'] as String, style: TextStyle(fontSize: 13.5,
               fontWeight: FontWeight.w700, color: tHue)),
             const SizedBox(height: 2),
             Text('${r['id']} · ${r['w']}', style: const TextStyle(fontSize: 11, color: _muted)),
            ])),
          ]),
          const SizedBox(height: 14),
          Text(r['d'] as String, style: const TextStyle(fontSize: 13.5, height: 1.6, color: _ink)),
          const Divider(height: 26),
          Row(children: [
            const Text('Status', style: TextStyle(fontSize: 12, color: _muted,
              fontWeight: FontWeight.w600)),
            const SizedBox(width: 12),
            _Drop(r['s'] as String, _opts, (v) => setState(() => _reports[e.key]['s'] = v!)),
          ]),
         ])));
      }),
    ]);
 }
}

// ═══ 5 · TEACHER CHAT ═══

class TeacherChatScreen extends StatefulWidget {
 final String me;
 const TeacherChatScreen({super.key, required this.me});
 @override
 State<TeacherChatScreen> createState() => _ChatState();
}

class _ChatState extends State<TeacherChatScreen> {
 int sel = 0;
 final _input = TextEditingController();
 final _scroll = ScrollController();

 final _chats = [
  {'n': 'Pranav', 'l': 'When is the essay due?', 't': '10:42', 'u': 2, 'g': false},
  {'n': 'Kushagr', 'l': 'Can I get an extension?', 't': '09:30', 'u': 1, 'g': false},
  {'n': 'Adhvik', 'l': 'Submitted the project!', 't': 'Yest.', 'u': 0, 'g': false},
  {'n': 'Jack', 'l': 'Free at 3pm today?', 't': 'Yest.', 'u': 0, 'g': false},
  {'n': 'Grade 9A', 'l': 'Reminder: quiz tomorrow.', 't': '09:00', 'u': 0, 'g': true},
 ];

 final _msgs = <int, List<List<String>>>{
  0: [['them', 'Hi Sir, when is the History essay due?', '10:38'],
    ['me', 'This Friday by 11:59 PM.', '10:40'],
    ['them', 'Should we include a bibliography?', '10:41'],
    ['me', 'Yes - at least 3 sources from the Research Hub.', '10:42']],
  1: [['them', 'Can I get a 2-day extension on the worksheet?', '09:28'],
    ['me', 'I\'ll give you one extra day. Submit by tomorrow.', '09:30']],
  2: [['them', 'I submitted the project just now!', 'Yest.'],
    ['me', 'Great work Adhvik - I\'ll review it today.', 'Yest.']],
  3: [['them', 'Hey, free at 3pm today?', 'Yest.'],
    ['me', 'Yes, let\'s catch up in the staff room.', 'Yest.']],
  4: [['me', 'Reminder: tomorrow\'s quiz covers Chapters 3–5.', '09:00']],
 };

 void _send() {
  final t = _input.text.trim();
  if (t.isEmpty) return;
  setState(() {
   _msgs.putIfAbsent(sel, () => []).add(['me', t, 'Now']);
   _chats[sel]['l'] = t;
   _input.clear();
  });
  WidgetsBinding.instance.addPostFrameCallback((_) {
   if (_scroll.hasClients) {
    _scroll.animateTo(_scroll.position.maxScrollExtent,
       duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
   }
  });
 }

 @override
 void dispose() { _input.dispose(); _scroll.dispose(); super.dispose(); }

 @override
 Widget build(BuildContext c) {
  final wide = MediaQuery.of(c).size.width >= 760;
  return Column(children: [
   _Head('Teacher Chat', sub: 'Signed in as ${widget.me}'),
   Expanded(child: wide
      ? Row(children: [SizedBox(width: 272, child: _list()), Expanded(child: _thread())])
      : _thread()),
  ]);
 }

 Widget _list() => Container(color: Colors.white, child: ListView.builder(
   padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
   itemCount: _chats.length,
   itemBuilder: (_, i) {
    final ch = _chats[i];
    final on = sel == i, grp = ch['g'] as bool;
    final hue = grp ? _teal : _purple;
    return Padding(padding: const EdgeInsets.only(bottom: 4),
       child: Material(color: Colors.transparent, child: InkWell(
         borderRadius: BorderRadius.circular(14),
         onTap: () => setState(() { sel = i; _chats[i]['u'] = 0; }),
         child: AnimatedContainer(duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: on ? _purple.withOpacity(.09) : Colors.transparent,
              borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
             _avatar((ch['n'] as String)[0], r: 19, bg: hue.withOpacity(.14), fg: hue),
             const SizedBox(width: 12),
             Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(ch['n'] as String, style: TextStyle(fontSize: 13.5, color: _ink,
                fontWeight: on ? FontWeight.w800 : FontWeight.w600)),
              const SizedBox(height: 3),
              Text(ch['l'] as String, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11.5, color: _muted)),
             ])),
             const SizedBox(width: 8),
             Column(children: [
              Text(ch['t'] as String, style: const TextStyle(fontSize: 10, color: _muted)),
              const SizedBox(height: 5),
              if ((ch['u'] as int) > 0)
               Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: const BoxDecoration(gradient: _gradSoft, shape: BoxShape.circle),
                  child: Text('${ch['u']}', style: const TextStyle(fontSize: 10,
                    color: Colors.white, fontWeight: FontWeight.w700))),
             ]),
            ])))));
   }));

 Widget _thread() {
  final ch = _chats[sel];
  final grp = ch['g'] as bool;
  final hue = grp ? _teal : _purple;
  final ms = _msgs[sel] ?? [];

  return Column(children: [
   Container(color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(children: [
       _avatar((ch['n'] as String)[0], r: 19, bg: hue.withOpacity(.14), fg: hue),
       const SizedBox(width: 13),
       Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(ch['n'] as String, style: const TextStyle(fontSize: 15,
          fontWeight: FontWeight.w700, color: _ink)),
        const SizedBox(height: 3),
        Row(children: [_dot(_green), const SizedBox(width: 6),
         Text(grp ? 'Class group' : 'Active now',
            style: const TextStyle(fontSize: 11, color: _muted))]),
       ])),
      ])),
   Container(height: 1, color: _indigo.withOpacity(.05)),
   Expanded(child: ListView.builder(controller: _scroll,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
      itemCount: ms.length,
      itemBuilder: (_, i) {
       final m = ms[i];
       final mine = m[0] == 'me';
       return Align(alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
         child: Container(margin: const EdgeInsets.only(bottom: 11),
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.fromLTRB(15, 11, 15, 9),
            decoration: BoxDecoration(
              gradient: mine ? _gradSoft : null,
              color: mine ? null : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18), topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(mine ? 18 : 5),
                bottomRight: Radius.circular(mine ? 5 : 18)),
              boxShadow: [BoxShadow(color: (mine ? _purple : _indigo).withOpacity(mine ? .25 : .06),
                blurRadius: 12, offset: const Offset(0, 4))]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
             Text(m[1], style: TextStyle(color: mine ? Colors.white : _ink,
               fontSize: 14, height: 1.45)),
             const SizedBox(height: 3),
             Text(m[2], style: TextStyle(color: mine ? Colors.white70 : _muted, fontSize: 10)),
            ])));
      })),
   Container(color: Colors.white,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 16),
      child: Row(children: [
       Expanded(child: TextField(controller: _input, onSubmitted: (_) => _send(),
         style: const TextStyle(fontSize: 14),
         decoration: const InputDecoration(hintText: 'Message…',
            hintStyle: TextStyle(fontSize: 14, color: _muted)))),
       const SizedBox(width: 10),
       Container(decoration: BoxDecoration(gradient: _gradSoft, shape: BoxShape.circle,
         boxShadow: [BoxShadow(color: _purple.withOpacity(.35), blurRadius: 12,
            offset: const Offset(0, 4))]),
         child: IconButton(onPressed: _send,
            icon: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 20))),
      ])),
  ]);
 }
}

// ═══ 6 · TEACHER PROFILE ═══

class TeacherProfileScreen extends StatelessWidget {
 final String name;
 const TeacherProfileScreen({super.key, required this.name});

 @override
 Widget build(BuildContext c) => _ProfileBody(
   name: name, role: 'Teacher', icon: Icons.school_rounded,
   rows: [
    ['School email', '${name.toLowerCase()}@campusconnect.edu', Icons.mail_rounded],
    ['Subjects', 'History · Computer Science', Icons.menu_book_rounded],
    ['Classes', 'Grade 9A, 9B · Grade 10A', Icons.groups_rounded],
    ['Employee ID', 'TC-2024-${name == 'Jason' ? '001' : '002'}', Icons.badge_rounded],
   ],
   stats: const [
    _Stat('Assignments created', '42', Icons.assignment_rounded, _purple),
    _Stat('Students managed', '3', Icons.groups_rounded, _green),
    _Stat('Suggestions handled', '5', Icons.lightbulb_rounded, _amber),
    _Stat('Reports resolved', '2', Icons.verified_rounded, _teal),
   ]);
}

// ═══ 7 · ADMIN DASHBOARD ═══

class AdminDashboardScreen extends StatelessWidget {
 const AdminDashboardScreen({super.key});

 static const _feed = [
  ['New Student Voice report submitted', '10 min ago', 0],
  ['Suggestion "Robotics Club" approved', '1h ago', 1],
  ['Announcement posted · Sports Day', '2h ago', 2],
  ['New teacher account · Jack', '1d ago', 3],
  ['Report #003 marked Resolved', '1d ago', 1],
 ];
 static const _fi = [Icons.volunteer_activism_rounded, Icons.check_circle_rounded,
   Icons.campaign_rounded, Icons.person_add_rounded];
 static const _fh = [_red, _green, _purple, _amber];

 static const _actions = [
  ['Add user', Icons.person_add_rounded, _purple],
  ['Announcement', Icons.campaign_rounded, _green],
  ['Create event', Icons.event_rounded, _amber],
  ['View reports', Icons.flag_rounded, _red],
 ];

 @override
 Widget build(BuildContext c) => _Page(
   title: 'Admin Dashboard',
   sub: 'CampusConnect · full platform overview',
   trailing: Container(padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(color: Colors.white.withOpacity(.18), shape: BoxShape.circle),
      child: const Icon(Icons.shield_rounded, color: Colors.white, size: 22)),
   children: [
    const SizedBox(height: 18),
    _label('Platform'),
    _grid(const [
      _Stat('Total students', '3', Icons.groups_rounded, _purple),
      _Stat('Teachers', '2', Icons.school_rounded, _green),
      _Stat('Active classes', '3', Icons.class_rounded, _amber),
      _Stat('Open reports', '2', Icons.flag_rounded, _red),
      _Stat('Pending suggestions', '2', Icons.lightbulb_rounded, _teal),
      _Stat('Events this month', '3', Icons.event_rounded, _indigo),
    ]),
    _label('Quick actions'),
    Wrap(spacing: 11, runSpacing: 11, children: _actions.map((a) {
      final hue = a[2] as Color;
      return Material(color: Colors.transparent, child: InkWell(
        borderRadius: BorderRadius.circular(14), onTap: () {},
        child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(color: hue.withOpacity(.1),
             borderRadius: BorderRadius.circular(14),
             border: Border.all(color: hue.withOpacity(.22))),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(a[1] as IconData, size: 17, color: hue),
            const SizedBox(width: 9),
            Text(a[0] as String, style: TextStyle(fontSize: 13, color: hue,
              fontWeight: FontWeight.w700)),
          ]))));
    }).toList()),
    _label('Recent activity'),
    Surface(pad: const EdgeInsets.symmetric(vertical: 6),
       child: Column(children: _feed.map((f) {
        final i = f[2] as int;
        return _feedTile(f[0] as String, f[1] as String, _fi[i], _fh[i]);
       }).toList())),
   ]);
}

// ═══ 8 · ADMIN PROFILE ═══

class AdminProfileScreen extends StatelessWidget {
 const AdminProfileScreen({super.key});

 @override
 Widget build(BuildContext c) => const _ProfileBody(
   name: 'Abhyuday', role: 'System Administrator', icon: Icons.shield_rounded,
   rows: [
    ['School email', 'abhyuday@campusconnect.edu', Icons.mail_rounded],
    ['Admin ID', 'ADM-2024-001', Icons.badge_rounded],
    ['Access level', 'Full access', Icons.lock_open_rounded],
    ['Permissions', 'Users · Classes · Reports', Icons.verified_user_rounded],
   ],
   stats: [
    _Stat('Users managed', '6', Icons.manage_accounts_rounded, _purple),
    _Stat('Reports reviewed', '5', Icons.flag_rounded, _red),
    _Stat('Announcements', '3', Icons.campaign_rounded, _green),
    _Stat('Events created', '3', Icons.event_rounded, _teal),
   ]);
}

// ═══ SHARED PROFILE LAYOUT ═══

class _ProfileBody extends StatelessWidget {
 final String name, role;
 final IconData icon;
 final List<List<dynamic>> rows;
 final List<_Stat> stats;
 const _ProfileBody({required this.name, required this.role, required this.icon,
   required this.rows, required this.stats});

 @override
 Widget build(BuildContext c) => Column(children: [
   Container(width: double.infinity,
      decoration: const BoxDecoration(gradient: _grad),
      padding: const EdgeInsets.fromLTRB(22, 34, 22, 34),
      child: SafeArea(bottom: false, child: Column(children: [
       Container(padding: const EdgeInsets.all(4),
         decoration: BoxDecoration(shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(.3), width: 2)),
         child: CircleAvatar(radius: 38, backgroundColor: Colors.white.withOpacity(.16),
            child: Text(name[0], style: const TextStyle(fontSize: 34,
              color: Colors.white, fontWeight: FontWeight.w800)))),
       const SizedBox(height: 16),
       Text(name, style: const TextStyle(color: Colors.white, fontSize: 24,
         fontWeight: FontWeight.w800, letterSpacing: -.3)),
       const SizedBox(height: 9),
       Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
         decoration: BoxDecoration(color: Colors.white.withOpacity(.18),
            borderRadius: BorderRadius.circular(30)),
         child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 7),
          Text(role, style: const TextStyle(color: Colors.white, fontSize: 12.5,
             fontWeight: FontWeight.w700)),
         ])),
      ]))),
   Expanded(child: ListView(padding: const EdgeInsets.fromLTRB(20, 4, 20, 32), children: [
    _label('Details'),
    Surface(pad: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
       child: Column(children: rows.map((r) => Padding(
         padding: const EdgeInsets.symmetric(vertical: 13),
         child: Row(children: [
          Container(padding: const EdgeInsets.all(9),
             decoration: BoxDecoration(color: _purple.withOpacity(.1),
               borderRadius: BorderRadius.circular(11)),
             child: Icon(r[2] as IconData, size: 16, color: _purple)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(r[0] as String, style: const TextStyle(fontSize: 11, color: _muted)),
            const SizedBox(height: 3),
            Text(r[1] as String, style: const TextStyle(fontSize: 13.5,
              fontWeight: FontWeight.w600, color: _ink)),
          ])),
         ]))).toList())),
    _label('Activity'),
    _grid(stats, ratio: 1.4),
    const SizedBox(height: 26),
    _gradBtn('Edit profile', Icons.edit_rounded, () {}),
    const SizedBox(height: 11),
    OutlinedButton.icon(onPressed: () {},
       icon: const Icon(Icons.lock_reset_rounded, size: 18),
       label: const Text('Change password'),
       style: OutlinedButton.styleFrom(foregroundColor: _purple,
         minimumSize: const Size.fromHeight(50),
         side: BorderSide(color: _purple.withOpacity(.35)),
         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)))),
   ])),
  ]);
}

// ═══ 9 · AI REPORT CARD GENERATOR ═══
//
// Composes a personalised written progress report from the same data the rest
// of the module displays, then exports it as a real A4 PDF.

/// Per-student detail that only the report generator needs.
const _deep = {
 'Pranav': {
  'roll': '9A-07', 'att': .94, 'punc': .91, 'rank': 2,
  'hist': [.79, .84, .91],
  'subj': {'Mathematics': .93, 'Science': .96, 'English': .82, 'History': .88},
  'style': 'research-led - learns fastest from primary sources and open-ended questions',
  'work': ['the Silk Road trade essay', 'Discovery Quest #4 on ancient civilisations'],
  'habit': 'starts long tasks early and revises before submitting',
  'watch': 'written expression in English lags behind the quality of the thinking behind it',
  'goal': 'lead a research group and push English writing up to the level of the analysis',
 },
 'Kushagr': {
  'roll': '9A-12', 'att': .78, 'punc': .69, 'rank': 3,
  'hist': [.71, .68, .66],
  'subj': {'Mathematics': .61, 'Science': .58, 'English': .74, 'History': .70},
  'style': 'discussion-led - engages far more in verbal work than in written follow-up',
  'work': ['the English narrative draft', 'the Chapter 5 science worksheet'],
  'habit': 'contributes confidently in class but loses marks on work handed in late',
  'watch': 'attendance and punctuality are now the main drag on the overall result',
  'goal': 'build a fixed routine for submitting written work on the day it is due',
 },
 'Adhvik': {
  'roll': '9A-01', 'att': .99, 'punc': .98, 'rank': 1,
  'hist': [.88, .92, .96],
  'subj': {'Mathematics': .98, 'Science': .95, 'English': .93, 'History': .97},
  'style': 'independent and methodical - plans, drafts, then refines well ahead of deadlines',
  'work': ['the Perfect Score mathematics paper', 'Discovery Quest #5'],
  'habit': 'sets the standard in the class for preparation and presentation',
  'watch': 'the current syllabus is no longer stretching them',
  'goal': 'mentor a peer and attempt olympiad-level extension work',
 },
};

class _Report {
 final String student, roll, teacher, term, grade, predicted, audience, style, note;
 final int overall, prev, rank, xp, miss, classAvg;
 final double att, punc;
 final List<double> hist;
 final Map<String, double> subj;
 final List<String> badges, signals;
 final String opening, subjects, habits, growth, nextSteps;

 const _Report({required this.student, required this.roll, required this.teacher,
   required this.term, required this.grade, required this.predicted, required this.audience,
   required this.style, required this.note, required this.overall, required this.prev,
   required this.rank, required this.xp, required this.miss, required this.classAvg,
   required this.att, required this.punc, required this.hist, required this.subj,
   required this.badges, required this.signals, required this.opening, required this.subjects,
   required this.habits, required this.growth, required this.nextSteps});

 int get delta => overall - prev;

 String get plain => '$term - Academic Progress Report\n'
   '$student ($roll)   Overall $overall% · Grade $grade · Rank $rank of ${_students.length}\n\n'
   'OVERVIEW\n$opening\n\nSUBJECT PERFORMANCE\n$subjects\n\n'
   'LEARNING HABITS\n$habits\n\nAREA FOR GROWTH\n$growth\n\n'
   'NEXT STEPS\n$nextSteps\n'
   '${note.trim().isEmpty ? '' : '\nTEACHER NOTE\n${note.trim()}\n'}'
   '\nPrepared by $teacher · CampusConnect';
}

String _grade(int o) => o >= 93 ? 'A+' : o >= 85 ? 'A' : o >= 77 ? 'B+'
  : o >= 70 ? 'B' : o >= 60 ? 'C' : 'D';

int _classAvg() {
 final v = _profiles.values.map((p) => (p['o'] as double) * 100).toList();
 return (v.reduce((a, b) => a + b) / v.length).round();
}

_Report _compose(String w, String aud, String teacher, String term, String note) {
 final p = _profiles[w]!, d = _deep[w]!;
 final subj = (d['subj'] as Map).cast<String, double>();
 final hist = (d['hist'] as List).cast<double>();
 final work = (d['work'] as List).cast<String>();
 final badges = (p['b'] as List).cast<String>();

 final ranked = subj.entries.toList()..sort((x, y) => y.value.compareTo(x.value));
 final bk = ranked.first.key, wk = ranked.last.key;
 final bp = (ranked.first.value * 100).round(), wp = (ranked.last.value * 100).round();

 final o = ((p['o'] as double) * 100).round();
 final prev = (hist[hist.length - 2] * 100).round();
 final delta = o - prev;
 final avg = _classAvg();
 final rank = d['rank'] as int;
 final att = d['att'] as double, punc = d['punc'] as double;
 final miss = p['miss'] as int, xp = p['xp'] as int;
 final g = _grade(o);
 final pg = _grade((o + (delta * 0.7).round()).clamp(0, 100));

 final ms = miss == 1 ? '' : 's';
 final ap = (att * 100).round(), pp = (punc * 100).round();
 final vsAvg = o - avg;
 final trend = delta >= 3 ? 'up $delta points on last term'
   : delta <= -3 ? 'down ${-delta} points on last term'
   : 'broadly level with last term';
 final place = vsAvg >= 5 ? '$vsAvg points above the class average of $avg%'
   : vsAvg <= -5 ? '${-vsAvg} points below the class average of $avg%'
   : 'in line with the class average of $avg%';
 final ord = rank == 1 ? '1st' : rank == 2 ? '2nd' : rank == 3 ? '3rd' : '${rank}th';

 String open, subs, hab, grow, next;

 // ── Voice: written to the parent, to the student, or for the school record ──
 if (aud == 'Parents') {
  open = '$w has completed $term with an overall attainment of $o%, a grade $g, placing them '
    '$ord in a class of ${_students.length} and $place. The result is $trend. '
    '${badges.isEmpty ? 'Effort has been steady throughout.'
      : 'They also earned ${badges.length} commendation${badges.length == 1 ? '' : 's'} this '
        'term: ${badges.join(' and ')}.'}';
  subs = '$w is strongest in $bk at $bp%, where ${work.first} was a clear highlight. '
    '$wk sits at $wp% and is the subject where support at home would make the most difference. '
    'Across all four subjects the pattern is ${_spreadWord(subj)}.';
  hab = 'Attendance stands at $ap% and punctuality at $pp%. As a learner $w is ${d['style']}, '
    'and ${d['habit']}. '
    '${miss == 0 ? 'Every piece of set work has been handed in on time this term.'
      : 'There ${miss == 1 ? 'is' : 'are'} currently $miss outstanding submission$ms, '
        'including ${work.last}.'}';
  grow = 'The honest area to work on is that ${d['watch']}. This is very fixable - twenty '
    'focused minutes on $wk three evenings a week, with the work checked rather than just '
    'completed, would move the needle quickly.';
  next = 'Over the coming term we would like $w to ${d['goal']}. On current trajectory the '
    'projected grade is $pg. We are always glad to talk this through - please reach out through '
    'the school portal to arrange a meeting.';
 } else if (aud == 'Student') {
  open = '$w - you finished $term on $o%, a grade $g. That puts you $ord in the class and '
    '$place, and it is $trend. '
    '${badges.isEmpty ? 'Keep building on the effort you have put in.'
      : 'You picked up ${badges.join(' and ')} along the way, which is genuinely worth being '
        'proud of.'}';
  subs = 'Your best subject is $bk at $bp% - ${work.first} was the standout piece, and it '
    'showed what you can do when you give yourself time. $wk is at $wp%, and that is the one '
    'holding your average back rather than anything to do with ability.';
  hab = 'You were present $ap% of the time and on time $pp% of the time. You are ${d['style']}, '
    'and you ${d['habit']}. '
    '${miss == 0 ? 'Everything has been handed in - that consistency is a real strength.'
      : 'You still owe $miss piece$ms of work, including ${work.last}. Clear those first.'}';
  grow = 'Being straight with you: ${d['watch']}. It is not a talent problem. Pick $wk, give '
    'it short and regular attention rather than one long panic session, and you will see the '
    'number move within a few weeks.';
  next = 'The target for next term is to ${d['goal']}. If you keep the current pattern you are '
    'on course for a $pg. Come and find me if you want help building a plan - that is what '
    'I am here for.';
 } else {
  open = 'Candidate $w (roll ${d['roll']}) attained an aggregate of $o% for $term, corresponding '
    'to grade $g. Class position is $ord of ${_students.length}; the result is $place and $trend. '
    'Cumulative platform engagement is recorded at $xp XP.';
  subs = 'Highest attainment was recorded in $bk ($bp%) and lowest in $wk ($wp%). Assessed '
    'evidence includes ${work.first}. Subject variance across the cohort profile is '
    '${_spreadWord(subj)}.';
  hab = 'Attendance $ap%; punctuality $pp%. Recorded learning profile: ${d['style']}. '
    '${miss == 0 ? 'No outstanding submissions on record.'
      : '$miss outstanding submission$ms on record, including ${work.last}.'}';
  grow = 'Noted concern: ${d['watch']}. Targeted intervention in $wk is advised, with '
    'reassessment at the mid-point of the next reporting cycle.';
  next = 'Recommended objective for the next cycle: ${d['goal']}. Projected attainment band: '
    '$pg. Continued placement in the current set is endorsed subject to review.';
 }

 return _Report(student: w, roll: d['roll'] as String, teacher: teacher, term: term,
   grade: g, predicted: pg, audience: aud, style: d['style'] as String, note: note,
   overall: o, prev: prev, rank: rank, xp: xp, miss: miss, classAvg: avg,
   att: att, punc: punc, hist: hist, subj: subj, badges: badges,
   signals: ['$ap% attendance', '$xp XP', '${badges.length} badges',
     '$miss missing', 'Rank $ord', '${delta >= 0 ? '+' : ''}$delta vs last term'],
   opening: open, subjects: subs, habits: hab, growth: grow, nextSteps: next);
}

String _spreadWord(Map<String, double> s) {
 final v = s.values.toList()..sort();
 final gap = ((v.last - v.first) * 100).round();
 return gap <= 8 ? 'very even, with no weak subject to flag'
   : gap <= 18 ? 'fairly even, with one subject trailing the rest'
   : 'uneven - a $gap-point gap between the strongest and weakest subject';
}

// ── Trend sparkline ──

class _Spark extends StatelessWidget {
 final List<double> v;
 final Color color;
 const _Spark(this.v, this.color);
 @override
 Widget build(BuildContext c) => SizedBox(height: 44,
   child: TweenAnimationBuilder<double>(
     tween: Tween(begin: 0, end: 1),
     duration: const Duration(milliseconds: 750), curve: Curves.easeOutCubic,
     builder: (_, t, __) => CustomPaint(painter: _SparkPainter(v, color, t),
       size: const Size(double.infinity, 44))));
}

class _SparkPainter extends CustomPainter {
 final List<double> v;
 final Color color;
 final double t;
 _SparkPainter(this.v, this.color, this.t);

 @override
 void paint(Canvas cv, Size s) {
  if (v.length < 2) return;
  final lo = v.reduce((a, b) => a < b ? a : b) - .06;
  final hi = v.reduce((a, b) => a > b ? a : b) + .06;
  final pts = <Offset>[];
  for (var i = 0; i < v.length; i++) {
   final x = s.width * i / (v.length - 1);
   final y = s.height - ((v[i] - lo) / (hi - lo)) * s.height;
   pts.add(Offset(x, y));
  }
  final path = Path()..moveTo(pts.first.dx, pts.first.dy);
  for (var i = 1; i < pts.length; i++) {
   final a = pts[i - 1], b = pts[i], mx = (a.dx + b.dx) / 2;
   path.cubicTo(mx, a.dy, mx, b.dy, b.dx, b.dy);
  }
  final fill = Path.from(path)
   ..lineTo(pts.last.dx, s.height)..lineTo(pts.first.dx, s.height)..close();
  cv.drawPath(fill, Paint()..shader = LinearGradient(
    begin: Alignment.topCenter, end: Alignment.bottomCenter,
    colors: [color.withOpacity(.22 * t), color.withOpacity(0)])
     .createShader(Rect.fromLTWH(0, 0, s.width, s.height)));
  cv.drawPath(path, Paint()..color = color.withOpacity(t)
    ..style = PaintingStyle.stroke..strokeWidth = 2.4..strokeCap = StrokeCap.round);
  for (final pt in pts) {
   cv.drawCircle(pt, 3.4, Paint()..color = Colors.white);
   cv.drawCircle(pt, 3.4, Paint()..color = color.withOpacity(t)
     ..style = PaintingStyle.stroke..strokeWidth = 2);
  }
 }

 @override
 bool shouldRepaint(_SparkPainter old) => old.t != t || old.v != v;
}

// ── Screen ──

class ReportCardScreen extends StatefulWidget {
 final String teacher;
 const ReportCardScreen({super.key, required this.teacher});
 @override
 State<ReportCardScreen> createState() => _RCState();
}

class _RCState extends State<ReportCardScreen> {
 static const _auds = ['Parents', 'Student', 'School records'];
 static const _termList = ['Term 3 · 2025-26', 'Term 2 · 2025-26'];
 static const _steps = ['Reading assessment history…', 'Comparing to class average…',
   'Checking attendance and submissions…', 'Writing the report…'];

 String who = _students.first, aud = 'Parents', term = _termList.first;
 final _note = TextEditingController();
 bool busy = false;
 int step = 0;
 _Report? out;

 @override
 void dispose() { _note.dispose(); super.dispose(); }

 Future<void> _generate() async {
  setState(() { busy = true; out = null; step = 0; });
  for (var i = 0; i < _steps.length; i++) {
   await Future.delayed(const Duration(milliseconds: 320));
   if (!mounted) return;
   setState(() => step = i);
  }
  await Future.delayed(const Duration(milliseconds: 260));
  if (!mounted) return;
  setState(() {
   busy = false;
   out = _compose(who, aud, widget.teacher, term, _note.text);
  });
 }

 void _refresh() {
  if (out == null) return;
  setState(() => out = _compose(who, aud, widget.teacher, term, _note.text));
 }

 Future<void> _export() async {
  final r = out;
  if (r == null) return;
  final bytes = await _reportPdf(r);
  await Printing.layoutPdf(onLayout: (_) async => bytes,
    name: 'ReportCard_${r.student}_${r.roll}.pdf');
 }

 Future<void> _exportAll() async {
  final docs = <_Report>[for (final s in _students)
    _compose(s, aud, widget.teacher, term, '')];
  final bytes = await _reportPdf(docs.first, extra: docs.skip(1).toList());
  await Printing.layoutPdf(onLayout: (_) async => bytes,
    name: 'ReportCards_Grade9A_${term.split(' ').first}.pdf');
 }

 void _copy() {
  final r = out;
  if (r == null) return;
  Clipboard.setData(ClipboardData(text: r.plain));
  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    content: Text('Report copied to clipboard'), behavior: SnackBarBehavior.floating));
 }

 @override
 Widget build(BuildContext c) => _Page(
   title: 'AI Report Cards',
   sub: 'Personalised progress reports, ready to send',
   trailing: _Drop(who, _students, (v) => setState(() { who = v!; out = null; }), light: true),
   children: [
    const SizedBox(height: 18),
    _snapshot(),
    _label('Composer'),
    Surface(pad: const EdgeInsets.all(18), child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
     const Text('WRITE THIS REPORT FOR', style: TextStyle(fontSize: 10,
       fontWeight: FontWeight.w800, color: _muted, letterSpacing: 1.1)),
     const SizedBox(height: 10),
     Wrap(spacing: 8, runSpacing: 8, children: _auds.map((t) {
      final on = t == aud;
      return GestureDetector(
        onTap: () => setState(() { aud = t; if (out != null) _refresh(); }),
        child: AnimatedContainer(duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
          decoration: BoxDecoration(gradient: on ? _gradSoft : null,
            color: on ? null : _bg, borderRadius: BorderRadius.circular(30),
            border: Border.all(color: on ? Colors.transparent : _purple.withOpacity(.18))),
          child: Text(t, style: TextStyle(fontSize: 12.5,
            fontWeight: on ? FontWeight.w700 : FontWeight.w600,
            color: on ? Colors.white : _ink))));
     }).toList()),
     const SizedBox(height: 18),
     const Text('REPORTING PERIOD', style: TextStyle(fontSize: 10,
       fontWeight: FontWeight.w800, color: _muted, letterSpacing: 1.1)),
     const SizedBox(height: 10),
     Align(alignment: Alignment.centerLeft,
       child: _Drop(term, _termList, (v) => setState(() { term = v!; out = null; }))),
     const SizedBox(height: 18),
     const Text('YOUR OWN NOTE  ·  OPTIONAL', style: TextStyle(fontSize: 10,
       fontWeight: FontWeight.w800, color: _muted, letterSpacing: 1.1)),
     const SizedBox(height: 10),
     TextField(controller: _note, maxLines: 3,
       onChanged: (_) => _refresh(),
       style: const TextStyle(fontSize: 13, height: 1.5),
       decoration: const InputDecoration(
         hintText: 'Anything you want added in your own words - it appears at the '
           'end of the report and in the PDF.',
         hintStyle: TextStyle(fontSize: 12.5, color: _muted, height: 1.45))),
     const SizedBox(height: 20),
     if (busy) _loader() else _gradBtn(out == null ? 'Generate report' : 'Regenerate',
       Icons.auto_awesome_rounded, _generate),
    ])),
    if (out != null) ...[
     _label('Preview  ·  matches the exported PDF'),
     _paper(out!),
     const SizedBox(height: 18),
     _gradBtn('Export as PDF', Icons.picture_as_pdf_rounded, _export),
     const SizedBox(height: 11),
     Row(children: [
      Expanded(child: _ghost('Copy text', Icons.copy_rounded, _purple, _copy)),
      const SizedBox(width: 11),
      Expanded(child: _ghost('Discard', Icons.close_rounded, _muted,
        () => setState(() => out = null))),
     ]),
     const SizedBox(height: 11),
     _ghost('Export all ${_students.length} reports as one PDF',
       Icons.folder_zip_rounded, _teal, _exportAll),
    ],
   ]);

 Widget _loader() => Container(
   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
   decoration: BoxDecoration(color: _purple.withOpacity(.08),
     borderRadius: BorderRadius.circular(14)),
   child: Row(children: [
    const SizedBox(width: 16, height: 16,
      child: CircularProgressIndicator(strokeWidth: 2, color: _purple)),
    const SizedBox(width: 13),
    Expanded(child: AnimatedSwitcher(duration: const Duration(milliseconds: 220),
      child: Text(_steps[step], key: ValueKey(step),
        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: _purple)))),
   ]));

 /// Live data snapshot above the composer.
 Widget _snapshot() {
  final p = _profiles[who]!, d = _deep[who]!;
  final hist = (d['hist'] as List).cast<double>();
  final o = ((p['o'] as double) * 100).round();
  final prev = (hist[hist.length - 2] * 100).round();
  final delta = o - prev;
  final hue = delta > 0 ? _green : delta < 0 ? _red : _purple;
  return Surface(pad: const EdgeInsets.all(18), child: Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
   Row(children: [
    _avatar(who[0], r: 20, bg: hue.withOpacity(.14), fg: hue),
    const SizedBox(width: 12),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
     Text('$who · ${d['roll']}', style: const TextStyle(fontSize: 14.5,
       fontWeight: FontWeight.w800, color: _ink)),
     const SizedBox(height: 3),
     Text('Rank ${d['rank']} of ${_students.length}  ·  class avg ${_classAvg()}%',
       style: const TextStyle(fontSize: 11.5, color: _muted)),
    ])),
    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
     Text('$o%', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
       color: hue, height: 1)),
     const SizedBox(height: 4),
     Row(children: [
      Icon(delta >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
        size: 13, color: hue),
      const SizedBox(width: 4),
      Text('${delta >= 0 ? '+' : ''}$delta pts', style: TextStyle(fontSize: 11.5,
        fontWeight: FontWeight.w700, color: hue)),
     ]),
    ]),
   ]),
   const SizedBox(height: 16),
   _Spark(hist, hue),
   const SizedBox(height: 6),
   Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: List.generate(
     hist.length, (i) => Text('T${i + 1}',
       style: const TextStyle(fontSize: 10, color: _muted)))),
  ]));
 }

}

Widget _ghost(String t, IconData i, Color c, VoidCallback tap) => OutlinedButton.icon(
  onPressed: tap, icon: Icon(i, size: 17), label: Text(t),
  style: OutlinedButton.styleFrom(foregroundColor: c,
    minimumSize: const Size.fromHeight(48),
    side: BorderSide(color: c.withOpacity(.35)),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))));

/// On-screen preview styled like the exported page. Shared by the teacher
/// generator and the student's read-only view.
Widget _paper(_Report r) {
  final hue = r.overall >= 85 ? _green : r.overall >= 70 ? _purple : _amber;
  return Container(
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: _purple.withOpacity(.12)),
      boxShadow: [BoxShadow(color: _indigo.withOpacity(.09),
        blurRadius: 24, offset: const Offset(0, 8))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
     Container(width: double.infinity,
       decoration: const BoxDecoration(gradient: _grad),
       padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
         const Icon(Icons.school_rounded, color: Colors.white, size: 15),
         const SizedBox(width: 8),
         Text('CAMPUSCONNECT', style: TextStyle(fontSize: 10, letterSpacing: 1.7,
           fontWeight: FontWeight.w800, color: Colors.white.withOpacity(.85))),
         const Spacer(),
         Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
           decoration: BoxDecoration(color: Colors.white.withOpacity(.18),
             borderRadius: BorderRadius.circular(20)),
           child: Text('For ${r.audience.toLowerCase()}',
             style: const TextStyle(fontSize: 9.5, color: Colors.white,
               fontWeight: FontWeight.w700))),
        ]),
        const SizedBox(height: 13),
        const Text('Academic Progress Report', style: TextStyle(color: Colors.white,
          fontSize: 19, fontWeight: FontWeight.w800, letterSpacing: -.3)),
        const SizedBox(height: 4),
        Text('${r.term}  ·  Grade 9, Section A',
          style: TextStyle(fontSize: 11.5, color: Colors.white.withOpacity(.72))),
       ])),
     Padding(padding: const EdgeInsets.all(20),
       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
         _avatar(r.student[0], r: 22, bg: hue.withOpacity(.14), fg: hue),
         const SizedBox(width: 13),
         Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(r.student, style: const TextStyle(fontSize: 17,
            fontWeight: FontWeight.w800, color: _ink)),
          const SizedBox(height: 3),
          Text('Roll ${r.roll}  ·  Rank ${r.rank} of ${_students.length}',
            style: const TextStyle(fontSize: 11.5, color: _muted)),
         ])),
         Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${r.overall}%', style: TextStyle(fontSize: 24,
            fontWeight: FontWeight.w800, color: hue, height: 1)),
          const SizedBox(height: 5),
          _pill('Grade ${r.grade}', hue, solid: true),
         ]),
        ]),
        const SizedBox(height: 16),
        Wrap(spacing: 6, runSpacing: 6,
          children: r.signals.map((s) => _pill(s, _purple)).toList()),
        const SizedBox(height: 18),
        Row(children: [
         _mini('Attendance', '${(r.att * 100).round()}%',
           r.att >= .9 ? _green : r.att >= .8 ? _amber : _red),
         const SizedBox(width: 10),
         _mini('Punctuality', '${(r.punc * 100).round()}%',
           r.punc >= .9 ? _green : r.punc >= .8 ? _amber : _red),
         const SizedBox(width: 10),
         _mini('Projected', r.predicted, _teal),
        ]),
        const SizedBox(height: 20),
        const Divider(height: 1),
        const SizedBox(height: 18),
        const Text('SUBJECT BREAKDOWN', style: TextStyle(fontSize: 10,
          fontWeight: FontWeight.w800, color: _muted, letterSpacing: 1.1)),
        const SizedBox(height: 12),
        ...r.subj.entries.map((e) => _Bar(e.key, e.value,
          e.value >= .85 ? _green : e.value >= .7 ? _purple : _amber)),
        const SizedBox(height: 6),
        _sec('Overview', r.opening),
        _sec('Subject performance', r.subjects),
        _sec('Learning habits', r.habits),
        _sec('Area for growth', r.growth),
        _sec('Next steps', r.nextSteps),
        if (r.badges.isNotEmpty) ...[
         const Text('COMMENDATIONS', style: TextStyle(fontSize: 10,
           fontWeight: FontWeight.w800, color: _muted, letterSpacing: 1.1)),
         const SizedBox(height: 9),
         Wrap(spacing: 7, runSpacing: 7, children: r.badges.map((b) => Container(
           padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
           decoration: BoxDecoration(color: _amber.withOpacity(.11),
             borderRadius: BorderRadius.circular(30),
             border: Border.all(color: _amber.withOpacity(.25))),
           child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.workspace_premium_rounded, size: 13, color: _amber),
            const SizedBox(width: 6),
            Text(b, style: const TextStyle(fontSize: 11.5,
              fontWeight: FontWeight.w600, color: _ink)),
           ]))).toList()),
         const SizedBox(height: 20),
        ],
        if (r.note.trim().isNotEmpty) ...[
         Container(width: double.infinity,
           padding: const EdgeInsets.all(15),
           decoration: BoxDecoration(color: _purple.withOpacity(.06),
             borderRadius: BorderRadius.circular(13),
             border: Border.all(color: _purple.withOpacity(.14))),
           child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('A NOTE FROM ${r.teacher.toUpperCase()}',
              style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800,
                color: _purple, letterSpacing: 1.1)),
            const SizedBox(height: 8),
            Text(r.note.trim(), style: const TextStyle(fontSize: 13,
              height: 1.6, color: _ink, fontStyle: FontStyle.italic)),
           ])),
         const SizedBox(height: 20),
        ],
        const Divider(height: 1),
        const SizedBox(height: 14),
        Row(children: [
         _avatar(r.teacher[0], r: 14),
         const SizedBox(width: 10),
         Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(r.teacher, style: const TextStyle(fontSize: 12.5,
            fontWeight: FontWeight.w700, color: _ink)),
          const SizedBox(height: 2),
          const Text('Class Teacher · Grade 9A',
            style: TextStyle(fontSize: 10.5, color: _muted)),
         ])),
         const Icon(Icons.verified_rounded, size: 15, color: _teal),
         const SizedBox(width: 5),
         const Text('Verified', style: TextStyle(fontSize: 10.5, color: _muted)),
        ]),
       ])),
    ]));
 }

 Widget _mini(String l, String v, Color c) => Expanded(child: Container(
   padding: const EdgeInsets.symmetric(vertical: 12),
   decoration: BoxDecoration(color: c.withOpacity(.09),
     borderRadius: BorderRadius.circular(13)),
   child: Column(children: [
    Text(v, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: c)),
    const SizedBox(height: 3),
    Text(l, style: const TextStyle(fontSize: 10, color: _muted)),
   ])));

 Widget _sec(String h, String body) => Padding(
   padding: const EdgeInsets.only(bottom: 18),
   child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(h.toUpperCase(), style: const TextStyle(fontSize: 10,
      fontWeight: FontWeight.w800, color: _muted, letterSpacing: 1.1)),
    const SizedBox(height: 8),
    Text(body, style: const TextStyle(fontSize: 13, height: 1.68, color: _ink)),
   ]));

// ── Student view ──
//
// Read-only. A student sees only their own report, only the version written
// for them, and can download or copy it. No generator controls, no other
// students, no class ranking table.

class MyReportCardScreen extends StatefulWidget {
 final String student;
 const MyReportCardScreen({super.key, required this.student});
 @override
 State<MyReportCardScreen> createState() => _MyRCState();
}

class _MyRCState extends State<MyReportCardScreen> {
 static const _termList = ['Term 3 · 2025-26', 'Term 2 · 2025-26'];
 String term = _termList.first;
 bool busy = true;

 /// Falls back to the first roster entry if the signed-in name is not a
 /// student on this roster, so the screen never renders empty.
 String get who => _deep.containsKey(widget.student) ? widget.student : _students.first;

 _Report get out => _compose(who, 'Student', 'Ms. Rao', term, '');

 @override
 void initState() {
  super.initState();
  Future.delayed(const Duration(milliseconds: 420), () {
   if (mounted) setState(() => busy = false);
  });
 }

 Future<void> _download() async {
  final bytes = await _reportPdf(out);
  await Printing.layoutPdf(onLayout: (_) async => bytes,
    name: 'MyReportCard_${out.student}_${out.roll}.pdf');
 }

 void _copy() {
  Clipboard.setData(ClipboardData(text: out.plain));
  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    content: Text('Report copied to clipboard'), behavior: SnackBarBehavior.floating));
 }

 @override
 Widget build(BuildContext c) {
  final r = out;
  return _Page(
    title: 'My Report Card',
    sub: 'Your progress, written for you',
    trailing: _Drop(term, _termList, (v) => setState(() => term = v!), light: true),
    children: [
     if (busy)
      const Padding(padding: EdgeInsets.only(top: 60),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2.4)))
     else ...[
      Surface(pad: const EdgeInsets.all(16), child: Row(children: [
       Container(padding: const EdgeInsets.all(9),
         decoration: BoxDecoration(color: _teal.withOpacity(.12),
           borderRadius: BorderRadius.circular(11)),
         child: const Icon(Icons.lock_rounded, size: 17, color: _teal)),
       const SizedBox(width: 13),
       const Expanded(child: Text(
         'This is your personal report, released by your class teacher. '
         'Only you can see it.',
         style: TextStyle(fontSize: 12.5, height: 1.45, color: _muted))),
      ])),
      const SizedBox(height: 16),
      _paper(r),
      const SizedBox(height: 18),
      _gradBtn('Download my report', Icons.picture_as_pdf_rounded, _download),
      const SizedBox(height: 11),
      _ghost('Copy text', Icons.copy_rounded, _purple, _copy),
      const SizedBox(height: 20),
     ],
    ]);
 }
}

// ── PDF rendering ──

const _pInk = PdfColor.fromInt(0xFF2D2A45);
const _pPurple = PdfColor.fromInt(0xFF6C5CE7);
const _pIndigo = PdfColor.fromInt(0xFF1F1147);
const _pTeal = PdfColor.fromInt(0xFF00CEC9);
const _pMuted = PdfColor.fromInt(0xFF8E8AA8);
const _pSoft = PdfColor.fromInt(0xFFEDEAFB);
const _pGreen = PdfColor.fromInt(0xFF00B894);
const _pAmber = PdfColor.fromInt(0xFFFDA65D);

PdfColor _pHue(double v) => v >= .85 ? _pGreen : v >= .7 ? _pPurple : _pAmber;

pw.Widget _pdfBar(String label, double v) {
 final c = _pHue(v);
 final f = (v * 100).round().clamp(1, 100).toInt();
 return pw.Container(margin: const pw.EdgeInsets.only(bottom: 10),
   child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
    pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
     pw.Text(label, style: const pw.TextStyle(fontSize: 10, color: _pInk)),
     pw.Text('$f%', style: pw.TextStyle(fontSize: 10, color: c,
       fontWeight: pw.FontWeight.bold)),
    ]),
    pw.SizedBox(height: 5),
    pw.Container(height: 7,
      decoration: pw.BoxDecoration(color: _pSoft,
        borderRadius: pw.BorderRadius.circular(4)),
      child: pw.Row(children: [
       pw.Expanded(flex: f, child: pw.Container(
         decoration: pw.BoxDecoration(color: c,
           borderRadius: pw.BorderRadius.circular(4)))),
       if (f < 100) pw.Expanded(flex: 100 - f, child: pw.SizedBox()),
      ])),
   ]));
}

pw.Widget _pdfSection(String h, String body) => pw.Container(
  margin: const pw.EdgeInsets.only(bottom: 15),
  child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
   pw.Text(h.toUpperCase(), style: pw.TextStyle(fontSize: 8.5, color: _pMuted,
     letterSpacing: 1.2, fontWeight: pw.FontWeight.bold)),
   pw.SizedBox(height: 6),
   pw.Text(body, textAlign: pw.TextAlign.justify,
     style: const pw.TextStyle(fontSize: 10.5, color: _pInk, lineSpacing: 3.6)),
  ]));

pw.Widget _pdfStat(String l, String v, PdfColor c) => pw.Expanded(child: pw.Container(
  margin: const pw.EdgeInsets.only(right: 8),
  padding: const pw.EdgeInsets.symmetric(vertical: 10),
  decoration: pw.BoxDecoration(color: _pSoft, borderRadius: pw.BorderRadius.circular(6)),
  child: pw.Column(children: [
   pw.Text(v, style: pw.TextStyle(fontSize: 14, color: c, fontWeight: pw.FontWeight.bold)),
   pw.SizedBox(height: 2),
   pw.Text(l, style: const pw.TextStyle(fontSize: 8, color: _pMuted)),
  ])));

/// Term-over-term trend rendered as a column chart.
pw.Widget _pdfTrend(List<double> h) {
 final lo = h.reduce((a, b) => a < b ? a : b) - .05;
 final hi = h.reduce((a, b) => a > b ? a : b) + .05;
 return pw.Container(height: 52, child: pw.Row(
   crossAxisAlignment: pw.CrossAxisAlignment.end,
   children: List.generate(h.length, (i) {
    final t = ((h[i] - lo) / (hi - lo)).clamp(.15, 1.0).toDouble();
    return pw.Expanded(child: pw.Container(
      margin: const pw.EdgeInsets.symmetric(horizontal: 5),
      child: pw.Column(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
       pw.Text('${(h[i] * 100).round()}%',
         style: pw.TextStyle(fontSize: 7.5, color: _pMuted, fontWeight: pw.FontWeight.bold)),
       pw.SizedBox(height: 3),
       pw.Container(height: 26 * t,
         decoration: pw.BoxDecoration(color: i == h.length - 1 ? _pPurple : _pSoft,
           borderRadius: pw.BorderRadius.circular(3))),
       pw.SizedBox(height: 4),
       pw.Text('T${i + 1}', style: const pw.TextStyle(fontSize: 7.5, color: _pMuted)),
      ])));
   })));
}

List<pw.Widget> _pdfBody(_Report r, String issued) {
 final hue = _pHue(r.overall / 100);
 return [
  pw.Container(width: double.infinity, color: _pIndigo,
    padding: const pw.EdgeInsets.fromLTRB(46, 38, 46, 30),
    child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
     pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
      pw.Text('CAMPUSCONNECT', style: pw.TextStyle(fontSize: 9,
        color: PdfColors.white, letterSpacing: 2.4, fontWeight: pw.FontWeight.bold)),
      pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: pw.BoxDecoration(color: _pPurple,
          borderRadius: pw.BorderRadius.circular(20)),
        child: pw.Text('For ${r.audience.toLowerCase()}',
          style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.white))),
     ]),
     pw.SizedBox(height: 16),
     pw.Text('Academic Progress Report', style: pw.TextStyle(fontSize: 22,
       color: PdfColors.white, fontWeight: pw.FontWeight.bold)),
     pw.SizedBox(height: 5),
     pw.Text('${r.term}  ·  Grade 9, Section A',
       style: const pw.TextStyle(fontSize: 10.5, color: _pSoft)),
    ])),
  pw.Container(padding: const pw.EdgeInsets.fromLTRB(46, 26, 46, 6),
    child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
     pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start,
       mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
      pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
       pw.Text(r.student, style: pw.TextStyle(fontSize: 18,
         color: _pInk, fontWeight: pw.FontWeight.bold)),
       pw.SizedBox(height: 3),
       pw.Text('Roll ${r.roll}  ·  Rank ${r.rank} of ${_students.length}'
         '  ·  Class average ${r.classAvg}%',
         style: const pw.TextStyle(fontSize: 9.5, color: _pMuted)),
      ]),
      pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: pw.BoxDecoration(color: _pSoft,
          borderRadius: pw.BorderRadius.circular(8)),
        child: pw.Column(children: [
         pw.Text('${r.overall}%', style: pw.TextStyle(fontSize: 20,
           color: hue, fontWeight: pw.FontWeight.bold)),
         pw.SizedBox(height: 2),
         pw.Text('Grade ${r.grade}', style: pw.TextStyle(fontSize: 9,
           color: _pInk, fontWeight: pw.FontWeight.bold)),
        ])),
     ]),
     pw.SizedBox(height: 20),
     pw.Row(children: [
      _pdfStat('Attendance', '${(r.att * 100).round()}%', _pHue(r.att)),
      _pdfStat('Punctuality', '${(r.punc * 100).round()}%', _pHue(r.punc)),
      _pdfStat('vs last term', '${r.delta >= 0 ? '+' : ''}${r.delta}',
        r.delta >= 0 ? _pGreen : _pAmber),
      _pdfStat('Projected', r.predicted, _pTeal),
     ]),
     pw.SizedBox(height: 22),
     pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
      pw.Expanded(flex: 3, child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
       pw.Text('SUBJECT BREAKDOWN', style: pw.TextStyle(fontSize: 8.5, color: _pMuted,
         letterSpacing: 1.2, fontWeight: pw.FontWeight.bold)),
       pw.SizedBox(height: 10),
       ...r.subj.entries.map((e) => _pdfBar(e.key, e.value)),
      ])),
      pw.SizedBox(width: 24),
      pw.Expanded(flex: 2, child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
       pw.Text('TREND', style: pw.TextStyle(fontSize: 8.5, color: _pMuted,
         letterSpacing: 1.2, fontWeight: pw.FontWeight.bold)),
       pw.SizedBox(height: 10),
       _pdfTrend(r.hist),
      ])),
     ]),
     pw.SizedBox(height: 20),
     pw.Divider(color: _pSoft, height: 1),
     pw.SizedBox(height: 16),
     _pdfSection('Overview', r.opening),
     _pdfSection('Subject performance', r.subjects),
     _pdfSection('Learning habits', r.habits),
     _pdfSection('Area for growth', r.growth),
     _pdfSection('Next steps', r.nextSteps),
     if (r.badges.isNotEmpty) ...[
      pw.Text('COMMENDATIONS', style: pw.TextStyle(fontSize: 8.5, color: _pMuted,
        letterSpacing: 1.2, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 8),
      pw.Wrap(spacing: 6, runSpacing: 6, children: r.badges.map((b) => pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: pw.BoxDecoration(color: _pSoft,
          borderRadius: pw.BorderRadius.circular(20)),
        child: pw.Text(b, style: const pw.TextStyle(fontSize: 9, color: _pInk)))).toList()),
      pw.SizedBox(height: 20),
     ],
     if (r.note.trim().isNotEmpty) ...[
      pw.Container(width: double.infinity,
        padding: const pw.EdgeInsets.all(14),
        decoration: pw.BoxDecoration(color: _pSoft,
          borderRadius: pw.BorderRadius.circular(8)),
        child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
         pw.Text('A NOTE FROM ${r.teacher.toUpperCase()}',
           style: pw.TextStyle(fontSize: 8, color: _pPurple,
             letterSpacing: 1.2, fontWeight: pw.FontWeight.bold)),
         pw.SizedBox(height: 6),
         pw.Text(r.note.trim(), style: pw.TextStyle(fontSize: 10.5,
           color: _pInk, lineSpacing: 3.4, fontStyle: pw.FontStyle.italic)),
        ])),
      pw.SizedBox(height: 20),
     ],
     pw.Divider(color: _pSoft, height: 1),
     pw.SizedBox(height: 16),
     pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
       crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
      pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
       pw.Container(width: 150, height: 1, color: _pMuted),
       pw.SizedBox(height: 6),
       pw.Text(r.teacher, style: pw.TextStyle(fontSize: 10.5,
         color: _pInk, fontWeight: pw.FontWeight.bold)),
       pw.Text('Class Teacher · Grade 9A',
         style: const pw.TextStyle(fontSize: 9, color: _pMuted)),
      ]),
      pw.Text('Issued $issued',
        style: const pw.TextStyle(fontSize: 8.5, color: _pMuted)),
     ]),
    ])),
 ];
}

Future<Uint8List> _reportPdf(_Report r, {List<_Report> extra = const []}) async {
 final doc = pw.Document(title: 'Report Card - ${r.student}', author: 'CampusConnect');
 final now = DateTime.now();
 final issued = '${now.day.toString().padLeft(2, '0')}/'
   '${now.month.toString().padLeft(2, '0')}/${now.year}';

 for (final rep in [r, ...extra]) {
  doc.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: pw.EdgeInsets.zero,
    footer: (ctx) => pw.Container(
      padding: const pw.EdgeInsets.fromLTRB(46, 0, 46, 20),
      child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
       pw.Text('CampusConnect · Teacher Analytics',
         style: const pw.TextStyle(fontSize: 8, color: _pMuted)),
       pw.Text('${rep.student} · ${rep.roll}',
         style: const pw.TextStyle(fontSize: 8, color: _pMuted)),
      ])),
    build: (ctx) => _pdfBody(rep, issued)));
 }
 return doc.save();
}

// ═══ CAMPUS MAP · MASTER LAYOUT PLAN ═══
//
// A surveyed-style site plan drawn with CustomPainter. Land parcels are real
// polygons bounded by angled carriageways, hit-tested against their own shape.
// Everything on the sheet is clickable: parcels and roads. Selection animates
// with a ripple, a lift, a glow and a marching-ants outline.

const _blue = Color(0xFF4A7DFF);
const _pink = Color(0xFFE84393);
const _leaf = Color(0xFF55A630);
const _paperColor = Color(0xFFFCFBFF);
const _line = Color(0xFF3A3550);
const _tar = Color(0xFFE4E1EE);

enum _BKind { academic, lab, library, sports, admin, amenity, open, parking }

extension _BKindX on _BKind {
 String get label => switch (this) {
   _BKind.academic => 'Academic',
   _BKind.lab => 'Laboratory',
   _BKind.library => 'Library',
   _BKind.sports => 'Sports',
   _BKind.admin => 'Administration',
   _BKind.amenity => 'Amenity',
   _BKind.open => 'Open space',
   _BKind.parking => 'Parking',
  };
 Color get hue => switch (this) {
   _BKind.academic => _purple,
   _BKind.lab => _teal,
   _BKind.library => _blue,
   _BKind.sports => _amber,
   _BKind.admin => _green,
   _BKind.amenity => _pink,
   _BKind.open => _leaf,
   _BKind.parking => _muted,
  };
 IconData get icon => switch (this) {
   _BKind.academic => Icons.school_rounded,
   _BKind.lab => Icons.science_rounded,
   _BKind.library => Icons.menu_book_rounded,
   _BKind.sports => Icons.sports_basketball_rounded,
   _BKind.admin => Icons.badge_rounded,
   _BKind.amenity => Icons.restaurant_rounded,
   _BKind.open => Icons.park_rounded,
   _BKind.parking => Icons.local_parking_rounded,
  };
}

enum _BState { free, inUse, event }

extension _BStateX on _BState {
 String get label => switch (this) {
   _BState.free => 'Free now', _BState.inUse => 'In use', _BState.event => 'Event today',
  };
 Color get hue => switch (this) {
   _BState.free => _green, _BState.inUse => _purple, _BState.event => _amber,
  };
}

/// A land parcel. [pts] are normalised polygon vertices, y increasing downward.
class _Parcel {
 final String no, name, short, now, next, host;
 final _BKind kind;
 final _BState state;
 final int area, cap, occ;
 final List<List<String>> clubs;
 final List<Offset> pts;
 /// Optional label position when the centroid sits under an overlay.
 final Offset? anchor;
 const _Parcel(this.no, this.name, this.short, this.kind, this.state, this.area,
   this.cap, this.occ, this.now, this.next, this.host, this.clubs, this.pts,
   {this.anchor});
}

class _Road {
 final String label, width, note;
 final List<Offset> pts;
 final Offset at;
 final double angle;
 final bool diagonal;
 final double maxW;
 const _Road(this.label, this.width, this.note, this.pts, this.at,
   {this.angle = 0, this.diagonal = false, this.maxW = .9});
}

// The diagonal spine. Left kerb runs (.600,.100) to (.860,.870).
const _dTop = .600, _dBot = .860, _dW = .055;

const _roads = <_Road>[
 _Road('45.0 M WIDE APPROACH ROAD', '45.0 m', 'Main gate and visitor entry',
   [Offset(.02, .045), Offset(.98, .045), Offset(.98, .100), Offset(.02, .100)],
   Offset(.42, .0725), maxW: .62),
 _Road('30.0 M WIDE ROAD', '30.0 m', 'Service and staff access',
   [Offset(.020, .100), Offset(.065, .100), Offset(.065, .955), Offset(.020, .955)],
   Offset(.0425, .58), angle: -1.5708, maxW: .5),
 _Road('75.0 M WIDE ROAD', '75.0 m', 'City carriageway along the south edge',
   [Offset(.02, .870), Offset(.98, .870), Offset(.98, .955), Offset(.02, .955)],
   Offset(.40, .9125), maxW: .6),
 _Road('18.0 M WIDE ROAD', '18.0 m', 'Internal spine between blocks',
   [Offset(.335, .100), Offset(.370, .100), Offset(.370, .870), Offset(.335, .870)],
   Offset(.3525, .30), angle: -1.5708, maxW: .38),
 _Road('12.0 M ROAD', '12.0 m', 'Cross link to the west cluster',
   [Offset(.065, .485), Offset(.370, .485), Offset(.370, .515), Offset(.065, .515)],
   Offset(.21, .500), maxW: .26),
 _Road('60.0 M WIDE ROAD', '60.0 m', 'Diagonal spine to the sports annexe',
   [Offset(_dTop, .100), Offset(_dTop + _dW, .100),
    Offset(_dBot + _dW, .870), Offset(_dBot, .870)],
   Offset(.7385, .485), diagonal: true, maxW: .5),
];

/// Classroom units in the dense north-west cluster, laid out on a lane grid.
List<_Parcel> _cluster() {
 const names = ['9-A', '9-B', '9-C', '10-A', '10-B', '10-C',
   '11-A', '11-B', '11-C', '12-A', '12-B', '12-C'];
 const busy = [true, true, false, true, false, true,
   true, false, true, false, true, false];
 const x0 = .070, y0 = .110, gw = .008, gh = .009;
 final cw = (.330 - x0 - 2 * gw) / 3, ch = (.480 - y0 - 3 * gh) / 4;
 return [
  for (var i = 0; i < 12; i++)
   () {
    final r = i ~/ 3, c = i % 3;
    final x = x0 + c * (cw + gw), y = y0 + r * (ch + gh);
    return _Parcel(
      (i + 1).toString().padLeft(2, '0'),
      'Classroom Unit ${names[i]}', names[i],
      _BKind.academic, busy[i] ? _BState.inUse : _BState.free,
      240, 32, busy[i] ? 28 + (i % 4) : 0,
      busy[i] ? 'Grade ${names[i]} - period 4' : 'Unassigned',
      busy[i] ? 'Period 5 from 12:40 PM' : 'Grade 8 English 1:30 PM',
      busy[i] ? (i.isEven ? 'Jason' : 'Jack') : 'Available',
      i == 4 ? [['Chess Club', '4:15 PM']] : const [],
      [Offset(x, y), Offset(x + cw, y), Offset(x + cw, y + ch), Offset(x, y + ch)]);
   }(),
 ];
}

final List<_Parcel> _parcels = [
 ..._cluster(),
 const _Parcel('13', 'Administration Block', 'ADMIN', _BKind.admin, _BState.inUse,
   1200, 40, 16, 'Reception and records open', 'Open until 5:00 PM', 'Abhyuday', [],
   [Offset(.070, .525), Offset(.195, .525), Offset(.195, .660), Offset(.070, .660)]),
 const _Parcel('14', 'Cafeteria and Dining', 'CAFETERIA', _BKind.amenity, _BState.free,
   1100, 160, 12, 'Between services', 'Lunch service 12:30 PM', 'Catering team', [],
   [Offset(.205, .525), Offset(.335, .525), Offset(.335, .660), Offset(.205, .660)]),
 const _Parcel('15', 'Computer and Innovation Centre', 'INNOVATION CENTRE',
   _BKind.lab, _BState.inUse, 1350, 72, 66,
   'Grade 10 Flutter workshop', 'Grade 9 algorithms 2:00 PM', 'Jason',
   [['Coding Club', '4:30 PM'], ['Hackathon Prep', '6:00 PM']],
   [Offset(.070, .670), Offset(.335, .670), Offset(.335, .790), Offset(.070, .790)]),
 const _Parcel('16', 'Parking and Transport Bay', 'PARKING', _BKind.parking, _BState.inUse,
   1800, 120, 88, '88 of 120 bays occupied', 'Bus departure 3:15 PM', 'Transport office', [],
   [Offset(.070, .800), Offset(.335, .800), Offset(.335, .865), Offset(.070, .865)]),
 const _Parcel('17', 'Science Laboratories', 'SCIENCE LABS', _BKind.lab, _BState.inUse,
   3200, 90, 74, 'Grade 10 optics practical', 'Grade 11 titration 1:30 PM', 'Jack',
   [['Robotics Club', '4:00 PM'], ['Eco Club', '4:30 PM']],
   [Offset(.370, .110), Offset(.6034, .110), Offset(.6675, .300), Offset(.370, .300)]),
 const _Parcel('18', 'Library and Resource Centre', 'LIBRARY', _BKind.library, _BState.inUse,
   1600, 90, 41, 'Silent study session', 'Book club 4:00 PM', 'Ms. Rao',
   [['Book Club', '4:00 PM'], ['Debate Society', '5:00 PM']],
   [Offset(.370, .310), Offset(.6709, .310), Offset(.7300, .485), Offset(.370, .485)]),
 const _Parcel('19', 'Sports Complex', 'SPORTS COMPLEX', _BKind.sports, _BState.event,
   3400, 200, 118, 'Inter-house basketball final', 'Free from 3:30 PM', 'Coach Menon',
   [['Basketball Team', '3:30 PM'], ['Yoga Club', '5:15 PM']],
   [Offset(.370, .520), Offset(.7418, .520), Offset(.7891, .660), Offset(.370, .660)]),
 const _Parcel('20', 'Main Playground', 'PLAYGROUND', _BKind.open, _BState.inUse,
   5400, 300, 96, 'Grade 8 games period', 'Athletics squad 3:30 PM', 'Coach Menon',
   [['Athletics', '3:30 PM']],
   [Offset(.370, .670), Offset(.7924, .670), Offset(.8330, .790), Offset(.370, .790)]),
 const _Parcel('21', 'Auditorium', 'AUDITORIUM', _BKind.amenity, _BState.event,
   1450, 400, 260, 'Annual science exhibition', 'Free from 4:00 PM', 'Abhyuday',
   [['Drama Society', '4:30 PM']],
   [Offset(.370, .800), Offset(.8364, .800), Offset(.8583, .865), Offset(.370, .865)]),
 const _Parcel('22', 'North Green Belt', 'GREEN BELT', _BKind.open, _BState.free,
   4200, 0, 0, 'Landscaped buffer zone', 'Gardening detail 4:00 PM', 'Estates',
   [['Gardening Club', '4:00 PM']],
   [Offset(.6584, .110), Offset(.970, .110), Offset(.970, .450), Offset(.7732, .450)]),
 const _Parcel('23', 'Open Amphitheatre', 'AMPHITHEATRE', _BKind.open, _BState.free,
   900, 250, 0, 'Unbooked', 'Morning assembly 8:15 AM', 'Admin office',
   [['Student Council', '4:45 PM']],
   [Offset(.7766, .460), Offset(.970, .460), Offset(.970, .630), Offset(.8340, .630)]),
 const _Parcel('24', 'Music and Arts Centre', 'MUSIC + ARTS', _BKind.amenity, _BState.inUse,
   980, 60, 27, 'Choir rehearsal', 'Art Club 4:00 PM', 'Mr. Dsouza',
   [['Choir', '3:45 PM'], ['Art Club', '4:00 PM'], ['Band Practice', '5:00 PM']],
   [Offset(.8374, .640), Offset(.970, .640), Offset(.970, .865), Offset(.9134, .865)]),
];

// ── Geometry helpers ──

Path _poly(List<Offset> pts, Size s) {
 final p = Path()..moveTo(pts.first.dx * s.width, pts.first.dy * s.height);
 for (var i = 1; i < pts.length; i++) {
  p.lineTo(pts[i].dx * s.width, pts[i].dy * s.height);
 }
 return p..close();
}

Offset _centroid(List<Offset> pts, Size s) {
 var x = 0.0, y = 0.0;
 for (final p in pts) {
  x += p.dx; y += p.dy;
 }
 return Offset(x / pts.length * s.width, y / pts.length * s.height);
}

Path _dashed(Path src, double dash, double gap, double phase) {
 final out = Path();
 final step = dash + gap;
 for (final m in src.computeMetrics()) {
  var d = -(phase % step) - step;
  while (d < m.length) {
   final a = d < 0 ? 0.0 : d;
   final b = (d + dash) > m.length ? m.length : (d + dash);
   if (b > a) out.addPath(m.extractPath(a, b), Offset.zero);
   d += step;
  }
 }
 return out;
}

// ── Painter ──

class _PlanPainter extends CustomPainter {
 final Animation<double> intro, pulse, ripple;
 final String? sel, hover;
 final int? road, roadHover;
 final _BKind? filter;
 final Offset? tapAt;

 _PlanPainter({required this.intro, required this.pulse, required this.ripple,
   required this.sel, required this.hover, required this.road,
   required this.roadHover, required this.filter, required this.tapAt})
   : super(repaint: Listenable.merge([intro, pulse, ripple]));

 TextPainter _tp(String t, double size, Color col, FontWeight w, double sp) =>
   TextPainter(
     text: TextSpan(text: t, style: TextStyle(fontSize: size, color: col,
       fontWeight: w, letterSpacing: sp, height: 1.05)),
     textDirection: TextDirection.ltr, textAlign: TextAlign.center)..layout();

 /// Centred text that shrinks to fit [maxW]. Returns the painted height.
 double _draw(Canvas c, String t, Offset at, double size, Color col,
   {FontWeight w = FontWeight.w700, double sp = .4,
    double maxW = 1e9, double angle = 0}) {
  var tp = _tp(t, size, col, w, sp);
  if (tp.width > maxW && maxW > 4) {
   final k = (maxW / tp.width).clamp(.45, 1.0).toDouble();
   tp = _tp(t, size * k, col, w, sp * k);
   if (tp.width > maxW) return 0;
  }
  c.save();
  c.translate(at.dx, at.dy);
  if (angle != 0) c.rotate(angle);
  tp.paint(c, Offset(-tp.width / 2, -tp.height / 2));
  c.restore();
  return tp.height;
 }

 double _rev(int i) {
  final start = i / _parcels.length * .5;
  return ((intro.value - start) / .5).clamp(0.0, 1.0).toDouble();
 }

 @override
 void paint(Canvas c, Size s) {
  final unit = s.width;

  c.drawRect(Offset.zero & s, Paint()..color = _paperColor);
  final border = _poly(const [Offset(.02, .045), Offset(.98, .045),
    Offset(.98, .955), Offset(.02, .955)], s);
  c.drawPath(border, Paint()..color = Colors.white);
  c.drawPath(border, Paint()..color = _line.withOpacity(.75)
    ..style = PaintingStyle.stroke..strokeWidth = 1.6);

  // ── Carriageways ──
  for (var i = 0; i < _roads.length; i++) {
   final r = _roads[i];
   final on = road == i, hov = roadHover == i;
   final p = _poly(r.pts, s);
   c.drawPath(p, Paint()..color = on
     ? _purple.withOpacity(.30) : hov ? const Color(0xFFD9D5E8) : _tar);
   c.drawPath(p, Paint()..color = on ? _purple : _line.withOpacity(.42)
     ..style = PaintingStyle.stroke..strokeWidth = on ? 1.6 : .9);

   // Road name, clipped to its own band so it can never bleed out.
   final ang = r.diagonal
     ? math.atan2((.870 - .100) * s.height, (_dBot - _dTop) * s.width)
     : r.angle;
   c.save();
   c.clipPath(p);
   _draw(c, r.label, Offset(r.at.dx * s.width, r.at.dy * s.height),
     unit * .0105, on ? _purple : const Color(0xFF56506E),
     sp: 1.3, angle: ang, maxW: r.maxW * (ang == 0 ? s.width : s.height),
     w: FontWeight.w800);
   c.restore();
  }

  // ── Parcels ──
  for (var i = 0; i < _parcels.length; i++) {
   final b = _parcels[i];
   final t = _rev(i);
   if (t <= 0) continue;
   final dim = filter != null && b.kind != filter;
   final on = sel == b.no;
   final hov = hover == b.no && !on;
   final hue = b.kind.hue;
   final ctr = _centroid(b.pts, s);
   final path = _poly(b.pts, s);

   c.save();
   // Pop-in, plus a small lift when selected.
   final k = .93 + .07 * t;
   c.translate(ctr.dx, ctr.dy);
   c.scale(k);
   if (on) c.translate(0, -1.5);
   c.translate(-ctr.dx, -ctr.dy);

   if (on) {
    c.drawPath(path, Paint()
      ..color = hue.withOpacity(.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9));
   }
   c.drawPath(path, Paint()..color = on
     ? hue.withOpacity(t)
     : hue.withOpacity((dim ? .06 : hov ? .46 : .30) * t));
   c.drawPath(path, Paint()
     ..color = on ? _line : hue.withOpacity((dim ? .2 : 1) * t)
     ..style = PaintingStyle.stroke
     ..strokeWidth = on ? 1.4 : hov ? 1.5 : .9);

   // Tap ripple, clipped to the parcel that was hit.
   if (on && tapAt != null && ripple.value < 1) {
    c.save();
    c.clipPath(path);
    final rad = ripple.value * s.width * .5;
    c.drawCircle(tapAt!, rad,
      Paint()..color = Colors.white.withOpacity(.42 * (1 - ripple.value)));
    c.restore();
   }

   // Marching ants around the live selection.
   if (on) {
    final phase = pulse.value * 14;
    c.drawPath(_dashed(path, 6, 5, phase), Paint()
      ..color = Colors.white.withOpacity(.9)
      ..style = PaintingStyle.stroke..strokeWidth = 1.6);
   }
   c.restore();

   if (dim) continue;
   _labels(c, s, b, path, on, t);
  }

  _north(c, s);
  _scale(c, s);
  _edges(c, s);
 }

 void _labels(Canvas c, Size s, _Parcel b, Path path, bool on, double t) {
  final bounds = path.getBounds();
  final ctr = b.anchor == null
    ? _centroid(b.pts, s)
    : Offset(b.anchor!.dx * s.width, b.anchor!.dy * s.height);
  final fg = on ? Colors.white : _line.withOpacity(t);
  final fg2 = on ? Colors.white70 : _line.withOpacity(.55 * t);
  final pad = 5.0;
  final availW = bounds.width - pad * 2;
  final big = bounds.width > s.width * .11 && bounds.height > s.height * .07;

  c.save();
  c.clipPath(path);
  if (big) {
   final ns = (s.width * .0175).clamp(8.0, 15.0).toDouble();
   final as2 = ns * .68;
   _draw(c, b.short, ctr.translate(0, -as2 * .8), ns, fg, sp: .55, maxW: availW);
   _draw(c, 'AREA ${b.area} SQM', ctr.translate(0, ns * .72), as2, fg2,
     w: FontWeight.w600, sp: .3, maxW: availW);
   _badge(c, b, Offset(bounds.left + pad + 8, bounds.top + pad + 5), s, on, t);
  } else {
   final sz = (s.width * .0135).clamp(6.5, 11.0).toDouble();
   _draw(c, '${b.no}  ${b.short}', ctr, sz, fg, sp: .2, maxW: availW);
  }
  if (b.state != _BState.free) {
   c.drawCircle(Offset(bounds.right - 6, bounds.top + 6), 2.6,
     Paint()..color = (on ? Colors.white : b.state.hue).withOpacity(t));
  }
  c.restore();
 }

 void _badge(Canvas c, _Parcel b, Offset at, Size s, bool on, double t) {
  final tp = _tp(b.no, (s.width * .0115).clamp(6.0, 10.0).toDouble(),
    Colors.white, FontWeight.w900, .3);
  final r = RRect.fromRectAndRadius(
    Rect.fromCenter(center: at, width: tp.width + 7, height: tp.height + 4),
    const Radius.circular(2.5));
  c.drawRRect(r, Paint()..color = (on ? Colors.white24 : b.kind.hue).withOpacity(t));
  tp.paint(c, Offset(at.dx - tp.width / 2, at.dy - tp.height / 2));
 }

 void _edges(Canvas c, Size s) {
  final f = s.width * .009;
  _draw(c, 'STAFF QUARTERS', Offset(s.width * .011, s.height * .22), f, _muted,
    angle: -1.5708, sp: 1, w: FontWeight.w700);
  _draw(c, 'SECTOR ROAD', Offset(s.width * .989, s.height * .78), f, _muted,
    angle: 1.5708, sp: 1, w: FontWeight.w700);
 }

 void _north(Canvas c, Size s) {
  final o = Offset(s.width * .952, s.height * .073);
  final rad = (s.width * .016).clamp(8.0, 16.0).toDouble();
  c.drawCircle(o, rad, Paint()..color = Colors.white);
  c.drawCircle(o, rad, Paint()..color = _line.withOpacity(.65)
    ..style = PaintingStyle.stroke..strokeWidth = 1);
  final p = Path()
   ..moveTo(o.dx, o.dy - rad * .68)
   ..lineTo(o.dx + rad * .42, o.dy + rad * .5)
   ..lineTo(o.dx, o.dy + rad * .18)
   ..lineTo(o.dx - rad * .42, o.dy + rad * .5)
   ..close();
  c.drawPath(p, Paint()..color = _line);
  _draw(c, 'N', Offset(o.dx, o.dy + rad + 5), s.width * .0105, _line,
    w: FontWeight.w900);
 }

 void _scale(Canvas c, Size s) {
  final left = s.width * .085, y = s.height * .932, seg = s.width * .035;
  for (var i = 0; i < 4; i++) {
   c.drawRect(Rect.fromLTWH(left + i * seg, y, seg, 3.2),
     Paint()..color = i.isEven ? _line : Colors.white);
  }
  c.drawRect(Rect.fromLTWH(left, y, seg * 4, 3.2), Paint()..color = _line
    ..style = PaintingStyle.stroke..strokeWidth = .7);
  _draw(c, '0', Offset(left, y + 9), s.width * .009, _line);
  _draw(c, '100 M', Offset(left + seg * 4, y + 9), s.width * .009, _line);
 }

 @override
 bool shouldRepaint(_PlanPainter o) => o.sel != sel || o.hover != hover
   || o.road != road || o.roadHover != roadHover || o.filter != filter
   || o.tapAt != tapAt;
}

// ── Generated plot photograph ──
//
// Each plot gets its own illustrated "site photo", painted from the plot's
// kind and number so every parcel looks different without shipping any assets.

class _PlotPhoto extends StatelessWidget {
 final _Parcel p;
 const _PlotPhoto(this.p);

 @override
 Widget build(BuildContext c) => ClipRRect(
   borderRadius: BorderRadius.circular(14),
   child: AspectRatio(aspectRatio: 16 / 9,
     child: TweenAnimationBuilder<double>(
       key: ValueKey(p.no),
       tween: Tween(begin: 0, end: 1),
       duration: const Duration(milliseconds: 650),
       curve: Curves.easeOutCubic,
       builder: (_, t, __) => Stack(fit: StackFit.expand, children: [
        Transform.scale(scale: 1.06 - .06 * t,
          child: CustomPaint(painter: _PhotoPainter(p, t))),
        Positioned(left: 10, bottom: 10, child: Opacity(opacity: t,
          child: _chip(Icons.photo_camera_rounded, 'Live view'))),
        Positioned(right: 10, bottom: 10, child: Opacity(opacity: t,
          child: _chip(Icons.circle, 'Updated now', dot: true))),
       ]))));

 Widget _chip(IconData i, String t, {bool dot = false}) => Container(
   padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
   decoration: BoxDecoration(color: Colors.black.withOpacity(.38),
     borderRadius: BorderRadius.circular(20)),
   child: Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(i, size: dot ? 7 : 11, color: dot ? _green : Colors.white),
    const SizedBox(width: 6),
    Text(t, style: const TextStyle(fontSize: 10,
      fontWeight: FontWeight.w700, color: Colors.white)),
   ]));
}

class _PhotoPainter extends CustomPainter {
 final _Parcel p;
 final double t;
 _PhotoPainter(this.p, this.t);

 int get seed => int.tryParse(p.no) ?? 1;
 bool _lit(int i, int j) => (i * 7 + j * 5 + seed * 3) % 4 != 0;

 @override
 void paint(Canvas c, Size s) {
  final w = s.width, h = s.height;
  final hue = p.kind.hue;
  final horizon = h * .70;

  // Sky
  c.drawRect(Offset.zero & s, Paint()..shader = LinearGradient(
    begin: Alignment.topCenter, end: Alignment.bottomCenter,
    colors: [hue.withOpacity(.34), const Color(0xFFEFF3FA)])
     .createShader(Rect.fromLTWH(0, 0, w, horizon)));

  // Sun and cloud bank
  c.drawCircle(Offset(w * .84, h * .20), h * .10,
    Paint()..color = Colors.white.withOpacity(.55));
  c.drawCircle(Offset(w * .84, h * .20), h * .062,
    Paint()..color = Colors.white.withOpacity(.85));
  _cloud(c, Offset(w * .18, h * .19), h * .085);
  _cloud(c, Offset(w * .52, h * .13), h * .06);

  // Distant tree line
  final far = Paint()..color = _leaf.withOpacity(.22);
  for (var i = 0; i < 9; i++) {
   final x = w * (.04 + i * .115) + (seed % 5) * 3;
   c.drawCircle(Offset(x, horizon - h * .045), h * (.05 + (i + seed) % 3 * .012), far);
  }

  // Ground
  final groundTop = horizon;
  c.drawRect(Rect.fromLTWH(0, groundTop, w, h - groundTop),
    Paint()..shader = LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: p.kind == _BKind.open || p.kind == _BKind.sports
        ? [const Color(0xFF8FCB6B), const Color(0xFF66A845)]
        : [const Color(0xFFDAD6E6), const Color(0xFFBFB9D0)])
       .createShader(Rect.fromLTWH(0, groundTop, w, h - groundTop)));

  switch (p.kind) {
   case _BKind.sports: _sports(c, s, horizon); break;
   case _BKind.open: _park(c, s, horizon); break;
   case _BKind.parking: _parking(c, s, horizon); break;
   default: _built(c, s, horizon);
  }

  // Foreground shrubs to frame the shot
  final near = Paint()..color = const Color(0xFF4E8A38).withOpacity(.85);
  c.drawCircle(Offset(w * .04, h * 1.02), h * .13, near);
  c.drawCircle(Offset(w * .13, h * 1.06), h * .11, near);
  c.drawCircle(Offset(w * .96, h * 1.03), h * .12, near);

  // Warm photographic vignette
  c.drawRect(Offset.zero & s, Paint()..shader = RadialGradient(
    center: Alignment.center, radius: .95,
    colors: [Colors.transparent, Colors.black.withOpacity(.20)],
    stops: const [.62, 1]).createShader(Offset.zero & s));
 }

 void _cloud(Canvas c, Offset o, double r) {
  final pnt = Paint()..color = Colors.white.withOpacity(.72);
  c.drawCircle(o, r, pnt);
  c.drawCircle(o.translate(r * .85, r * .18), r * .78, pnt);
  c.drawCircle(o.translate(-r * .85, r * .22), r * .66, pnt);
 }

 /// Shared facade used by every built parcel, with per-kind extras.
 void _built(Canvas c, Size s, double horizon) {
  final w = s.width, h = s.height;
  final storeys = p.kind == _BKind.academic ? 3 : p.kind == _BKind.library ? 2 : 2;
  final bw = w * (p.area > 2000 ? .62 : .50);
  final bh = h * (.16 + storeys * .095);
  final r = Rect.fromLTWH((w - bw) / 2, horizon - bh, bw, bh);

  // Side wing for the larger parcels
  if (p.area > 1300) {
   final wing = Rect.fromLTWH(r.right - 4, horizon - bh * .62, w * .16, bh * .62);
   c.drawRect(wing, Paint()..color = const Color(0xFFCBC4DC));
   c.drawRect(wing, Paint()..color = _line.withOpacity(.3)
     ..style = PaintingStyle.stroke..strokeWidth = 1);
  }

  c.drawRect(r.translate(5, 3), Paint()..color = Colors.black.withOpacity(.13));
  c.drawRect(r, Paint()..color = const Color(0xFFF3F1F8));
  c.drawRect(Rect.fromLTWH(r.left, r.top, r.width, h * .035),
    Paint()..color = p.kind.hue.withOpacity(.85));
  c.drawRect(r, Paint()..color = _line.withOpacity(.35)
    ..style = PaintingStyle.stroke..strokeWidth = 1.1);

  // Window grid
  const cols = 5;
  final gw = r.width / (cols + 1.4), gh = h * .052;
  for (var j = 0; j < storeys; j++) {
   for (var i = 0; i < cols; i++) {
    final x = r.left + r.width * .10 + i * gw;
    final y = r.top + h * .07 + j * (gh + h * .028);
    if (y + gh > r.bottom - h * .05) continue;
    final win = Rect.fromLTWH(x, y, gw * .62, gh);
    c.drawRect(win, Paint()..color = _lit(i, j)
      ? const Color(0xFFFFD98A) : const Color(0xFF9FB4CE));
    c.drawRect(win, Paint()..color = _line.withOpacity(.25)
      ..style = PaintingStyle.stroke..strokeWidth = .7);
   }
  }

  // Entrance
  final door = Rect.fromLTWH(r.center.dx - w * .028, r.bottom - h * .10,
    w * .056, h * .10);
  c.drawRect(door, Paint()..color = p.kind.hue.withOpacity(.75));
  c.drawRect(Rect.fromLTWH(door.left - 6, door.top - 5, door.width + 12, 5),
    Paint()..color = p.kind.hue);

  switch (p.kind) {
   case _BKind.lab:
    c.drawCircle(Offset(r.center.dx, r.top - h * .05), h * .062,
      Paint()..color = const Color(0xFFDDD7EA));
    c.drawCircle(Offset(r.center.dx, r.top - h * .05), h * .062,
      Paint()..color = _line.withOpacity(.3)
        ..style = PaintingStyle.stroke..strokeWidth = 1);
    break;
   case _BKind.admin:
    c.drawLine(Offset(r.left + w * .05, r.top), Offset(r.left + w * .05, r.top - h * .17),
      Paint()..color = _line..strokeWidth = 1.6);
    final f = Path()
     ..moveTo(r.left + w * .05, r.top - h * .17)
     ..lineTo(r.left + w * .13, r.top - h * .13)
     ..lineTo(r.left + w * .05, r.top - h * .09)..close();
    c.drawPath(f, Paint()..color = _green);
    break;
   case _BKind.library:
    for (var i = 0; i < 4; i++) {
     final x = r.left + r.width * (.18 + i * .21);
     c.drawRect(Rect.fromLTWH(x, r.bottom - h * .16, w * .014, h * .16),
       Paint()..color = const Color(0xFFE3DFEE));
    }
    break;
   case _BKind.amenity:
    for (var i = 0; i < 5; i++) {
     c.drawRect(Rect.fromLTWH(r.left + i * (r.width / 5), r.top + h * .035,
       r.width / 5, h * .026),
       Paint()..color = i.isEven ? _pink.withOpacity(.8) : Colors.white);
    }
    break;
   default:
    break;
  }
 }

 void _sports(Canvas c, Size s, double horizon) {
  final w = s.width, h = s.height;
  final court = Path()
   ..moveTo(w * .16, h)..lineTo(w * .34, horizon + h * .03)
   ..lineTo(w * .70, horizon + h * .03)..lineTo(w * .92, h)..close();
  c.drawPath(court, Paint()..color = const Color(0xFFCE7B4A));
  c.drawPath(court, Paint()..color = Colors.white.withOpacity(.85)
    ..style = PaintingStyle.stroke..strokeWidth = 2);
  c.drawLine(Offset(w * .25, (h + horizon) / 2 + h * .03),
    Offset(w * .81, (h + horizon) / 2 + h * .03),
    Paint()..color = Colors.white.withOpacity(.8)..strokeWidth = 1.6);
  c.drawCircle(Offset(w * .53, (h + horizon) / 2 + h * .03), h * .08,
    Paint()..color = Colors.white.withOpacity(.8)
      ..style = PaintingStyle.stroke..strokeWidth = 1.6);
  // Hoop and stands
  c.drawLine(Offset(w * .52, horizon + h * .03), Offset(w * .52, horizon - h * .20),
    Paint()..color = _line..strokeWidth = 2.2);
  c.drawRect(Rect.fromLTWH(w * .47, horizon - h * .24, w * .10, h * .055),
    Paint()..color = Colors.white);
  c.drawRect(Rect.fromLTWH(w * .47, horizon - h * .24, w * .10, h * .055),
    Paint()..color = _line..style = PaintingStyle.stroke..strokeWidth = 1);
  for (var i = 0; i < 3; i++) {
   c.drawRect(Rect.fromLTWH(w * .06, horizon - h * (.06 + i * .05), w * .16, h * .045),
     Paint()..color = _amber.withOpacity(.55 + i * .12));
  }
 }

 void _park(Canvas c, Size s, double horizon) {
  final w = s.width, h = s.height;
  final path = Path()
   ..moveTo(w * .34, h)..quadraticBezierTo(w * .48, h * .86, w * .46, horizon + h * .02)
   ..lineTo(w * .58, horizon + h * .02)
   ..quadraticBezierTo(w * .62, h * .88, w * .72, h)..close();
  c.drawPath(path, Paint()..color = const Color(0xFFD9D2C4));
  for (var i = 0; i < 5; i++) {
   final x = w * (.10 + i * .19) + (seed % 4) * 4;
   final y = horizon + h * (.06 + (i % 2) * .09);
   final r = h * (.10 + (i + seed) % 3 * .022);
   c.drawLine(Offset(x, y), Offset(x, y - r * 1.05),
     Paint()..color = const Color(0xFF7A5637)..strokeWidth = 3);
   c.drawCircle(Offset(x, y - r * 1.35), r, Paint()..color = const Color(0xFF4E8A38));
   c.drawCircle(Offset(x - r * .3, y - r * 1.55), r * .68,
     Paint()..color = const Color(0xFF63A648));
  }
  for (var i = 0; i < 2; i++) {
   final x = w * (.26 + i * .46);
   c.drawRect(Rect.fromLTWH(x, horizon + h * .19, w * .07, h * .018),
     Paint()..color = const Color(0xFF8A6642));
   c.drawRect(Rect.fromLTWH(x + w * .006, horizon + h * .205, w * .008, h * .05),
     Paint()..color = const Color(0xFF6F5133));
  }
 }

 void _parking(Canvas c, Size s, double horizon) {
  final w = s.width, h = s.height;
  c.drawRect(Rect.fromLTWH(0, horizon, w, h - horizon),
    Paint()..color = const Color(0xFF6E6880));
  for (var i = 0; i < 7; i++) {
   c.drawLine(Offset(w * (.06 + i * .14), horizon + h * .06),
     Offset(w * (.02 + i * .155), h),
     Paint()..color = Colors.white.withOpacity(.55)..strokeWidth = 1.6);
  }
  const cols = [Color(0xFFE17055), Color(0xFF4A7DFF), Color(0xFFF3F1F8),
    Color(0xFF00B894), Color(0xFF2D2A45)];
  for (var i = 0; i < 5; i++) {
   final x = w * (.10 + i * .15), y = horizon + h * (.12 + (i % 2) * .13);
   final body = Rect.fromLTWH(x, y, w * .10, h * .075);
   c.drawRRect(RRect.fromRectAndRadius(body, const Radius.circular(3)),
     Paint()..color = cols[(i + seed) % cols.length]);
   c.drawRRect(RRect.fromRectAndRadius(
     Rect.fromLTWH(x + w * .018, y - h * .034, w * .064, h * .04),
     const Radius.circular(3)), Paint()..color = cols[(i + seed) % cols.length]);
   c.drawRect(Rect.fromLTWH(x + w * .024, y - h * .026, w * .052, h * .026),
     Paint()..color = const Color(0xFF9FB4CE));
  }
  c.drawRect(Rect.fromLTWH(w * .78, horizon - h * .22, w * .04, h * .22),
    Paint()..color = const Color(0xFFCBC4DC));
  c.drawCircle(Offset(w * .80, horizon - h * .24), h * .035,
    Paint()..color = const Color(0xFFFFD98A));
 }

 @override
 bool shouldRepaint(_PhotoPainter o) => o.p.no != p.no || o.t != t;
}

// ── Screen ──

class CampusMapScreen extends StatefulWidget {
 const CampusMapScreen({super.key});
 @override
 State<CampusMapScreen> createState() => _MapState();
}

class _MapState extends State<CampusMapScreen> with TickerProviderStateMixin {
 static const _views = ['Site plan', 'Plot schedule'];

 late final AnimationController _intro = AnimationController(
   vsync: this, duration: const Duration(milliseconds: 1150))..forward();
 late final AnimationController _pulse = AnimationController(
   vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
 late final AnimationController _ripple = AnimationController(
   vsync: this, duration: const Duration(milliseconds: 560), value: 1);
 late final AnimationController _zoom = AnimationController(
   vsync: this, duration: const Duration(milliseconds: 340));
 final TransformationController _tc = TransformationController();
 Animation<Matrix4>? _zAnim;

 String view = _views.first;
 String? sel, hover;
 int? road, roadHover;
 _BKind? filter;
 Offset? tapAt;
 Size _size = Size.zero;

 @override
 void initState() {
  super.initState();
  _zoom.addListener(() {
   if (_zAnim != null) _tc.value = _zAnim!.value;
  });
 }

 @override
 void dispose() {
  _intro.dispose(); _pulse.dispose(); _ripple.dispose();
  _zoom.dispose(); _tc.dispose();
  super.dispose();
 }

 _Parcel? get picked {
  if (sel == null) return null;
  for (final b in _parcels) {
   if (b.no == sel) return b;
  }
  return null;
 }

 int _count(_BState s) => _parcels.where((b) => b.state == s).length;
 int get _totalArea => _parcels.fold(0, (a, b) => a + b.area);

 // ── Hit testing ──

 String? _parcelAt(Offset at, Size s) {
  for (final b in _parcels.reversed) {
   if (filter != null && b.kind != filter) continue;
   if (_poly(b.pts, s).contains(at)) return b.no;
  }
  return null;
 }

 int? _roadAt(Offset at, Size s) {
  for (var i = 0; i < _roads.length; i++) {
   if (_poly(_roads[i].pts, s).contains(at)) return i;
  }
  return null;
 }

 void _tap(Offset at, Size s) {
  final p = _parcelAt(at, s);
  if (p != null) {
   HapticFeedback.selectionClick();
   setState(() {
    road = null;
    tapAt = at;
    sel = sel == p ? null : p;
   });
   if (sel != null) _ripple.forward(from: 0);
   return;
  }
  final r = _roadAt(at, s);
  if (r != null) {
   HapticFeedback.selectionClick();
   setState(() { sel = null; road = road == r ? null : r; });
   return;
  }
  setState(() { sel = null; road = null; });
 }

 void _move(Offset at, Size s) {
  final p = _parcelAt(at, s);
  final r = p == null ? _roadAt(at, s) : null;
  if (p != hover || r != roadHover) setState(() { hover = p; roadHover = r; });
 }

 // ── Zoom ──

 void _to(Matrix4 target) {
  _zAnim = Matrix4Tween(begin: _tc.value, end: target)
    .animate(CurvedAnimation(parent: _zoom, curve: Curves.easeOutCubic));
  _zoom.forward(from: 0);
 }

 void _zoomBy(double f) {
  if (_size == Size.zero) return;
  final cur = _tc.value.getMaxScaleOnAxis();
  final next = (cur * f).clamp(1.0, 6.0).toDouble();
  if ((next - cur).abs() < .001) return;
  final k = next / cur;
  final c = Offset(_size.width / 2, _size.height / 2);
  final m = Matrix4.identity()
   ..translate(c.dx, c.dy)
   ..scale(k)
   ..translate(-c.dx, -c.dy);
  _to(m.multiplied(_tc.value));
 }

 @override
 Widget build(BuildContext c) {
  final clubs = <List<String>>[
   for (final b in _parcels) for (final cl in b.clubs) [cl[0], cl[1], b.name]
  ]..sort((a, b) => a[1].compareTo(b[1]));

  return _Page(
    title: 'Campus Map',
    sub: 'Master layout plan  ·  tap any plot or road',
    trailing: _Drop(view, _views, (v) => setState(() => view = v!), light: true),
    children: [
     const SizedBox(height: 18),
     Row(children: [
      _countTile('In use', _count(_BState.inUse), _purple),
      _countTile('Free now', _count(_BState.free), _green),
      _countTile('Events today', _count(_BState.event), _amber),
     ]),
     if (view == _views.first) ...[
      _label('Land use filter'),
      _filters(),
      const SizedBox(height: 14),
      _sheet(),
      const SizedBox(height: 12),
      _legend(),
     ] else ...[
      _label('Statement of plots'),
      _schedule(),
     ],
     AnimatedSize(duration: const Duration(milliseconds: 280), curve: Curves.easeOutCubic,
       alignment: Alignment.topCenter,
       child: picked != null
         ? Column(children: [_label('Plot details'), _detail(picked!)])
         : road != null
           ? Column(children: [_label('Road details'), _roadCard(_roads[road!])])
           : const SizedBox(width: double.infinity)),
     _label('Clubs meeting today'),
     Surface(pad: const EdgeInsets.symmetric(vertical: 6),
       child: Column(children: clubs.map((cl) => _feedTile(
         '${cl[0]}  ·  ${cl[2]}', cl[1], Icons.groups_rounded, _teal)).toList())),
     const SizedBox(height: 8),
    ]);
 }

 // ── Filters ──

 Widget _filters() {
  final kinds = _parcels.map((b) => b.kind).toSet().toList()
   ..sort((a, b) => a.index.compareTo(b.index));
  return SizedBox(height: 38, child: ListView(scrollDirection: Axis.horizontal, children: [
   _chip('All plots', null, _purple),
   ...kinds.map((k) => _chip(k.label, k, k.hue)),
  ]));
 }

 Widget _chip(String t, _BKind? k, Color hue) {
  final on = filter == k;
  return Padding(padding: const EdgeInsets.only(right: 8),
    child: GestureDetector(
      onTap: () => setState(() {
       filter = on && k != null ? null : k;
       sel = null; road = null;
      }),
      child: AnimatedContainer(duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: on ? hue : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: on ? Colors.transparent : hue.withOpacity(.25)),
          boxShadow: on ? [BoxShadow(color: hue.withOpacity(.28),
            blurRadius: 12, offset: const Offset(0, 4))] : null),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
         if (k != null) ...[Icon(k.icon, size: 14, color: on ? Colors.white : hue),
           const SizedBox(width: 6)],
         Text(t, style: TextStyle(fontSize: 12,
           fontWeight: on ? FontWeight.w700 : FontWeight.w600,
           color: on ? Colors.white : _ink)),
        ]))));
 }

 // ── The drawing sheet ──

 Widget _plan() => LayoutBuilder(builder: (ctx, cs) {
   final s = Size(cs.maxWidth, cs.maxHeight);
   WidgetsBinding.instance.addPostFrameCallback((_) {
    if (_size != s) _size = s;
   });
   return MouseRegion(
     cursor: hover != null || roadHover != null
       ? SystemMouseCursors.click : SystemMouseCursors.basic,
     onHover: (e) => _move(e.localPosition, s),
     onExit: (_) => setState(() { hover = null; roadHover = null; }),
     child: GestureDetector(
       behavior: HitTestBehavior.opaque,
       onTapUp: (d) => _tap(d.localPosition, s),
       child: CustomPaint(size: s, painter: _PlanPainter(
         intro: _intro, pulse: _pulse, ripple: _ripple,
         sel: sel, hover: hover, road: road, roadHover: roadHover,
         filter: filter, tapAt: tapAt))));
  });

 Widget _sheet() => Container(
   padding: const EdgeInsets.all(8),
   decoration: BoxDecoration(color: Colors.white,
     borderRadius: BorderRadius.circular(16),
     border: Border.all(color: _line.withOpacity(.35), width: 1.3),
     boxShadow: [BoxShadow(color: _indigo.withOpacity(.09),
       blurRadius: 24, offset: const Offset(0, 8))]),
   child: Column(children: [
    ClipRRect(borderRadius: BorderRadius.circular(8),
      child: AspectRatio(aspectRatio: 1.32, child: Stack(children: [
       Positioned.fill(child: InteractiveViewer(
         transformationController: _tc, maxScale: 6, child: _plan())),
       Positioned(right: 8, bottom: 8, child: Column(children: [
        _zoomBtn(Icons.add_rounded, () => _zoomBy(1.7)),
        const SizedBox(height: 6),
        _zoomBtn(Icons.remove_rounded, () => _zoomBy(1 / 1.7)),
        const SizedBox(height: 6),
        _zoomBtn(Icons.center_focus_strong_rounded,
          () => _to(Matrix4.identity())),
       ])),
       if (sel == null && road == null)
        Positioned(left: 10, top: 10, child: IgnorePointer(
          child: FadeTransition(
            opacity: Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(parent: _intro, curve: const Interval(.7, 1))),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: Colors.white.withOpacity(.92),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _purple.withOpacity(.25))),
              child: Row(mainAxisSize: MainAxisSize.min, children: const [
               Icon(Icons.touch_app_rounded, size: 13, color: _purple),
               SizedBox(width: 6),
               Text('Tap a plot', style: TextStyle(fontSize: 10.5,
                 fontWeight: FontWeight.w700, color: _purple)),
              ]))))),
      ]))),
    const SizedBox(height: 8),
    _statement(),
    const SizedBox(height: 8),
    _titleBlock(),
   ]));

 /// Drawing annex: the statement of plots, kept off the plan so it can never
 /// sit on top of a parcel.
 Widget _statement() {
  final rows = <List<String>>[];
  for (final k in _BKind.values) {
   final g = _parcels.where((b) => b.kind == k);
   if (g.isEmpty) continue;
   rows.add([k.label.toUpperCase(), '${g.length}',
     '${g.fold(0, (a, b) => a + b.area)}']);
  }
  Widget line(List<String> r, {bool head = false, bool total = false}) {
   final st = TextStyle(fontSize: head ? 8 : 9,
     letterSpacing: head ? 1 : .3,
     fontWeight: head || total ? FontWeight.w900 : FontWeight.w600,
     color: head ? _muted : _line.withOpacity(total ? 1 : .78));
   return Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
     child: Row(children: [
      Expanded(flex: 5, child: Text(r[0], style: st,
        maxLines: 1, overflow: TextOverflow.ellipsis)),
      Expanded(flex: 2, child: Text(r[1], style: st, textAlign: TextAlign.right)),
      Expanded(flex: 3, child: Text(r[2], style: st, textAlign: TextAlign.right)),
     ]));
  }
  return Container(
    decoration: BoxDecoration(
      border: Border.all(color: _line.withOpacity(.5)),
      borderRadius: BorderRadius.circular(8)),
    child: Column(children: [
     Container(width: double.infinity,
       padding: const EdgeInsets.symmetric(vertical: 6),
       decoration: BoxDecoration(color: _line.withOpacity(.06),
         borderRadius: const BorderRadius.vertical(top: Radius.circular(7))),
       child: const Text('STATEMENT OF PLOTS', textAlign: TextAlign.center,
         style: TextStyle(fontSize: 8.5, letterSpacing: 1.3,
           fontWeight: FontWeight.w900, color: _line))),
     Divider(height: 1, color: _line.withOpacity(.35)),
     line(const ['LAND USE', 'NO.', 'AREA SQM'], head: true),
     Divider(height: 1, color: _line.withOpacity(.2)),
     ...rows.map(line),
     Divider(height: 1, color: _line.withOpacity(.35)),
     line(['TOTAL', '${_parcels.length}', '$_totalArea'], total: true),
     const SizedBox(height: 3),
    ]));
 }

 Widget _zoomBtn(IconData i, VoidCallback tap) => Material(
   color: Colors.white,
   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9),
     side: BorderSide(color: _line.withOpacity(.25))),
   elevation: 2,
   shadowColor: _indigo.withOpacity(.2),
   child: InkWell(borderRadius: BorderRadius.circular(9), onTap: tap,
     child: SizedBox(width: 30, height: 30, child: Icon(i, size: 17, color: _ink))));

 Widget _titleBlock() => Container(
   decoration: BoxDecoration(
     border: Border.all(color: _line.withOpacity(.5)),
     borderRadius: BorderRadius.circular(8)),
   child: Row(children: [
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 11),
      decoration: BoxDecoration(gradient: _gradSoft,
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(7))),
      child: const Icon(Icons.architecture_rounded, size: 17, color: Colors.white)),
    Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
       Text('CAMPUSCONNECT SCHOOL  ·  LAYOUT PLAN',
         maxLines: 1, overflow: TextOverflow.ellipsis,
         style: TextStyle(fontSize: 8.5, letterSpacing: .9,
           fontWeight: FontWeight.w800, color: _line.withOpacity(.85))),
       const SizedBox(height: 3),
       Text('SHEET 01  |  SCALE 1:1000  |  ${_parcels.length} PLOTS  |  '
         'SITE AREA $_totalArea SQM',
         maxLines: 1, overflow: TextOverflow.ellipsis,
         style: const TextStyle(fontSize: 7.5, letterSpacing: .6,
           fontWeight: FontWeight.w700, color: _muted)),
      ]))),
    IconButton(
      onPressed: _fullscreen,
      tooltip: 'Open full sheet',
      visualDensity: VisualDensity.compact,
      icon: const Icon(Icons.open_in_full_rounded, size: 17, color: _purple)),
   ]));

 void _fullscreen() => showDialog(context: context, builder: (dc) => Dialog(
   insetPadding: const EdgeInsets.all(10),
   backgroundColor: Colors.white,
   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
   child: Padding(padding: const EdgeInsets.all(10), child: Column(
     mainAxisSize: MainAxisSize.min, children: [
    Row(children: [
     const SizedBox(width: 6),
     const Expanded(child: Text('Master layout plan  ·  pinch to zoom',
       style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _ink))),
     IconButton(onPressed: () => Navigator.pop(dc),
       icon: const Icon(Icons.close_rounded, size: 20, color: _muted)),
    ]),
    const SizedBox(height: 4),
    Flexible(child: ClipRRect(borderRadius: BorderRadius.circular(10),
      child: AspectRatio(aspectRatio: 1.32,
        child: InteractiveViewer(maxScale: 8, child: _plan())))),
   ]))));

 Widget _legend() => Wrap(spacing: 12, runSpacing: 9, children:
   _BKind.values.map((k) {
    final on = filter == k;
    return GestureDetector(
      onTap: () => setState(() { filter = on ? null : k; sel = null; road = null; }),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
       Container(width: 11, height: 11,
         decoration: BoxDecoration(color: k.hue.withOpacity(.3),
           border: Border.all(color: k.hue, width: 1.1),
           borderRadius: BorderRadius.circular(2))),
       const SizedBox(width: 6),
       Text(k.label, style: TextStyle(fontSize: 10.5,
         fontWeight: on ? FontWeight.w700 : FontWeight.w400,
         color: on ? k.hue : _muted)),
      ]));
   }).toList());

 // ── Road card ──

 Widget _roadCard(_Road r) => Surface(pad: const EdgeInsets.all(18),
   child: Row(children: [
    Container(padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(color: _purple.withOpacity(.12),
        borderRadius: BorderRadius.circular(14)),
      child: const Icon(Icons.add_road_rounded, color: _purple, size: 21)),
    const SizedBox(width: 14),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
     Text('CARRIAGEWAY  ·  ${r.width} WIDE',
       style: const TextStyle(fontSize: 10.5, letterSpacing: .8,
         fontWeight: FontWeight.w800, color: _muted)),
     const SizedBox(height: 4),
     Text(r.label, style: const TextStyle(fontSize: 15,
       fontWeight: FontWeight.w800, color: _ink, height: 1.25)),
     const SizedBox(height: 5),
     Text(r.note, style: const TextStyle(fontSize: 12.5, color: _muted, height: 1.4)),
    ])),
    IconButton(onPressed: () => setState(() => road = null),
      icon: const Icon(Icons.close_rounded, size: 19, color: _muted),
      visualDensity: VisualDensity.compact),
   ]));

 // ── Schedule view ──

 Widget _schedule() => Surface(pad: const EdgeInsets.all(4), child: Column(children: [
   Container(
     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
     decoration: BoxDecoration(color: _indigo.withOpacity(.06),
       borderRadius: BorderRadius.circular(11)),
     child: const Row(children: [
      SizedBox(width: 32, child: Text('NO.', style: _thStyle)),
      Expanded(flex: 5, child: Text('PLOT', style: _thStyle)),
      Expanded(flex: 3, child: Text('AREA', style: _thStyle, textAlign: TextAlign.right)),
      Expanded(flex: 3, child: Text('STATUS', style: _thStyle, textAlign: TextAlign.right)),
     ])),
   ..._parcels.map((b) {
    final on = sel == b.no;
    return InkWell(
      borderRadius: BorderRadius.circular(11),
      onTap: () => setState(() { road = null; sel = on ? null : b.no; }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: on ? b.kind.hue.withOpacity(.10) : null,
          borderRadius: BorderRadius.circular(11)),
        child: Row(children: [
         SizedBox(width: 32, child: Row(children: [
          Container(width: 9, height: 9,
            decoration: BoxDecoration(color: b.kind.hue.withOpacity(.3),
              border: Border.all(color: b.kind.hue, width: 1.1),
              borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 6),
          Text(b.no, style: const TextStyle(fontSize: 11,
            fontWeight: FontWeight.w800, color: _muted)),
         ])),
         Expanded(flex: 5, child: Column(
           crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(b.name, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12.5,
              fontWeight: FontWeight.w700, color: _ink)),
          const SizedBox(height: 2),
          Text(b.kind.label, style: const TextStyle(fontSize: 10.5, color: _muted)),
         ])),
         Expanded(flex: 3, child: Text('${b.area}\nSQM', textAlign: TextAlign.right,
           style: const TextStyle(fontSize: 11, height: 1.3,
             fontWeight: FontWeight.w600, color: _ink))),
         Expanded(flex: 3, child: Align(alignment: Alignment.centerRight,
           child: _pill(b.state.label, b.state.hue))),
        ])));
   }),
   Container(
     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
     decoration: BoxDecoration(color: _purple.withOpacity(.07),
       borderRadius: BorderRadius.circular(11)),
     child: Row(children: [
      const Expanded(child: Text('TOTAL SITE AREA',
        style: TextStyle(fontSize: 11, letterSpacing: .8,
          fontWeight: FontWeight.w800, color: _ink))),
      Text('$_totalArea SQM', style: const TextStyle(fontSize: 13,
        fontWeight: FontWeight.w800, color: _purple)),
     ])),
  ]));

 // ── Detail panel ──

 Widget _detail(_Parcel b) {
  final hue = b.kind.hue;
  final load = b.cap == 0 ? 0.0 : (b.occ / b.cap).clamp(0.0, 1.0).toDouble();
  final loadHue = load > .85 ? _red : load > .5 ? _amber : _green;
  return Surface(pad: const EdgeInsets.all(18), child: Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
   _PlotPhoto(b),
   const SizedBox(height: 18),
   Row(children: [
    Container(padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(color: hue.withOpacity(.12),
        borderRadius: BorderRadius.circular(14)),
      child: Icon(b.kind.icon, color: hue, size: 21)),
    const SizedBox(width: 14),
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
     Text('PLOT ${b.no}  ·  ${b.area} SQM',
       style: const TextStyle(fontSize: 10.5, letterSpacing: .8,
         fontWeight: FontWeight.w800, color: _muted)),
     const SizedBox(height: 4),
     Text(b.name, style: const TextStyle(fontSize: 17,
       fontWeight: FontWeight.w800, color: _ink, height: 1.2)),
     const SizedBox(height: 7),
     Row(children: [
      _pill(b.kind.label, hue), const SizedBox(width: 7),
      _pill(b.state.label, b.state.hue, solid: b.state == _BState.event),
     ]),
    ])),
    IconButton(onPressed: () => setState(() => sel = null),
      icon: const Icon(Icons.close_rounded, size: 19, color: _muted),
      visualDensity: VisualDensity.compact),
   ]),
   if (b.cap > 0) ...[
    const SizedBox(height: 20),
    Row(children: [
     const Text('Current occupancy', style: TextStyle(fontSize: 12.5,
       fontWeight: FontWeight.w600, color: _ink)),
     const Spacer(),
     Text('${b.occ} of ${b.cap}', style: TextStyle(fontSize: 12.5,
       fontWeight: FontWeight.w800, color: loadHue)),
    ]),
    const SizedBox(height: 8),
    TweenAnimationBuilder<double>(tween: Tween(begin: 0, end: load),
      duration: const Duration(milliseconds: 600), curve: Curves.easeOutCubic,
      builder: (_, v, __) => ClipRRect(borderRadius: BorderRadius.circular(20),
        child: LinearProgressIndicator(value: v, minHeight: 8,
          color: loadHue, backgroundColor: _bg))),
   ],
   const SizedBox(height: 20),
   _row(Icons.play_circle_fill_rounded, 'Happening now', b.now, b.state.hue),
   const SizedBox(height: 14),
   _row(Icons.schedule_rounded, 'Up next', b.next, _muted),
   const SizedBox(height: 14),
   _row(Icons.person_rounded, 'Responsible', b.host, _purple),
   if (b.clubs.isNotEmpty) ...[
    const SizedBox(height: 18),
    const Text('CLUBS MEETING HERE', style: TextStyle(fontSize: 10,
      fontWeight: FontWeight.w800, color: _muted, letterSpacing: 1.1)),
    const SizedBox(height: 10),
    Wrap(spacing: 8, runSpacing: 8, children: b.clubs.map((cl) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: _teal.withOpacity(.10),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _teal.withOpacity(.25))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
       const Icon(Icons.groups_rounded, size: 14, color: _teal),
       const SizedBox(width: 7),
       Text('${cl[0]}  ·  ${cl[1]}', style: const TextStyle(fontSize: 11.5,
         fontWeight: FontWeight.w600, color: _ink)),
      ]))).toList()),
   ],
   const SizedBox(height: 20),
   Row(children: [
    Expanded(child: _gradBtn(
      b.state == _BState.free ? 'Book this plot' : 'Request a slot',
      Icons.event_available_rounded,
      () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Booking request sent for ${b.name}'),
        behavior: SnackBarBehavior.floating)))),
    const SizedBox(width: 11),
    Expanded(child: OutlinedButton.icon(
      onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Message drafted to ${b.host}'),
        behavior: SnackBarBehavior.floating)),
      icon: const Icon(Icons.forum_rounded, size: 17),
      label: const Text('Contact'),
      style: OutlinedButton.styleFrom(foregroundColor: _purple,
        minimumSize: const Size.fromHeight(50),
        side: BorderSide(color: _purple.withOpacity(.35)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))))),
   ]),
  ]));
 }

 Widget _row(IconData i, String label, String value, Color hue) => Row(
   crossAxisAlignment: CrossAxisAlignment.start, children: [
   Container(padding: const EdgeInsets.all(8),
     decoration: BoxDecoration(color: hue.withOpacity(.11),
       borderRadius: BorderRadius.circular(10)),
     child: Icon(i, size: 15, color: hue)),
   const SizedBox(width: 13),
   Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(label, style: const TextStyle(fontSize: 10.5, color: _muted)),
    const SizedBox(height: 3),
    Text(value, style: const TextStyle(fontSize: 13.5,
      fontWeight: FontWeight.w600, color: _ink, height: 1.35)),
   ])),
  ]);
}

const _thStyle = TextStyle(fontSize: 9.5, letterSpacing: 1,
  fontWeight: FontWeight.w800, color: _muted);
