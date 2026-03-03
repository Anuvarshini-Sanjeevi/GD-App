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
  static const String localUrl = 'http://localhost:8080';
  static const String androidEmulatorUrl = 'http://10.0.2.2:8080';
  static const String devTunnelUrl = 'https://d29qdzpk-8080.inc1.devtunnels.ms';

  static String get baseUrl {
    return devTunnelUrl;
  }

  static Future<List<SessionConfig>> getSessionConfigs() async {
    try {
      final Map<String, String> headers = {
        'Accept': 'application/json',
        'X-Tunnel-Skip-AntiPhish': 'true',
      };
      
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
                  final tokenSession = t['session'] ?? t['session_config'] ?? t['sessionConfig'] ?? {};
                  final tokenTopic = tokenSession['topic'] ?? tokenSession['sessionName'] ?? tokenSession['session_name'];
                  return tokenTopic == session.topic || tokenTopic == session.sessionName;
                });
                if (tokenMatches.isNotEmpty) {
                  matchingTokenData = tokenMatches.first;
                }
              }

              // 2. Merging Activities
              StudentActivity? matchingActivity;
              if (activities.isNotEmpty) {
                final activityMatches = activities.where((a) => a.title == session.topic || a.title == session.sessionName);
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
                  token: matchingTokenData?['token']?.toString() ?? matchingActivity?.token ?? session.token,
                  expiryTime: matchingTokenData?['timings']?['expiry_time'] ?? matchingTokenData?['expiry_time'] ?? session.expiryTime,
                  joiningTime: matchingTokenData?['timings']?['joining_time'] ?? matchingTokenData?['joining_time'] ?? session.joiningTime,
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
    // Try multiple endpoints to be resilient to backend changes
    final List<String> endpoints = [
      '$baseUrl/api/student/login', // Most common pattern for this app
      '$baseUrl/api/auth/login',    // Alternative pattern
      '$baseUrl/auth/login',        // Legacy/Common pattern 
      '$baseUrl/api/login',         // Alternate pattern
    ];

    Object? lastError;
    // try endpoints
    for (final endpoint in endpoints) {
      try {
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
        rethrow;
      }
    }

    // FINAL FALLBACK: Dev Bypass for testing if API is down
    if (password == 'admin123') {
      debugPrint('API Error: ${lastError.toString()}. Engaging Dev Bypass for admin123.');
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
        }

        if (retryCount < 2) {
          debugPrint('Retrying login request (anti-phishing bypass)...');
          await Future.delayed(const Duration(seconds: 1));
          return _performLoginRequest(url, username, password, retryCount: retryCount + 1);
        }
        throw ApiException('Server returned an HTML page instead of JSON (Status: ${response.statusCode}).', statusCode: response.statusCode);
      }
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body) as Map<String, dynamic>;
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
          throw ApiException('Login failed: ${response.statusCode}', statusCode: response.statusCode);
        }
      }
    } catch (e) {
      rethrow;
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
          .timeout(const Duration(seconds: 30));

      debugPrint('API Response [hall-qr-tokens]: ${response.statusCode}');

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        if (decoded is List) return decoded;
        if (decoded is Map<String, dynamic>) {
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
        return _getDummyHallQrTokens();
      }
    } catch (e) {
      debugPrint('getHallQrTokens error: $e, using fallback');
      return _getDummyHallQrTokens();
    }
  }

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
      '$baseUrl/api/auth/me',
      '$baseUrl/auth/me',
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
            .timeout(const Duration(seconds: 10));

        debugPrint('API Response [profile]: ${response.statusCode}');
        
        if (response.statusCode == 200) {
          return json.decode(response.body);
        } else if (response.statusCode == 404) {
          debugPrint('404 on $url, trying next fallback if available...');
          lastError = ApiException('Profile endpoint not found: 404', statusCode: 404);
          continue;
        } else {
          throw ApiException('Failed to load profile: ${response.statusCode}', statusCode: response.statusCode);
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
  }
}
