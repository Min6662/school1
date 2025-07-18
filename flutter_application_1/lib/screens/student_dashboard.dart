import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'add_student_information_screen.dart';
import 'admin_dashboard.dart';
import 'teacher_dashboard.dart';
import 'settings_screen.dart';
import 'student_information_screen.dart';

class StudentDashboard extends StatefulWidget {
  final int currentIndex;
  const StudentDashboard({super.key, this.currentIndex = 2});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  List<ParseObject> students = [];
  bool loading = false;
  String searchQuery = '';
  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    setState(() => loading = true);
    final query = QueryBuilder<ParseObject>(ParseObject('Student'));
    if (searchQuery.isNotEmpty) {
      query.whereContains('name', searchQuery);
    }
    final response = await query.query();
    if (response.success && response.results != null) {
      setState(() {
        students = List<ParseObject>.from(response.results!);
        loading = false;
      });
    } else {
      setState(() => loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to fetch students: \'${response.error?.message ?? 'Unknown error'}')),
        );
      }
    }
  }

  void _onSearchChanged(String value) {
    setState(() {
      searchQuery = value.trim();
    });
    _fetchStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const AdminDashboard(currentIndex: 0),
                ),
              );
            }
          },
        ),
        title: const Text('search and find students',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.blue),
            onPressed: _fetchStudents,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    itemCount: students.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final student = students[i];
                      final name = student.get<String>('name') ?? '';
                      final grade = student.get<String>('grade') ?? '';
                      final photoUrl = student.get<String>('photo');
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: (photoUrl != null &&
                                  photoUrl.isNotEmpty)
                              ? NetworkImage(photoUrl)
                              : const NetworkImage(
                                  'https://randomuser.me/api/portraits/men/1.jpg'),
                        ),
                        title: Text(name),
                        subtitle: Text('Grade: $grade'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StudentInformationScreen(
                                objectId: student.objectId!,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddStudentInformationScreen(),
            ),
          );
        },
        backgroundColor: Colors.blue,
        tooltip: 'Add Student',
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Teachers'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Students'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
        currentIndex: widget.currentIndex,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => const AdminDashboard(currentIndex: 0)));
          } else if (index == 1) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const TeacherDashboard()));
          } else if (index == 2) {
            // Already on StudentDashboard
          } else if (index == 3) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()));
          }
        },
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
