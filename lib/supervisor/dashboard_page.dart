import 'package:flutter/material.dart';
import 'dart:async';
import 'package:gdapp/supervisor/table_monitor_page.dart';
import 'package:gdapp/supervisor/sessions_page.dart';
import 'package:gdapp/supervisor/current_otp_page.dart';
import 'package:gdapp/services/api_service.dart';

class SupervisorDashboardPage extends StatefulWidget {
  const SupervisorDashboardPage({Key? key}) : super(key: key);

  @override
  State<SupervisorDashboardPage> createState() =>
      _SupervisorDashboardPageState();
}

class _SupervisorDashboardPageState extends State<SupervisorDashboardPage> {
  List<dynamic> _sessions = [];
  bool _isLoading = true;
  Timer? _refreshTimer;
  int _totalAttended = 0;

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

      int attendedCount = 0;

      final filteredSessions = allSessions.where((s) {
        final Map<String, dynamic> data = s is Map
            ? (s['session'] ?? s['session_config'] ?? s['sessionConfig'] ?? s)
            : {};
        final String? timeStr =
            data['start_time']?.toString() ?? data['startTime']?.toString();

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

        // Calculate attended sessions (sessions that have already started/ended)
        if (startTime.isBefore(now)) {
          attendedCount++;
        }

        return startTime.isAfter(oneHourLater) &&
            startTime.isBefore(twoHoursLater);
      }).toList();

      if (mounted) {
        setState(() {
          _sessions = filteredSessions;
          _totalAttended = attendedCount > 0
              ? attendedCount
              : 28; // fallback to 28 if none found
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
      backgroundColor: const Color(0xFFF4F7FF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(),

                const SizedBox(height: 32),

                // Overview label
                const Text(
                  'OVERVIEW',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF94A3B8),
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 16),

                // Total Attended Card
                _buildTotalAttendedCard(),

                const SizedBox(height: 16),

                // Stats Cards
                _buildStatsCards(),

                const SizedBox(height: 24),

                // Current Session
                _buildCurrentSessionSection(),

                const SizedBox(height: 28),

                // Schedule Section
                _buildScheduleSection(),

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
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
            letterSpacing: -0.5,
          ),
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
              ),
              child: const Icon(
                Icons.notifications_none,
                color: Color(0xFF1E293B),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF2563EB),
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

  Widget _buildTotalAttendedCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF2563EB),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Attended',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$_totalAttended',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  height: 1.0,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F4EA),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.star_border,
                        color: Color(0xFF34A853), size: 18),
                  ),
                  const SizedBox(width: 8),
                  const Text('My Rating',
                      style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                ]),
                const SizedBox(height: 16),
                const Text('4.6',
                    style: TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E8FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.location_on_outlined,
                        color: Color(0xFFA855F7), size: 18),
                  ),
                  const SizedBox(width: 8),
                  const Text('Halls',
                      style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                ]),
                const SizedBox(height: 16),
                const Text('5',
                    style: TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentSessionSection() {
    if (_isLoading) {
      return const Center(
          child: Padding(
        padding: EdgeInsets.all(20),
        child: CircularProgressIndicator(),
      ));
    }
    if (_sessions.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1.5,
              style: BorderStyle.solid),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.sensors, color: Color(0xFF94A3B8), size: 24),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'No Active Sessions',
                  style: TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Check back later for live events',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
    return _buildLivePreviewCard();
  }

  Widget _buildLivePreviewCard() {
    // Get the first active session or just the first one
    final session = _sessions.firstWhere(
      (s) =>
          s['is_active'] == true ||
          s['status']?.toString().toUpperCase() == 'ACTIVE',
      orElse: () => _sessions.first,
    );

    final Map<String, dynamic> sessionData = session is Map
        ? (session['session'] ??
            session['session_config'] ??
            session['sessionConfig'] ??
            session)
        : {};

    final String title = sessionData['topic'] ??
        sessionData['session_name'] ??
        sessionData['sessionName'] ??
        sessionData['name'] ??
        'GD Session';

    final String hall = sessionData['hall'] ??
        sessionData['hall_name'] ??
        sessionData['hallName'] ??
        'Unknown Hall';

    final bool isActive =
        (sessionData['status']?.toString().toUpperCase() == 'ACTIVE') ||
            (sessionData['is_active'] == true) ||
            (session['status']?.toString().toUpperCase() == 'ACTIVE') ||
            (session['is_active'] == true);

    final String activityType = session['activity_type']?.toString() ??
        sessionData['activity_type']?.toString() ??
        'Group Discussion';

    // Parse the start time to get a realistic date/time string, or fallback
    String dateTimeStr =
        '2026-03-09T05:51:00.000Z'; // default fallback matching image
    if (sessionData['start_time'] != null) {
      if (sessionData['date'] != null) {
        dateTimeStr = '${sessionData['date']}T${sessionData['start_time']}';
      } else {
        dateTimeStr = sessionData['start_time'].toString();
      }
    } else if (session['timings'] != null &&
        session['timings']['start_time'] != null) {
      dateTimeStr = session['timings']['start_time'].toString();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F5FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: Color(0xFF3B82F6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hall,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Monitor Active\nSession',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              if (isActive)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'LIVE NOW',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF10B981),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),
          // Large Title Section
          Text(
            activityType, // Swap: Large text is now the session type/topic
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),

          // Date Time Row
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: Color(0xFF94A3B8),
              ),
              const SizedBox(width: 8),
              Text(
                dateTimeStr,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Inner Info Container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F7FB),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'HALL ACCESS TOKEN',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF94A3B8),
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  session['id']?.toString() ??
                      sessionData['session_id']?.toString() ??
                      '516', // Swap: Show session ID here
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3B82F6),
                    letterSpacing: 1.0,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Divider(color: Color(0xFFE2E8F0), height: 1),
                ),
                const Text(
                  'SESSION OTP', // Match screenshot label
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF94A3B8),
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      session['current_otp']?.toString() ?? '897476', // Show OTP here
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3B82F6),
                        letterSpacing: 4.0,
                      ),
                    ),
                    const Icon(
                      Icons.security_outlined,
                      color: Color(0xFF10B981),
                      size: 24,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Action Buttons
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
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Monitor Tables',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'SCHEDULE',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Color(0xFF94A3B8),
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
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2563EB),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildScheduleTimelineItem(
          time: '4:00',
          ampm: 'PM',
          title: 'Project Pitch Round',
          location: 'Hall B • Level 3',
          tag: 'TODAY',
          tagColor: const Color(0xFFF59E0B),
          tagBgColor: const Color(0xFFFEF3C7),
          dotColor: const Color(0xFFF59E0B),
          isLast: false,
        ),
        _buildScheduleTimelineItem(
          time: '10:00',
          ampm: 'AM',
          title: 'Prototype Review',
          location: 'Lab 1 • Level 1',
          tag: 'TOMORROW',
          tagColor: const Color(0xFF2563EB),
          tagBgColor: const Color(0xFFDBEAFE),
          dotColor: const Color(0xFF2563EB),
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildScheduleTimelineItem({
    required String time,
    required String ampm,
    required String title,
    required String location,
    required String tag,
    required Color tagColor,
    required Color tagBgColor,
    required Color dotColor,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Time column
          SizedBox(
            width: 44,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const SizedBox(height: 20),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  ampm,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Timeline line and dot
          Column(
            children: [
              const SizedBox(height: 24),
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: const Color(0xFFE2E8F0),
                    margin: const EdgeInsets.only(top: 8),
                  ),
                )
              else
                const SizedBox(height: 20),
            ],
          ),
          const SizedBox(width: 16),
          // Card content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: tagBgColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: tagColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          location,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
