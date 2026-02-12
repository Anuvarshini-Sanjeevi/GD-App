import 'package:flutter/material.dart';

class TableMonitorPage extends StatefulWidget {
  const TableMonitorPage({Key? key}) : super(key: key);

  @override
  State<TableMonitorPage> createState() => _TableMonitorPageState();
}

class _TableMonitorPageState extends State<TableMonitorPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
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
                
                // Live Session Card
                _buildLiveSessionCard(),
                
                const SizedBox(height: 24),
                
                // Table Monitor Section
                _buildTableMonitorSection(),
              ],
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
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
          color: Colors.black,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Back to',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Monitoring',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
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
    );
  }

  Widget _buildLiveSessionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF4A7FFF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.circle,
                  color: Color(0xFF4A7FFF),
                  size: 8,
                ),
                SizedBox(width: 6),
                Text(
                  'LIVE SESSION',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A7FFF),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tech Strategy Finals',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                'Level 4 Target',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Tables',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '12',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Session Time',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '00:45:12',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A7FFF),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableMonitorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'TABLE MONITOR',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
                letterSpacing: 0.5,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Filter',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4A7FFF),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Table 05 - Running
        _buildTableCard(
          tableNumber: 'Table 05',
          status: 'RUNNING',
          statusColor: const Color(0xFF4A7FFF),
          presentCount: '6/6 Present',
          timeInfo: '14:32',
          showTimer: true,
          actionButton: _buildEngagementButton(),
        ),
        
        const SizedBox(height: 12),
        
        // Table 06 - Waiting
        _buildTableCard(
          tableNumber: 'Table 06',
          status: 'WAITING',
          statusColor: Colors.grey,
          presentCount: '4/6 Present',
          timeInfo: 'Auto-start: 2m',
          showTimer: true,
          actionButton: _buildStartSessionButton(),
        ),
        
        const SizedBox(height: 12),
        
        // Table 07 - Rating Pending
        _buildTableCard(
          tableNumber: 'Table 07',
          status: 'RATING PENDING',
          statusColor: Colors.orange,
          presentCount: '5/5 Present',
          timeInfo: 'Finished 2m ago',
          showTimer: false,
          actionButton: _buildRatingButtons(),
          showFinishedInfo: true,
        ),
        
        const SizedBox(height: 12),
        
        // Table 04 - Finished
        _buildTableCard(
          tableNumber: 'Table 04',
          status: 'FINISHED',
          statusColor: const Color(0xFF34C759),
          presentCount: 'Rated Low',
          timeInfo: 'Feedback added',
          showTimer: false,
          actionButton: _buildUpdateStatusButton(),
          isFinished: true,
        ),
      ],
    );
  }

  Widget _buildTableCard({
    required String tableNumber,
    required String status,
    required Color statusColor,
    required String presentCount,
    required String timeInfo,
    required bool showTimer,
    required Widget actionButton,
    bool showFinishedInfo = false,
    bool isFinished = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: showFinishedInfo 
            ? Border.all(color: Colors.orange.withOpacity(0.3), width: 2)
            : isFinished
                ? Border.all(color: const Color(0xFF34C759).withOpacity(0.3), width: 2)
                : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tableNumber,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.people_outline,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Text(
                presentCount,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                showTimer ? Icons.access_time : Icons.check_circle_outline,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Text(
                timeInfo,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          actionButton,
        ],
      ),
    );
  }

  Widget _buildEngagementButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4A7FFF),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Rate Engagement',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildStartSessionButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF4A7FFF),
          side: const BorderSide(color: Color(0xFF4A7FFF), width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.play_arrow, size: 20),
            SizedBox(width: 6),
            Text(
              'Start Session',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildRatingOption(
            icon: Icons.sentiment_dissatisfied,
            label: 'LOW',
            color: Colors.red,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildRatingOption(
            icon: Icons.sentiment_neutral,
            label: 'MOD',
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildRatingOption(
            icon: Icons.sentiment_satisfied_alt,
            label: 'HIGH',
            color: const Color(0xFF34C759),
          ),
        ),
      ],
    );
  }

  Widget _buildRatingOption({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateStatusButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black,
          side: BorderSide(color: Colors.grey[300]!, width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.refresh, size: 20),
            SizedBox(width: 6),
            Text(
              'Update Status',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
