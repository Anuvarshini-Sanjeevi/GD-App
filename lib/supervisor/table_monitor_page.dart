import 'package:flutter/material.dart';
import 'package:gdapp/services/api_service.dart';
import 'package:gdapp/supervisor/growth_page.dart';


class TableMonitorPage extends StatefulWidget {
  final dynamic session;
  const TableMonitorPage({Key? key, required this.session}) : super(key: key);

  @override
  State<TableMonitorPage> createState() => _TableMonitorPageState();
}

class _TableMonitorPageState extends State<TableMonitorPage> {
  dynamic _latestSession;
  bool _isLoading = true;
  bool _isSubmittingCount = false;
  String? _errorMessage;
  int _totalTables = 12;
  late TextEditingController _tableCountController;

  @override
  void initState() {
    super.initState();
    _latestSession = widget.session;
    _tableCountController =
        TextEditingController(text: _totalTables.toString());
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

  String? _extractSessionId(dynamic source) {
    if (source is! Map) return null;
    return source['token_id']?.toString() ??
        source['session_id']?.toString() ??
        source['id']?.toString() ??
        source['session']?['id']?.toString() ??
        source['session']?['session_id']?.toString() ??
        source['session_config']?['id']?.toString() ??
        source['sessionConfig']?['id']?.toString();
  }

  int _extractTableCount(dynamic source) {
    if (source is! Map) return _totalTables;
    final Map<String, dynamic> data = source['session'] ?? 
                                     source['session_config'] ?? 
                                     source['sessionConfig'] ?? 
                                     source;
    
    final dynamic count = data['table_count'] ?? 
                          data['total_tables'] ?? 
                          data['tableCount'] ?? 
                          source['table_count'] ??
                          source['total_tables'];
                          
    if (count == null) return _totalTables;
    if (count is int) return count;
    return int.tryParse(count.toString()) ?? _totalTables;
  }

  Future<void> _submitTableCount() async {
    final sessionId =
        _extractSessionId(_latestSession) ?? _extractSessionId(widget.session);
    if (sessionId == null || sessionId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Unable to identify session for count update.')),
      );
      return;
    }

    if (!mounted) return;
    setState(() => _isSubmittingCount = true);
    try {
      await ApiService.updateSessionTableCount(
        sessionId: sessionId,
        tableCount: _totalTables,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Table count submitted: $_totalTables')),
      );

      // Fetch latest data after successful submission
      await _fetchLatestData();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit count: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmittingCount = false);
    }
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

      final targetId = _extractSessionId(widget.session);
      debugPrint('TableMonitorPage: Targeting Session ID: $targetId');

      if (sessions.isNotEmpty && targetId != null) {
        // Find the specific session based on the ID we're monitoring
        dynamic updated;
        try {
          updated = sessions.firstWhere(
            (s) {
              final currentId = _extractSessionId(s);
              return currentId == targetId;
            },
          );
          debugPrint('TableMonitorPage: Found matching session in live feed');
        } catch (_) {
          debugPrint(
              'TableMonitorPage: Session $targetId not found in live feed, using passed data');
          updated = widget.session;
        }

        if (mounted) {
          setState(() {
            _latestSession = updated;
            _totalTables = _extractTableCount(updated);
            _tableCountController.text = _totalTables.toString();
            _isLoading = false;
          });
        }
      } else {
        debugPrint(
            'TableMonitorPage: Sessions list empty or Target ID null. Sessions: ${sessions.length}, ID: $targetId');
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
                                const Icon(Icons.error_outline,
                                    color: Colors.red, size: 20),
                                const SizedBox(width: 8),
                                Text(_errorMessage!,
                                    style: const TextStyle(color: Colors.red)),
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
                  fontSize: 12,
                  color: Color(0xFF8A96A8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Monitoring',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2533),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFA185F4),
          ),
          child: const Center(
            child: Text(
              'S',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLiveSessionCard() {
    final Map<String, dynamic> sessionData = _latestSession is Map
        ? (_latestSession['session'] ??
            _latestSession['session_config'] ??
            _latestSession['sessionConfig'] ??
            _latestSession)
        : {};

    final String title = _latestSession['session_id']?.toString() ??
        sessionData['session_id']?.toString() ??
        _latestSession['id']?.toString() ??
        sessionData['id']?.toString() ??
        sessionData['topic'] ??
        sessionData['session_name'] ??
        sessionData['sessionName'] ??
        sessionData['name'] ??
        sessionData['title'] ??
        _latestSession['topic'] ??
        _latestSession['session_name'] ??
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
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF1FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.circle,
                      color: Color(0xFF3A78E8),
                      size: 6,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'LIVE SESSION',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF3A78E8),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Text(
                '00:45:12',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF3A78E8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F2533),
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: Color(0xFF8A96A8),
              ),
              const SizedBox(width: 4),
              Text(
                hall,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF8A96A8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Manage Tables',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF8A96A8),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildCountStepperButton(
                      icon: Icons.keyboard_arrow_down,
                      onPressed: () => _updateTableCount(_totalTables - 1),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          _totalTables.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1F2533),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildCountStepperButton(
                      icon: Icons.keyboard_arrow_up,
                      onPressed: () => _updateTableCount(_totalTables + 1),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed:
                              _isSubmittingCount ? null : _submitTableCount,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3A78E8),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: _isSubmittingCount
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Submit Count',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
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
    );
  }

  Widget _buildCountStepperButton(
      {required IconData icon, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 20, color: const Color(0xFF3A78E8)),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      ),
    );
  }

  Widget _buildTableMonitorSection() {
    return Column(
      children: List.generate(_totalTables, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _DiscussionCard(
            title: 'Group Discussion',
            status: 'UPCOMING',
            statusTextColor: const Color(0xFF3A78E8),
            statusBgColor: const Color(0xFFEAF1FF),
            tableNumber: (index + 1).toString(),
            rating: 0,
          ),
        );
      }),
    );
  }
}

class _DiscussionCard extends StatefulWidget {
  final String title;
  final String status;
  final Color statusTextColor;
  final Color statusBgColor;
  final String tableNumber;
  final int rating;

  const _DiscussionCard({
    required this.title,
    required this.status,
    required this.statusTextColor,
    required this.statusBgColor,
    required this.tableNumber,
    required this.rating,
  });

  @override
  State<_DiscussionCard> createState() => _DiscussionCardState();
}

class _DiscussionCardState extends State<_DiscussionCard> {
  late int _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.rating;
  }

  void _updateRating(int newRating) {
    setState(() {
      _currentRating = newRating;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F2533),
                    height: 1.2,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: widget.statusBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  widget.status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: widget.statusTextColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text(
                'Table Number',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8A96A8),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF1F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.tableNumber,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F2533),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1, color: Color(0xFFF2F4F8)),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text(
                'Rate Discussion',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8A96A8),
                ),
              ),
              const Spacer(),
              ...List.generate(5, (index) {
                final starIndex = index + 1;
                final isFilled = starIndex <= _currentRating;
                return GestureDetector(
                  onTap: () => _updateRating(starIndex),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(
                      isFilled ? Icons.star : Icons.star_border,
                      size: 20,
                      color: isFilled
                          ? const Color(0xFFE8A313)
                          : const Color(0xFFD7DCE5),
                    ),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SupervisorGrowthPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3A78E8),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Monitor Tables',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
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
}
