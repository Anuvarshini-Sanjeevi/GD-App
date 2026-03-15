import 'package:flutter/material.dart';

class TeamMember {
  final String name;
  final String department;
  final bool isYou;
  final Color avatarColor;
  final bool isScanned;

  TeamMember({
    required this.name,
    required this.department,
    this.isYou = false,
    required this.avatarColor,
    this.isScanned = false,
  });
}
