import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:gdapp/student/team_allocation_page.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:gdapp/services/api_service.dart';

class ScanHallQRPage extends StatefulWidget {
  const ScanHallQRPage({Key? key}) : super(key: key);

  @override
  State<ScanHallQRPage> createState() => _ScanHallQRPageState();
}

class _ScanHallQRPageState extends State<ScanHallQRPage>
    with SingleTickerProviderStateMixin {
  bool _isScanning = true;
  bool _showOTPInput = false;
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());
  late AnimationController _scanAnimationController;
  late Animation<double> _scanAnimation;
  bool _isProcessing = false;
  final MobileScannerController _scannerController = MobileScannerController();

  @override
  void initState() {
    super.initState();
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
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _otpFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning || _isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? code = barcodes.first.rawValue;
      if (code != null) {
        debugPrint('Barcode found! $code');
        setState(() {
          _isProcessing = true;
        });

        // Call backend to mark attendance
        ApiService.scanToken(code).then((result) {
          if (mounted) {
            setState(() {
              _isScanning = false;
              _isProcessing = false;
            });
            _showSuccessDialog();
          }
        }).catchError((e) {
          if (mounted) {
            setState(() {
              _isProcessing = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e is ApiException ? e.message : 'Scan failed: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        });
      }
    }
  }

  void _simulateQRScan() {
    // Legacy manual trigger for testing or if QR fails
    setState(() {
      _isProcessing = true;
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isScanning = false;
          _showOTPInput = true;
          _isProcessing = false;
        });
        _otpFocusNodes[0].requestFocus();
      }
    });
  }

  void _onOTPChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      _otpFocusNodes[index + 1].requestFocus();
    }
    
    // Check if all fields are filled
    if (_otpControllers.every((controller) => controller.text.isNotEmpty)) {
      _verifyOTP();
    }
  }

  void _onOTPBackspace(int index) {
    if (index > 0 && _otpControllers[index].text.isEmpty) {
      _otpFocusNodes[index - 1].requestFocus();
    }
  }

  void _verifyOTP() {
    String otp = _otpControllers.map((c) => c.text).join();
    
    setState(() {
      _isProcessing = true;
    });

    // Call backend to mark attendance
    ApiService.scanToken(otp).then((result) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        
        // Show success dialog
        _showSuccessDialog();
      }
    }).catchError((e) {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e is ApiException ? e.message : 'Verification failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Successfully Joined!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'You have been assigned to Team Alpha',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Close scan page
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const TeamAllocationPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A7FFF),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Join the Session',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _resetScan() {
    setState(() {
      _isScanning = true;
      _showOTPInput = false;
      for (var controller in _otpControllers) {
        controller.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF0D2146)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Scan Hall QR',
          style: TextStyle(color: Color(0xFF0D2146), fontWeight: FontWeight.bold),
        ),
        actions: [
          ValueListenableBuilder<MobileScannerState>(
            valueListenable: _scannerController,
            builder: (context, state, child) {
              final torchState = state.torchState;
              switch (torchState) {
                case TorchState.off:
                  return IconButton(
                    icon: const Icon(Icons.flash_off, color: Color(0xFF0D2146)),
                    onPressed: () => _scannerController.toggleTorch(),
                  );
                case TorchState.on:
                  return IconButton(
                    icon: const Icon(Icons.flash_on, color: Colors.yellow),
                    onPressed: () => _scannerController.toggleTorch(),
                  );
                case TorchState.unavailable:
                default:
                  return const SizedBox.shrink();
              }
            },
          ),
          if (_showOTPInput)
            IconButton(
              icon: const Icon(Icons.refresh, color: Color(0xFF0D2146)),
              onPressed: _resetScan,
            ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Main Content
            if (_isScanning) _buildScannerView() else _buildOTPView(),
            
            // Processing Overlay
            if (_isProcessing)
              Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildScannerView() {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              // Camera Preview
              MobileScanner(
                controller: _scannerController,
                onDetect: _onDetect,
                errorBuilder: (context, error, child) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error, color: Colors.red, size: 64),
                        const SizedBox(height: 16),
                        Text(
                          error.errorCode.name,
                          style: const TextStyle(color: Color(0xFF0D2146)),
                        ),
                      ],
                    ),
                  );
                },
              ),
              
              // Scanning Frame Overlay
              Center(
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF0D2146).withOpacity(0.2),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      // Corner Decorations
                      _buildCorner(Alignment.topLeft),
                      _buildCorner(Alignment.topRight),
                      _buildCorner(Alignment.bottomLeft),
                      _buildCorner(Alignment.bottomRight),
                      
                      // Animated Scan Line
                      AnimatedBuilder(
                        animation: _scanAnimation,
                        builder: (context, child) {
                          return Positioned(
                            top: _scanAnimation.value * 260,
                            left: 10,
                            right: 10,
                            child: Container(
                              height: 2,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    const Color(0xFF4A7FFF),
                                    Colors.transparent,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF4A7FFF).withOpacity(0.5),
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
            ],
          ),
        ),
        
        // Bottom Instructions
        Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Text(
                'Position the QR code within the frame to scan',
                style: TextStyle(
                  color: Color(0xFF0D2146),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Use OTP Button (Pill shape as in image)
              SizedBox(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _isScanning = false;
                      _showOTPInput = true;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.black,
                    side: const BorderSide(color: Colors.white, width: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    shape: const StadiumBorder(),
                  ),
                  child: const Text(
                    'Use OTP',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCorner(Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          border: Border(
            top: alignment.y < 0
                ? const BorderSide(color: Color(0xFF4A7FFF), width: 4)
                : BorderSide.none,
            bottom: alignment.y > 0
                ? const BorderSide(color: Color(0xFF4A7FFF), width: 4)
                : BorderSide.none,
            left: alignment.x < 0
                ? const BorderSide(color: Color(0xFF4A7FFF), width: 4)
                : BorderSide.none,
            right: alignment.x > 0
                ? const BorderSide(color: Color(0xFF4A7FFF), width: 4)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildOTPView() {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              
              // Success Icon (Blue now)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A7FFF).withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF4A7FFF).withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.qr_code_scanner,
                  color: Color(0xFF4A7FFF),
                  size: 64,
                ),
              ),
              
              const SizedBox(height: 32),
              
              const Text(
                'Enter OTP',
                style: TextStyle(
                  color: Color(0xFF0D2146),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 12),
              
              Text(
                'Enter the 6-digit OTP to join the session',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 48),
              
              // OTP Input Boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (index) {
                  return Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: index == 2 ? 8 : 4,
                    ),
                    child: _buildOTPBox(index),
                  );
                }),
              ),
              
              const SizedBox(height: 32),
              
              // Resend OTP
              TextButton(
                onPressed: () {
                  // Resend OTP logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('OTP sent successfully'),
                      backgroundColor: Color(0xFF4A7FFF),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: const Text(
                  'Resend OTP',
                  style: TextStyle(
                    color: Color(0xFF4A7FFF),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              
              const SizedBox(height: 64),
              
              // Verify Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _otpControllers.every((c) => c.text.isNotEmpty)
                      ? _verifyOTP
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A7FFF),
                    disabledBackgroundColor: Colors.grey[200],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Verify & Join',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _otpControllers.every((c) => c.text.isNotEmpty) ? Colors.white : Colors.grey[500],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOTPBox(int index) {
    return Container(
      width: 48,
      height: 56,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _otpFocusNodes[index].hasFocus
              ? const Color(0xFF4A7FFF)
              : Colors.grey[300]!,
          width: 2,
        ),
      ),
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _otpFocusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(
          color: Color(0xFF0D2146),
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (value) {
          _onOTPChanged(index, value);
          setState(() {}); // For button state update
        },
        onTap: () {
          setState(() {});
        },
        onEditingComplete: () {
          if (index < 5) {
            _otpFocusNodes[index + 1].requestFocus();
          }
        },
      ),
    );
  }
}
