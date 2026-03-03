import 'package:flutter/material.dart';
import 'dart:async';
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

  void _loadSessions() {
    try {
      final sessions = ApiService.getBookedSlots();
      if (mounted) {
        setState(() {
          _bookedSessions = sessions;
          _isLoading = false;
        });
      }
    } catch (e) {
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
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF0D2146)),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Upcoming',
                    style: TextStyle(
                      color: Color(0xFF0D2146),
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      letterSpacing: -0.5,
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
                              Icon(Icons.event_busy_rounded, size: 64, color: const Color(0xFF0D2146).withOpacity(0.2)),
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
                                  fontSize: 14,
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
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
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
                          ),
                        ),
                      ),
                    ],
                  ),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
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
                            ),
                          ),
                        ],
                      ),
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
                    ],
                  ),
                ],
              ),
            ),
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
          ],
        ),
      ),
    );
  }

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
}
