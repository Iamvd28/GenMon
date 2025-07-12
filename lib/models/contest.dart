class Contest {
  final String id;
  final String title;
  final String question;
  final List<String> participants; // user ids or names
  final int maxParticipants;
  final String status; // waiting, live, completed
  final DateTime? startTime;

  Contest({
    required this.id,
    required this.title,
    required this.question,
    required this.participants,
    required this.maxParticipants,
    required this.status,
    this.startTime,
  });

  // For backend integration, add fromJson/toJson methods here
} 