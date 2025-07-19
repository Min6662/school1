import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'add_student_information_screen.dart';
import 'admin_dashboard.dart';
import 'teacher_dashboard.dart';
import 'settings_screen.dart';

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
                    separatorBuilder: (_, __) => const SizedBox(height: 4),
                    itemBuilder: (context, i) {
                      final student = students[i];
                      final name = student.get<String>('name') ?? '';
                      final years = student.get<int>('yearsOfExperience') ?? 0;
                      final rating = student.get<double>('rating') ?? 4.5;
                      final ratingCount =
                          student.get<int>('ratingCount') ?? 100;
                      final hourlyRate =
                          student.get<String>('hourlyRate') ?? '20/hr';
                      final photoUrl = student.get<String>('photo') ??
                          'https://randomuser.me/api/portraits/men/1.jpg';
                      return TeacherCard(
                        name: name,
                        role: 'Student Of Assalam',
                        years: years,
                        rating: rating,
                        ratingCount: ratingCount,
                        hourlyRate: hourlyRate,
                        imageUrl: photoUrl,
                        onAdd: () {},
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

class TeacherCard extends StatelessWidget {
  final String name;
  final String role;
  final int years;
  final double rating;
  final int ratingCount;
  final String hourlyRate;
  final String imageUrl;
  final VoidCallback? onAdd;
  const TeacherCard({
    super.key,
    required this.name,
    required this.role,
    required this.years,
    required this.rating,
    required this.ratingCount,
    required this.hourlyRate,
    required this.imageUrl,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[300],
                  child: const Icon(Icons.person, size: 32, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.work, size: 16, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(role,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  Text(name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('$years years of experience',
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.orange, size: 16),
                      Text('${rating.toStringAsFixed(1)}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(' ($ratingCount)',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(hourlyRate,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Colors.orange),
              onPressed: onAdd,
            ),
          ],
        ),
      ),
    );
  }
}
