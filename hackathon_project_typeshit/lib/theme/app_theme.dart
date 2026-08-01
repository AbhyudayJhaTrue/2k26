import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF6C5CE7);
  static const Color accent = Color(0xFF00CEC9);
  static const Color success = Color(0xFF00B894);
  static const Color warning = Color(0xFFF39C12);
  static const Color surface = Color(0xFFF5F6FA);
  static const Color background = Color(0xFF140D3E);
  static const Color ink = Color(0xFF2D3436);
  static const Color muted = Color(0xFF6E7191);
  static const Color card = Color(0xFFFFFFFF);
  static const Color gradientStart = Color(0xFF4F5BFF);
  static const Color gradientMiddle = Color(0xFF5CCEFA);
  static const Color gradientEnd = Color(0xFF2EDCA2);

  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x22000000),
      blurRadius: 24,
      offset: Offset(0, 12),
    ),
  ];
}

extension ColorOpacityHelpers on Color {
  Color withValues({double alpha = 1.0}) => withOpacity(alpha);
}

class HoverScale extends StatefulWidget {
  const HoverScale({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 1.04,
    this.duration = const Duration(milliseconds: 180),
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final Duration duration;

  @override
  State<HoverScale> createState() => _HoverScaleState();
}

class _HoverScaleState extends State<HoverScale> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final child = AnimatedScale(
      scale: _hovering ? widget.scale : 1,
      duration: widget.duration,
      curve: Curves.easeOut,
      child: widget.child,
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(onTap: widget.onTap, child: child),
    );
  }
}
