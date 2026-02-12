import 'package:flutter/material.dart';

class GrowthPage extends StatefulWidget {
  final Function(int) onNavigate;
  const GrowthPage({Key? key, required this.onNavigate}) : super(key: key);

  @override
  State<GrowthPage> createState() => _GrowthPageState();
}

class _GrowthPageState extends State<GrowthPage> {
  String _selectedTab = 'Overall';

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Active participation',
          style: TextStyle(
            color: Color(0xFF0D2146),
            fontWeight: FontWeight.bold,
            fontSize: 24,
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
                  const SizedBox(width: 8),
                  _buildTab('Top 3'),
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
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    // Top Performers Podium
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildRankPodium(
                            name: _selectedTab == 'Department' ? 'Rahul K' : 'Indhuja V',
                            rank: '2',
                            points: _selectedTab == 'Department' ? '45 pts' : '25 pts',
                            height: 140,
                            isWinner: false,
                          ),
                          _buildRankPodium(
                            name: _selectedTab == 'Department' ? 'Priya D' : 'Adhish S',
                            rank: '1',
                            points: _selectedTab == 'Department' ? '88 pts' : '62 pts',
                            height: 180,
                            isWinner: true,
                          ),
                          _buildRankPodium(
                            name: _selectedTab == 'Department' ? 'Sowmiya R' : 'Govarthini G',
                            rank: '3',
                            points: _selectedTab == 'Department' ? '32 pts' : '23 pts',
                            height: 130,
                            isWinner: false,
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    // List
                    Expanded(
                      child: ListView.builder(
                        itemCount: _allRanks.length,
                        itemBuilder: (context, index) {
                          final item = _allRanks[index];
                          return _buildRankItem(
                            item['rank']!,
                            item['name']!,
                            item['team']!,
                            item['score']!,
                          );
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
    required bool isWinner,
  }) {
    return Column(
      children: [
        Container(
          width: 90,
          height: height,
          decoration: BoxDecoration(
            color: isWinner ? const Color(0xFFE8EFFF) : const Color(0xFFF5F8FF),
            borderRadius: BorderRadius.circular(12),
            border: isWinner ? Border.all(color: const Color(0xFF4A7FFF), width: 1.5) : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                rank,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isWinner ? const Color(0xFF4A7FFF) : Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D2146),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A7FFF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  points,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRankItem(String rank, String name, String team, String score) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey.shade100,
            child: Text(
              rank,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
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
                  team,
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
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF0D2146),
                ),
              ),
              const Text(
                'points',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
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
              color: Colors.blueAccent,
              shape: BoxShape.circle,
            ),
            child: const Text(
              '23',
              style: TextStyle(
                color: Colors.white,
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
