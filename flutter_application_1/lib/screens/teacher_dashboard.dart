import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import '../models/teacher.dart';
import '../views/teacher_card.dart' as views;
import 'admin_dashboard.dart';
import 'settings_screen.dart';
import 'add_teacher_information_screen.dart';
import 'student_dashboard.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  bool loading = true;
  String error = '';
  List<Teacher> teachers = [];

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
        teachers = response.results!.map<Teacher>((obj) {
          return Teacher(
            objectId: obj.get<String>('objectId') ?? '',
            fullName: obj.get<String>('fullName') ?? '',
            subject: obj.get<String>('subject') ?? '',
            gender: obj.get<String>('gender') ?? '',
            photoUrl: obj.get<String>('photo'),
            yearsOfExperience: obj.get<int>('yearsOfExperience') ?? 0,
            rating: (obj.get<num>('rating') ?? 0.0).toDouble(),
            ratingCount: obj.get<int>('ratingCount') ?? 0,
            hourlyRate: (obj.get<num>('hourlyRate') ?? 0.0).toDouble(),
          );
        }).toList();
        loading = false;
      });
    } else {
      setState(() {
        error = 'Failed to fetch teachers.';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const AdminDashboard(currentIndex: 0),
              ),
            );
          },
        ),
        title: const Text('Teachers', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
              ? Center(
                  child: Text(error, style: const TextStyle(color: Colors.red)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: teachers.length,
                  itemBuilder: (context, index) {
                    final teacher = teachers[index];
                    return views.TeacherCard(
                      name: teacher.fullName,
                      photoUrl: teacher.photoUrl,
                      yearsOfExperience: teacher.yearsOfExperience,
                      rating: teacher.rating,
                      ratingCount: teacher.ratingCount,
                      hourlyRate: teacher.hourlyRate,
                      onAdd: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddTeacherInformationScreen(),
                          ),
                        );
                      },
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddTeacherInformationScreen(),
            ),
          );
        },
        backgroundColor: Colors.blue,
        tooltip: 'Add Teacher',
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
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => const AdminDashboard(currentIndex: 0)));
          } else if (index == 1) {
            // Already on Teachers
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const StudentDashboard(currentIndex: 2),
              ),
            );
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
