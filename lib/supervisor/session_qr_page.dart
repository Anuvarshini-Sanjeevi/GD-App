import 'package:flutter/material.dart';
import 'package:gdapp/utils/otp_utils.dart';
import 'dart:async';

class SessionQrPage extends StatefulWidget {
  final dynamic session;

  const SessionQrPage({Key? key, required this.session}) : super(key: key);

  @override
  State<SessionQrPage> createState() => _SessionQrPageState();
}

class _SessionQrPageState extends State<SessionQrPage> {
  late String _otp;
  Timer? _refreshTimer;
  late String _token;

  @override
  void initState() {
    super.initState();
    _token = '${widget.session['token'] ?? widget.session['id'] ?? 'N/A'}';
    
    // Check for API-provided OTP
    final String? apiOtp = widget.session['current_otp']?.toString() ?? 
                          widget.session['otp']?.toString();
    
    if (apiOtp != null) {
      _otp = apiOtp;
    } else {
      _generateOtp();
    }
    
    // Refresh OTP every minute to ensure it's up to date
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      // Re-check api otp if we're polling or just regenerate
      _generateOtp();
    });
  }

  void _generateOtp() {
    final String? apiOtp = widget.session['current_otp']?.toString() ?? 
                          widget.session['otp']?.toString();
    
    setState(() {
      _otp = apiOtp ?? OTPUtils.generateOTP(_token);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> sessionData = widget.session is Map ? (widget.session['session'] ?? widget.session['session_config'] ?? widget.session) : {};

    final String title = sessionData['topic'] ?? 
                        sessionData['session_name'] ?? 
                        sessionData['name'] ?? 
                        'Unnamed Session';
                        
    final String hall = sessionData['hall'] ?? 
                       sessionData['hall_name'] ?? 
                       sessionData['location'] ?? 
                       'Unknown Hall';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Session QR Code',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                hall,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 40),
              // Stylized QR Container
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4A7FFF).withOpacity(0.15),
                      blurRadius: 40,
                      offset: const Offset(0, 10),
                    ),
                  ],
                  border: Border.all(
                    color: const Color(0xFF4A7FFF).withOpacity(0.1),
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    // Real QR Code from API
                    Container(
                      width: 240,
                      height: 240,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
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
                      'SESSION TOKEN',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _token,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'SESSION OTP',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _otp,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A7FFF),
                        letterSpacing: 4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Students can scan this QR code\nor enter the OTP to join.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Print/Share logic could go here
                  },
                  icon: const Icon(Icons.print_rounded),
                  label: const Text('Print QR Code'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A7FFF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
