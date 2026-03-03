import 'package:flutter/material.dart';
import 'package:gdapp/services/api_service.dart';

class TableMonitorPage extends StatefulWidget {
  final dynamic session;
  const TableMonitorPage({Key? key, required this.session}) : super(key: key);

  @override
  State<TableMonitorPage> createState() => _TableMonitorPageState();
}

class _TableMonitorPageState extends State<TableMonitorPage> {
  dynamic _latestSession;
  bool _isLoading = true;
  String? _errorMessage;
  int _totalTables = 12;
  late TextEditingController _tableCountController;

  @override
  void initState() {
    super.initState();
    _latestSession = widget.session;
    _tableCountController = TextEditingController(text: _totalTables.toString());
    _fetchLatestData();
  }

  @override
  void dispose() {
    _tableCountController.dispose();
    super.dispose();
  }

  void _updateTableCount(int newCount) {
    if (newCount < 1) return;
    setState(() {
      _totalTables = newCount;
      _tableCountController.text = _totalTables.toString();
    });
  }

  Future<void> _fetchLatestData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      debugPrint('TableMonitorPage: Fetching latest session data...');
      final sessions = await ApiService.getHallQrTokens();
      
      // Better ID extraction helper
      String? getExtractedId(dynamic s) {
        if (s == null || s is! Map) return null;
        // Prioritize session_id then id then nested ids
        final id = (s['session_id']?.toString() ?? 
                    s['id']?.toString() ?? 
                    s['session']?['id']?.toString() ?? 
                    s['session']?['session_id']?.toString() ??
                    s['session_config']?['id']?.toString() ??
                    s['sessionConfig']?['id']?.toString());
        return id;
      }

      final targetId = getExtractedId(widget.session);
      debugPrint('TableMonitorPage: Targeting Session ID: $targetId');
      
      if (sessions.isNotEmpty && targetId != null) {
        // Find the specific session based on the ID we're monitoring
        dynamic updated;
        try {
          updated = sessions.firstWhere(
            (s) {
              final currentId = getExtractedId(s);
              return currentId == targetId;
            },
          );
          debugPrint('TableMonitorPage: Found matching session in live feed');
        } catch (_) {
          debugPrint('TableMonitorPage: Session $targetId not found in live feed, using passed data');
          updated = widget.session;
        }
        
        if (mounted) {
          setState(() {
            _latestSession = updated;
            _isLoading = false;
          });
        }
      } else {
        debugPrint('TableMonitorPage: Sessions list empty or Target ID null. Sessions: ${sessions.length}, ID: $targetId');
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      debugPrint('TableMonitorPage: Error fetching session details: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load live data';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchLatestData,
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
                      
                      if (_errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red, size: 20),
                              const SizedBox(width: 8),
                              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),

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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
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
    final Map<String, dynamic> sessionData = _latestSession is Map ? (_latestSession['session'] ?? _latestSession['session_config'] ?? _latestSession['sessionConfig'] ?? _latestSession) : {};

    final String title = sessionData['topic'] ?? 
                        sessionData['session_name'] ?? 
                        sessionData['sessionName'] ?? 
                        sessionData['name'] ?? 
                        sessionData['title'] ??
                        _latestSession['topic'] ??
                        _latestSession['session_name'] ??
                        _latestSession['session_id']?.toString() ??
                        'Unnamed Session';
                        
    final String hall = sessionData['hall'] ?? 
                       sessionData['hall_name'] ?? 
                       sessionData['hallName'] ?? 
                       sessionData['location'] ?? 
                       _latestSession['hall'] ??
                       _latestSession['hall_name'] ??
                       'Unknown Hall';

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
          Text(
            title,
            style: const TextStyle(
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
                hall,
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
                    Row(
                      children: [
                        _buildCountStepperButton(
                          icon: Icons.keyboard_arrow_down,
                          onPressed: () => _updateTableCount(_totalTables - 1),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 40,
                          child: TextField(
                            controller: _tableCountController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            onSubmitted: (val) {
                              final count = int.tryParse(val);
                              if (count != null) _updateTableCount(count);
                            },
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildCountStepperButton(
                          icon: Icons.keyboard_arrow_up,
                          onPressed: () => _updateTableCount(_totalTables + 1),
                        ),
                      ],
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

  Widget _buildCountStepperButton({required IconData icon, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 24, color: const Color(0xFF4A7FFF)),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
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
        
        // Dynamically generate table cards
        ...List.generate(_totalTables, (index) {
          final tableNum = index + 1;
          final tableStr = 'Table ${tableNum.toString().padLeft(2, '0')}';
          
          // Use real data pattern for some tables, placeholders for others
          if (tableNum == 5) {
            return Column(
              children: [
                _buildTableCard(
                  tableNumber: tableStr,
                  status: 'RUNNING',
                  statusColor: const Color(0xFF4A7FFF),
                  presentCount: '6/6 Present',
                  timeInfo: '14:32',
                  showTimer: true,
                  actionButton: _buildEngagementButton(),
                ),
                const SizedBox(height: 12),
              ],
            );
          } else if (tableNum == 6) {
            return Column(
              children: [
                _buildTableCard(
                  tableNumber: tableStr,
                  status: 'WAITING',
                  statusColor: Colors.grey,
                  presentCount: '4/6 Present',
                  timeInfo: 'Auto-start: 2m',
                  showTimer: true,
                  actionButton: _buildStartSessionButton(),
                ),
                const SizedBox(height: 12),
              ],
            );
          } else if (tableNum == 7) {
            return Column(
              children: [
                _buildTableCard(
                  tableNumber: tableStr,
                  status: 'RATING PENDING',
                  statusColor: Colors.orange,
                  presentCount: '5/5 Present',
                  timeInfo: 'Finished 2m ago',
                  showTimer: false,
                  actionButton: _buildRatingButtons(),
                  showFinishedInfo: true,
                ),
                const SizedBox(height: 12),
              ],
            );
          } else if (tableNum == 4) {
            return Column(
              children: [
                _buildTableCard(
                  tableNumber: tableStr,
                  status: 'FINISHED',
                  statusColor: const Color(0xFF34C759),
                  presentCount: 'Rated Low',
                  timeInfo: 'Feedback added',
                  showTimer: false,
                  actionButton: _buildUpdateStatusButton(),
                  isFinished: true,
                ),
                const SizedBox(height: 12),
              ],
            );
          } else {
            // Default placeholder for other tables
            return Column(
              children: [
                _buildTableCard(
                  tableNumber: tableStr,
                  status: 'PENDING',
                  statusColor: Colors.grey[400]!,
                  presentCount: '0/6 Present',
                  timeInfo: '--:--',
                  showTimer: false,
                  actionButton: _buildStartSessionButton(),
                ),
                const SizedBox(height: 12),
              ],
            );
          }
        }),
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
