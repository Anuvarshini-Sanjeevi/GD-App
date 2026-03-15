import 'package:flutter/material.dart';
import 'dart:async';
<<<<<<< HEAD
import 'package:intl/intl.dart';
=======
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
import 'package:gdapp/services/api_service.dart';
import 'package:gdapp/student/verification_page.dart';
import 'package:gdapp/student/team_allocation_page.dart';

class UpcomingSessionsPage extends StatefulWidget {
  const UpcomingSessionsPage({super.key});

  @override
  State<UpcomingSessionsPage> createState() => _UpcomingSessionsPageState();
}

class _UpcomingSessionsPageState extends State<UpcomingSessionsPage> {
  List<Map<String, dynamic>> _bookedSessions = [];
  bool _isLoading = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadSessions();
    // Refresh every minute to update statuses
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _loadSessions();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

<<<<<<< HEAD
  void _loadSessions() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final sessions = await ApiService.getBookedSlots();
      debugPrint('Loaded ${sessions.length} sessions for Upcoming Page');
=======
  void _loadSessions() {
    try {
      final sessions = ApiService.getBookedSlots();
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
      if (mounted) {
        setState(() {
          _bookedSessions = sessions;
          _isLoading = false;
        });
      }
    } catch (e) {
<<<<<<< HEAD
      debugPrint('Error loading sessions in UI: $e');
=======
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom Header
            Padding(
<<<<<<< HEAD
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF0D2146)),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
=======
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF0D2146)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
                  const Text(
                    'Upcoming',
                    style: TextStyle(
                      color: Color(0xFF0D2146),
<<<<<<< HEAD
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      letterSpacing: -0.2,
=======
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      letterSpacing: -0.5,
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
                    ),
                  ),
                ],
              ),
            ),
<<<<<<< HEAD

=======
            
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _bookedSessions.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
<<<<<<< HEAD
                              Icon(Icons.event_busy_rounded,
                                  size: 64,
                                  color: const Color(0xFF0D2146).withOpacity(0.2)),
=======
                              Icon(Icons.event_busy_rounded, size: 64, color: const Color(0xFF0D2146).withOpacity(0.2)),
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
                              const SizedBox(height: 16),
                              const Text(
                                'No Booked Sessions',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFF0D2146),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Sessions you book will appear here.',
                                style: TextStyle(
<<<<<<< HEAD
                                  fontSize: 13,
=======
                                  fontSize: 14,
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          itemCount: _bookedSessions.length,
                          itemBuilder: (context, index) {
                            return _buildSessionCard(_bookedSessions[index]);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionCard(Map<String, dynamic> session) {
<<<<<<< HEAD
    final String status = session['status'] ?? 'UPCOMING';
    final Color accentColor = _getAccentColor(session['activityType'], status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 14,
            offset: const Offset(0, 4),
=======
    final bool isActive = session['status'] == 'ACTIVE';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF2E63F2).withOpacity(0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E63F2).withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 6),
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
          ),
        ],
      ),
      child: ClipRRect(
<<<<<<< HEAD
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Left accent bar
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(width: 5, color: accentColor),
            ),
            // Card content
            Padding(
              padding: const EdgeInsets.fromLTRB(19, 14, 14, 14), // Increased left padding to clear accent bar
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Category chip + Status chip
=======
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
<<<<<<< HEAD
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5F0FF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _labelForActivityType(
                              session['activityType'] ?? 'SESSION'),
                          style: const TextStyle(
                            color: Color(0xFF2E63F2),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: _getStatusBgColor(status),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: _getStatusTextColor(status),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
=======
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5EDFF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_today_rounded, size: 14, color: Color(0xFF2E63F2)),
                            const SizedBox(width: 6),
                            Text(
                              session['displayDate'] ?? '',
                              style: const TextStyle(
                                color: Color(0xFF2E63F2),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(session['status']).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          session['status'],
                          style: TextStyle(
                            color: _getStatusColor(session['status']),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
                          ),
                        ),
                      ),
                    ],
                  ),
<<<<<<< HEAD
                  const SizedBox(height: 12),
                  // Title
                  Text(
                    session['title'] ?? 'Session',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E3A8A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Date / Time row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.calendar_today_outlined,
                            size: 18, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        '${session['displayDate'] ?? ''} • ${session['time'] ?? ''}',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Location row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.location_on_outlined,
                            size: 18, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          session['hall'] ?? 'Main Hall',
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Dashed divider
                  _buildDashedDivider(),
                  const SizedBox(height: 14),
                  // Bottom row: Target level + QR button
=======
                  const SizedBox(height: 20),
                  Text(
                    session['title'] ?? '',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D2146),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.access_time_filled_rounded, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        session['time'] ?? '',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      // Location (hall) removed as requested
                    ],
                  ),
                  const SizedBox(height: 16),
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
<<<<<<< HEAD
                          const Icon(Icons.star_border_rounded,
                              size: 24, color: Color(0xFF3B82F6)),
                          const SizedBox(width: 10),
                          Text(
                            'Target: Level ${session['targetLevel'] ?? '1'}',
                            style: const TextStyle(
                              color: Color(0xFF3B82F6),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
=======
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E63F2).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.stars_rounded, size: 18, color: Color(0xFF2E63F2)),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Target: Level ${session['targetLevel'] ?? "1"}',
                            style: const TextStyle(
                              color: Color(0xFF2E63F2),
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
                            ),
                          ),
                        ],
                      ),
<<<<<<< HEAD
                      GestureDetector(
                        onTap: () async {
                          final success = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VerificationPage(
                                showScannerFirst: true,
                                bookedSessionTitle: session['title'] ?? '',
                                initialOtp: session['otp']?.toString(),
                                activityType:
                                    session['activityType']?.toString(),
                              ),
                            ),
                          );
                          if (success == true && mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const TeamAllocationPage()),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.qr_code_2_rounded,
                            color: Color(0xFF2E63F2),
                            size: 28,
                          ),
                        ),
                      ),
=======
                      // QR Icon - always shown for booked sessions
                      GestureDetector(
                          onTap: () async {
                            final success = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VerificationPage(
                                  showScannerFirst: true,
                                  bookedSessionTitle: session['title'] ?? '',
                                ),
                              ),
                            );
                            
                            if (success == true && mounted) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const TeamAllocationPage()),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2E63F2),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF2E63F2).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.qr_code_scanner_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
                    ],
                  ),
                ],
              ),
            ),
<<<<<<< HEAD
=======
            if (session['warning'] != null && (session['warning'] as String).isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                color: const Color(0xFFFFF7E6),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 20, color: Color(0xFFD48806)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        session['warning'],
                        style: const TextStyle(
                          color: Color(0xFFD48806),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
          ],
        ),
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildDashedDivider() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const double dashW = 6;
        const double gap = 4;
        final int count =
            (constraints.constrainWidth() / (dashW + gap)).floor();
        return Row(
          children: List.generate(count, (_) {
            return Padding(
              padding: const EdgeInsets.only(right: gap),
              child: SizedBox(
                width: dashW,
                height: 1.5,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: Colors.grey.shade300),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Color _getAccentColor(String? activityType, String status) {
    if (status == 'ACTIVE') return const Color(0xFF22C55E);
    switch ((activityType ?? '').toUpperCase()) {
      case 'TECHNICAL_EVENTS':
      case 'TECHNICAL':
        return const Color(0xFF22C55E);
      case 'DISCUSSION':
      case 'GROUP_DISCUSSION':
        return const Color(0xFF2E63F2);
      case 'PRESENTATION':
        return const Color(0xFF8A59FF);
      case 'INTERVIEW':
        return const Color(0xFFFF6B35);
      default:
        return const Color(0xFF2E63F2);
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return const Color(0xFFF0FDF4);
      case 'UPCOMING':
        return const Color(0xFFF5F3FF);
      case 'COMPLETED':
        return Colors.grey.shade100;
      default:
        return const Color(0xFFF5F3FF);
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return const Color(0xFF16A34A);
      case 'UPCOMING':
        return const Color(0xFF8B5CF6);
      case 'COMPLETED':
        return Colors.grey.shade600;
      default:
        return const Color(0xFF8B5CF6);
    }
  }

  String _labelForActivityType(String? activityType) {
    if (activityType == null || activityType.isEmpty) return 'SESSION';
    return activityType.replaceAll('_', ' ').toUpperCase();
  }
=======
  Color _getStatusColor(String status) {
    switch (status) {
      case 'ACTIVE':
        return const Color(0xFF00D9A5);
      case 'UPCOMING':
        return const Color(0xFF8A59FF);
      default:
        return Colors.grey;
    }
  }
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
}
