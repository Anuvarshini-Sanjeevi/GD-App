import 'package:flutter/material.dart';
import 'dart:async';
import 'package:gdapp/student/activity_assessment_page.dart';
import 'package:gdapp/student/verification_page.dart';
import 'package:gdapp/models/team_member.dart';
import 'package:gdapp/services/api_service.dart';

class TeamAllocationPage extends StatefulWidget {
  const TeamAllocationPage({Key? key}) : super(key: key);

  @override
  State<TeamAllocationPage> createState() => _TeamAllocationPageState();
}

class _TeamAllocationPageState extends State<TeamAllocationPage> {
  Timer? _timer;
  int _secondsRemaining = 300; // 5 minute running time
  bool _isAuthenticated = false;
<<<<<<< HEAD
  bool _isLoading = true;
  int _scannedCount = 0;
  final int _totalMembers = 10;
  Map<String, dynamic>? _userProfile;
  Map<String, dynamic>? _activeSession;
  List<dynamic> _fetchedAttendees = [];

  String get _currentActivityType {
    final type = _activeSession?['activity_type']?.toString().toUpperCase() ?? 
                 _userProfile?['activity_type']?.toString().toUpperCase() ?? 
                 'GROUP_DISCUSSION';
    
    // Map to the specific values requested by the user
    if (type.contains('TECHNICAL')) return 'TECHNICAL_EVENTS';
    if (type.contains('PRESENTATION')) return 'PRESENTATION';
    if (type.contains('CASE')) return 'CASE_STUDY';
    if (type.contains('DEBATE')) return 'DEBATE_CLUB';
    return 'GROUP_DISCUSSION';
  }
=======
  int _scannedCount = 6;
  final int _totalMembers = 10;
  bool _isLoading = true;
  Map<String, dynamic>? _userProfile;
  Map<String, dynamic>? _activeSession;
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadSessionTiming(),
      _loadUserProfile(),
    ]);
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await ApiService.getUserProfile();
      if (mounted) {
        setState(() {
          _userProfile = profile;
        });
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }
  }
  Future<void> _loadSessionTiming() async {
    setState(() => _isLoading = true);
    try {
      // 1. Try fetching specifically booked tokens
      List<dynamic> tokens = await ApiService.getHallQrTokens(booking: 'booked');
      
      // 2. Fallback to all tokens if booked is empty
      if (tokens.isEmpty) {
        debugPrint('Booked tokens empty, fetching all tokens...');
        tokens = await ApiService.getHallQrTokens();
      }

      if (tokens.isNotEmpty) {
        // 3. Find specifically active token or fallback to first
        final activeToken = tokens.firstWhere(
          (t) => t['is_active'] == true || t['status'] == 'ACTIVE',
          orElse: () => tokens.first,
        );
        
        debugPrint('Selected Session for Assessment: ${activeToken.keys.toList()}');
        
        final timings = activeToken['timings'] ?? activeToken;
        if (timings['expiry_time'] != null || timings['expire_time'] != null) {
          final expiryStr = timings['expiry_time'] ?? timings['expire_time'];
          final expiry = expiryStr is String ? DateTime.parse(expiryStr) : DateTime.fromMillisecondsSinceEpoch(expiryStr);
          final now = DateTime.now();
          final diff = expiry.difference(now).inSeconds;
          
          setState(() {
            _activeSession = activeToken;
            _secondsRemaining = (diff > 0 && diff < 300) ? diff : 300;
            _isLoading = false;
          });
          _startTimer();
          return;
        }
      }
    } catch (e) {
      debugPrint('Error loading timing: $e');
    }
    
    setState(() {
      _secondsRemaining = 300;
      _isLoading = false;
    });
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

<<<<<<< HEAD
  Future<void> _refreshAttendees() async {
    try {
      final type = _currentActivityType;
      debugPrint('Refreshing attendees for activity type: $type');
      
      final attendees = await ApiService.getActiveAttendees(
        activityType: type, 
        all: true
      );
          
      if (mounted) {
        final user = _userProfile?['user'] ?? _userProfile;
        final userName = user?['name']?.toString() ?? user?['full_name']?.toString() ?? '';
        
        setState(() {
          _fetchedAttendees = attendees;
          
          // Auto-detect authentication if user is in the list
          if (userName.isNotEmpty) {
            final bool isAlreadyInList = attendees.any((a) {
              final aName = (a['name'] ?? a['full_name'] ?? a['student_name'] ?? '').toString();
              return aName.toLowerCase() == userName.toLowerCase();
            });
            if (isAlreadyInList) {
              _isAuthenticated = true;
            }
          }

          // Only update count if we actually got data
          if (attendees.isNotEmpty) {
            _scannedCount = attendees.length;
          }
        });
      }
    } catch (e) {
      debugPrint('Error refreshing attendees: $e');
    }
  }

=======
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
<<<<<<< HEAD
        
        // Refresh attendees every 5 seconds
        if (_secondsRemaining % 5 == 0) {
          _refreshAttendees();
        }
=======
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
      } else {
        _timer?.cancel();
        _navigateToAssessment();
      }
    });
  }

  void _navigateToAssessment() {
    if (mounted) {
      final questions = _getAssessmentQuestions();
      debugPrint('Navigating to assessment with ${questions.length} questions');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ActivityAssessmentPage(
            teamMembers: _getTeamMembers(),
            questions: questions,
          ),
        ),
      );
    }
  }

<<<<<<< HEAD
  void _handleAuthentication() async {
    setState(() {
      _isAuthenticated = true;
      if (_scannedCount == 0) _scannedCount = 1;
    });
    // Immediately fetch attendees after authentication
    await _refreshAttendees();
=======
  void _handleAuthentication() {
    setState(() {
      _isAuthenticated = true;
      // Note: If authenticated, we might want to refresh session data 
      // but if the timer is the same for the whole team, we just continue.
      _scannedCount = 7;
    });
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
  }

  void _onVerifyPress() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const VerificationPage()),
    );
    if (result != null) {
      _handleAuthentication();
    }
  }

  String _formatTimer(int seconds) {
    if (_isLoading) return "--:--";
    int minutes = seconds ~/ 60;
    int secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Team Allocation',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timer Display
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4D4D).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.timer_outlined, color: Color(0xFFFF4D4D), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      _formatTimer(_secondsRemaining),
                      style: const TextStyle(
                        color: Color(0xFFFF4D4D),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),

            // Assigned Table Card
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF4A7FFF),
                    Color(0xFF5B8FFF),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    'ASSIGNED TABLE',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
<<<<<<< HEAD
                  Text(
                    _userProfile?['table_no']?.toString() ?? 
                    _userProfile?['table']?.toString() ?? 
                    _activeSession?['table_no']?.toString() ?? 
                    '05', // Dynamic fallback
                    style: const TextStyle(
=======
                  const Text(
                    '05', // This could be made dynamic if available in profile
                    style: TextStyle(
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
                      color: Colors.white,
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${_activeSession?['session']?['topic'] ?? _userProfile?['session']?['topic'] ?? _userProfile?['topic'] ?? 'Group B'} • ${_activeSession?['session']?['hall_name'] ?? _activeSession?['session']?['hall'] ?? 'Main Hall'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Team Members Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Team Members',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A7FFF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$_scannedCount/$_totalMembers scanned',
                    style: const TextStyle(
                      color: Color(0xFF4A7FFF),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Team Members Grid
            _buildTeamMembersList(),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
<<<<<<< HEAD
          child: _isAuthenticated 
            ? SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _navigateToAssessment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C853), // Vivid green
                    padding: const EdgeInsets.symmetric(vertical: 20),
=======
          child: !_isAuthenticated 
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _onVerifyPress,
                      icon: const Icon(Icons.qr_code_scanner),
                      label: const Text('Scan Table QR'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A7FFF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _onVerifyPress,
                      icon: const Icon(Icons.key),
                      label: const Text('Enter OTP'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF4A7FFF),
                        side: const BorderSide(color: Color(0xFF4A7FFF)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ActivityAssessmentPage(
                          teamMembers: _getTeamMembers(),
                          questions: _getAssessmentQuestions(),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Verified • Start Assessment',
                    style: TextStyle(
<<<<<<< HEAD
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
=======
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
                      color: Colors.white,
                    ),
                  ),
                ),
<<<<<<< HEAD
              )
            : SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _onVerifyPress,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Scan Table QR'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A7FFF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
=======
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
              ),
        ),
      ),
    );
  }

  Widget _buildTeamMembersList() {
    final members = _getTeamMembers();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: members.length,
      itemBuilder: (context, index) {
        return _buildTeamMemberCard(members[index]);
      },
    );
  }

  Widget _buildTeamMemberCard(TeamMember member) {
<<<<<<< HEAD
    bool isScanned = member.isScanned;
=======
    bool isScanned = member.isYou ? _isAuthenticated : (member.name.contains('Arjun') || member.name.contains('Mei') || member.name.contains('David') || member.name.contains('Sarah') || member.name.contains('Carlos'));
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: member.isYou ? const Color(0xFFF3F7FF) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: member.isYou ? const Color(0xFF4A7FFF).withOpacity(0.2) : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Avatar
              Center(
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: member.avatarColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      member.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Name
              Text(
                member.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 4),
              
              // Department
              Text(
                member.department,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              // YOU badge
              if (member.isYou) ...[
                const SizedBox(height: 8),
                Center(
                  child: Container(
<<<<<<< HEAD
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A7FFF),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4A7FFF).withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
=======
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A7FFF),
                      borderRadius: BorderRadius.circular(8),
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
                    ),
                    child: const Text(
                      'YOU',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
<<<<<<< HEAD
                        letterSpacing: 0.8,
=======
                        letterSpacing: 0.5,
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (isScanned)
            const Positioned(
<<<<<<< HEAD
              top: 8,
              right: 8,
              child: Icon(Icons.check_circle, color: Color(0xFF00C853), size: 24),
=======
              top: 0,
              right: 0,
              child: Icon(Icons.check_circle, color: Colors.green, size: 20),
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
            ),
        ],
      ),
    );
  }

  List<TeamMember> _getTeamMembers() {
    final user = _userProfile?['user'] ?? _userProfile;
    final userName = user?['name']?.toString() ?? user?['full_name']?.toString() ?? 'Student';
    final userDept = user?['department']?.toString() ?? user?['dept']?.toString() ?? 'Computer Science';

<<<<<<< HEAD
    List<TeamMember> team = [];
    
    // Add real members from API
    if (_fetchedAttendees.isNotEmpty) {
      for (var attendee in _fetchedAttendees) {
        final aName = attendee['name']?.toString() ?? 
                      attendee['full_name']?.toString() ?? 
                      attendee['student_name']?.toString() ?? 'Student';
        final aDept = attendee['department']?.toString() ?? 
                      attendee['dept']?.toString() ?? 'N/A';
        final bool isMe = aName.toLowerCase() == userName.toLowerCase() && userName.isNotEmpty;
        
        team.add(TeamMember(
          name: isMe ? '$aName (You)' : aName,
          department: aDept,
          isYou: isMe,
          avatarColor: isMe ? const Color(0xFF64B5F6) : Colors.primaries[team.length % Colors.primaries.length],
          isScanned: true, // If they are in fetched list, they are scanned
        ));
      }
    } 
    
    // If we are authenticated but list is empty, show at least 'You'
    if (team.isEmpty || (team.isNotEmpty && !team.any((m) => m.isYou))) {
      final bool alreadyHasMe = team.any((m) => m.name.contains('(You)'));
      if (!alreadyHasMe) {
        team.insert(0, TeamMember(
          name: '$userName (You)',
          department: userDept,
          isYou: true,
          avatarColor: const Color(0xFF64B5F6),
          isScanned: _isAuthenticated,
        ));
      }
    }

    return team;
=======
    return [
      TeamMember(
        name: '$userName (You)',
        department: userDept,
        isYou: true,
        avatarColor: const Color(0xFF64B5F6),
      ),
      TeamMember(
        name: 'Arjun Patel',
        department: 'Mechanical Eng.',
        avatarColor: const Color(0xFF5C6BC0),
      ),
      TeamMember(
        name: 'Mei Ling',
        department: 'Information Tech',
        avatarColor: const Color(0xFFE57373),
      ),
      TeamMember(
        name: 'David Okafor',
        department: 'Civil Eng.',
        avatarColor: const Color(0xFF81C784),
      ),
      TeamMember(
        name: 'Sarah Miller',
        department: 'Electrical Eng.',
        avatarColor: const Color(0xFF78909C),
      ),
      TeamMember(
        name: 'Carlos Rodriguez',
        department: 'Design School',
        avatarColor: const Color(0xFFFFB74D),
      ),
      TeamMember(
        name: 'Aisha Khalil',
        department: 'Architecture',
        avatarColor: const Color(0xFF7986CB),
      ),
      TeamMember(
        name: 'Rahul Verma',
        department: 'Data Science',
        avatarColor: const Color(0xFFA1887F),
      ),
      TeamMember(
        name: 'Lina Tran',
        department: 'Biotech',
        avatarColor: const Color(0xFFE0E0E0),
      ),
      TeamMember(
        name: 'James Wilson',
        department: 'Robotics',
        avatarColor: const Color(0xFF90A4AE),
      ),
    ];
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
  }

  List<String> _getAssessmentQuestions() {
    if (_activeSession == null) return [];
    
    debugPrint('Extracting questions from session data...');
    debugPrint('Keys available: ${_activeSession!.keys.toList()}');
    
    // 1. Try finding 'evaluation_questions' or 'assessment_questions' at any level
    List<dynamic>? questionsData;
    
    // Try top level
    questionsData = _activeSession?['evaluation_questions'] ?? 
                    _activeSession?['assessment_questions'];
                    
    // Try nested in session/sessionConfig
    if (questionsData == null) {
      final sessionData = _activeSession?['session'] ?? 
                          _activeSession?['sessionConfig'] ?? 
                          _activeSession?['session_config'];
      if (sessionData is Map) {
        debugPrint('Checking nested session data: ${sessionData.keys.toList()}');
        questionsData = sessionData['evaluation_questions'] ?? 
                        sessionData['assessment_questions'];
      }
    }
                                        
    if (questionsData != null && questionsData.isNotEmpty) {
      debugPrint('Found ${questionsData.length} questions in API response');
      return questionsData
          .map((q) => (q['question_text'] ?? q['question'] ?? q['questionText'] ?? '').toString())
          .where((text) => text.isNotEmpty)
          .toList();
    }
    
    debugPrint('WARNING: No questions found in session data keys: ${_activeSession!.keys.toList()}');
    return [];
  }
}

