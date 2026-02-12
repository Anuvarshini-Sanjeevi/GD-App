class SessionConfig {
  final String id;
  final String sessionName;
  final String topic;
  final String date;
  final String startTime;
  final String endTime;
  final String hall;
  final String status;
  final String? targetLevel;
  final String? alert;

  SessionConfig({
    required this.id,
    required this.sessionName,
    required this.topic,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.hall,
    required this.status,
    this.targetLevel,
    this.alert,
  });

  factory SessionConfig.fromJson(Map<String, dynamic> json) {
    // If we have createdAt but no date, use createdAt as a fallback
    String? rawDate = json['date'] ?? json['sessionDate'] ?? json['session_date'] ?? json['createdAt'];
    String? rawStartTime = json['startTime'] ?? json['start_time'] ?? json['createdAt'];
    String? rawEndTime = json['endTime'] ?? json['end_time'];

    // If session_id exists, use it as a default topic/name if missing
    String? sid = json['session_id']?.toString() ?? json['session_id']?.toString();
    String defaultName = sid != null ? 'Session #$sid' : 'Group Discussion';

    return SessionConfig(
      id: json['config_id']?.toString() ?? json['id']?.toString() ?? '',
      sessionName: json['sessionName'] ?? json['session_name'] ?? defaultName,
      topic: json['topic'] ?? json['sessionName'] ?? json['session_name'] ?? defaultName,
      date: rawDate ?? '',
      startTime: rawStartTime ?? '',
      endTime: rawEndTime ?? '',
      hall: json['hall'] ?? json['hallName'] ?? json['hall_name'] ?? json['location'] ?? 'Main Hall',
      status: json['status'] ?? 'UPCOMING',
      targetLevel: json['targetLevel']?.toString() ?? json['target_level']?.toString(),
      alert: json['alert'] ?? json['prerequisite'],
    );
  }
}
