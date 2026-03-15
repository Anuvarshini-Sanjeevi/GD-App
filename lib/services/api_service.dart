import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:gdapp/models/session_config.dart';
import 'package:gdapp/models/student_activity.dart';
import 'package:gdapp/models/ranking_data.dart';

// Custom exception class that works on all platforms (unlike dart:io's HttpException)
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});
  @override
  String toString() => message;
}

class ApiService {
  static String? _authToken;

  static set authToken(String? token) => _authToken = token;
  static String? get authToken => _authToken;
  static bool lastActivitiesFetchWasSuccessful = false;
  static bool lastSessionsFetchWasSuccessful = false;

  // Temporary in-memory storage for booked slots
  static final List<Map<String, dynamic>> _bookedSlots = [];

  // Use 10.0.2.2 for Android emulator to reach host's localhost
  // Use localhost for web/desktop
  // Local server configuration
<<<<<<< HEAD
  static const String localUrl = 'https://d29qdzpk-8080.inc1.devtunnels.ms';
  static const String androidEmulatorUrl =
      'https://d29qdzpk-8080.inc1.devtunnels.ms';
  static const String physicalDeviceUrl = 'http://10.150.250.47:8080';
=======
  static const String localUrl = 'http://localhost:8080';
  static const String androidEmulatorUrl = 'http://10.0.2.2:8080';
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
  static const String devTunnelUrl = 'https://d29qdzpk-8080.inc1.devtunnels.ms';

  static String get baseUrl {
    if (kIsWeb) return localUrl;
<<<<<<< HEAD
    if (defaultTargetPlatform == TargetPlatform.android) {
      // Use Dev Tunnel URL for Android
      return devTunnelUrl;
    }
=======
    if (defaultTargetPlatform == TargetPlatform.android) return androidEmulatorUrl;
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
    return localUrl;
  }

  static Future<List<SessionConfig>> getSessionConfigs() async {
    try {
      final Map<String, String> headers = {
        'Accept': 'application/json',
        'X-Tunnel-Skip-AntiPhish': 'true',
      };
<<<<<<< HEAD

=======
      
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
      if (_authToken != null) {
        headers['Authorization'] = 'Bearer $_authToken';
      }
      // Fetching all session configs (instead of just active) to support history
      final url = '$baseUrl/api/session-configs';
      debugPrint('API Request: GET $url');
      final response = await http
          .get(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(const Duration(seconds: 15));

      debugPrint('API Response [session_configs]: ${response.statusCode}');
<<<<<<< HEAD

=======
      
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
      if (response.statusCode == 200) {
        lastSessionsFetchWasSuccessful = true;
        final dynamic decoded = json.decode(response.body);

        List<dynamic> jsonList;
        if (decoded is List) {
          jsonList = decoded;
        } else if (decoded is Map<String, dynamic>) {
          jsonList = decoded['data'] ??
              decoded['content'] ??
              decoded['sessionConfigs'] ??
              decoded['session_configs'] ??
              [decoded];
        } else {
          debugPrint('Invalid response, using fallback');
          return _getDummySessionConfigs();
        }

        List<SessionConfig> sessions = jsonList
            .map((json) => SessionConfig.fromJson(json as Map<String, dynamic>))
            .toList();

        // Proactively fetch hall QR tokens and student activities to merge with sessions
        try {
          // Parallel fetch for efficiency
          final results = await Future.wait([
            getHallQrTokens(),
            getStudentActivities(),
          ]);

          final tokens = results[0] as List;
          final activities = results[1] as List<StudentActivity>;

          if (tokens.isNotEmpty || activities.isNotEmpty) {
            sessions = sessions.map((session) {
              // 1. Merging Tokens
              dynamic matchingTokenData;
              if (tokens.isNotEmpty) {
                final tokenMatches = tokens.where((t) {
<<<<<<< HEAD
                  final tokenSession = t['session'] ??
                      t['session_config'] ??
                      t['sessionConfig'] ??
                      {};
                  final tokenTopic = tokenSession['topic'] ??
                      tokenSession['sessionName'] ??
                      tokenSession['session_name'];
                  return tokenTopic == session.topic ||
                      tokenTopic == session.sessionName;
=======
                  final tokenSession = t['session'] ?? t['session_config'] ?? t['sessionConfig'] ?? {};
                  final tokenTopic = tokenSession['topic'] ?? tokenSession['sessionName'] ?? tokenSession['session_name'];
                  return tokenTopic == session.topic || tokenTopic == session.sessionName;
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
                });
                if (tokenMatches.isNotEmpty) {
                  matchingTokenData = tokenMatches.first;
                }
              }

              // 2. Merging Activities
              StudentActivity? matchingActivity;
              if (activities.isNotEmpty) {
<<<<<<< HEAD
                final activityMatches = activities.where((a) =>
                    a.title == session.topic || a.title == session.sessionName);
=======
                final activityMatches = activities.where((a) => a.title == session.topic || a.title == session.sessionName);
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
                if (activityMatches.isNotEmpty) {
                  matchingActivity = activityMatches.first;
                }
              }

              if (matchingTokenData != null || matchingActivity != null) {
                return SessionConfig(
                  id: session.id,
                  sessionName: session.sessionName,
                  topic: session.topic,
                  date: session.date,
                  startTime: session.startTime,
                  endTime: session.endTime,
                  hall: session.hall,
                  status: session.status,
                  targetLevel: session.targetLevel,
                  alert: session.alert,
<<<<<<< HEAD
                  token: matchingTokenData?['token']?.toString() ??
                      matchingActivity?.token ??
                      session.token,
                  expiryTime: matchingTokenData?['timings']?['expiry_time'] ??
                      matchingTokenData?['expiry_time'] ??
                      session.expiryTime,
                  joiningTime: matchingTokenData?['timings']?['joining_time'] ??
                      matchingTokenData?['joining_time'] ??
                      session.joiningTime,
=======
                  token: matchingTokenData?['token']?.toString() ?? matchingActivity?.token ?? session.token,
                  expiryTime: matchingTokenData?['timings']?['expiry_time'] ?? matchingTokenData?['expiry_time'] ?? session.expiryTime,
                  joiningTime: matchingTokenData?['timings']?['joining_time'] ?? matchingTokenData?['joining_time'] ?? session.joiningTime,
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
                  activity: matchingActivity ?? session.activity,
                );
              }
              return session;
            }).toList();
          }
        } catch (e) {
          debugPrint('Error merging tokens/activities: $e');
        }

        debugPrint('API Status: Success [session_configs] with merged data');
        return sessions;
      } else {
        lastSessionsFetchWasSuccessful = false;
<<<<<<< HEAD
        debugPrint(
            'Sessions Error Status: ${response.statusCode}, using fallback');
=======
        debugPrint('Sessions Error Status: ${response.statusCode}, using fallback');
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
        return _getDummySessionConfigs();
      }
    } catch (e) {
      lastSessionsFetchWasSuccessful = false;
      debugPrint('Sessions Fetch Fallback engaged due to error: $e');
      return _getDummySessionConfigs();
    }
  }

<<<<<<< HEAD
  static Future<Map<String, dynamic>> login(
      String username, String password) async {
    // Try multiple endpoints to be resilient to backend changes
    final List<String> endpoints = [
      '$baseUrl/api/student/login', // Most common pattern for this app
      '$baseUrl/api/supervisor/login', // Explicit supervisor endpoint
      '$baseUrl/api/auth/login', // Alternative pattern
      '$baseUrl/auth/login', // Legacy/Common pattern
      '$baseUrl/api/login', // Alternate pattern
=======
  static Future<Map<String, dynamic>> login(String username, String password) async {
    // Try multiple endpoints to be resilient to backend changes
    final List<String> endpoints = [
      '$baseUrl/api/student/login', // Most common pattern for this app
      '$baseUrl/api/auth/login',    // Alternative pattern
      '$baseUrl/auth/login',        // Legacy/Common pattern 
      '$baseUrl/api/login',         // Alternate pattern
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
    ];

    Object? lastError;
    // try endpoints
    for (final endpoint in endpoints) {
      try {
<<<<<<< HEAD
        final rawResponse =
            await _performLoginRequest(endpoint, username, password);
        return _normalizeLoginResponse(rawResponse);
      } catch (e) {
        lastError = e;
        final errorStr = e.toString().toLowerCase();
        final int? statusCode = _extractStatusCodeFromError(e);

        // If it's a 401 (Unauthorized), 403 (Forbidden), or 404 (Not Found),
        // try the next endpoint. This handles cases where a student might try
        // the supervisor endpoint first or vice versa.
        bool isRetryableError = errorStr.contains('401') ||
            errorStr.contains('403') ||
            errorStr.contains('404') ||
            errorStr.contains('500') ||
            errorStr.contains('502') ||
            errorStr.contains('503') ||
            errorStr.contains('504') ||
            errorStr.contains('bad gateway') ||
            errorStr.contains('gateway') ||
            errorStr.contains('timeout') ||
            errorStr.contains('failed to connect') ||
            errorStr.contains('errno') ||
            (statusCode != null && statusCode >= 500);

        if (isRetryableError) {
          debugPrint(
              'Notice: Issue with $endpoint ($errorStr), trying next fallback...');
          continue;
        }

        // For other errors (like 500 or malformed JSON), we might want to stop or rethrow
        // Check if it's a connection timeout, in which case we don't want to loop for 3 minutes
        if (errorStr.contains('timeout') ||
            errorStr.contains('failed to connect') ||
            errorStr.contains('errno') ||
            errorStr.contains('socketexception')) {
          debugPrint(
              'Notice: Connection error on $endpoint, skipping further retries to fail fast.');
          throw ApiException(
              'Connection timed out. The server might be slow or unreachable. Please try again.',
              statusCode: 408);
        }

=======
        return await _performLoginRequest(endpoint, username, password);
      } catch (e) {
        lastError = e;
        final errorStr = e.toString().toLowerCase();
        if (errorStr.contains('404') || 
            errorStr.contains('timeout') || 
            errorStr.contains('failed to connect') ||
            errorStr.contains('errno')) {
          debugPrint('Notice: Issue with $endpoint ($errorStr), trying next fallback...');
          continue;
        }
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
        rethrow;
      }
    }

<<<<<<< HEAD
    // Debug-only emergency login when backend is temporarily unavailable.
    if (kDebugMode && _isGatewayOrServerError(lastError)) {
      final normalizedUser = username.trim().toLowerCase();
      final role =
          normalizedUser.contains('supervisor') ? 'SUPERVISOR' : 'STUDENT';
      debugPrint(
          'Login fallback: using debug emergency session due to gateway/server error.');
      return {
        'token':
            'debug-fallback-token-${DateTime.now().millisecondsSinceEpoch}',
        'role': role,
        'user': {
          'name': username,
          'email':
              normalizedUser.contains('@') ? username : '$username@example.com',
          'role': role,
        },
      };
    }

    // FINAL FALLBACK: Dev Bypass for testing if API is down
    if (password == 'admin123') {
      debugPrint(
          'API Error: ${lastError.toString()}. Engaging Dev Bypass for admin123.');
=======
    // FINAL FALLBACK: Dev Bypass for testing if API is down
    if (password == 'admin123') {
      debugPrint('API Error: ${lastError.toString()}. Engaging Dev Bypass for admin123.');
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
      return {
        'token': 'dev-token-999',
        'role': 'STUDENT',
        'user': {
          'id': 1,
          'name': username,
          'email': '$username@example.com',
          'role': 'STUDENT',
          'department': 'Computer Science'
        }
      };
    }

<<<<<<< HEAD
    if (lastError != null) {
      if (lastError.toString().contains('TimeoutException') ||
          lastError.toString().contains('Connection timed out')) {
        throw ApiException(
            'Connection timed out. The server might be slow or unreachable. Please try again.',
            statusCode: 408);
      }
      throw lastError;
    }
    throw Exception('Login failed: API unreachable and no bypass used.');
  }

  static int? _extractStatusCodeFromError(Object error) {
    if (error is ApiException) {
      return error.statusCode;
    }

    final match = RegExp(r'\b([1-5]\d\d)\b').firstMatch(error.toString());
    if (match == null) return null;
    return int.tryParse(match.group(1)!);
  }

  static bool _isGatewayOrServerError(Object? error) {
    if (error == null) return false;
    final code = _extractStatusCodeFromError(error);
    if (code != null && code >= 500) return true;

    final lower = error.toString().toLowerCase();
    return lower.contains('bad gateway') ||
        lower.contains('gateway') ||
        lower.contains('upstream') ||
        lower.contains('502') ||
        lower.contains('503') ||
        lower.contains('504');
  }

  static Map<String, dynamic> _normalizeLoginResponse(
      Map<String, dynamic> raw) {
    final dynamic data = raw['data'];
    final dynamic user = raw['user'];
    final dynamic session = raw['session'];
    final dynamic result = raw['result'];

    final token = raw['token'] ??
        raw['accessToken'] ??
        raw['access_token'] ??
        (data is Map ? data['token'] : null) ??
        (data is Map ? data['accessToken'] : null) ??
        (data is Map ? data['access_token'] : null) ??
        (data is Map && data['session'] is Map
            ? data['session']['token']
            : null) ??
        (user is Map ? user['token'] : null) ??
        (session is Map ? session['token'] : null) ??
        (result is Map ? result['token'] : null);

    final role = raw['role'] ??
        raw['userRole'] ??
        (user is Map ? user['role'] : null) ??
        (user is Map ? user['userRole'] : null) ??
        (data is Map ? data['role'] : null) ??
        (data is Map ? data['userRole'] : null) ??
        (data is Map && data['user'] is Map ? data['user']['role'] : null) ??
        (session is Map ? session['role'] : null) ??
        (result is Map ? result['role'] : null);

    return {
      ...raw,
      if (token != null) 'token': token,
      if (role != null) 'role': role,
    };
  }

  static Future<Map<String, dynamic>> _performLoginRequest(
      String url, String username, String password,
      {int retryCount = 0}) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-Tunnel-Skip-AntiPhish': 'true',
      };

      final payloads = <Map<String, dynamic>>[
        {'username': username, 'password': password},
        {'email': username, 'password': password},
        {'userName': username, 'password': password},
        {'identifier': username, 'password': password},
        {'login': username, 'password': password},
      ];

      http.Response? lastResponse;
      for (int index = 0; index < payloads.length; index++) {
        final payload = payloads[index];
        debugPrint(
            'API Request: POST $url (attempt ${retryCount + 1}, payload ${index + 1}/${payloads.length})');

        final response = await http
            .post(
              Uri.parse(url),
              headers: headers,
              body: json.encode(payload),
            )
            .timeout(const Duration(seconds: 30));

        lastResponse = response;

        if (response.statusCode == 200 || response.statusCode == 201) {
          final decoded = json.decode(response.body);
          if (decoded is Map<String, dynamic>) {
            return decoded;
          }
          throw ApiException('Login response was not a JSON object.',
              statusCode: response.statusCode);
        }

        final status = response.statusCode;
        if (status == 400 || status == 401 || status == 422) {
          continue;
        }

        break;
      }

      final response = lastResponse!;

      debugPrint('API Response [login]: ${response.statusCode}');

      // Detect HTML response (Dev Tunnel anti-phishing page or Express 404)
      final body = response.body.trimLeft();
      if (body.startsWith('<!DOCTYPE') ||
          body.startsWith('<html') ||
          body.startsWith('<HTML')) {
        debugPrint('Received HTML instead of JSON');

        // If it's a 404, throw immediately so login fallback can catch it
        if (response.statusCode == 404) {
          throw ApiException('HTTP Error 404: Not Found (HTML Response)',
              statusCode: 404);
=======
    if (lastError != null) throw lastError;
    throw Exception('Login failed: API unreachable and no bypass used.');
  }

  static Future<Map<String, dynamic>> _performLoginRequest(String url, String username, String password, {int retryCount = 0}) async {
    try {
      debugPrint('API Request: POST $url (attempt ${retryCount + 1})');
      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'X-Tunnel-Skip-AntiPhish': 'true',
            },
            body: json.encode({
              'username': username,
              'email': username, // Support both common field names
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('API Response [login]: ${response.statusCode}');
      
      // Detect HTML response (Dev Tunnel anti-phishing page or Express 404)
      final body = response.body.trimLeft();
      if (body.startsWith('<!DOCTYPE') || body.startsWith('<html') || body.startsWith('<HTML')) {
        debugPrint('Received HTML instead of JSON');
        
        // If it's a 404, throw immediately so login fallback can catch it
        if (response.statusCode == 404) {
          throw ApiException('HTTP Error 404: Not Found (HTML Response)', statusCode: 404);
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
        }

        if (retryCount < 2) {
          debugPrint('Retrying login request (anti-phishing bypass)...');
          await Future.delayed(const Duration(seconds: 1));
<<<<<<< HEAD
          return _performLoginRequest(url, username, password,
              retryCount: retryCount + 1);
        }
        throw ApiException(
            'Server returned an HTML page instead of JSON (Status: ${response.statusCode}).',
            statusCode: response.statusCode);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
        throw ApiException('Login response was not a JSON object.',
            statusCode: response.statusCode);
=======
          return _performLoginRequest(url, username, password, retryCount: retryCount + 1);
        }
        throw ApiException('Server returned an HTML page instead of JSON (Status: ${response.statusCode}).', statusCode: response.statusCode);
      }
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body) as Map<String, dynamic>;
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
      } else {
        try {
          final decoded = json.decode(response.body);
          throw ApiException(
            decoded['message'] ??
                decoded['error'] ??
                'Login failed: ${response.statusCode}',
            statusCode: response.statusCode,
          );
        } catch (_) {
<<<<<<< HEAD
          throw ApiException('Login failed: ${response.statusCode}',
              statusCode: response.statusCode);
=======
          throw ApiException('Login failed: ${response.statusCode}', statusCode: response.statusCode);
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
        }
      }
    } catch (e) {
      rethrow;
    }
  }

<<<<<<< HEAD
  /// Verifies a student-entered OTP by:
  /// 1. Fetching the active hall-qr-token to read its `current_otp`
  /// 2. Comparing the entered OTP with `current_otp`
  /// 3. If correct, posting to the scan endpoint to mark attendance
  static Future<Map<String, dynamic>> verifyStudentOtp(String enteredOtp,
      {String? sessionTitle, String? activityType}) async {
    // ── Step 1: Fetch the active hall-qr-token ──────────────────────────────
    final Map<String, String> headers = {
      'Accept': 'application/json',
      'X-Tunnel-Skip-AntiPhish': 'true',
      if (_authToken != null) 'Authorization': 'Bearer $_authToken',
    };

    // Endpoints to try for fetching the active token
    final List<String> fetchEndpoints = [
      '$baseUrl/api/hall-qr-tokens/active',
      '$baseUrl/api/hall-qr-tokens?active=true',
      '$baseUrl/api/hall-qr-tokens',
    ];

    Map<String, dynamic>? activeToken;

    for (final url in fetchEndpoints) {
      try {
        debugPrint('API [verifyStudentOtp] Fetching active tokens: GET $url');
        final response = await http
            .get(Uri.parse(url), headers: headers)
            .timeout(const Duration(seconds: 10));

        debugPrint(
            'API [verifyStudentOtp] Token fetch response: ${response.statusCode}');

        if (response.statusCode == 200) {
          final dynamic decoded = json.decode(response.body);
          List<dynamic> tokensList = [];
          
          if (decoded is List) {
            tokensList = decoded;
          } else if (decoded is Map<String, dynamic>) {
            final inner = decoded['data'] ?? decoded['tokens'] ?? decoded['content'] ?? [decoded];
            if (inner is List) tokensList = inner;
          }

          if (tokensList.isNotEmpty) {
            // Find the token that matches the sessionTitle
            final match = tokensList.firstWhere((t) {
              final session = t['session'] ?? t['session_config'] ?? t['sessionConfig'] ?? {};
              final topic = (session['topic'] ?? session['sessionName'] ?? session['session_name'] ?? '').toString();
              
              // Case-insensitive match on title/topic
              final bool titleMatches = sessionTitle == null || 
                                       topic.toLowerCase() == sessionTitle.toLowerCase() ||
                                       sessionTitle == 'Session';
              
              // Match on activity type if provided
              final String tActivity = (t['activity_type'] ?? t['activityType'] ?? session['activity_type'] ?? '').toString();
              final bool activityMatches = activityType == null ||
                                          tActivity.toLowerCase() == activityType.toLowerCase() ||
                                          tActivity.isEmpty;

              final bool isActive = t['is_active'] == true || t['isActive'] == true || t['status'] == 'ACTIVE';
              
              return titleMatches && activityMatches && isActive;
            }, orElse: () => null);

            if (match != null) {
              activeToken = match as Map<String, dynamic>;
              debugPrint('Found matching active token for session "$sessionTitle": $activeToken');
              break;
            }
          }
        }
      } catch (e) {
        debugPrint('Error fetching tokens from $url: $e');
      }
    }

    // ── Step 2: Compare OTPs ─────────────────────────────────────────────────
    if (activeToken != null) {
      final String? currentOtp = activeToken['current_otp']?.toString() ??
          activeToken['currentOtp']?.toString() ??
          activeToken['otp']?.toString();

      debugPrint(
          'OTP check — entered: $enteredOtp, current_otp: $currentOtp');

      if (currentOtp != null && currentOtp.isNotEmpty) {
        if (enteredOtp.trim() != currentOtp.trim()) {
          throw ApiException(
            'Incorrect OTP. Please check the 6-digit code and try again.',
            statusCode: 400,
          );
        }
        // OTP matched — mark attendance via the scan endpoint
        debugPrint('OTP matched! Marking attendance...');
        return verifyOtp(enteredOtp, sessionTitle: sessionTitle);
      }
    }

    // ── Fallback: no active token fetched — try scan endpoint directly ────────
    debugPrint(
        'No active token found locally. Attempting direct scan endpoint...');
    return verifyOtp(enteredOtp, sessionTitle: sessionTitle);
  }

  static Future<Map<String, dynamic>> verifyOtp(String code,
      {String? sessionTitle}) async {
    // Endpoints ordered by likelihood — /api/sessions/scan confirmed from backend logs
    final List<String> endpoints = [
      '$baseUrl/api/sessions/scan',
      '$baseUrl/api/hall-qr-tokens/scan',
      '$baseUrl/hall-qr-tokens/scan',
      '$baseUrl/api/hall-qr-tokens/verify',
      '$baseUrl/api/attendance/mark',
      '$baseUrl/api/attendance/verify',
    ];

    Object? lastError;

    for (final url in endpoints) {
      try {
        final Map<String, dynamic> payload = {'otp': code};

        debugPrint('API Attempt [verifyOtp]: POST $url, otp: $code');
        final response = await http
            .post(
              Uri.parse(url),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'X-Tunnel-Skip-AntiPhish': 'true',
                if (_authToken != null) 'Authorization': 'Bearer $_authToken',
              },
              body: json.encode(payload),
            )
            .timeout(const Duration(seconds: 10));

        debugPrint('API Response [verifyOtp] ($url): ${response.statusCode}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          final decoded = json.decode(response.body);
          debugPrint('OTP Verification Success: $decoded');
          return decoded;
        }

        // Check if body is JSON  
        final body = response.body.trim();
        if (body.startsWith('{') || body.startsWith('[')) {
          // JSON response = the endpoint exists and understood the request
          // This is the real error (e.g. "Invalid OTP"), stop retrying
          final decoded = json.decode(body) as Map<String, dynamic>;
          final msg = decoded['message'] ?? decoded['error'] ?? 'Failed to verify OTP (${response.statusCode})';
          debugPrint('Endpoint $url responded with JSON error: $msg');
          throw ApiException(msg, statusCode: response.statusCode);
        }

        // HTML = endpoint not found, continue to next
        debugPrint('HTML 404 at $url — endpoint does not exist, trying next...');
        lastError = ApiException('No active session found for this OTP.', statusCode: 404);

      } catch (e) {
        if (e is ApiException && e.message != 'No active session found for this OTP.') {
          // Real error from a valid endpoint — show to user immediately
          rethrow;
        }
        lastError = e;
        debugPrint('Error on $url: $e');
      }
    }

    if (lastError is ApiException) throw lastError!;
    throw ApiException('No active session found. Please ensure there is an active session.', statusCode: 404);
  }


  static Future<List<dynamic>> getAttendees(String tokenId) async {
    final url = '$baseUrl/api/hall-qr-tokens/$tokenId/attendees';
    debugPrint('API Request: GET $url');
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'X-Tunnel-Skip-AntiPhish': 'true',
          if (_authToken != null) 'Authorization': 'Bearer $_authToken',
        },
      ).timeout(const Duration(seconds: 15));

      debugPrint('API Response [getAttendees]: ${response.statusCode}');

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        if (decoded is List) return decoded;
        if (decoded is Map<String, dynamic>) {
          return decoded['data'] ??
              decoded['attendees'] ??
              decoded['students'] ??
              decoded['content'] ??
              [decoded];
        }
        return [];
      } else {
        debugPrint('getAttendees error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Error in getAttendees: $e');
      return [];
    }
  }

  static Future<List<dynamic>> getActiveAttendees(
      {String? activityType, bool all = false}) async {
    String url = '$baseUrl/api/hall-qr-tokens/active/attendees';

    List<String> queryParams = [];
    if (activityType != null && activityType.isNotEmpty) {
      queryParams.add('activity_type=$activityType');
    }
    if (all) {
      queryParams.add('all=true');
    }

    if (queryParams.isNotEmpty) {
      url += '?${queryParams.join('&')}';
    }

    debugPrint('API Request: GET $url');
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
          'X-Tunnel-Skip-AntiPhish': 'true',
          if (_authToken != null) 'Authorization': 'Bearer $_authToken',
        },
      ).timeout(const Duration(seconds: 15));

      debugPrint('API Response [getActiveAttendees]: ${response.statusCode}');

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        if (decoded is List) return decoded;
        if (decoded is Map<String, dynamic>) {
          return decoded['data'] ??
              decoded['attendees'] ??
              decoded['students'] ??
              decoded['content'] ??
              [decoded];
        }
        return [];
      } else {
        debugPrint('getActiveAttendees error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Error in getActiveAttendees: $e');
      return [];
=======
  static Future<Map<String, dynamic>> scanToken(String code) async {
    final url = '$baseUrl/api/hall-qr-tokens/scan';
    debugPrint('API Request: POST $url with token: $code');
    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'X-Tunnel-Skip-AntiPhish': 'true',
              if (_authToken != null) 'Authorization': 'Bearer $_authToken',
            },
            body: json.encode({'otp': code}),
          )
          .timeout(const Duration(seconds: 15));

      debugPrint('API Response [scanToken]: ${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        try {
          final decoded = json.decode(response.body);
          throw ApiException(
            decoded['message'] ?? 
            decoded['error'] ?? 
            'Failed to mark attendance: ${response.statusCode}',
            statusCode: response.statusCode,
          );
        } catch (_) {
          throw ApiException('Failed to mark attendance: ${response.statusCode}', statusCode: response.statusCode);
        }
      }
    } catch (e) {
      debugPrint('Error in scanToken: $e');
      rethrow;
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
    }
  }

  static Future<List<dynamic>> getHallQrTokens({String? booking}) async {
    try {
      final Map<String, String> headers = {
        'Accept': 'application/json',
        'X-Tunnel-Skip-AntiPhish': 'true',
      };
      if (_authToken != null) {
        headers['Authorization'] = 'Bearer $_authToken';
      }

      String url = '$baseUrl/api/hall-qr-tokens';
      if (booking != null) {
        url += '?question_type=$booking';
      }
      debugPrint('API Request: GET $url');
      final response = await http
          .get(Uri.parse(url), headers: headers)
<<<<<<< HEAD
          .timeout(const Duration(seconds: 10));
=======
          .timeout(const Duration(seconds: 30));
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3

      debugPrint('API Response [hall-qr-tokens]: ${response.statusCode}');

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        if (decoded is List) return decoded;
        if (decoded is Map<String, dynamic>) {
<<<<<<< HEAD
          return decoded['data'] ??
              decoded['tokens'] ??
              decoded['content'] ??
              decoded['session_configs'] ??
              decoded['sessionConfigs'] ??
              decoded['sessions'] ??
              [decoded];
        }
        return [];
      } else {
        debugPrint(
            'hall-qr-tokens error: ${response.statusCode}, using fallback');
=======
          return decoded['data'] ?? 
                 decoded['tokens'] ?? 
                 decoded['content'] ?? 
                 decoded['session_configs'] ?? 
                 decoded['sessionConfigs'] ?? 
                 decoded['sessions'] ?? 
                 [decoded];
        }
        return [];
      } else {
        debugPrint('hall-qr-tokens error: ${response.statusCode}, using fallback');
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
        return _getDummyHallQrTokens();
      }
    } catch (e) {
      debugPrint('getHallQrTokens error: $e, using fallback');
      return _getDummyHallQrTokens();
    }
  }

<<<<<<< HEAD
  static Future<void> updateSessionTableCount({
    required String sessionId,
    required int tableCount,
  }) async {
    final List<String> endpoints = [
      '$baseUrl/api/hall-qr-tokens/$sessionId/table-count',
      '$baseUrl/api/hall-qr-tokens/$sessionId/tables/count',
      '$baseUrl/api/session-configs/$sessionId/table-count',
      '$baseUrl/api/sessions/$sessionId/table-count',
      '$baseUrl/api/hall-qr-tokens/$sessionId', // Some APIs use generic update
    ];

    final List<Map<String, dynamic>> jsonPayloads = [
      {'table_count': tableCount},
      {'total_tables': tableCount},
      {'tableCount': tableCount},
      {'count': tableCount},
    ];

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Tunnel-Skip-AntiPhish': 'true',
      if (_authToken != null) 'Authorization': 'Bearer $_authToken',
    };

    Object? lastError;
    
    // 1. Try JSON payloads with PATCH, POST, and PUT
    for (final endpoint in endpoints) {
      for (final method in ['PATCH', 'POST', 'PUT']) {
        for (final payload in jsonPayloads) {
          try {
            debugPrint('API Attempt: $method $endpoint (JSON: $payload)');
            http.Response response;
            
            if (method == 'PATCH') {
              response = await http.patch(Uri.parse(endpoint), headers: headers, body: json.encode(payload)).timeout(const Duration(seconds: 10));
            } else if (method == 'POST') {
              response = await http.post(Uri.parse(endpoint), headers: headers, body: json.encode(payload)).timeout(const Duration(seconds: 10));
            } else {
              response = await http.put(Uri.parse(endpoint), headers: headers, body: json.encode(payload)).timeout(const Duration(seconds: 10));
            }

            if (response.statusCode >= 200 && response.statusCode < 300) {
              debugPrint('API Success: $method $endpoint');
              return;
            }
            debugPrint('API Failed (${response.statusCode}): $method $endpoint');
            lastError = ApiException('Server returned ${response.statusCode}', statusCode: response.statusCode);
          } catch (e) {
            lastError = e;
          }
        }
      }
    }

    // 2. Try sending as Query Parameters (some backends expect this for simple updates)
    for (final endpoint in endpoints) {
      final queryUrl = Uri.parse(endpoint).replace(queryParameters: {
        'table_count': tableCount.toString(),
        'tableCount': tableCount.toString(),
        'count': tableCount.toString(),
      });
      
      for (final method in ['POST', 'PATCH', 'GET']) {
        try {
          debugPrint('API Attempt: $method $queryUrl (Query Params)');
          http.Response response;
          if (method == 'POST') response = await http.post(queryUrl, headers: headers).timeout(const Duration(seconds: 10));
          else if (method == 'PATCH') response = await http.patch(queryUrl, headers: headers).timeout(const Duration(seconds: 10));
          else response = await http.get(queryUrl, headers: headers).timeout(const Duration(seconds: 10));

          if (response.statusCode >= 200 && response.statusCode < 300) {
            debugPrint('API Success (Query): $method $queryUrl');
            return;
          }
        } catch (e) {
          lastError = e;
        }
      }
    }

    // 3. Try raw body (the "count alone")
    for (final endpoint in endpoints) {
      try {
        debugPrint('API Attempt: POST $endpoint (Raw Body: $tableCount)');
        final response = await http.post(
          Uri.parse(endpoint), 
          headers: {...headers, 'Content-Type': 'text/plain'}, 
          body: tableCount.toString()
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode >= 200 && response.statusCode < 300) {
          debugPrint('API Success (Raw): POST $endpoint');
          return;
        }
      } catch (e) {
        lastError = e;
      }
    }

    if (lastError != null) throw lastError;
    throw ApiException('Failed to update table count after multiple attempts.');
  }

=======
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
  static List<dynamic> _getDummyHallQrTokens() {
    return [
      {
        'token': 'TOKEN-123-ABC',
        'is_active': true,
        'current_otp': '123456',
        'activity_type': 'booked',
        'timings': {
          'start_time': '2026-02-25T10:00:00Z',
          'expiry_time': '2026-02-25T23:59:59Z',
          'joining_time': '2026-02-25T10:05:00Z',
        },
        'session': {
          'topic': 'Design Thinking Sprint',
          'hall_name': 'Hall A',
          'start_time': '10:00 AM',
          'date': '2024-02-21',
          'status': 'ACTIVE'
        },
      },
      {
        'token': 'TOKEN-456-XYZ',
        'is_active': false,
        'timings': {
          'start_time': '2026-02-25T14:30:00Z',
          'expiry_time': '2026-02-25T15:00:00Z',
          'joining_time': '2026-02-25T14:35:00Z',
        },
        'session': {
          'topic': 'Project Review',
          'hall_name': 'Hall B',
          'start_time': '02:30 PM',
          'date': '2024-02-21',
          'status': 'PENDING'
        }
      }
    ];
  }

  static Future<Map<String, dynamic>> getUserProfile() async {
    final List<String> endpoints = [
<<<<<<< HEAD
      '$baseUrl/auth/me', // Prioritize the one requested by the user
      '$baseUrl/api/auth/me',
=======
      '$baseUrl/api/auth/me',
      '$baseUrl/auth/me',
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
      '$baseUrl/api/me',
    ];

    final Map<String, String> headers = {
      'Accept': 'application/json',
      'X-Tunnel-Skip-AntiPhish': 'true',
    };

    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    Object? lastError;
    for (final url in endpoints) {
      try {
        debugPrint('API Request: GET $url');
        final response = await http
            .get(Uri.parse(url), headers: headers)
<<<<<<< HEAD
            .timeout(const Duration(seconds: 30));

        debugPrint('API Response [profile]: ${response.statusCode}');

=======
            .timeout(const Duration(seconds: 10));

        debugPrint('API Response [profile]: ${response.statusCode}');
        
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
        if (response.statusCode == 200) {
          return json.decode(response.body);
        } else if (response.statusCode == 404) {
          debugPrint('404 on $url, trying next fallback if available...');
<<<<<<< HEAD
          lastError =
              ApiException('Profile endpoint not found: 404', statusCode: 404);
          continue;
        } else {
          throw ApiException('Failed to load profile: ${response.statusCode}',
              statusCode: response.statusCode);
=======
          lastError = ApiException('Profile endpoint not found: 404', statusCode: 404);
          continue;
        } else {
          throw ApiException('Failed to load profile: ${response.statusCode}', statusCode: response.statusCode);
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
        }
      } catch (e) {
        lastError = e;
        if (e is! ApiException || e.statusCode != 404) {
          rethrow;
        }
      }
    }

    if (lastError != null) throw lastError;
    throw Exception('Failed to load profile: unknown error');
  }

  static Future<List<StudentActivity>> getStudentActivities() async {
    final url = '$baseUrl/api/student/activities';
    debugPrint('Fetching activities from: $url');
    debugPrint('Auth Token present: ${_authToken != null}');

    try {
      final Map<String, String> headers = {
        'Accept': 'application/json',
        'X-Tunnel-Skip-AntiPhish': 'true',
      };

      if (_authToken != null) {
        headers['Authorization'] = 'Bearer $_authToken';
      }

      final response = await http
          .get(
            Uri.parse(url),
            headers: headers,
          )
<<<<<<< HEAD
          .timeout(const Duration(
              seconds: 10)); // Reduced to 30s to trigger fallback faster

      debugPrint('API Response Status: [activities] ${response.statusCode}');

      if (response.statusCode == 200) {
        lastActivitiesFetchWasSuccessful = true;
        final dynamic decoded = json.decode(response.body);

=======
          .timeout(const Duration(seconds: 10)); // Reduced to 30s to trigger fallback faster

      debugPrint('API Response Status: [activities] ${response.statusCode}');
      
      if (response.statusCode == 200) {
        lastActivitiesFetchWasSuccessful = true;
        final dynamic decoded = json.decode(response.body);
        
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
        List<dynamic> jsonList;
        if (decoded is List) {
          jsonList = decoded;
        } else if (decoded is Map<String, dynamic>) {
          jsonList = decoded['data'] ??
              decoded['content'] ??
              decoded['activities'] ??
              [decoded];
        } else {
          debugPrint('Invalid response format, using fallback');
          return _getDummyActivities();
        }

        return jsonList
            .map((json) =>
                StudentActivity.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        lastActivitiesFetchWasSuccessful = false;
<<<<<<< HEAD
        debugPrint(
            'Activities Error Status: ${response.statusCode}, using fallback');
=======
        debugPrint('Activities Error Status: ${response.statusCode}, using fallback');
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
        return _getDummyActivities();
      }
    } catch (e) {
      lastActivitiesFetchWasSuccessful = false;
      debugPrint('Activities Fetch Fallback engaged due to error: $e');
      return _getDummyActivities();
    }
  }

  static List<StudentActivity> _getDummyActivities() {
    return const [
      StudentActivity(
        id: '1',
        title: 'Group Discussion',
        subtitle: 'Table 5 • 10:00 AM',
        progressLabel: 'Collaboration',
        progress: 0.3,
        level: 3,
        levels: 10,
        status: 'ACTIVE',
        credits: '+50 Credits',
        activityType: 'DISCUSSION',
        category: 'Communication',
        completedLevels: 3,
        progressPercent: 30.0,
        token: 'GD-123',
      ),
      StudentActivity(
        id: '2',
        title: 'Team Presentation',
        subtitle: 'Pending Review',
        progressLabel: 'Presentation',
        progress: 0.25,
        level: 2,
        levels: 8,
        status: 'PENDING',
        credits: '+100 Credits',
        activityType: 'PRESENTATION',
        category: 'Soft Skills',
        completedLevels: 2,
        progressPercent: 25.0,
      ),
      StudentActivity(
        id: '3',
        title: 'Peer Assessment',
        subtitle: 'Feedback',
        progressLabel: 'Feedback',
        progress: 1.0,
        level: 6,
        levels: 6,
        status: 'COMPLETED',
        credits: '+30 Credits',
        activityType: 'ASSESSMENT',
        category: 'Feedback',
        completedLevels: 6,
        progressPercent: 100.0,
      ),
      StudentActivity(
        id: '4',
        title: 'Technical Interview',
        subtitle: 'Problem Solving',
        progressLabel: 'Problem Solving',
        progress: 0.66,
        level: 8,
        levels: 12,
        status: 'PENDING',
        credits: '+120 Credits',
        activityType: 'INTERVIEW',
        category: 'Technical',
        completedLevels: 8,
        progressPercent: 66.0,
      ),
    ];
  }

  static List<SessionConfig> _getDummySessionConfigs() {
    final now = DateTime.now();
<<<<<<< HEAD
    final today =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final tomorrow =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${(now.day + 1).toString().padLeft(2, '0')}";

=======
    final today = "${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}";
    final tomorrow = "${now.year}-${now.month.toString().padLeft(2,'0')}-${(now.day + 1).toString().padLeft(2,'0')}";
    
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
    return [
      SessionConfig(
        id: '1',
        sessionName: 'Morning Group Discussion',
        topic: 'AI Ethics & Society',
        date: today,
        startTime: '10:00',
        endTime: '11:00',
        hall: 'Main Auditorium',
        status: 'ACTIVE',
        targetLevel: '4',
        alert: 'Laptop required',
      ),
      SessionConfig(
        id: '2',
        sessionName: 'Technical Interview Prep',
        topic: 'Data Structures',
        date: today,
        startTime: '14:00',
        endTime: '16:00',
        hall: 'Lab 3',
        status: 'SCHEDULED',
        targetLevel: '5',
      ),
      SessionConfig(
        id: '3',
        sessionName: 'Communication Skills',
        topic: 'Public Speaking',
        date: tomorrow,
        startTime: '09:00',
        endTime: '10:30',
        hall: 'Seminar Hall B',
        status: 'UPCOMING',
        targetLevel: '3',
      ),
    ];
  }

  static Future<List<RankingData>> getRankings() async {
    try {
      final Map<String, String> headers = {
        'Accept': 'application/json',
        'X-Tunnel-Skip-AntiPhish': 'true',
      };
      if (_authToken != null) {
        headers['Authorization'] = 'Bearer $_authToken';
      }

      final url = '$baseUrl/api/admin-analytics/rankings';
      debugPrint('API Request: GET $url');
      final response = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 15));

      debugPrint('API Response [rankings]: ${response.statusCode}');

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        List<dynamic> jsonList;
        if (decoded is List) {
          jsonList = decoded;
        } else if (decoded is Map<String, dynamic>) {
          jsonList = decoded['data'] ?? decoded['rankings'] ?? [decoded];
        } else {
          return _getDummyRankings();
        }

        return jsonList
            .map((json) => RankingData.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        return _getDummyRankings();
      }
    } catch (e) {
      debugPrint('Rankings fetch error: $e');
      return _getDummyRankings();
    }
  }

  static List<RankingData> _getDummyRankings() {
    return const [
      RankingData(rank: '#1', name: 'Adhish S', team: 'Team A', score: 62),
      RankingData(rank: '#2', name: 'Indhuja V', team: 'Team B', score: 25),
      RankingData(rank: '#3', name: 'Govarthini G', team: 'Team C', score: 23),
      RankingData(rank: '#4', name: 'Rahul K', team: 'Team D', score: 21),
      RankingData(rank: '#5', name: 'Sowmiya R', team: 'Team A', score: 19),
      RankingData(rank: '#6', name: 'Pradeep M', team: 'Team B', score: 18),
      RankingData(rank: '#7', name: 'Ananya P', team: 'Team C', score: 17),
      RankingData(rank: '#8', name: 'Karthik S', team: 'Team D', score: 16),
      RankingData(rank: '#9', name: 'Deepika J', team: 'Team A', score: 15),
      RankingData(rank: '#10', name: 'Manoj V', team: 'Team B', score: 14),
    ];
  }

  // Booking logic
<<<<<<< HEAD
  static Future<void> bookSlot(
      StudentActivity activity, DateTime date, String timeRange) async {
    
    // Try to extract hall from subtitle (e.g., "Main Hall • 10:00 AM")
    String hallName = 'Main Hall';
    if (activity.subtitle.contains('•')) {
      final parts = activity.subtitle.split('•');
      if (parts.isNotEmpty) {
        hallName = parts.first.trim();
      }
    } else if (activity.subtitle.isNotEmpty && !activity.subtitle.contains(':')) {
      // If it's not a time string (no ":"), assume it's a hall or description
      hallName = activity.subtitle;
    }
    
    // Special mapping for design consistency if hall is still default
    if (hallName == 'Main Hall') {
      if (activity.title.toLowerCase().contains('technical')) {
        hallName = 'Tech Hub, Lab 4';
      } else if (activity.title.toLowerCase().contains('discussion')) {
        hallName = 'Room 302, Main Building';
      }
    }

    _bookedSlots.insert(0, {
      'id': 'local_${DateTime.now().millisecondsSinceEpoch}',
      'title': 'Session', // Match screenshot: Large text is "Session"
      'date': date,
      'time': timeRange,
      'hall': hallName,
      'targetLevel': activity.levels.toString(),
      'warning': 'Please be on time',
      'activityType': activity.title, // Match screenshot: Tag is the activity title (e.g., "GROUP DISCUSSION")
      'status': 'UPCOMING',
    });
    
    debugPrint(
        'Booked slot locally: ${activity.title} (${activity.activityType}) at $timeRange in $hallName on $date');
    
    // Simulate API latency for "fetching" feel
    await Future.delayed(const Duration(milliseconds: 800));
  }

  static Future<List<Map<String, dynamic>>> getBookedSlots() async {
    final List<Map<String, dynamic>> allSessions = [];
    
    // 1. Add locally booked slots first (most recent first)
    for (final slot in _bookedSlots) {
      final DateTime date = slot['date'];
      allSessions.add({
        ...slot,
        'displayDate': DateFormat('MMM dd').format(date),
      });
    }

    try {
      // 2. Fetch all available tokens from the API to capture any active sessions
      final List<dynamic> tokens = await getHallQrTokens();
      debugPrint('Fetched ${tokens.length} total tokens from API');

      for (var token in tokens) {
        final sessionData = token['session'] ?? token['session_config'] ?? token['sessionConfig'] ?? {};
        final timings = token['timings'] ?? {};
        
        // Extract session name/title
        final String title = sessionData['topic'] ?? sessionData['sessionName'] ?? sessionData['session_name'] ?? 'Session';
        
        // Extracting date and time
        String? rawDate = sessionData['date'] ?? timings['start_time'] ?? timings['expiry_time'] ?? token['created_at'] ?? token['date'];
        
        String timeRange = 'N/A';
        try {
          if (sessionData['start_time'] != null && sessionData['end_time'] != null) {
            timeRange = '${sessionData['start_time']} - ${sessionData['end_time']}';
          } else if (timings['start_time'] != null) {
            final dt = DateTime.tryParse(timings['start_time'].toString());
            if (dt != null) {
              timeRange = DateFormat('hh:mm a').format(dt);
              if (timings['expiry_time'] != null) {
                final edt = DateTime.tryParse(timings['expiry_time'].toString());
                if (edt != null) {
                  timeRange += ' - ${DateFormat('hh:mm a').format(edt)}';
                }
              }
            } else {
              timeRange = timings['start_time'].toString();
            }
          }
        } catch (e) {
          debugPrint('Error parsing timeRange: $e');
        }
        
        DateTime sessionDate = DateTime.now();
        if (rawDate != null) {
          try {
            sessionDate = DateTime.parse(rawDate.toString());
          } catch (e) {
            final tryDate = DateTime.tryParse(rawDate.toString());
            if (tryDate != null) sessionDate = tryDate;
          }
        }

        final displayDate = DateFormat('MMM dd').format(sessionDate);

        // Skip if this token title AND date matches a local one (deduplication)
        if (allSessions.any((s) => s['title'] == title && s['displayDate'] == displayDate)) {
          continue; 
        }

        String status = 'UPCOMING';
        if (token['is_active'] == true || token['status'] == 'ACTIVE') {
          status = 'ACTIVE';
        }

        allSessions.add({
          'id': token['id']?.toString() ?? token['token_id']?.toString() ?? '',
          'title': title,
          'date': sessionDate,
          'time': timeRange,
          'hall': sessionData['hall_name'] ?? sessionData['hallName'] ?? sessionData['hall'] ?? 'Main Hall',
          'targetLevel': sessionData['target_level'] ?? sessionData['targetLevel'] ?? '1',
          'status': status,
          'displayDate': DateFormat('MMM dd').format(sessionDate),
          'warning': token['alert'] ?? sessionData['alert'] ?? '',
          'otp': token['current_otp']?.toString() ?? token['otp']?.toString() ?? '',
          'activityType': token['activity_type']?.toString() ?? 
                          sessionData['activity_type']?.toString() ?? 
                          token['activityType']?.toString() ?? 'SESSION',
        });
      }
    } catch (e) {
      debugPrint('Error in getBookedSlots API: $e');
    }
    
    return allSessions;
=======
  static Future<void> bookSlot(StudentActivity activity, DateTime date, String timeRange) async {
    // In a real app, this would be a POST request
    _bookedSlots.add({
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': activity.title,
      'date': date,
      'time': timeRange,
      'hall': activity.subtitle.split('•').first.trim(),
      'targetLevel': activity.levels.toString(),
      'warning': 'Please be on time',
    });
    debugPrint('Booked slot: ${activity.title} at $timeRange on ${date.toString()}');
  }

  static List<Map<String, dynamic>> getBookedSlots() {
    final now = DateTime.now();
    return _bookedSlots.map((slot) {
      final DateTime date = slot['date'];
      final String timeRange = slot['time'];
      
      // Parse start time from range "10:00 AM - 11:30 AM"
      final startTimeStr = timeRange.split('-').first.trim();
      final startTimeParts = startTimeStr.split(' ');
      final timeParts = startTimeParts[0].split(':');
      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);
      final amPm = startTimeParts[1];

      if (amPm == 'PM' && hour < 12) hour += 12;
      if (amPm == 'AM' && hour == 12) hour = 0;

      final sessionStartTime = DateTime(date.year, date.month, date.day, hour, minute);
      
      String status = 'UPCOMING';
      if (now.isAfter(sessionStartTime)) {
        status = 'ACTIVE';
      }

      return {
        ...slot,
        'status': status,
        'displayDate': DateFormat('MMM dd').format(date),
      };
    }).where((slot) => slot['status'] == 'UPCOMING' || slot['status'] == 'ACTIVE').toList();
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
  }
}
