import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gdapp/models/student_activity.dart';
import 'package:gdapp/services/api_service.dart';
<<<<<<< HEAD
import 'package:gdapp/student/upcoming_sessions_page.dart';
=======
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3

class SlotBookingPage extends StatefulWidget {
  final StudentActivity activity;

  const SlotBookingPage({super.key, required this.activity});

  @override
  State<SlotBookingPage> createState() => _SlotBookingPageState();
}

class _SlotBookingPageState extends State<SlotBookingPage> {
  DateTime? _selectedDate;
  String? _selectedSlotId;
  final List<DateTime> _availableDates = [];

  @override
  void initState() {
    super.initState();
    _generateDates();
<<<<<<< HEAD
    if (_availableDates.isNotEmpty) {
      _selectedDate = _availableDates.first;
    }
=======
    _selectedDate = _availableDates.first;
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
  }

  void _generateDates() {
    final now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      _availableDates.add(now.add(Duration(days: i)));
    }
  }

  final List<Map<String, String>> _slots = [
<<<<<<< HEAD
    {'id': '1', 'time': '10:00 AM - 11:30 AM', 'duration': '1h 30m duration'},
    {'id': '2', 'time': '02:00 PM - 03:30 PM', 'duration': '1h 30m duration'},
    {'id': '3', 'time': '04:30 PM - 06:00 PM', 'duration': '1h 30m duration'},
=======
    {'id': '1', 'time': '10:00 AM - 11:30 AM'},
    {'id': '2', 'time': '02:00 PM - 03:30 PM'},
    {'id': '3', 'time': '04:30 PM - 06:00 PM'},
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Custom Header
          _buildHeader(),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Available Slots Title with Badge
                  _buildSectionTitle(),

                  const SizedBox(height: 24),

                  // Slots List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _slots.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final slot = _slots[index];
                      final isSelected = _selectedSlotId == slot['id'];
                      return _buildBookingCard(slot, isSelected);
                    },
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // Bottom Confirm Button
          _buildConfirmButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF1D7BFA),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 24,
        right: 24,
        bottom: 30,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back,
                  color: Color(0xFF1E293B), size: 20),
            ),
          ),
          const SizedBox(height: 20),

          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded,
                    color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(
                  widget.activity.category.isNotEmpty ? widget.activity.category : 'Activity',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
=======
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0D2146)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Book a Slot',
          style: TextStyle(
            color: Color(0xFF0D2146),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Activity Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.activity.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.activity.subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Select Date Section
            const Text(
              'Select Date',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _availableDates.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final date = _availableDates[index];
                  final isSelected = _selectedDate != null &&
                      DateUtils.isSameDay(date, _selectedDate);
                  return _buildDateCard(date, isSelected);
                },
              ),
            ),
            const SizedBox(height: 32),

            // Available Slots Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Available Slots',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  '(${_slots.length})',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
                  ),
                ),
              ],
            ),
<<<<<<< HEAD
          ),
          const SizedBox(height: 16),

          // Titles
          Text(
            widget.activity.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose your preferred time block to participate in this session.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.4,
            ),
          ),
        ],
=======
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _slots.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final slot = _slots[index];
                final isSelected = _selectedSlotId == slot['id'];
                return _buildSlotCard(slot, isSelected);
              },
            ),
            const SizedBox(height: 40),

            // Confirm Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_selectedDate != null && _selectedSlotId != null)
                    ? () => _handleBooking()
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                child: const Text(
                  'Confirm Booking',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildSectionTitle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Available Slots',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Icon(Icons.access_time, size: 16, color: Colors.grey[400]),
              const SizedBox(width: 6),
              Text(
                '3 Options',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBookingCard(Map<String, String> slot, bool isSelected) {
=======
  Widget _buildDateCard(DateTime date, bool isSelected) {
    final dayName = DateFormat('EEE').format(date).toUpperCase();
    final dayNum = DateFormat('dd').format(date);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = date;
        });
      },
      child: Container(
        width: 80,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF3B82F6) : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayName,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? const Color(0xFF3B82F6) : Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              dayNum,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotCard(Map<String, String> slot, bool isSelected) {
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSlotId = slot['id'];
        });
      },
      child: Container(
<<<<<<< HEAD
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF1D7BFA) : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF1D7BFA)
                    : const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.access_time_filled,
                color: isSelected ? Colors.white : const Color(0xFF1D7BFA),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    slot['time'] ?? 'No time set',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    slot['duration'] ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),

            // Radio Indicator
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF1D7BFA)
                      : (Colors.grey[300] ?? Colors.grey),
=======
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF3B82F6) : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.access_time,
              color: isSelected ? const Color(0xFF3B82F6) : Colors.grey.shade400,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                slot['time']!,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF1E293B),
                ),
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF3B82F6) : Colors.grey.shade300,
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
<<<<<<< HEAD
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF1D7BFA),
                        ),
                        child: const Icon(Icons.check,
                            color: Colors.white, size: 10),
=======
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF3B82F6),
                        ),
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildConfirmButton() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _selectedSlotId != null ? () => _handleBooking() : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1D7BFA),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
            disabledBackgroundColor: Colors.grey[300],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                'Confirm Booking',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _handleBooking() async {
    final selectedSlot = _slots.firstWhere((s) => s['id'] == _selectedSlotId);

    // Perform the booking
    await ApiService.bookSlot(widget.activity, _selectedDate ?? DateTime.now(),
        selectedSlot['time'] ?? '');
=======
  void _handleBooking() async {
    final selectedSlot = _slots.firstWhere((s) => s['id'] == _selectedSlotId);
    
    // Perform the booking
    await ApiService.bookSlot(
      widget.activity, 
      _selectedDate!, 
      selectedSlot['time']!
    );
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3

    // Show success dialog
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Booking Confirmed'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Activity: ${widget.activity.title}'),
            const SizedBox(height: 8),
<<<<<<< HEAD
=======
            Text('Date: ${DateFormat('EEEE, MMM dd').format(_selectedDate!)}'),
            const SizedBox(height: 8),
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
            Text('Time: ${selectedSlot['time']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
<<<<<<< HEAD
              Navigator.pop(context); // Back to schedule
            },
            child: const Text('Back'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Back to schedule
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const UpcomingSessionsPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1D7BFA),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('View Upcoming'),
=======
              Navigator.pop(context); // Go back to schedule
            },
            child: const Text('OK'),
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
          ),
        ],
      ),
    );
  }
}
