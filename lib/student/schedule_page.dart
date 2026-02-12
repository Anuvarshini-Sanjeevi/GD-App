import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gdapp/models/session_config.dart';
import 'package:gdapp/services/api_service.dart';

class SchedulePage extends StatefulWidget {
  final Function(int) onNavigate;
  const SchedulePage({Key? key, required this.onNavigate}) : super(key: key);

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  int _selectedTab = 0; // 0 for Upcoming, 1 for History
  List<SessionConfig> _sessions = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchActiveSessionConfigs();
  }

  Future<void> _fetchActiveSessionConfigs() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final sessions = await ApiService.getActiveSessionConfigs();
      if (mounted) {
        setState(() {
          _sessions = sessions;
          _isLoading = false;
        });

         ScaffoldMessenger.of(context).hideCurrentSnackBar();
         ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(ApiService.lastSessionsFetchWasSuccessful
                  ? '✅ Live schedule updated'
                  : 'ℹ️ Offline mode: Showing scheduled sessions'),
              duration: const Duration(seconds: 2),
              backgroundColor: ApiService.lastSessionsFetchWasSuccessful
                  ? Colors.green
                  : Colors.orange,
            ),
          );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final sessionDate = DateTime(date.year, date.month, date.day);

      if (sessionDate == today) {
        return 'Today, ${DateFormat('MMM dd').format(date)}';
      } else if (sessionDate == today.add(const Duration(days: 1))) {
        return 'Tomorrow, ${DateFormat('MMM dd').format(date)}';
      }
      return DateFormat('EEE, MMM dd').format(date);
    } catch (_) {
      return dateStr; // Return as-is if parsing fails
    }
  }

  String _formatTimeRange(String start, String end) {
    try {
      // Try parsing ISO datetime or time strings
      String formatTime(String t) {
        if (t.contains('T')) {
          return DateFormat('HH:mm').format(DateTime.parse(t));
        }
        return t;
      }
      return '${formatTime(start)} - ${formatTime(end)}';
    } catch (_) {
      return '$start - $end';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'OPEN':
      case 'ACTIVE':
        return Colors.green;
      case 'UPCOMING':
      case 'SCHEDULED':
        return Colors.blue.shade300;
      case 'COMPLETED':
      case 'CLOSED':
        return Colors.grey;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.blue.shade300;
    }
  }

  bool _isHighlighted(String status) {
    final s = status.toUpperCase();
    return s == 'OPEN' || s == 'ACTIVE';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0D2146)),
          onPressed: () {
            widget.onNavigate(0);
          },
        ),
        title: const Text(
          'Schedule',
          style: TextStyle(
            color: Color(0xFF0D2146),
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Tab Switcher
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F7FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTab('Upcoming', 0),
                    ),
                    Expanded(
                      child: _buildTab('History', 1),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Schedule List
            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Color(0xFF4A7FFF),
            ),
            SizedBox(height: 16),
            Text(
              'Loading sessions...',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_off_rounded,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              const Text(
                'Unable to load sessions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D2146),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Could not connect to the server.\nPlease check your connection and try again.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _fetchActiveSessionConfigs,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A7FFF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Filter sessions based on selected tab
    final filteredSessions = _sessions.where((session) {
      final status = session.status.toUpperCase();
      if (_selectedTab == 0) {
        // Upcoming/Active
        return ['OPEN', 'ACTIVE', 'UPCOMING', 'SCHEDULED', 'START'].contains(status);
      } else {
        // History
        return ['COMPLETED', 'CLOSED', 'CANCELLED', 'FINISHED'].contains(status);
      }
    }).toList();

    if (filteredSessions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _selectedTab == 0 ? Icons.event_available_rounded : Icons.history_rounded,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              _selectedTab == 0 ? 'No active sessions' : 'No history found',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D2146),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedTab == 0 
                ? 'There are no scheduled sessions at the moment.'
                : 'Your past sessions will appear here.',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchActiveSessionConfigs,
      color: const Color(0xFF4A7FFF),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filteredSessions.length + 1, // +1 for bottom padding
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          if (index == filteredSessions.length) {
            return const SizedBox(height: 24); // Bottom padding
          }
          final session = filteredSessions[index];
          
          // Improved time range formatting for display
          String timeDisplay = _formatTimeRange(session.startTime, session.endTime);
          if (timeDisplay == ' - ') {
            timeDisplay = 'Time TBA';
          } else if (timeDisplay.endsWith(' - ')) {
            timeDisplay = timeDisplay.substring(0, timeDisplay.length - 3);
          }

          return _buildScheduleCard(
            date: _formatDate(session.date),
            title: session.topic.isNotEmpty ? session.topic : session.sessionName,
            time: timeDisplay,
            location: session.hall.isNotEmpty ? session.hall : 'TBA',
            target: session.targetLevel != null
                ? 'Target: Level ${session.targetLevel}'
                : '',
            status: session.status.toUpperCase(),
            statusColor: _getStatusColor(session.status),
            alert: session.alert,
            isHighlighted: _isHighlighted(session.status),
          );
        },
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    bool isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? const Color(0xFF0D2146) : Colors.grey.shade600,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleCard({
    required String date,
    required String title,
    required String time,
    required String location,
    required String target,
    required String status,
    required Color statusColor,
    String? alert,
    bool isHighlighted = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighlighted ? const Color(0xFF4A7FFF) : Colors.grey.shade200,
          width: isHighlighted ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F7FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF4A7FFF)),
                      const SizedBox(width: 8),
                      Text(
                        date,
                        style: const TextStyle(
                          color: Color(0xFF4A7FFF),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D2146),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey.shade500),
                const SizedBox(width: 6),
                Text(
                  time,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.location_on_outlined, size: 16, color: Colors.grey.shade500),
                const SizedBox(width: 6),
                Text(
                  location,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            if (target.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 16, color: Color(0xFF4A7FFF)),
                  const SizedBox(width: 6),
                  Text(
                    target,
                    style: const TextStyle(
                      color: Color(0xFF4A7FFF),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
            if (alert != null && alert.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, size: 18, color: Color(0xFFE65100)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        alert,
                        style: const TextStyle(
                          color: Color(0xFFBF360C),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
