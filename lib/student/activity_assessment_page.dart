import 'package:flutter/material.dart';
import 'package:gdapp/models/team_member.dart';
import 'dart:async';

class ActivityAssessmentPage extends StatefulWidget {
  final List<TeamMember> teamMembers;
  
  const ActivityAssessmentPage({
    Key? key,
    required this.teamMembers,
  }) : super(key: key);

  @override
  State<ActivityAssessmentPage> createState() => _ActivityAssessmentPageState();
}

class _ActivityAssessmentPageState extends State<ActivityAssessmentPage> {
  int currentQuestion = 1;
  final int totalQuestions = 5;
  int remainingTime = 300; // 5 minutes in seconds
  
  TeamMember? firstPlace;
  TeamMember? secondPlace;
  TeamMember? thirdPlace;
  
  late List<TeamMember> availableMembers;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Remove "You" from the list for ranking
    availableMembers = widget.teamMembers
        .where((member) => !member.isYou)
        .toList();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    remainingTime = 300;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (remainingTime > 0) {
            remainingTime--;
          } else {
            _timer?.cancel();
            _nextQuestion();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onMemberDraggedToRank(TeamMember member, int rank) {
    setState(() {
      // Remove from previous rank if already placed
      if (firstPlace == member) firstPlace = null;
      if (secondPlace == member) secondPlace = null;
      if (thirdPlace == member) thirdPlace = null;

      // Assign to new rank
      if (rank == 1) {
        firstPlace = member;
      } else if (rank == 2) {
        secondPlace = member;
      } else if (rank == 3) {
        thirdPlace = member;
      }
    });
  }

  void _removeFromRank(int rank) {
    setState(() {
      if (rank == 1) {
        firstPlace = null;
      } else if (rank == 2) {
        secondPlace = null;
      } else if (rank == 3) {
        thirdPlace = null;
      }
    });
  }

  List<TeamMember> _getAvailableMembers() {
    return availableMembers.where((member) {
      return member != firstPlace && 
             member != secondPlace && 
             member != thirdPlace;
    }).toList();
  }

  int _getRankedCount() {
    int count = 0;
    if (firstPlace != null) count++;
    if (secondPlace != null) count++;
    if (thirdPlace != null) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final available = _getAvailableMembers();
    final rankedCount = _getRankedCount();
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Activity Assessment',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Question Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question $currentQuestion of $totalQuestions',
                      style: const TextStyle(
                        color: Color(0xFF4A7FFF),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, size: 14, color: Colors.orange),
                          const SizedBox(width: 4),
                          Text(
                            '${(remainingTime ~/ 60).toString().padLeft(2, '0')}:${(remainingTime % 60).toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              color: Colors.orange,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Who was the most active participant\nin this session?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          // STATIC TOP 3 SECTION
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SELECT TOP 3 MEMBERS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Ranking Slots
                Row(
                  children: [
                    Expanded(child: _buildRankSlot(1, '1st Place', firstPlace)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildRankSlot(2, '2nd Place', secondPlace)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildRankSlot(3, '3rd Place', thirdPlace)),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),

          // SCROLLABLE TEAM MEMBERS SECTION
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Team Members Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'TEAM MEMBERS (${available.length})',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'Drag to fill top 3',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Team Members Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: available.length,
                    itemBuilder: (context, index) {
                      return _buildDraggableMemberCard(available[index]);
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          
          // Next Question Button
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: rankedCount == 3 ? _nextQuestion : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A7FFF),
                  disabledBackgroundColor: Colors.grey[300],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Next Question',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankSlot(int rank, String label, TeamMember? member) {
    return DragTarget<TeamMember>(
      onAccept: (draggedMember) {
        _onMemberDraggedToRank(draggedMember, rank);
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 140,
          decoration: BoxDecoration(
            gradient: member != null 
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF4A7FFF).withOpacity(0.1),
                      const Color(0xFF5B8FFF).withOpacity(0.15),
                    ],
                  )
                : null,
            color: member == null 
                ? (isHovering ? const Color(0xFFE3F2FD) : Colors.white)
                : null,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: member != null 
                  ? const Color(0xFF4A7FFF) 
                  : (isHovering ? const Color(0xFF4A7FFF) : Colors.grey[300]!),
              width: isHovering || member != null ? 2 : 1.5,
            ),
            boxShadow: member != null || isHovering
                ? [
                    BoxShadow(
                      color: const Color(0xFF4A7FFF).withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: member != null
              ? Stack(
                  children: [
                    // Member content
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: member.avatarColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: member.avatarColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
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
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              member.name.replaceAll(' (You)', ''),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Rank badge with medal icon
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: rank == 1
                                ? [const Color(0xFFFFD700), const Color(0xFFFFA500)]
                                : rank == 2
                                    ? [const Color(0xFFC0C0C0), const Color(0xFF808080)]
                                    : [const Color(0xFFCD7F32), const Color(0xFF8B4513)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              rank == 1 ? Icons.emoji_events : Icons.workspace_premium,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$rank',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Remove button
                    Positioned(
                      top: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: () => _removeFromRank(rank),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isHovering ? Icons.add_circle : Icons.add_circle_outline,
                        color: isHovering ? const Color(0xFF4A7FFF) : Colors.grey[400],
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 13,
                          color: isHovering ? const Color(0xFF4A7FFF) : Colors.grey[400],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (isHovering) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Drop here',
                          style: TextStyle(
                            fontSize: 11,
                            color: const Color(0xFF4A7FFF).withOpacity(0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildDraggableMemberCard(TeamMember member) {
    return LongPressDraggable<TeamMember>(
      data: member,
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 160,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF4A7FFF),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                member.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  decoration: TextDecoration.none,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                member.department,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.none,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.4,
        child: _buildMemberCard(member),
      ),
      child: _buildMemberCard(member),
    );
  }

  Widget _buildMemberCard(TeamMember member) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF4A7FFF).withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            member.name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            member.department,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _nextQuestion() {
    if (currentQuestion < totalQuestions) {
      setState(() {
        currentQuestion++;
        firstPlace = null;
        secondPlace = null;
        thirdPlace = null;
        _startTimer();
      });
    } else {
      _timer?.cancel();
      // Show completion dialog
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
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
              'Assessment Complete!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Thank you for completing the activity assessment',
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
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A7FFF),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Done',
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
}
