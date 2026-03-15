import 'package:flutter/material.dart';
import 'package:gdapp/services/api_service.dart';
import 'package:gdapp/models/ranking_data.dart';

class SupervisorGrowthPage extends StatefulWidget {
  const SupervisorGrowthPage({super.key});

  @override
  State<SupervisorGrowthPage> createState() => _SupervisorGrowthPageState();
}

class _SupervisorGrowthPageState extends State<SupervisorGrowthPage> {
  String _selectedTab = 'Overall';
  bool _isLoading = false;
  List<RankingData> _rankings = [];

  final List<Map<String, String>> _mockRanks = [
    {'rank': '#1', 'name': 'Adhish S', 'team': 'Team A', 'score': '62'},
    {'rank': '#2', 'name': 'Indhuja V', 'team': 'Team B', 'score': '25'},
    {'rank': '#3', 'name': 'Govarthini G', 'team': 'Team C', 'score': '23'},
    {'rank': '#4', 'name': 'Rahul K', 'team': 'Team D', 'score': '21'},
    {'rank': '#5', 'name': 'Sowmiya R', 'team': 'Team A', 'score': '19'},
    {'rank': '#6', 'name': 'Pradeep M', 'team': 'Team B', 'score': '18'},
    {'rank': '#7', 'name': 'Ananya P', 'team': 'Team C', 'score': '17'},
    {'rank': '#8', 'name': 'Karthik S', 'team': 'Team D', 'score': '16'},
    {'rank': '#9', 'name': 'Deepika J', 'team': 'Team A', 'score': '15'},
    {'rank': '#10', 'name': 'Manoj V', 'team': 'Team B', 'score': '14'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchRankings();
  }

  Future<void> _fetchRankings() async {
    setState(() => _isLoading = true);
    try {
      final rankings = await ApiService.getRankings();
      if (mounted) {
        setState(() {
          _rankings = rankings;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Performance Insights',
          style: TextStyle(
            color: Color(0xFF1F2533),
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2533)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Monitoring student progress across all activities',
                style: TextStyle(
                  color: Color(0xFF8A96A8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Leaderboard
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: const Color(0xFFF2F4F8)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    // Podium
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildRankPodium(
                            name: _rankings.length > 1 ? _rankings[1].name : 'Indhuja V',
                            rank: '2',
                            points: _rankings.length > 1 ? _rankings[1].score.toString() : '25',
                            height: 140,
                            color: const Color(0xFFF3F7FF),
                            borderColor: const Color(0xFF3A78E8),
                          ),
                          const SizedBox(width: 12),
                          _buildRankPodium(
                            name: _rankings.isNotEmpty ? _rankings[0].name : 'Adhish S',
                            rank: '1',
                            points: _rankings.isNotEmpty ? _rankings[0].score.toString() : '62',
                            height: 180,
                            isWinner: true,
                            color: const Color(0xFFF1F0FF),
                            borderColor: const Color(0xFFA185F4),
                          ),
                          const SizedBox(width: 12),
                          _buildRankPodium(
                            name: _rankings.length > 2 ? _rankings[2].name : 'Govarthini G',
                            rank: '3',
                            points: _rankings.length > 2 ? _rankings[2].score.toString() : '23',
                            height: 130,
                            color: const Color(0xFFFFF4F0),
                            borderColor: const Color(0xFFFF844B),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Divider(height: 1, color: Color(0xFFF2F4F8)),
                    // List
                    Expanded(
                      child: _isLoading 
                          ? const Center(child: CircularProgressIndicator())
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _rankings.isNotEmpty ? _rankings.length : _mockRanks.length,
                                itemBuilder: (context, index) {
                                  if (_rankings.isNotEmpty) {
                                    final item = _rankings[index];
                                    return _buildRankItem(
                                      item.rank,
                                      item.name,
                                      'ST-ID-${index + 100}',
                                      item.score.toString(),
                                    );
                                  } else {
                                    final item = _mockRanks[index];
                                    return _buildRankItem(
                                      item['rank']!,
                                      item['name']!,
                                      'ST-ID-${index + 100}',
                                      item['score']!,
                                    );
                                  }
                                },
                            ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label) {
    bool isSelected = _selectedTab == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3A78E8) : const Color(0xFFF2F4F8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF8A96A8),
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildRankPodium({
    required String name,
    required String rank,
    required String points,
    required double height,
    bool isWinner = false,
    required Color color,
    required Color borderColor,
  }) {
    return Expanded(
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor.withOpacity(0.3), width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: isWinner ? 28 : 24,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: isWinner ? 26 : 22,
                backgroundColor: borderColor.withOpacity(0.1),
                child: Text(
                  name[0].toUpperCase(),
                  style: TextStyle(
                    fontSize: isWinner ? 20 : 16,
                    color: borderColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name.split(' ')[0],
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1F2533),
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '$points pts',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: borderColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankItem(String rank, String name, String id, String score) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF2F4F8)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFFF2F4F8),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                rank.replaceAll('#', ''),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: Color(0xFF1F2533),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: Color(0xFF1F2533),
                  ),
                ),
                Text(
                  id,
                  style: const TextStyle(
                    color: Color(0xFF8A96A8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
            Text(
            score,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: Color(0xFF3A78E8),
            ),
          ),
        ],
      ),
    );
  }
}
