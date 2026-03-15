class StudentActivity {
  final String id;
  final String title;
  final String subtitle;
  final String progressLabel;
  final double progress;
  final int level;
  final int levels;
  final String status;
  final String credits;
  final String activityType;
  final String category;
  final int completedLevels;
  final double progressPercent;
  final String? token;

  const StudentActivity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.progressLabel,
    required this.progress,
    required this.level,
    required this.levels,
    required this.status,
    required this.credits,
    required this.activityType,
    required this.category,
    required this.completedLevels,
    required this.progressPercent,
    this.token,
  });

  factory StudentActivity.fromJson(Map<String, dynamic> json) {
    // Mapping from the new API structure while maintaining some fallback for old fields
    final totalLevels = (json['levels'] ?? json['total_levels'] ?? 10).toInt();
    final completedLevels = (json['completed_levels'] ?? 0).toInt();
    final progressVal = json['progress_percent'] != null 
        ? (json['progress_percent'] / 100.0) 
        : (json['progress'] ?? (completedLevels / totalLevels)).toDouble();

    return StudentActivity(
      id: json['id']?.toString() ?? json['activity_id']?.toString() ?? '',
      title: json['name'] ?? json['title'] ?? json['activity_name'] ?? 'Untitled Activity',
      subtitle: json['subtitle'] ?? json['description'] ?? json['session_info'] ?? '',
      progressLabel: json['progressLabel'] ?? json['category'] ?? json['type'] ?? json['skill'] ?? 'Activity',
      progress: progressVal,
      level: (json['level'] ?? completedLevels).toInt(),
      levels: totalLevels,
      status: json['status'] ?? 'NOT_STARTED',
      credits: json['credits']?.toString() ?? '+0 Credits',
      activityType: json['activity_type'] ?? 'ACTIVITY',
      category: json['category'] ?? 'General',
      completedLevels: completedLevels,
      progressPercent: (json['progress_percent'] ?? (progressVal * 100)).toDouble(),
      token: json['token']?.toString(),
    );
  }
}
