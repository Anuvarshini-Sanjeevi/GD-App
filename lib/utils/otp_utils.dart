import 'dart:convert';
import 'package:crypto/crypto.dart';

class OTPUtils {
  /// Generates a 6-digit OTP based on the session token and current time.
  /// The OTP remains valid for 10 minutes.
  static String generateOTP(String token) {
    // Current time in 10-minute intervals
    final int interval = DateTime.now().millisecondsSinceEpoch ~/ (1000 * 60 * 10);
    
    // Create a combined string of token and interval
    final String data = '$token-$interval';
    
    // Generate SHA-256 hash
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    
    // Convert part of the hash to a 6-digit number
    // We take the first 4 bytes and convert to an integer
    final int hashValue = digest.bytes[0] << 24 |
                         digest.bytes[1] << 16 |
                         digest.bytes[2] << 8 |
                         digest.bytes[3];
    
    // Ensure positive value and get 6 digits
    final int otp = (hashValue.abs() % 900000) + 100000;
    
    return otp.toString();
  }
}
