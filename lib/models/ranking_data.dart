class RankingData {
  final String rank;
  final String name;
  final String team;
  final int score;

  const RankingData({
    required this.rank,
    required this.name,
    required this.team,
    required this.score,
  });

  factory RankingData.fromJson(Map<String, dynamic> json) {
    return RankingData(
      rank: json['rank']?.toString() ?? '',
      name: json['name'] ?? json['username'] ?? 'Anonymous',
      team: json['team'] ?? json['department'] ?? 'General',
      score: (json['score'] ?? json['points'] ?? 0).toInt(),
    );
  }
}
