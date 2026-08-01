class QuestTask {
  final String description;
  final bool completed;

  const QuestTask({
    required this.description,
    this.completed = false,
  });
}

class DiscoveryQuest {
  final String title;
  final String description;
  final String subject;
  final String badge;
  final int xpReward;
  final bool completed;
  final List<QuestTask> tasks;

  const DiscoveryQuest({
    required this.title,
    required this.description,
    required this.subject,
    required this.badge,
    required this.xpReward,
    this.completed = false,
    this.tasks = const [],
  });
}
