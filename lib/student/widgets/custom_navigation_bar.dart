import 'package:flutter/material.dart';

class CustomNavigationBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onIndexChanged;

  const CustomNavigationBar({
    Key? key,
    required this.selectedIndex,
    required this.onIndexChanged,
  }) : super(key: key);

  @override
  State<CustomNavigationBar> createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  final List<NavItem> navItems = [
    NavItem(label: 'Home', icon: Icons.home),
    NavItem(label: 'Schedule', icon: Icons.calendar_today),
    NavItem(label: 'Growth', icon: Icons.bar_chart),
    NavItem(label: 'Profile', icon: Icons.person),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Home
          _buildNavItem(0, navItems[0]),
          // Schedule
          _buildNavItem(1, navItems[1]),
          // Center Add Button
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.4),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // Add button action
                },
                customBorder: CircleBorder(),
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
          // Growth
          _buildNavItem(2, navItems[2]),
          // Profile
          _buildNavItem(3, navItems[3]),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, NavItem item) {
    final isSelected = widget.selectedIndex == index;
    return GestureDetector(
      onTap: () => widget.onIndexChanged(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            item.icon,
            color: isSelected ? Colors.blue : Colors.grey,
            size: 24,
          ),
          SizedBox(height: 4),
          Text(
            item.label,
            style: TextStyle(
              fontSize: 10,
              color: isSelected ? Colors.blue : Colors.grey,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class NavItem {
  final String label;
  final IconData icon;

  NavItem({required this.label, required this.icon});
}
