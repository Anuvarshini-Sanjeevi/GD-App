import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gdapp/models/session_config.dart';
import 'package:gdapp/services/api_service.dart';
import 'package:gdapp/models/student_activity.dart';
import 'package:gdapp/student/slot_booking_page.dart';

class SchedulePage extends StatefulWidget {
  final Function(int, {bool? showScanner}) onNavigate;
  const SchedulePage({super.key, required this.onNavigate});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  List<StudentActivity> _activities = [];
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchActivities();
  }

  Future<void> _fetchActivities() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final activities = await ApiService.getStudentActivities();
      debugPrint('Fetched ${activities.length} activities');
      if (mounted) {
        setState(() {
          _activities = activities;
          _isLoading = false;
        });

         ScaffoldMessenger.of(context).hideCurrentSnackBar();
         ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(ApiService.lastActivitiesFetchWasSuccessful
                  ? '✅ Live activities updated'
                  : 'ℹ️ Offline mode: Showing saved activities'),
              duration: const Duration(seconds: 2),
              backgroundColor: ApiService.lastActivitiesFetchWasSuccessful
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



  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'OPEN':
      case 'ACTIVE':
        return Colors.green;
      case 'UPCOMING':
      case 'SCHEDULED':
      case 'NOT_STARTED':
        return Colors.blue.shade300;
      case 'COMPLETED':
      case 'CLOSED':
      case 'FINISHED':
      case 'DONE':
        return Colors.grey;
      case 'CANCELLED':
        return Colors.red;
      case 'TEST_ACTIVITY':
        return Colors.purple.shade300;
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
          style: const TextStyle(
            color: Color(0xFF0D2146),
            fontWeight: FontWeight.bold,
            fontSize: 20,
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search activities by name or skill',
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF9CA3AF)),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Color(0xFF9CA3AF)),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
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
            const CircularProgressIndicator(
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
                onPressed: _fetchActivities,
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

    // Filter activities based on search query
    final filteredActivities = _activities.where((activity) {
      final titleMatch = activity.title.toLowerCase().contains(_searchQuery);
      final subtitleMatch = activity.subtitle.toLowerCase().contains(_searchQuery);
      final categoryMatch = activity.category.toLowerCase().contains(_searchQuery);
      return titleMatch || subtitleMatch || categoryMatch;
    }).toList();

    if (filteredActivities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'No activities found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D2146),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isEmpty
                ? 'There are no sessions available at the moment.'
                : 'Try searching with different keywords.',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchActivities,
      color: const Color(0xFF4A7FFF),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filteredActivities.length + 2, // +1 for materials, +1 for bottom padding
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildCourseMaterialsCard();
          }
          if (index == filteredActivities.length + 1) {
            return const SizedBox(height: 24); // Bottom padding
          }
          final activity = filteredActivities[index - 1];
          
          return _buildScheduleCard(
            activity: activity,
            token: activity.token,
            isHighlighted: _isHighlighted(activity.status),
          );
        },
      ),
    );
  }

  Widget _buildCourseMaterialsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
  }



  Widget _buildScheduleCard({
    required StudentActivity activity,
    String? token,
    bool isHighlighted = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Blue Header with Large Icon
          Container(
            height: 160,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFFF3F7FF),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: const Center(
              child: Icon(
                Icons.group_outlined,
                size: 80,
                color: Color(0xFF4A7FFF),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      activity.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    Text(
                      activity.category,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Levels: ${activity.levels}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 12),
                _buildSegmentedProgress(activity),
                const SizedBox(height: 24),
                // Book a Slot Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SlotBookingPage(activity: activity),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A7FFF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Book a Slot',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedProgress(StudentActivity activity) {
    final total = activity.levels;
    final completed = activity.completedLevels;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(total, (index) {
            bool isCompleted = index < completed;
            
            return Expanded(
              child: Container(
                height: 8,
                margin: EdgeInsets.only(right: index == total - 1 ? 0 : 4),
                decoration: BoxDecoration(
                  color: isCompleted ? const Color(0xFF4A7FFF) : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(
          'Progress: $completed/$total levels (${activity.progressPercent.toInt()}%)',
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
