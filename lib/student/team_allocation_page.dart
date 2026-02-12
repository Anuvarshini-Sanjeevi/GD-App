import 'package:flutter/material.dart';
import 'package:gdapp/student/activity_assessment_page.dart';
import 'package:gdapp/models/team_member.dart';

class TeamAllocationPage extends StatelessWidget {
  const TeamAllocationPage({Key? key}) : super(key: key);

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
                  const Text(
                    '05',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Group B • Creative Zone',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
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
                  child: const Text(
                    '10/10',
                    style: TextStyle(
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
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ActivityAssessmentPage(
                      teamMembers: _getTeamMembers(),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A7FFF),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Start the Assessment',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
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
        childAspectRatio: 0.8, // Decreased to provide more height for the "YOU" badge
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: member.isYou ? const Color(0xFFF5F8FF) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: member.isYou ? const Color(0xFF4A7FFF).withOpacity(0.2) : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Avatar
          Container(
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF4A7FFF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'YOU',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<TeamMember> _getTeamMembers() {
    return [
      TeamMember(
        name: 'Priya Sharma (You)',
        department: 'Computer Science',
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
  }
}
