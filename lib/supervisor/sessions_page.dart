import 'package:flutter/material.dart';
import 'dart:async';
import 'package:gdapp/supervisor/table_monitor_page.dart';
import 'package:gdapp/supervisor/session_qr_page.dart';
import 'package:gdapp/supervisor/supervisor_profile_page.dart';
import 'package:gdapp/services/api_service.dart';
import 'package:gdapp/utils/otp_utils.dart';

class SessionsPage extends StatefulWidget {
  final VoidCallback? onBack;
  const SessionsPage({Key? key, this.onBack}) : super(key: key);

  @override
  State<SessionsPage> createState() => _SessionsPageState();
}

class _SessionsPageState extends State<SessionsPage> {
  String _selectedFilter = 'Active';
  List<dynamic> _sessions = [];
  bool _isLoading = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _fetchSessions();
    // Refresh sessions every minute for real-time OTP updates
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _fetchSessions(showLoader: false);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchSessions({bool showLoader = true}) async {
    if (!mounted) return;
    if (showLoader) {
      setState(() => _isLoading = true);
    }
    try {
      debugPrint('SessionsPage: Fetching hall-qr-tokens...');
      final sessions = await ApiService.getHallQrTokens();
      if (mounted) {
        setState(() {
          _sessions = sessions;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching sessions: $e');
      if (mounted) {
        setState(() {
          _sessions = [];
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch sessions: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _fetchSessions,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        _buildHeader(),
                        
                        const SizedBox(height: 24),
                        
                        // Search Bar
                        _buildSearchBar(),
                        
                        const SizedBox(height: 20),
                        
                        // Stats Cards
                        _buildStatsRow(),
                        
                        const SizedBox(height: 28),
                        
                        // Ongoing Section
                        _buildOngoingSection(),
                        
                        const SizedBox(height: 80), // Space for bottom nav
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: widget.onBack ?? () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
          color: Colors.black,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good Afternoon,',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Supervisor',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SupervisorProfilePage(),
              ),
            );
          },
          child: Stack(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: const DecorationImage(
                    image: NetworkImage('https://i.pravatar.cc/150?img=33'),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFF5F7FA), width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search sessions...',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF4A7FFF)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    int activeCount = _sessions.where((s) => s['is_active'] == true || s['status']?.toString().toUpperCase() == 'ACTIVE').length;
    int totalCount = _sessions.length;
    int pendingCount = totalCount - activeCount;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.show_chart,
            value: '$activeCount',
            label: 'Active',
            color: const Color(0xFF4A7FFF),
            isActive: _selectedFilter == 'Active',
            onTap: () => setState(() => _selectedFilter = 'Active'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.format_list_bulleted,
            value: '$totalCount',
            label: 'Total',
            color: Colors.grey,
            isActive: _selectedFilter == 'Total',
            onTap: () => setState(() => _selectedFilter = 'Total'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.access_time,
            value: '$pendingCount',
            label: 'Pending',
            color: Colors.grey,
            isActive: _selectedFilter == 'Pending',
            onTap: () => setState(() => _selectedFilter = 'Pending'),
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
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF4A7FFF) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: isActive 
                  ? const Color(0xFF4A7FFF).withOpacity(0.3)
                  : Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : color,
              size: 24,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isActive ? Colors.white : Colors.black,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isActive ? Colors.white.withOpacity(0.9) : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOngoingSection() {
    List<dynamic> filteredSessions = _sessions;
    if (_selectedFilter == 'Active') {
      filteredSessions = _sessions.where((s) => s['is_active'] == true || s['status']?.toString().toUpperCase() == 'ACTIVE').toList();
    } else if (_selectedFilter == 'Pending') {
      filteredSessions = _sessions.where((s) => s['is_active'] != true && s['status']?.toString().toUpperCase() != 'ACTIVE').toList();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_selectedFilter} Sessions',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.grey),
              onPressed: _fetchSessions,
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (filteredSessions.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                children: [
                  Icon(Icons.inbox_outlined, size: 48, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'No ${_selectedFilter.toLowerCase()} sessions found',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          )
        else
          ...filteredSessions.map((session) => _buildSessionCard(session)).toList(),
      ],
    );
  }

  void _showQrSheet(dynamic session) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SessionQrPage(session: session),
      ),
    );
  }

  Widget _buildSessionCard(dynamic session) {
    // Handle nested session data (common in hall-qr-tokens API)
    final Map<String, dynamic> sessionData = session is Map ? (session['session'] ?? session['session_config'] ?? session['sessionConfig'] ?? session) : {};
    
    final bool statusIsActive = (sessionData['status']?.toString().toUpperCase() == 'ACTIVE') || 
                               (sessionData['is_active'] == true) ||
                               (session['status']?.toString().toUpperCase() == 'ACTIVE') ||
                               (session['is_active'] == true);
    final bool isActive = statusIsActive;
    
    final String title = sessionData['topic'] ?? 
                        sessionData['session_name'] ?? 
                        sessionData['sessionName'] ?? 
                        sessionData['name'] ?? 
                        sessionData['title'] ?? 
                        sessionData['session_id']?.toString() ??
                        'Unnamed Session';
                        
    final String hall = sessionData['hall'] ?? 
                       sessionData['hall_name'] ?? 
                       sessionData['hallName'] ?? 
                       sessionData['location'] ?? 
                       sessionData['room'] ?? 
                       sessionData['venue'] ??
                       'Unknown Hall';
                       
    final String date = sessionData['date'] ?? 
                       sessionData['session_date'] ?? 
                       sessionData['sessionDate'] ?? 
                       '';
                       
    final String time = sessionData['time'] ?? 
                       sessionData['start_time'] ?? 
                       sessionData['startTime'] ?? 
                       '';
    
    final String token = session['token'] ?? 
                        sessionData['token'] ?? 
                        session['qr_token'] ?? 
                        sessionData['qr_token'] ?? 
                        session['hall_qr_token'] ?? 
                        sessionData['hall_qr_token'] ?? 
                        'Loading...';
    
    final String? apiOtp = session['current_otp']?.toString() ?? 
                          sessionData['current_otp']?.toString() ??
                          session['otp']?.toString() ??
                          sessionData['otp']?.toString();
    
    final String displayOtp = apiOtp ?? OTPUtils.generateOTP(token);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? const Color(0xFF4A7FFF).withOpacity(0.2) : Colors.grey.withOpacity(0.1),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A7FFF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.location_on, size: 16, color: Color(0xFF4A7FFF)),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hall,
                    style: const TextStyle(
                      fontSize: 14, 
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    isActive ? 'Monitor Active Session' : 'Scheduled Session',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF00D9A5).withOpacity(0.15) : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isActive ? 'LIVE NOW' : 'PENDING',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isActive ? const Color(0xFF00D9A5) : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              letterSpacing: -0.5,
            ),
          ),
          if (date.isNotEmpty || time.isNotEmpty) ...[
             const SizedBox(height: 6),
             Row(
               children: [
                 Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey[500]),
                 const SizedBox(width: 4),
                 Text(
                    '${date.split('T')[0]} • $time',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                 ),
               ],
             ),
          ],
          
          const SizedBox(height: 20),
          // Stylized Token & OTP Display
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withOpacity(0.1)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'HALL ACCESS TOKEN',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          token,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A7FFF),
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SESSION OTP',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          displayOtp,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A7FFF),
                            letterSpacing: 4,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Icon(Icons.security, size: 24, color: Colors.green),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TableMonitorPage(session: session),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A7FFF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Monitor Tables', 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _showQrSheet(session),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
