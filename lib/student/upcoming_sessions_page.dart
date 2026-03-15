import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
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

  void _loadSessions() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final sessions = await ApiService.getBookedSlots();
      debugPrint('Loaded ${sessions.length} sessions for Upcoming Page');
      if (mounted) {
        setState(() {
          _bookedSessions = sessions;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading sessions in UI: $e');
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
                  const Text(
                    'Upcoming',
                    style: TextStyle(
                      color: Color(0xFF0D2146),
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _bookedSessions.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.event_busy_rounded,
                                  size: 64,
                                  color: const Color(0xFF0D2146).withOpacity(0.2)),
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
                                  fontSize: 13,
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
          ),
        ],
      ),
      child: ClipRRect(
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
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
                          ),
                        ),
                      ),
                    ],
                  ),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star_border_rounded,
                              size: 24, color: Color(0xFF3B82F6)),
                          const SizedBox(width: 10),
                          Text(
                            'Target: Level ${session['targetLevel'] ?? '1'}',
                            style: const TextStyle(
                              color: Color(0xFF3B82F6),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
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
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
}
