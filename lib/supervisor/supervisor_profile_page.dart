import 'package:flutter/material.dart';
import 'dart:async';
import 'package:gdapp/services/auth_service.dart';
import 'package:gdapp/services/api_service.dart';
import 'package:gdapp/login_page.dart';

class SupervisorProfilePage extends StatefulWidget {
  final VoidCallback? onBack;

  const SupervisorProfilePage({Key? key, this.onBack}) : super(key: key);

  @override
  State<SupervisorProfilePage> createState() => _SupervisorProfilePageState();
}

class _SupervisorProfilePageState extends State<SupervisorProfilePage> {
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
    
    // Exhaustive extraction for supervisor
    final name = user?['name']?.toString() ?? 
                 user?['full_name']?.toString() ?? 
                 user?['displayName']?.toString() ?? 
                 user?['fullName']?.toString() ?? 
                 'Supervisor';
                 
    final role = user?['role']?.toString() ?? 
                 user?['user_role']?.toString() ?? 
                 user?['userRole']?.toString() ?? 
                 'Faculty';
                 
    final department = user?['department']?.toString() ?? 
                       user?['dept']?.toString() ?? 
                       user?['dept_name']?.toString() ?? 
                       user?['department_name']?.toString() ?? 
                       user?['branch']?.toString() ?? 
                       user?['deptName']?.toString() ?? 
                       'Not Assigned';
                       
    final office = user?['office']?.toString() ?? 
                   user?['location']?.toString() ?? 
                   user?['office_location']?.toString() ?? 
                   user?['officeLocation']?.toString() ?? 
                   'Not Specified';
                   
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
                  
    final batch = user?['batch']?.toString() ?? 
                  user?['year']?.toString() ?? 
                  user?['batch_year']?.toString() ?? 
                  user?['joining_year']?.toString() ?? 
                  user?['batchYear']?.toString() ?? 
                  '-';
                  
    final rollNumber = user?['roll_number']?.toString() ?? 
                       user?['rollNumber']?.toString() ?? 
                       user?['rollNo']?.toString() ?? 
                       user?['roll_no']?.toString() ?? 
                       user?['reg_no']?.toString() ?? 
                       user?['regNo']?.toString() ?? 
                       user?['admission_no']?.toString() ?? 
                       user?['username']?.toString() ?? 
                       '-';

    return Scaffold(
        backgroundColor: const Color(0xFFF8FAFF),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Blue Header
                _buildHeader(context, name, role),

                // Floating Access Card
                _buildAccessCard(),

                // Active Session Card (New)


                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('ACADEMIC DETAILS'),
                      const SizedBox(height: 12),
                      _buildDetailsCard([
                        _buildDetailItem(
                          icon: Icons.domain_outlined,
                          label: 'Department',
                          value: department,
                        ),
                        const Divider(height: 1, indent: 56),
                        _buildDetailItem(
                          icon: Icons.location_on_outlined,
                          label: 'Office Location',
                          value: office,
                        ),
                      ]),

                      const SizedBox(height: 28),

                      _buildSectionHeader('CONTACT INFORMATION'),
                      const SizedBox(height: 12),
                      _buildDetailsCard([
                        _buildDetailItem(
                          icon: Icons.mail_outline,
                          label: 'Email Address',
                          value: email,
                        ),
                        const Divider(height: 1, indent: 56),
                        _buildDetailItem(
                          icon: Icons.phone_outlined,
                          label: 'Phone Number',
                          value: phone,
                        ),
                        const Divider(height: 1, indent: 56),
                        _buildDetailItem(
                          icon: Icons.badge_outlined,
                          label: 'Roll / Admin Number',
                          value: rollNumber,
                        ),
                        const Divider(height: 1, indent: 56),
                        _buildDetailItem(
                          icon: Icons.calendar_today_outlined,
                          label: 'Batch',
                          value: batch,
                        ),
                      ]),

                      const SizedBox(height: 28),

                      // Settings Button
                      _buildActionCard(
                        icon: Icons.tune_outlined,
                        label: 'Account Settings',
                        onTap: () {},
                      ),

                      const SizedBox(height: 16),

                      // Logout Button
                      _buildLogoutButton(context),

                      const SizedBox(height: 20),
                      // Debug helper for supervisor
                      Center(
                        child: GestureDetector(
                          onLongPress: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Debug: Supervisor Keys'),
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
                            'Long press for debug info',
                            style: TextStyle(color: Colors.grey.withOpacity(0.3), fontSize: 10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildHeader(BuildContext context, String name, String role) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 40),
      decoration: const BoxDecoration(
        color: Color(0xFF2563EB), // Rich blue color from image
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: widget.onBack ?? () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const Text(
                  'Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 48), // Spacer for centering
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Profile Image
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border:
                  Border.all(color: Colors.white.withOpacity(0.2), width: 1),
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'S',
                style: const TextStyle(
                  color: Color(0xFF2563EB),
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            role,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessCard() {
    return Transform.translate(
      offset: const Offset(0, -35),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF9C3), // Light yellow
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.shield_outlined,
                color: Color(0xFFB45309), // Gold/Amber
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Supervisor Access',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Verified Authority',
                    style: TextStyle(
                      fontSize: 13,
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7), // Light green
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Active',
                style: TextStyle(
                  color: Color(0xFF166534), // Dark green
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: Color(0xFF64748B),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildDetailsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF3B82F6), size: 22),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1F5F9)),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF64748B), size: 22),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Color(0xFF94A3B8), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return InkWell(
      onTap: () async {
        await AuthService().signOut();
        if (context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (route) => false,
          );
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2), // Light red
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFEE2E2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.logout, color: Color(0xFFDC2626), size: 22),
            SizedBox(width: 12),
            Text(
              'Sign Out',
              style: TextStyle(
                color: Color(0xFFDC2626),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
