import 'package:flutter/material.dart';
import '../models/teacher.dart';
import '../views/teacher_card.dart' as views;
import 'admin_dashboard.dart';
import 'settings_screen.dart';
import 'add_teacher_information_screen.dart';
import 'student_dashboard.dart';
import '../services/class_service.dart';
import '../services/cache_service.dart';
import 'package:hive/hive.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  bool loading = true;
  String error = '';
  List<Teacher> teachers = [];
  Map<String, Uint8List?> teacherImages = {};

  @override
  void initState() {
    super.initState();
    _loadTeachers();
  }

  Future<void> _loadTeachers({bool forceRefresh = false}) async {
    setState(() {
      loading = true;
      error = '';
    });
    try {
      final teacherList = await ClassService.getTeacherList();
      teachers =
          teacherList.map((data) => Teacher.fromParseObject(data)).toList();
      setState(() {
        loading = false;
      });
      // Load teacher images from cache or network
      for (final teacher in teachers) {
        _getTeacherImage(teacher.objectId, teacher.photoUrl ?? '');
      }
    } catch (e) {
      setState(() {
        error = 'Failed to load teachers: \\${e.toString()}';
        loading = false;
      });
    }
  }

  Future<void> _getTeacherImage(String teacherId, String imageUrl) async {
    print('Getting image for teacherId: $teacherId, imageUrl: $imageUrl');
    final box = await Hive.openBox('teacherImages');
    final cached = box.get(teacherId);
    if (cached != null) {
      print('Loaded image from cache for $teacherId');
      setState(() {
        teacherImages[teacherId] = Uint8List.fromList(List<int>.from(cached));
      });
      return;
    }
    if (imageUrl.isNotEmpty && imageUrl.startsWith('http')) {
      try {
        final response = await http.get(Uri.parse(imageUrl));
        print('Image download status for $teacherId: ${response.statusCode}');
        if (response.statusCode == 200) {
          await box.put(teacherId, response.bodyBytes);
          setState(() {
            teacherImages[teacherId] = response.bodyBytes;
          });
          print('Image cached for $teacherId');
        } else {
          print('Failed to download image for $teacherId');
        }
      } catch (e) {
        print('Error downloading image for $teacherId: $e');
      }
    } else {
      print('No valid image URL for $teacherId');
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.blue),
            tooltip: 'Refresh Teacher List',
            onPressed: () async {
              await CacheService.clearTeacherList();
              _loadTeachers(forceRefresh: true);
            },
          ),
        ],
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
                      imageBytes: teacherImages[teacher.objectId],
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
