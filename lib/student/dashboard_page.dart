import 'package:flutter/material.dart';
import 'package:gdapp/student/widgets/custom_navigation_bar.dart';
import 'package:gdapp/student/growth_page.dart';
import 'package:gdapp/student/activities_page.dart';
import 'package:gdapp/student/schedule_page.dart';
import 'package:gdapp/student/profile_page.dart';
import 'package:gdapp/student/upcoming_sessions_page.dart';
import 'package:gdapp/student/verification_page.dart';
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
      _HomeContent(onNavigate: (idx, {showScanner}) => _onNavigate(idx)),
      GrowthPage(onNavigate: (idx, {showScanner}) => _onNavigate(idx)),
      SchedulePage(onNavigate: (idx, {showScanner}) => _onNavigate(idx)),
      ProfilePage(onNavigate: (idx, {showScanner}) => _onNavigate(idx)),
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
        onIndexChanged: (idx) => _onNavigate(idx),
      ),
    );
  }
}

class _HomeContent extends StatefulWidget {
  final Function(int, {bool? showScanner}) onNavigate;
  const _HomeContent({Key? key, required this.onNavigate}) : super(key: key);

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> {
  late Future<List<StudentActivity>> _activitiesFuture;
  late Future<Map<String, dynamic>> _profileFuture;

  @override
  void initState() {
    super.initState();
    _activitiesFuture = ApiService.getStudentActivities();
    _profileFuture = ApiService.getUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(context),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Your Performance',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1C1E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatusGrid(),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Join Window',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1C1E),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const UpcomingSessionsPage()),
                  );
                },
                child: const Text(
                  'View All',
                  style: TextStyle(
                    color: Color(0xFF2E63F2),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildJoinWindowSection(),
          const SizedBox(height: 32),
          const Text(
            'Recent Updates',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1C1E),
            ),
          ),
          const SizedBox(height: 16),
          _buildUpdatesCard(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _profileFuture,
      builder: (context, snapshot) {
        final profile = snapshot.data;
        final user = profile?['user'] ?? profile;
        final name = user?['name']?.toString() ?? 'Student';
        final initial = name.isNotEmpty ? name[0].toUpperCase() : 'S';

        return Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: const Color(0xFFE5EDFF),
              child: Text(
                initial,
                style: const TextStyle(
                  color: Color(0xFF2E63F2),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1C1E),
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            const Spacer(),
          ],
        );
      },
    );
  }

  Widget _buildStatBadge({
    required IconData icon,
    required String value,
    required Color iconColor,
    required Color bgColor,
    Color textColor = const Color(0xFF1A1C1E),
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(100),
        border: bgColor == Colors.white ? Border.all(color: Colors.grey[200]!) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJoinWindowSection() {
    return FutureBuilder<List<StudentActivity>>(
      future: _activitiesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        // Use the first activity as the "active" one for the join window
        final activeActivity = snapshot.hasData && snapshot.data!.isNotEmpty 
            ? snapshot.data!.first 
            : null;

        if (activeActivity != null) {
          return _buildDetailedJoinCard(activeActivity);
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: const Center(
            child: Text(
              'No active sessions found',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailedJoinCard(StudentActivity? activity) {
    if (activity == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE5EDFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2E63F2).withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E63F2).withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E63F2).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.circle, size: 8, color: Color(0xFF4ADE80)),
                      SizedBox(width: 8),
                      Text(
                        'Window Open',
                        style: TextStyle(
                          color: Color(0xFF2E63F2),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  activity.category,
                  style: const TextStyle(
                    color: Color(0xFF2E63F2),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              activity.title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1C1E),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              activity.subtitle,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF4B5563),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => widget.onNavigate(2),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E63F2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.qr_code_scanner_rounded, size: 20),
                        SizedBox(width: 10),
                        Text(
                          'Scan QR',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => widget.onNavigate(2, showScanner: false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFF2E63F2)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.keyboard_alt_outlined, color: Color(0xFF2E63F2), size: 20),
                        SizedBox(width: 10),
                        Text(
                          'Enter OTP',
                          style: TextStyle(
                            color: Color(0xFF2E63F2),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLightJoinCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE5EDFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2E63F2).withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2E63F2).withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.access_time_filled_rounded, color: Color(0xFF2E63F2), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Join window open',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1C1E),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '02:14 left to scan QR or use OTP and join your table.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4B5563),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _buildGridItem(
          'Level Rank',
          '12 / 86',
          'Current level',
          icon: Icons.emoji_events_outlined,
          iconColor: Colors.orange,
        ),
        _buildGridItem(
          'Last Score',
          '0.73',
          'Promoted',
          icon: Icons.track_changes_rounded,
          iconColor: Colors.teal,
          isPromoted: true,
        ),
        _buildGridItem(
          'Next Goal',
          'Level 3',
          '2 sessions left',
          icon: Icons.outlined_flag_rounded,
          iconColor: Colors.blue,
        ),
        _buildGridItem(
          'Last Result',
          'Rank 2',
          'Out of 8 in table',
          icon: Icons.bar_chart_rounded,
          iconColor: Colors.deepPurple,
        ),
      ],
    );
  }

  Widget _buildGridItem(
    String label,
    String value,
    String subtext, {
    required IconData icon,
    required Color iconColor,
    bool isPromoted = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2E63F2),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E63F2).withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: Colors.white),
              ),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              if (isPromoted) ...[
                const Text('🎉 ', style: TextStyle(fontSize: 12)),
              ],
              Text(
                subtext,
                style: TextStyle(
                  color: isPromoted ? const Color(0xFF4ADE80) : Colors.white.withOpacity(0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpdatesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE5EDFF),
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Icon(Icons.notifications_none_rounded, color: Color(0xFF2E63F2), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Today\'s Summary',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1C1E),
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Session not started yet. Join early to secure your table and rank.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFBCC1CD),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
