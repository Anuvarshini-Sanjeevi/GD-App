import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:gdapp/models/session_config.dart';
import 'package:gdapp/models/student_activity.dart';

class ApiService {
  static String? _authToken;

  static set authToken(String? token) => _authToken = token;
  static String? get authToken => _authToken;
  static bool lastActivitiesFetchWasSuccessful = false;
  static bool lastSessionsFetchWasSuccessful = false;

  // Use 10.0.2.2 for Android emulator to reach host's localhost
  // Use localhost for web/desktop
  static String get baseUrl {
    // For web, always use localhost
    if (kIsWeb) {
      return 'http://localhost:8080';
    }
    
    // For mobile (physical device or emulator), use the machine's LAN IP
    // This allows physical devices to connect to the backend
    // Make sure your backend server is listening on 0.0.0.0 (all interfaces)
    return 'http://10.150.250.228:8080';
  }

  static Future<List<SessionConfig>> getActiveSessionConfigs() async {
    try {
      final Map<String, String> headers = {
        'Accept': 'application/json',
        'X-Tunnel-Skip-AntiPhish': 'true',
      };
      
      if (_authToken != null) {
        headers['Authorization'] = 'Bearer $_authToken';
      }

      debugPrint('API Request: GET $baseUrl/api/session-configs/active');
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/session-configs/active'),
            headers: headers,
          )
          .timeout(const Duration(seconds: 30));

      debugPrint('API Response [active_sessions]: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        lastSessionsFetchWasSuccessful = true;
        final dynamic decoded = json.decode(response.body);

        // Handle both direct list response and wrapped response
        List<dynamic> jsonList;
        if (decoded is List) {
          jsonList = decoded;
        } else if (decoded is Map<String, dynamic>) {
          // Try common wrapper keys
          jsonList = decoded['data'] ??
              decoded['content'] ??
              decoded['sessionConfigs'] ??
              decoded['session_configs'] ??
              [decoded]; // If it's a single object, wrap in list
        } else {
          debugPrint('Invalid response, using fallback');
          return _getDummySessionConfigs();
        }

        debugPrint('API Status: Success [active_sessions]');
        return jsonList
            .map((json) => SessionConfig.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        lastSessionsFetchWasSuccessful = false;
        debugPrint('Sessions Error Status: ${response.statusCode}, using fallback');
        return _getDummySessionConfigs();
      }
    } catch (e) {
      lastSessionsFetchWasSuccessful = false;
      debugPrint('Sessions Fetch Fallback engaged due to error: $e');
      return _getDummySessionConfigs();
    }
  }

  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      debugPrint('API Request: POST $baseUrl/auth/login');
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'X-Tunnel-Skip-AntiPhish': 'true',
            },
            body: json.encode({
              'username': username,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 10));

      debugPrint('API Response [login]: ${response.statusCode}');
      final decoded = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return decoded as Map<String, dynamic>;
      } else {
        throw HttpException(
          decoded['message'] ??
              decoded['error'] ??
              'Login failed: ${response.statusCode}',
        );
      }
    } catch (e) {
      rethrow;
    }
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
          .timeout(const Duration(seconds: 10)); // Reduced to 30s to trigger fallback faster

      debugPrint('API Response Status: [activities] ${response.statusCode}');
      
      if (response.statusCode == 200) {
        lastActivitiesFetchWasSuccessful = true;
        final dynamic decoded = json.decode(response.body);
        
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
        debugPrint('Activities Error Status: ${response.statusCode}, using fallback');
        return _getDummyActivities();
      }
    } catch (e) {
      lastActivitiesFetchWasSuccessful = false;
      debugPrint('Activities Fetch Fallback engaged due to error: $e');
      return _getDummyActivities();
    }
  }

  static List<StudentActivity> _getDummyActivities() {
    return [
      StudentActivity(
        id: '1',
        title: 'Group Discussion',
        subtitle: 'Table 5 • 10:00 AM',
        progressLabel: 'Collaboration',
        progress: 0.3,
        level: 10,
        status: 'ACTIVE',
        credits: '+50 Credits',
      ),
      StudentActivity(
        id: '2',
        title: 'Team Presentation',
        subtitle: 'Pending Review',
        progressLabel: 'Presentation',
        progress: 0.25,
        level: 8,
        status: 'PENDING',
        credits: '+100 Credits',
      ),
      StudentActivity(
        id: '3',
        title: 'Peer Assessment',
        subtitle: 'Feedback',
        progressLabel: 'Feedback',
        progress: 0.65,
        level: 6,
        status: 'COMPLETED',
        credits: '+30 Credits',
      ),
      StudentActivity(
        id: '4',
        title: 'Technical Interview',
        subtitle: 'Problem Solving',
        progressLabel: 'Problem Solving',
        progress: 0.71,
        level: 12,
        status: 'PENDING',
        credits: '+120 Credits',
      ),
    ];
  }

  static List<SessionConfig> _getDummySessionConfigs() {
    final now = DateTime.now();
    final today = "${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}";
    final tomorrow = "${now.year}-${now.month.toString().padLeft(2,'0')}-${(now.day + 1).toString().padLeft(2,'0')}";
    
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
}
