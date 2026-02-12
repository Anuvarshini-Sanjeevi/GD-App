import 'package:flutter/material.dart';
import 'package:gdapp/services/auth_service.dart';
import 'package:gdapp/login_page.dart';

class SupervisorProfilePage extends StatelessWidget {
  final VoidCallback? onBack;

  const SupervisorProfilePage({Key? key, this.onBack}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFF8FAFF),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Blue Header
                _buildHeader(context),

                // Floating Access Card
                _buildAccessCard(),

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
                          value: 'Computer Science & Eng.',
                        ),
                        const Divider(height: 1, indent: 56),
                        _buildDetailItem(
                          icon: Icons.location_on_outlined,
                          label: 'Office Location',
                          value: 'Science Block A, Room 304',
                        ),
                      ]),

                      const SizedBox(height: 28),

                      _buildSectionHeader('CONTACT INFORMATION'),
                      const SizedBox(height: 12),
                      _buildDetailsCard([
                        _buildDetailItem(
                          icon: Icons.mail_outline,
                          label: 'Email Address',
                          value: 'sarah.j@university.edu',
                        ),
                        const Divider(height: 1, indent: 56),
                        _buildDetailItem(
                          icon: Icons.phone_outlined,
                          label: 'Phone Number',
                          value: '+1 (555) 123-4567',
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

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildHeader(BuildContext context) {
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
                  onPressed: onBack ?? () => Navigator.pop(context),
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
            child: const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white24,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=32'),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Dr. Sarah Johnson',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Assistant Professor',
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
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF64748B),
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
                style: TextStyle(
                  fontSize: 12,
                  color: const Color(0xFF94A3B8),
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
            Icon(Icons.chevron_right, color: const Color(0xFF94A3B8), size: 20),
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
