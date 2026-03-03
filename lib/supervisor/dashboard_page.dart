import 'package:flutter/material.dart';
import 'dart:async';
import 'package:gdapp/supervisor/table_monitor_page.dart';
import 'package:gdapp/supervisor/sessions_page.dart';
import 'package:gdapp/supervisor/current_otp_page.dart';
import 'package:gdapp/services/api_service.dart';

class SupervisorDashboardPage extends StatefulWidget {
  const SupervisorDashboardPage({Key? key}) : super(key: key);

  @override
  State<SupervisorDashboardPage> createState() => _SupervisorDashboardPageState();
}

class _SupervisorDashboardPageState extends State<SupervisorDashboardPage> {
  List<dynamic> _sessions = [];
  bool _isLoading = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _fetchSessions();
    // Refresh sessions every minute to keep OTP and status updated
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _fetchSessions();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchSessions() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final List<dynamic> allSessions = await ApiService.getHallQrTokens();
      
      final now = DateTime.now();
      final oneHourLater = now.add(const Duration(hours: 1));
      final twoHoursLater = now.add(const Duration(hours: 2));

      final filteredSessions = allSessions.where((s) {
        final Map<String, dynamic> data = s is Map ? (s['session'] ?? s['session_config'] ?? s['sessionConfig'] ?? s) : {};
        final String? timeStr = data['start_time']?.toString() ?? data['startTime']?.toString();
        
        if (timeStr == null || timeStr.isEmpty) return false;

        DateTime? startTime;
        // Try parsing as ISO
        startTime = DateTime.tryParse(timeStr);
        
        // If it's just "HH:mm" or "HH:mm:ss", try to combine with today's date
        if (startTime == null && timeStr.contains(':')) {
           try {
             final parts = timeStr.split(':');
             final hour = int.parse(parts[0]);
             final minute = int.parse(parts[1]);
             startTime = DateTime(now.year, now.month, now.day, hour, minute);
             
             // If the parsed time is already past today, it might be for tomorrow, or just an old entry.
             // But for "coming in 1-2 hours", we'll assume today.
           } catch (_) {}
        }

        if (startTime == null) return false;

        return startTime.isAfter(oneHourLater) && startTime.isBefore(twoHoursLater);
      }).toList();

      if (mounted) {
        setState(() {
          _sessions = filteredSessions;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching sessions on dashboard: $e');
      if (mounted) {
        setState(() {
          _sessions = [];
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(),
                
                const SizedBox(height: 24),
                
                // Stats Cards
                _buildStatsCards(),
                
                const SizedBox(height: 28),
                
                // Current Session
                _buildCurrentSessionSection(),
                
                const SizedBox(height: 28),
                
                // Up Next Section
                _buildUpNextSection(),
                
                const SizedBox(height: 80), // Add space for bottom nav
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Dashboard',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D2146),
            letterSpacing: -0.5,
          ),
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.notifications_outlined,
                color: Colors.black,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF6B4CE6), Color(0xFF9B7EF5)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6B4CE6).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'S',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.star_outline,
            value: '4.6',
            label: 'My Rating',
            color: const Color(0xFF34C759),
            bgColor: const Color(0xFFE8F5E9),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.calendar_today_outlined,
            value: '28',
            label: 'Attended',
            color: const Color(0xFF4A7FFF),
            bgColor: const Color(0xFFE3F2FD),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.location_on_outlined,
            value: '5',
            label: 'Halls',
            color: const Color(0xFF4A7FFF),
            bgColor: const Color(0xFFE8EAF6),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: const Color(0xFF0D2146).withOpacity(0.6),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentSessionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
        const Text(
          'ACTIVE SESSIONS',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Color(0xFF667085),
            letterSpacing: 1.2,
          ),
        ),
          ],
        ),
        const SizedBox(height: 8),
        
        if (_isLoading)
          const Center(child: Padding(
            padding: EdgeInsets.all(20),
            child: CircularProgressIndicator(),
          ))
        else if (_sessions.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.withOpacity(0.1)),
            ),
            child: Column(
              children: [
                Icon(Icons.event_busy, color: Colors.grey[300], size: 40),
                const SizedBox(height: 12),
                Text(
                  'No event live',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          )
        else
          _buildLivePreviewCard(),
      ],
    );
  }

  Widget _buildLivePreviewCard() {
    // Get the first active session or just the first one
    final session = _sessions.firstWhere(
      (s) => s['is_active'] == true || s['status']?.toString().toUpperCase() == 'ACTIVE',
      orElse: () => _sessions.first,
    );

    final Map<String, dynamic> sessionData = session is Map ? (session['session'] ?? session['session_config'] ?? session['sessionConfig'] ?? session) : {};
    
    final String title = sessionData['topic'] ?? 
                        sessionData['session_name'] ?? 
                        sessionData['sessionName'] ?? 
                        sessionData['name'] ?? 
                        'GD Session';
                        
    final String hall = sessionData['hall'] ?? 
                       sessionData['hall_name'] ?? 
                       sessionData['hallName'] ?? 
                       'Main Hall';
                       
    final bool isActive = (sessionData['status']?.toString().toUpperCase() == 'ACTIVE') || 
                          (sessionData['is_active'] == true) ||
                          (session['status']?.toString().toUpperCase() == 'ACTIVE') ||
                          (session['is_active'] == true);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4A7FFF),
            Color(0xFF5B8FFF),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A7FFF).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      sessionData['targetLevel']?.toString() ?? sessionData['target_level']?.toString() ?? 'GD Level 2',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.bolt,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
          if (isActive) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.circle,
                    color: Colors.white,
                    size: 8,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'LIVE NOW',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'LOCATION',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white60,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hall,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TableMonitorPage(
                              session: session,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF4A7FFF),
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Enter Session',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Current OTP Display
                  if (isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'JOIN OTP',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            session['current_otp']?.toString() ?? '...',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CurrentOtpPage(),
                        ),
                      );
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.qr_code, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpNextSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'UP NEXT',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFF667085),
                letterSpacing: 1.2,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SessionsPage()),
                ).then((_) => _fetchSessions());
              },
              child: const Text(
                'View All',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A7FFF),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildUpNextCard(
          time: '4PM',
          title: 'Project Pitch Round',
          location: 'Hall B',
          level: 'Level 3',
          tag: 'Today',
          tagColor: Colors.orange,
        ),
        const SizedBox(height: 12),
        _buildUpNextCard(
          time: '10AM',
          title: 'Prototype Review',
          location: 'Lab 1',
          level: 'Level 1',
          tag: 'Tmrw',
          tagColor: const Color(0xFF4A7FFF),
        ),
      ],
    );
  }

  Widget _buildUpNextCard({
    required String time,
    required String title,
    required String location,
    required String level,
    required String tag,
    required Color tagColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              time,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D2146),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D2146),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$location • $level',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: tagColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              tag,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: tagColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
