import 'package:flutter/material.dart';
import 'package:gdapp/student/widgets/custom_navigation_bar.dart';
import 'package:gdapp/student/growth_page.dart';
import 'package:gdapp/student/activities_page.dart';
import 'package:gdapp/student/schedule_page.dart';
import 'package:gdapp/student/profile_page.dart';
import 'package:gdapp/student/scan_hall_qr_page.dart';
import 'package:gdapp/models/student_activity.dart';
import 'package:gdapp/services/api_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  void _onNavigate(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _HomeContent(onNavigate: _onNavigate),
      SchedulePage(onNavigate: _onNavigate),
      GrowthPage(onNavigate: _onNavigate),
      ProfilePage(onNavigate: _onNavigate),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: pages,
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(
        selectedIndex: _selectedIndex,
        onIndexChanged: _onNavigate,
      ),
    );
  }
}

class _HomeContent extends StatefulWidget {
  final Function(int) onNavigate;
  const _HomeContent({Key? key, required this.onNavigate}) : super(key: key);

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  late Future<List<StudentActivity>> _activitiesFuture;

  @override
  void initState() {
    super.initState();
    _activitiesFuture = ApiService.getStudentActivities();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          _buildProfileHeader(context),
          const SizedBox(height: 24),

          // Top Contributor Card
          _buildContributorCard(),
          const SizedBox(height: 24),

          // Today's Session
          _buildTodaySession(context),
          const SizedBox(height: 24),

          // Group Activities
          _buildGroupActivities(context),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: Colors.grey[300],
          child: Icon(Icons.person, size: 32, color: Colors.grey[600]),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hello, Priya',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Level 4 Scholar',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const Spacer(),
        Icon(Icons.notifications, color: Colors.grey[600]),
      ],
    );
  }

  Widget _buildContributorCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF4A7FFF),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.star, color: Colors.white, size: 16),
                SizedBox(width: 6),
                Text(
                  'Top Contributor',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '1,240 XP',
            style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Next Milestone: Team Lead Access',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: const LinearProgressIndicator(
              value: 0.65,
              minHeight: 8,
              backgroundColor: Colors.white12,
              valueColor: AlwaysStoppedAnimation(Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatBox('+150 Credits', Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatBox('-20 Penalties', Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String text, Color textColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildTodaySession(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Today\'s Session',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Starts in 15m',
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ScanHallQRPage()),
                  );
                },
                child: _buildSessionCard(
                  icon: Icons.qr_code,
                  title: 'Scan Hall QR',
                  subtitle: 'Join Random Team',
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ActivitiesPage()),
                  );
                },
                child: _buildSessionCard(
                  icon: Icons.assignment_turned_in,
                  title: 'Activities',
                  subtitle: 'Discussions & Tasks',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSessionCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBBDEFB)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(icon, size: 32, color: Colors.blue),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupActivities(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Group Activities',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ActivitiesPage()),
                );
              },
              child: const Text(
                'View All',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        FutureBuilder<List<StudentActivity>>(
          future: _activitiesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ));
            } else if (snapshot.hasError) {
              return Text('Error loading activities',
                  style: TextStyle(color: Colors.red[300], fontSize: 12));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('No recent activities');
            }

            final activities = snapshot.data!.take(2).toList();
            return Column(
              children: activities.map((activity) {
                Color labelColor;
                switch (activity.status.toUpperCase()) {
                  case 'COMPLETED':
                    labelColor = Colors.green;
                    break;
                  case 'IN_PROGRESS':
                  case 'ACTIVE':
                    labelColor = Colors.blue;
                    break;
                  default:
                    labelColor = Colors.orange;
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _buildActivityItem(
                    title: activity.title,
                    subtitle: activity.subtitle,
                    label: activity.status,
                    labelColor: labelColor,
                    credits: activity.credits,
                    creditsColor: labelColor,
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActivityItem({
    required String title,
    required String subtitle,
    required String label,
    required Color labelColor,
    required String credits,
    required Color creditsColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(8),
            child: Icon(
              title.contains('Discussion') ? Icons.forum : Icons.slideshow,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: labelColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: labelColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                credits,
                style: TextStyle(
                  fontSize: 12,
                  color: creditsColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
