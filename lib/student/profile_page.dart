import 'package:flutter/material.dart';
import 'package:gdapp/services/auth_service.dart';
import 'package:gdapp/services/api_service.dart';
import 'package:gdapp/login_page.dart';

class ProfilePage extends StatefulWidget {
  final Function(int, {bool? showScanner}) onNavigate;
  const ProfilePage({Key? key, required this.onNavigate}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _profile;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final profile = await ApiService.getUserProfile();
      debugPrint('PROFILE DATA: $profile');
      if (profile.containsKey('user')) {
        debugPrint('USER OBJECT KEYS: ${profile['user'].keys.toList()}');
      } else {
        debugPrint('PROFILE OBJECT KEYS: ${profile.keys.toList()}');
      }
      if (mounted) {
        setState(() {
          _profile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $_error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadProfile,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final user = _profile?['user'] ?? _profile;
    
    // Detailed extraction with every possible variation
    final name = user?['name']?.toString() ?? 
                 user?['full_name']?.toString() ?? 
                 user?['displayName']?.toString() ?? 
                 user?['fullName']?.toString() ?? 
                 'Student';
                 
    final role = user?['role']?.toString() ?? 
                 user?['user_role']?.toString() ?? 
                 user?['userRole']?.toString() ?? 
                 'Scholar';
                 
    final level = user?['level']?.toString() ?? 
                  user?['current_level']?.toString() ?? 
                  user?['student_level']?.toString() ?? 
                  user?['currentLevel']?.toString() ?? 
                  '-';
                  
    final batch = user?['batch']?.toString() ?? 
                  user?['year']?.toString() ?? 
                  user?['batch_year']?.toString() ?? 
                  user?['joining_year']?.toString() ?? 
                  user?['batchYear']?.toString() ?? 
                  '-';
                  
    final department = user?['department']?.toString() ?? 
                       user?['dept']?.toString() ?? 
                       user?['dept_name']?.toString() ?? 
                       user?['department_name']?.toString() ?? 
                       user?['branch']?.toString() ?? 
                       user?['deptName']?.toString() ?? 
                       'Not Assigned';
                       
    final rollNumber = user?['roll_number']?.toString() ?? 
                       user?['rollNumber']?.toString() ?? 
                       user?['rollNo']?.toString() ?? 
                       user?['roll_no']?.toString() ?? 
                       user?['reg_no']?.toString() ?? 
                       user?['regNo']?.toString() ?? 
                       user?['admission_no']?.toString() ?? 
                       user?['username']?.toString() ?? 
                       '-';
                       
    final email = user?['email']?.toString() ?? 
                  user?['email_id']?.toString() ?? 
                  user?['emailId']?.toString() ?? 
                  'No Email';
                  
    final phone = user?['phone_number']?.toString() ?? 
                  user?['phoneNumber']?.toString() ?? 
                  user?['phone']?.toString() ?? 
                  user?['mobile']?.toString() ?? 
                  user?['mobile_number']?.toString() ?? 
                  user?['mobileNo']?.toString() ?? 
                  user?['contact']?.toString() ?? 
                  'No Phone';
                  
    final rank = user?['rank']?.toString() ?? 
                 user?['global_rank']?.toString() ?? 
                 user?['current_rank']?.toString() ?? 
                 user?['rank_position']?.toString() ?? 
                 user?['rankPosition']?.toString() ?? 
                 '-';
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Color(0xFF0D2146),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF0D2146)),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 10),
              // Profile Image Section
              Center(
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 55,
                        backgroundColor: const Color(0xFFE5EDFF),
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'S',
                          style: const TextStyle(
                            color: Color(0xFF2E63F2),
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D2146),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F7FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$level • Batch $batch',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Info Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildInfoCard('Roll Number', rollNumber)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildInfoCard('Batch', batch)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildInfoCard('Department', department)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildInfoCard('Rank', '#$rank', isIcon: true, icon: Icons.emoji_events_outlined, iconColor: Colors.orange)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Contact Details
              _buildSectionHeader('Personal Details'),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(Icons.email_outlined, 'Email', email),
                    const Divider(height: 24),
                    _buildDetailRow(Icons.phone_outlined, 'Phone', phone),
                    const Divider(height: 24),
                  ],
                ),
              ),
             
              const SizedBox(height: 24),
              // Log Out Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () async {
                      await AuthService().signOut();
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                          (route) => false,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5252),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.logout, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Log Out',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Debug helper (tap to reveal keys)
              GestureDetector(
                onLongPress: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Debug: Profile Keys'),
                      content: SingleChildScrollView(
                        child: Text(user != null ? user.keys.join('\n') : 'No user data'),
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
                      ],
                    ),
                  );
                },
                child: Text(
                  'Long press here for debug info',
                  style: TextStyle(color: Colors.grey.withOpacity(0.3), fontSize: 10),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0D2146),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade400),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 10,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF0D2146),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String value, {bool isIcon = false, IconData? icon, Color? iconColor}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              if (isIcon && icon != null) ...[
                Icon(icon, size: 16, color: iconColor),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D2146),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
