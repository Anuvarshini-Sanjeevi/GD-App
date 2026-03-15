import 'package:flutter/material.dart';

class TeamMember {
  final String name;
  final String department;
  final bool isYou;
  final Color avatarColor;
<<<<<<< HEAD
  final bool isScanned;
=======
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3

  TeamMember({
    required this.name,
    required this.department,
    this.isYou = false,
    required this.avatarColor,
<<<<<<< HEAD
    this.isScanned = false,
=======
>>>>>>> 60bed6f0fd6ef27fcf4a221174415c5c7ec02cb3
  });
}
