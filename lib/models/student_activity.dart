class StudentActivity {
  final String id;
  final String title;
  final String subtitle;
  final String progressLabel;
  final double progress;
  final int level;
  final String status;
  final String credits;

  StudentActivity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.progressLabel,
    required this.progress,
    required this.level,
    required this.status,
    required this.credits,
  });

  factory StudentActivity.fromJson(Map<String, dynamic> json) {
    return StudentActivity(
      id: json['id']?.toString() ?? json['activity_id']?.toString() ?? '',
      title: json['title'] ?? json['activity_name'] ?? json['name'] ?? 'Untitled Activity',
      subtitle: json['subtitle'] ?? json['description'] ?? json['session_info'] ?? '',
      progressLabel: json['progressLabel'] ?? json['type'] ?? json['skill'] ?? 'Activity',
      progress: (json['progress'] ?? 0).toDouble(),
      level: (json['level'] ?? json['levels'] ?? 1).toInt(),
      status: json['status'] ?? 'PENDING',
      credits: json['credits']?.toString() ?? '+0 Credits',
    );
  }
}
