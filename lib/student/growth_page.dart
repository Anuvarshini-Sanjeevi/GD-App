import 'package:flutter/material.dart';
import 'package:gdapp/services/api_service.dart';
import 'package:gdapp/models/ranking_data.dart';

class GrowthPage extends StatefulWidget {
  final Function(int, {bool? showScanner}) onNavigate;
  const GrowthPage({super.key, required this.onNavigate});

  @override
  State<GrowthPage> createState() => _GrowthPageState();
}

class _GrowthPageState extends State<GrowthPage> {
  String _selectedTab = 'Overall';
  bool _isLoading = false;
  List<RankingData> _rankings = [];

  final List<Map<String, String>> _allRanks = [
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
    setState(() {
      _isLoading = true;
    });

    try {
      final rankings = await ApiService.getRankings();
      if (mounted) {
        setState(() {
          _rankings = rankings;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Active participation',
          style: TextStyle(
            color: Color(0xFF0D2146),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.grey),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Maximum levels completed across all activities',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildTab('Overall'),
                  const SizedBox(width: 8),
                  _buildTab('Department'),
                  const SizedBox(width: 8),
                  _buildTab('Skill wise'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Leaderboard
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Top Performers Card Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🏆', style: TextStyle(fontSize: 24)),
                          const SizedBox(width: 8),
                          const Text(
                            'Top Performers',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0D2146),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Top Performers Podium
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildRankPodium(
                            name: _selectedTab == 'Skill wise' && _rankings.isNotEmpty ? _rankings[1].name : (_selectedTab == 'Department' ? 'Rahul K' : 'Indhuja V'),
                            rank: '2',
                            points: _selectedTab == 'Skill wise' && _rankings.isNotEmpty ? '${_rankings[1].score}' : (_selectedTab == 'Department' ? '45' : '25'),
                            height: 160,
                            color: const Color(0xFFEAECF0),
                            borderColor: const Color(0xFF98A2B3),
                          ),
                          const SizedBox(width: 8),
                          _buildRankPodium(
                            name: _selectedTab == 'Skill wise' && _rankings.length > 0 ? _rankings[0].name : (_selectedTab == 'Department' ? 'Priya D' : 'Adhish S'),
                            rank: '1',
                            points: _selectedTab == 'Skill wise' && _rankings.length > 0 ? '${_rankings[0].score}' : (_selectedTab == 'Department' ? '88' : '62'),
                            height: 200,
                            isWinner: true,
                            color: const Color(0xFFFEF0C7),
                            borderColor: const Color(0xFFF79009),
                          ),
                          const SizedBox(width: 8),
                          _buildRankPodium(
                            name: _selectedTab == 'Skill wise' && _rankings.isNotEmpty ? _rankings[2].name : (_selectedTab == 'Department' ? 'Sowmiya R' : 'Govarthini G'),
                            rank: '3',
                            points: _selectedTab == 'Skill wise' && _rankings.isNotEmpty ? '${_rankings[2].score}' : (_selectedTab == 'Department' ? '32' : '23'),
                            height: 150,
                            color: const Color(0xFFFFE4D6),
                            borderColor: const Color(0xFFF97066),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // List
                    Expanded(
                      child: _isLoading 
                          ? const Center(child: CircularProgressIndicator())
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              itemCount: _selectedTab == 'Skill wise' && _rankings.isNotEmpty ? _rankings.length : _allRanks.length,
                              itemBuilder: (context, index) {
                                if (_selectedTab == 'Skill wise' && _rankings.isNotEmpty) {
                                  final item = _rankings[index];
                                  return _buildRankItem(
                                    item.rank,
                                    item.name,
                                    item.rank == '#1' ? '7376231EI102' : '2024UEC5014', // Mock IDs
                                    item.score.toString(),
                                  );
                                } else {
                                  final item = _allRanks[index];
                                  return _buildRankItem(
                                    item['rank']!,
                                    item['name']!,
                                    index == 0 ? '7376231EI102' : '2024UEC5014', // Mock IDs
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
            // Sticky "You" rank
            _buildYouRank(),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label) {
    bool isSelected = _selectedTab == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4A7FFF) : const Color(0xFFF3F7FF),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade600,
            fontWeight: FontWeight.w600,
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
    String medal = '';
    if (rank == '1') medal = '🥇';
    else if (rank == '2') medal = '🥈';
    else if (rank == '3') medal = '🥉';

    return Expanded(
      child: Stack(
        children: [
          Container(
            height: height,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor, width: 2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const SizedBox(height: 4),
                CircleAvatar(
                  radius: isWinner ? 28 : 24,
                  backgroundColor: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: CircleAvatar(
                      radius: isWinner ? 26 : 22,
                      backgroundColor: const Color(0xFFE5EDFF),
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'S',
                        style: TextStyle(
                          fontSize: isWinner ? 20 : 16,
                          color: const Color(0xFF2E63F2),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Text(
                  name.split(' ')[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF344054),
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: borderColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$points pts',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Icon(
              Icons.emoji_events_rounded,
              color: borderColor,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankItem(String rank, String name, String id, String score) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F7),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                rank,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Color(0xFF667085),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFFE5EDFF),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'S',
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF2E63F2),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF0D2146),
                  ),
                ),
                Text(
                  id,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                score,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: Color(0xFF0D2146),
                ),
              ),
              const Text(
                'points',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildYouRank() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF4A7FFF).withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Text(
              'G',
              style: TextStyle(
                color: Color(0xFF4A7FFF),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'You',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Text(
                  'Current rank outside top 10',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              Text(
                '18',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              Text(
                'points',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
