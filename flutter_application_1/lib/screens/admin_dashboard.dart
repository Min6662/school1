import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import '../widgets/modern_dashboard.dart';
import 'settings_screen.dart';
import 'teacher_dashboard.dart';
import 'student_dashboard.dart';
import '../views/class_list.dart';
import '../screens/assign_student_to_class_screen.dart';
import 'student_attendance_screen.dart';
import 'teacher_qr_scan_screen.dart';

class AdminDashboard extends StatefulWidget {
  final int currentIndex;
  const AdminDashboard({super.key, this.currentIndex = 0});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List<ParseObject> teachers = [];
  bool loading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    _fetchTeachers();
  }

  Future<void> _fetchTeachers() async {
    setState(() {
      loading = true;
      error = '';
    });
    final query = QueryBuilder<ParseObject>(ParseObject('Teacher'));
    final response = await query.query();
    if (response.success && response.results != null) {
      setState(() {
        teachers = response.results!.cast<ParseObject>();
        loading = false;
      });
    } else {
      setState(() {
        error = 'Failed to fetch teachers.';
        loading = false;
      });
    }
  }

  Widget _teacherListWidget() {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error.isNotEmpty) {
      return Center(
          child: Text(error, style: const TextStyle(color: Colors.red)));
    }
    if (teachers.isEmpty) {
      return const Center(child: Text('No teachers found.'));
    }
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: teachers.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final teacher = teachers[index];
          final name = teacher.get<String>('fullName') ?? '';
          final photoUrl = teacher.get<String>('photo');
          final subject = teacher.get<String>('subject') ?? '';
          final gender = teacher.get<String>('gender') ?? '';
          final years = teacher.get<int>('yearsOfExperience') ?? 0;
          return Card(
            child: IntrinsicWidth(
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: SizedBox(
                        width: 112,
                        height: 112,
                        child: (photoUrl != null && photoUrl.isNotEmpty)
                            ? Image.network(photoUrl, fit: BoxFit.cover)
                            : Image.network(
                                'https://randomuser.me/api/portraits/men/1.jpg',
                                fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2),
                          Text('Subject: $subject',
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2),
                          Text('Gender: $gender',
                              style: const TextStyle(fontSize: 12)),
                          Text('Experience: $years years',
                              style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ModernDashboard(
      title: 'Assalam School',
      subtitle: 'Campus circle',
      activities: const [
        {'title': 'Teacher lecture'},
        {'title': 'The school play'},
        {'title': 'Club activities'},
        {'title': 'The lost and found'},
      ],
      users: const [],
      items: const [
        {
          'title': 'Barbecue',
          'desc': 'Highly recommended',
          'image':
              'https://images.unsplash.com/photo-1504674900247-0877df9cc836'
        },
        {
          'title': 'Beer Crayfish',
          'desc': '87 Reviews',
          'image':
              'https://images.unsplash.com/photo-1464306076886-debede6b2b47'
        },
        {'title': 'Spaghetti', 'desc': '32 Reviews', 'image': ''},
      ],
      actions: [
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.black),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()));
          },
        ),
      ],
      currentIndex: widget.currentIndex,
      onTabSelected: (index) {
        if (index == 0) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => const AdminDashboard(currentIndex: 0)));
        } else if (index == 1) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const TeacherDashboard()));
        } else if (index == 2) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => const StudentDashboard(currentIndex: 2)));
        } else if (index == 3) {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()));
        }
      },
      onClassTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ClassList()),
        );
      },
      onStudentTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => const StudentDashboard(currentIndex: 2)),
        );
      },
      onExamResultTap: () {
        // TODO: Implement exam result navigation
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exam Result card clicked')),
        );
      },
      onEnrolmentsTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AssignStudentToClassScreen()),
        );
      },
      onQRScanTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TeacherQRScanScreen()),
        );
      },
      onStudentAttendanceTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const StudentAttendanceScreen()),
        );
      },
    );
  }
}
