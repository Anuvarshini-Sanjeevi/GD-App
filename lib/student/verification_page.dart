import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:async';
import 'package:gdapp/services/api_service.dart';
import 'package:gdapp/student/team_allocation_page.dart';
import 'package:gdapp/utils/otp_utils.dart';

class VerificationPage extends StatefulWidget {
  final Function(String)? onVerified;
  final bool showScannerFirst;
  final String? bookedSessionTitle;
  final String? initialOtp;
  final String? activityType;

  const VerificationPage({
    Key? key,
    this.onVerified,
    this.showScannerFirst = true,
    this.bookedSessionTitle,
    this.initialOtp,
    this.activityType,
  }) : super(key: key);

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage>
    with SingleTickerProviderStateMixin {
  late bool _isScanning;
  String _otp = "";
  final MobileScannerController _scannerController = MobileScannerController();
  late AnimationController _scanAnimationController;
  late Animation<double> _scanAnimation;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _isScanning = widget.showScannerFirst;
    _otp = '';
    _scanAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scanAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _scanAnimationController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning || _isProcessing) return;
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? code = barcodes.first.rawValue;
      if (code != null) {
        _handleVerified(code);
      }
    }
  }

  void _handleVerified(String code, {bool isOtpEntry = false}) async {
    setState(() => _isProcessing = true);
    debugPrint(
        'Verifying code: $code for session: ${widget.bookedSessionTitle} (otp entry: $isOtpEntry)');

    try {
      // For manual OTP entry: fetch current_otp from API and verify first.
      // For QR scan: go directly to the scan endpoint.
      final result = isOtpEntry
          ? await ApiService.verifyStudentOtp(code,
              sessionTitle: widget.bookedSessionTitle,
              activityType: widget.activityType)
          : await ApiService.verifyOtp(code,
              sessionTitle: widget.bookedSessionTitle);
      debugPrint('Attendance marked successfully: $result');

      if (mounted) {
        debugPrint('Verification successful!');
        if (widget.onVerified != null) {
          widget.onVerified!(code);
        }

        if (mounted) {
          debugPrint('Verification successful!');
          if (widget.onVerified != null) {
            widget.onVerified!(code);
          }

          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop(true);
          } else {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const TeamAllocationPage()),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Verification error: $e');

      // Fallback: If backend fails, we can still try local verification
      // as a backup if the user wants to allow offline marking (optional)
      // For now, let's treat backend failure as a failed attempt to be safe

      if (mounted) {
        setState(() {
          _isProcessing = false;
          _otp = ''; // Clear OTP boxes so user can re-enter
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(e is ApiException ? e.message : 'Verification failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onNumberPressed(String number) {
    if (_otp.length < 6) {
      setState(() {
        _otp += number;
      });
    }
  }

  void _onBackspace() {
    if (_otp.isNotEmpty) {
      setState(() {
        _otp = _otp.substring(0, _otp.length - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isScanning ? Colors.black : const Color(0xFFF9FAFB),
      body: Stack(
        children: [
          _isScanning ? _buildScannerView() : _buildOtpView(),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScannerView() {
    return Stack(
      children: [
        MobileScanner(
          controller: _scannerController,
          onDetect: _onDetect,
        ),

        // Darkened overlay with cutout
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.5),
            BlendMode.srcOut,
          ),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  backgroundBlendMode: BlendMode.dstOut,
                ),
              ),
              Center(
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Scanning UI Elements
        SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Center(
                child: Container(
                  width: 260,
                  height: 260,
                  child: Stack(
                    children: [
                      // Viewfinder Corners
                      _buildViewfinderCorner(Alignment.topLeft),
                      _buildViewfinderCorner(Alignment.topRight),
                      _buildViewfinderCorner(Alignment.bottomLeft),
                      _buildViewfinderCorner(Alignment.bottomRight),

                      // Animated Scan line
                      AnimatedBuilder(
                        animation: _scanAnimation,
                        builder: (context, child) {
                          return Positioned(
                            top: _scanAnimation.value * 250 + 5,
                            left: 10,
                            right: 10,
                            child: Container(
                              height: 2,
                              decoration: BoxDecoration(
                                color: const Color(0xFF2E63F2),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF2E63F2)
                                        .withOpacity(0.5),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Position QR code within the frame to scan',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 48),

              // Use OTP Pill Button
              GestureDetector(
                onTap: () => setState(() => _isScanning = false),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Text(
                    'Use OTP',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildViewfinderCorner(Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          border: Border(
            top: alignment.y < 0
                ? const BorderSide(color: Colors.white, width: 4)
                : BorderSide.none,
            bottom: alignment.y > 0
                ? const BorderSide(color: Colors.white, width: 4)
                : BorderSide.none,
            left: alignment.x < 0
                ? const BorderSide(color: Colors.white, width: 4)
                : BorderSide.none,
            right: alignment.x > 0
                ? const BorderSide(color: Colors.white, width: 4)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildOtpView() {
    return Column(
      children: [
        // Purple Header
        Container(
          width: double.infinity,
          height: 120,
          decoration: const BoxDecoration(
            color: Color(0xFF2E63F2), // Dashboard blue theme
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => setState(() => _isScanning = true),
                  ),
                ),
                const Center(
                  child: Text(
                    'OTP Entry',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 32),
                const Text(
                  'Enter Verification Code',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "We've sent a 6-digit code to verify your identity",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 32),

                // OTP Indicators & spacer wrapped to handle overflow
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(6, (index) {
                            return Container(
                              width: 48,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: index < _otp.length
                                      ? const Color(0xFF2E63F2)
                                      : const Color(0xFFE5E7EB),
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  index < _otp.length ? _otp[index] : "",
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1F2937),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          '${_otp.length}/6 digits entered',
                          style: const TextStyle(
                              color: Color(0xFF9CA3AF), fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 100,
                          height: 3,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5E7EB),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Number Pad
                _buildNumberPad(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNumberPad() {
    return Column(
      children: [
        _buildNumberRow(['1', '2', '3']),
        _buildNumberRow(['4', '5', '6']),
        _buildNumberRow(['7', '8', '9']),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNumberButton(
              icon: Icons.delete_outline,
              onPressed: _onBackspace,
            ),
            _buildNumberButton(
              text: '0',
              onPressed: () => _onNumberPressed('0'),
            ),
            _buildNumberButton(
              icon: Icons.arrow_forward,
              color: _otp.length == 6
                  ? const Color(0xFF2E63F2)
                  : const Color(0xFFE5E7EB),
              iconColor: Colors.white,
              onPressed: () {
                if (_otp.length == 6) {
                  _handleVerified(_otp, isOtpEntry: true);
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberRow(List<String> numbers) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: numbers
            .map((n) => _buildNumberButton(
                text: n, onPressed: () => _onNumberPressed(n)))
            .toList(),
      ),
    );
  }

  Widget _buildNumberButton({
    String? text,
    IconData? icon,
    Color? color,
    Color? iconColor,
    VoidCallback? onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: color ?? Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            if (color == null)
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Center(
          child: text != null
              ? Text(
                  text,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                )
              : Icon(
                  icon,
                  color: iconColor ?? const Color(0xFF6B7280),
                  size: 28,
                ),
        ),
      ),
    );
  }
}
