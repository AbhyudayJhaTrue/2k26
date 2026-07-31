class Assignment {
  final String id;
  final String title;
  final String subject;
  final DateTime dueDate;
  final String status; // 'pending', 'submitted', or 'graded'
  final String description;
  final String? grade;
  final String? feedback;

  const Assignment({
    required this.id,
    required this.title,
    required this.subject,
    required this.dueDate,
    required this.status,
    this.description = '',
    this.grade,
    this.feedback,
  });
}