class CalendarEvent {
  final String title;
  final String type; // 'exam', 'holiday', 'sports', 'event', 'club'
  final DateTime date;

  const CalendarEvent({
    required this.title,
    required this.type,
    required this.date,
  });
}