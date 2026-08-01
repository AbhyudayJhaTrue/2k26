import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../user_database.dart';

class ResearchHubScreen extends StatefulWidget {
  const ResearchHubScreen({super.key});

  @override
  State<ResearchHubScreen> createState() => _ResearchHubScreenState();
}

class _ResearchHubScreenState extends State<ResearchHubScreen> {
  String _selectedSubject = 'All';
  String _selectedType = 'All';
  bool _isGridView = true;
  bool _showBookmarked = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> _subjects = [
    'All', 'Mathematics', 'English', 'Physics',
    'Biology', 'Chemistry', 'History', 'Geography',
    'Computer Science', 'General'
  ];

  final List<String> _types = [
    'All', 'article', 'video', 'book', 'journal',
    'website', 'research_paper', 'government'
  ];

  final Map<String, IconData> _typeIcons = {
    'article': Icons.article,
    'video': Icons.play_circle_fill,
    'book': Icons.menu_book,
    'journal': Icons.science,
    'website': Icons.language,
    'research_paper': Icons.description,
    'government': Icons.account_balance,
  };

  final Map<String, Color> _typeColors = {
    'article': const Color(0xFF6C5CE7),
    'video': const Color(0xFFE17055),
    'book': const Color(0xFF0984E3),
    'journal': const Color(0xFF00B894),
    'website': const Color(0xFFFDCB6E),
    'research_paper': const Color(0xFFE84393),
    'government': const Color(0xFF00CEC9),
  };

  final Map<String, String> _typeLabels = {
    'article': 'Article',
    'video': 'Video',
    'book': 'Book',
    'journal': 'Journal',
    'website': 'Website',
    'research_paper': 'Research Paper',
    'government': 'Government',
  };

  List<ResearchResource> get _trending =>
      UserDatabase.instance.researchResources.take(4).toList();

  List<ResearchResource> get _filtered {
    return UserDatabase.instance.researchResources.where((r) {
      final matchSubject = _selectedSubject == 'All' || r.subject == _selectedSubject;
      final matchType = _selectedType == 'All' || r.type == _selectedType;
      final matchSearch = _searchQuery.isEmpty ||
          r.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          r.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          r.source.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchBookmark = !_showBookmarked || r.isBookmarked;
      return matchSubject && matchType && matchSearch && matchBookmark;
    }).toList();
  }

  Color _difficultyColor(String d) {
    switch (d) {
      case 'Beginner': return Colors.green;
      case 'Intermediate': return Colors.orange;
      case 'Advanced': return Colors.red;
      default: return Colors.grey;
    }
  }

  String _difficultyEmoji(String d) {
    switch (d) {
      case 'Beginner': return '🟢';
      case 'Intermediate': return '🟡';
      case 'Advanced': return '🔴';
      default: return '⚪';
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            expandedHeight: 190,
            pinned: true,
            backgroundColor: const Color(0xFF00B894),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _showBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: Colors.white,
                ),
                onPressed: () => setState(() => _showBookmarked = !_showBookmarked),
              ),
            ],
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
                    padding: const EdgeInsets.fromLTRB(20, 50, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🔬 Research Hub',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Teacher-approved resources only • No AI answers',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (v) => setState(() => _searchQuery = v),
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search by title, subject, source...',
                              hintStyle: GoogleFonts.poppins(
                                color: Colors.white60,
                                fontSize: 12,
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Colors.white60,
                                size: 20,
                              ),
                              border: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        body: ListView(
          children: [
            // ── TRENDING SECTION ───────────────────────────
            if (_searchQuery.isEmpty && _selectedSubject == 'All' && _selectedType == 'All' && !_showBookmarked) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Text(
                      '🔥 Trending Resources',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: const Color(0xFF2D3436),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 140,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _trending.length,
                  itemBuilder: (_, i) => _trendingCard(_trending[i]),
                ),
              ),
              const SizedBox(height: 8),
              const Divider(height: 1),
            ],

            // ── STATS + TOGGLE ROW ─────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${filtered.length} Resources Found',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: const Color(0xFF2D3436),
                        ),
                      ),
                      if (_showBookmarked)
                        Text(
                          '⭐ Showing saved only',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: const Color(0xFF00B894),
                          ),
                        ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6FA),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        _toggleBtn(Icons.grid_view, true),
                        _toggleBtn(Icons.list, false),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── SUBJECT FILTER ─────────────────────────────
            Container(
              color: Colors.white,
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                itemCount: _subjects.length,
                itemBuilder: (_, i) {
                  final s = _subjects[i];
                  final selected = _selectedSubject == s;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedSubject = s),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: selected ? const Color(0xFF00B894) : const Color(0xFFF5F6FA),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        s,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: selected ? Colors.white : const Color(0xFF636E72),
                          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // ── TYPE FILTER ────────────────────────────────
            Container(
              color: Colors.white,
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                itemCount: _types.length,
                itemBuilder: (_, i) {
                  final t = _types[i];
                  final selected = _selectedType == t;
                  final color = _typeColors[t] ?? const Color(0xFF00B894);
                  return GestureDetector(
                    onTap: () => setState(() => _selectedType = t),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: selected ? color : const Color(0xFFF5F6FA),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          if (t != 'All')
                            Icon(
                              _typeIcons[t] ?? Icons.category,
                              size: 12,
                              color: selected ? Colors.white : color,
                            ),
                          if (t != 'All') const SizedBox(width: 4),
                          Text(
                            t == 'All' ? 'All' : (_typeLabels[t] ?? t),
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: selected ? Colors.white : const Color(0xFF636E72),
                              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // ── RESOURCE GRID / LIST ───────────────────────
            filtered.isEmpty
                ? SizedBox(
                    height: 200,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🔍', style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 12),
                          Text(
                            'No resources found',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: const Color(0xFF636E72),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : _isGridView
                    ? GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.78,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) => _gridCard(filtered[i]),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) => _listCard(filtered[i]),
                      ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── TRENDING CARD ─────────────────────────────────────────
  Widget _trendingCard(ResearchResource r) {
    final color = _typeColors[r.type] ?? const Color(0xFF00B894);
    final icon = _typeIcons[r.type] ?? Icons.link;

    return GestureDetector(
      onTap: () => _showDetail(r),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12, bottom: 4, top: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                Text('🔥', style: const TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              r.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: const Color(0xFF2D3436),
              ),
            ),
            const Spacer(),
            Text(
              r.source,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '⏱ ${r.readTime}',
              style: GoogleFonts.poppins(
                fontSize: 9,
                color: const Color(0xFF636E72),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── GRID CARD ─────────────────────────────────────────────
  Widget _gridCard(ResearchResource r) {
    final color = _typeColors[r.type] ?? const Color(0xFF00B894);
    final icon = _typeIcons[r.type] ?? Icons.link;

    return GestureDetector(
      onTap: () => _showDetail(r),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 75,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Stack(
                children: [
                  Center(child: Icon(icon, size: 32, color: color)),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: GestureDetector(
                      onTap: () => setState(() => r.isBookmarked = !r.isBookmarked),
                      child: Icon(
                        r.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        color: r.isBookmarked ? const Color(0xFF00B894) : Colors.grey,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (r.teacherApproved)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00B894).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '✅ Approved',
                            style: GoogleFonts.poppins(
                              fontSize: 8,
                              color: const Color(0xFF00B894),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    r.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      color: const Color(0xFF2D3436),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '🏛 ${r.source}',
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        '${_difficultyEmoji(r.difficulty)} ${r.difficulty}',
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          color: _difficultyColor(r.difficulty),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '⏱ ${r.readTime}',
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      color: const Color(0xFF636E72),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── LIST CARD ─────────────────────────────────────────────
  Widget _listCard(ResearchResource r) {
    final color = _typeColors[r.type] ?? const Color(0xFF00B894);
    final icon = _typeIcons[r.type] ?? Icons.link;

    return GestureDetector(
      onTap: () => _showDetail(r),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: const Color(0xFF2D3436),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    r.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: const Color(0xFF636E72),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _typeLabels[r.type] ?? r.type,
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${_difficultyEmoji(r.difficulty)} ${r.difficulty}',
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          color: _difficultyColor(r.difficulty),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '⏱ ${r.readTime}',
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          color: const Color(0xFF636E72),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '🏛 ${r.source}',
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                GestureDetector(
                  onTap: () => setState(() => r.isBookmarked = !r.isBookmarked),
                  child: Icon(
                    r.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: r.isBookmarked ? const Color(0xFF00B894) : Colors.grey,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 8),
                const Icon(Icons.chevron_right, color: Color(0xFF636E72), size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── DETAIL POPUP ──────────────────────────────────────────
  void _showDetail(ResearchResource r) {
    final color = _typeColors[r.type] ?? const Color(0xFF00B894);
    final icon = _typeIcons[r.type] ?? Icons.link;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => DraggableScrollableSheet(
          initialChildSize: 0.65,
          maxChildSize: 0.92,
          minChildSize: 0.4,
          builder: (_, controller) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: ListView(
              controller: controller,
              padding: const EdgeInsets.all(24),
              children: [
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
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(icon, color: color, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.title,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2D3436),
                            ),
                          ),
                          Text(
                            '${r.subject} • ${_typeLabels[r.type] ?? r.type}',
                            style: GoogleFonts.poppins(fontSize: 12, color: color),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setModalState(() => r.isBookmarked = !r.isBookmarked);
                        setState(() {});
                      },
                      child: Icon(
                        r.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        color: r.isBookmarked ? const Color(0xFF00B894) : Colors.grey,
                        size: 26,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Info chips row
                Row(
                  children: [
                    _infoChip('🏛 ${r.source}', color),
                    const SizedBox(width: 8),
                    _infoChip('${_difficultyEmoji(r.difficulty)} ${r.difficulty}', _difficultyColor(r.difficulty)),
                    const SizedBox(width: 8),
                    _infoChip('⏱ ${r.readTime}', Colors.grey),
                  ],
                ),
                const SizedBox(height: 16),
                if (r.teacherApproved)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00B894).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF00B894).withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified, color: Color(0xFF00B894), size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Teacher Approved Resource',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: const Color(0xFF00B894),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  'About this Resource',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D3436),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  r.description,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: const Color(0xFF636E72),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Opening ${r.url}',
                            style: GoogleFonts.poppins(fontSize: 12)),
                        backgroundColor: const Color(0xFF00B894),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    );
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
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.open_in_new, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Open Resource',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
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
      ),
    );
  }

  Widget _infoChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _toggleBtn(IconData icon, bool isGrid) {
    final selected = _isGridView == isGrid;
    return GestureDetector(
      onTap: () => setState(() => _isGridView = isGrid),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF00B894) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: selected ? Colors.white : Colors.grey),
      ),
    );
  }
}