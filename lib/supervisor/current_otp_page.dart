import 'package:flutter/material.dart';
import 'package:gdapp/utils/otp_utils.dart';
import 'package:gdapp/services/api_service.dart';
import 'dart:async';

class CurrentOtpPage extends StatefulWidget {
  const CurrentOtpPage({Key? key}) : super(key: key);

  @override
  State<CurrentOtpPage> createState() => _CurrentOtpPageState();
}

class _CurrentOtpPageState extends State<CurrentOtpPage> {
  bool _isLoading = true;
  dynamic _activeSession;
  String? _error;
  Timer? _refreshTimer;
  String _otp = '';
  String _token = '';

  @override
  void initState() {
    super.initState();
    _fetchActiveSession();
    // Refresh data every 5 minutes and OTP every 1 minute
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (timer.tick % 5 == 0) {
        _fetchActiveSession();
      } else {
        _generateOtp();
      }
    });
  }

  Future<void> _fetchActiveSession() async {
    if (!mounted) return;
    setState(() {
      _isLoading = _activeSession == null; // Only show full loader if we don't have data yet
      _error = null;
    });

    try {
      final List<dynamic> sessions = await ApiService.getHallQrTokens();
      // Find the first active session
      final active = sessions.firstWhere(
        (s) => s['is_active'] == true || s['status']?.toString().toUpperCase() == 'ACTIVE',
        orElse: () => null,
      );

      if (mounted) {
        setState(() {
          _activeSession = active;
          if (active != null) {
            _token = active['token']?.toString() ?? 'N/A';
            
            // Check for API-provided OTP
            final String? apiOtp = active['current_otp']?.toString() ?? 
                                  active['otp']?.toString();
            
            if (apiOtp != null) {
              _otp = apiOtp;
            } else {
              _generateOtp();
            }
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _generateOtp() {
    if (_token != 'N/A') {
      setState(() {
        _otp = OTPUtils.generateOTP(_token);
      });
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Active Session OTP',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF4A7FFF)),
            onPressed: _fetchActiveSession,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null && _activeSession == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Failed to load session info',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _fetchActiveSession,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A7FFF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_activeSession == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              'No Active Session Found',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Check scheduled sessions or refresh',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: _fetchActiveSession,
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    final Map<String, dynamic> sessionData = _activeSession is Map 
        ? (_activeSession['session'] ?? _activeSession['session_config'] ?? _activeSession) 
        : {};

    final String title = sessionData['topic'] ?? sessionData['session_name'] ?? 'Active Session';
    final String hall = sessionData['hall'] ?? sessionData['hall_name'] ?? 'Main Hall';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF4A7FFF).withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A7FFF).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.sensors, color: Color(0xFF4A7FFF)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        hall,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00D9A5).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'LIVE',
                    style: TextStyle(color: Color(0xFF00D9A5), fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          
          // Main OTP Card
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4A7FFF).withOpacity(0.1),
                  blurRadius: 40,
                  offset: const Offset(0, 10),
                ),
              ],
              border: Border.all(color: const Color(0xFF4A7FFF).withOpacity(0.05)),
            ),
            child: Column(
              children: [
                const Text(
                  'JOIN OTP',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _otp,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A7FFF),
                    letterSpacing: 8,
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 24),
                
                // Real QR Code from API
                Container(
                  width: 220,
                  height: 220,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Image.network(
                    'https://api.qrserver.com/v1/create-qr-code/?size=200x200&data=$_otp',
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(Icons.qr_code, size: 100, color: Colors.grey),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                const Text(
                  'HALL ACCESS TOKEN',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _token,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 40),
          Text(
            'Keep this screen open for students to join.\nThe OTP will refresh automatically.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], height: 1.5),
          ),
          
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                // Future feature: Print
              },
              icon: const Icon(Icons.print_outlined),
              label: const Text('Print QR Details'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF4A7FFF),
                side: const BorderSide(color: Color(0xFF4A7FFF)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
