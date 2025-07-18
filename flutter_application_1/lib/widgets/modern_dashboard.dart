import 'package:flutter/material.dart';
import 'package:reorderables/reorderables.dart';

class ModernDashboard extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<Map<String, String>> activities;
  final List<Map<String, String>> users;
  final List<Map<String, String>> items;
  final List<Widget>? actions;
  final int currentIndex;
  final void Function(int)? onTabSelected;
  final VoidCallback? onClassTap;
  final VoidCallback? onStudentTap;
  final VoidCallback? onExamResultTap;
  final VoidCallback? onEnrolmentsTap;
  final VoidCallback? onQRScanTap;
  final VoidCallback? onStudentAttendanceTap;
  const ModernDashboard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.activities,
    required this.users,
    required this.items,
    this.actions,
    this.currentIndex = 0,
    this.onTabSelected,
    this.onClassTap,
    this.onStudentTap,
    this.onExamResultTap,
    this.onEnrolmentsTap,
    this.onQRScanTap,
    this.onStudentAttendanceTap,
  });

  @override
  State<ModernDashboard> createState() => _ModernDashboardState();
}

class _ModernDashboardState extends State<ModernDashboard> {
  int _selectedIndex = 0;

  // Initialize school data cards at declaration to avoid LateInitializationError
  List<Map<String, dynamic>> _schoolDataCards = [];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex;
    _schoolDataCards = [
      {
        'icon': Icons.class_,
        'title': 'Class',
        'description': 'View all classes',
        'onTap': widget.onClassTap ?? () {},
      },
      {
        'icon': Icons.school,
        'title': 'Student',
        'description': 'View all students',
        'onTap': widget.onStudentTap ?? () {},
      },
      {
        'icon': Icons.assignment,
        'title': 'Exam Result',
        'description': 'View exam results',
        'onTap': widget.onExamResultTap ?? () {},
      },
      {
        'icon': Icons.how_to_reg,
        'title': 'Enrolments',
        'description': 'View enrolments',
        'onTap': widget.onEnrolmentsTap ?? () {},
      },
      {
        'icon': Icons.qr_code_scanner,
        'title': 'QR Scan',
        'description': 'Teacher attendance',
        'onTap': widget.onQRScanTap ?? () {},
      },
      {
        'icon': Icons.check_circle,
        'title': 'Attendance',
        'description': 'For Students',
        'onTap': widget.onStudentAttendanceTap ?? () {},
      },
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (widget.onTabSelected != null) {
      widget.onTabSelected!(index);
    }
    // Navigate to StudentListScreen when Students tab is tapped
    if (index == 2) {
      // Use root navigator to ensure navigation works in all dashboard contexts
      Navigator.of(context, rootNavigator: true).pushNamed('/studentList');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.blue,
              child: Icon(Icons.school, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Text(widget.title, style: const TextStyle(color: Colors.black)),
          ],
        ),
        actions: widget.actions,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
              16, 16, 16, kBottomNavigationBarHeight + 17),
          children: [
            Text(widget.subtitle,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: widget.activities.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  final act = widget.activities[i];
                  return Container(
                    width: 160,
                    constraints: const BoxConstraints(maxWidth: 180),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Colors.blueAccent, Colors.pinkAccent]),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        act['title'] ?? '',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            // School Data Section
            const SizedBox(height: 32),
            const Text('School Data',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 16),
            ReorderableWrap(
              spacing: 16,
              runSpacing: 16,
              maxMainAxisCount: 2,
              needsLongPressDraggable: true,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  final item = _schoolDataCards.removeAt(oldIndex);
                  _schoolDataCards.insert(newIndex, item);
                });
              },
              children: _schoolDataCards.map((card) {
                return _schoolDataCard(
                  icon: card['icon'],
                  title: card['title'],
                  description: card['description'],
                  onTap: card['onTap'],
                  key: ValueKey(card['title']),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Teachers'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Students'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  Widget _schoolDataCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
    Key? key,
  }) {
    return GestureDetector(
      key: key,
      onTap: onTap,
      child: Container(
        constraints:
            const BoxConstraints(minWidth: 160, maxWidth: 300, minHeight: 140),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.blue),
            const SizedBox(height: 16),
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text(description,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
