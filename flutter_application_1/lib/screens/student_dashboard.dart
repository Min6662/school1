import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'add_student_information_screen.dart';
import 'admin_dashboard.dart';
import 'teacher_dashboard.dart';
import 'settings_screen.dart';
import '../services/class_service.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

class StudentDashboard extends StatefulWidget {
  final int currentIndex;
  const StudentDashboard({super.key, this.currentIndex = 2});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  List<Map<String, dynamic>> allStudents = [];
  List<Map<String, dynamic>> filteredStudents = [];
  bool loading = false;
  String searchQuery = '';
  String error = '';

  @override
  void initState() {
    super.initState();
    _loadCachedStudents();
  }

  Future<void> _loadCachedStudents() async {
    setState(() {
      loading = true;
      error = '';
    });
    try {
      final box = await Hive.openBox('studentListBox');
      final cached = box.get('studentList') as List<dynamic>?;
      if (cached != null && cached.isNotEmpty) {
        allStudents =
            cached.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        filteredStudents = _filterStudents(searchQuery);
        setState(() {
          loading = false;
        });
      } else {
        await _loadStudents(forceRefresh: false);
      }
    } catch (e) {
      setState(() {
        error = 'Failed to load cached students: \\${e.toString()}';
        loading = false;
      });
    }
  }

  Future<void> _loadStudents({bool forceRefresh = false}) async {
    setState(() {
      loading = true;
      error = '';
    });
    try {
      final students =
          await ClassService.getStudentList(forceRefresh: forceRefresh);
      allStudents = students;
      final box = await Hive.openBox('studentListBox');
      await box.put('studentList', allStudents);
      filteredStudents = _filterStudents(searchQuery);
      setState(() {
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        error = 'Error loading students: \\${e.toString()}';
      });
    }
  }

  Future<void> _refreshStudents() async {
    final box = await Hive.openBox('studentListBox');
    await box.delete('studentList');
    await _loadStudents(forceRefresh: true);
  }

  List<Map<String, dynamic>> _filterStudents(String query) {
    if (query.isEmpty) return allStudents;
    final lower = query.toLowerCase();
    return allStudents
        .where((stu) => (stu['name'] ?? '').toLowerCase().contains(lower))
        .toList();
  }

  void _onSearchChanged(String value) {
    setState(() {
      searchQuery = value.trim();
      filteredStudents = _filterStudents(searchQuery);
    });
  }

  Future<Uint8List?> _getStudentImage(String studentId, String imageUrl) async {
    final box = Hive.box('studentImages');
    final cached = box.get(studentId);
    if (cached != null) {
      return Uint8List.fromList(List<int>.from(cached));
    }
    if (imageUrl.isNotEmpty && imageUrl.startsWith('http')) {
      try {
        final response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode == 200) {
          await box.put(studentId, response.bodyBytes);
          return response.bodyBytes;
        }
      } catch (_) {}
    }
    return null;
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
            onPressed: () => _refreshStudents(),
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
          if (error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(error, style: const TextStyle(color: Colors.red)),
            ),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    itemCount: filteredStudents.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 4),
                    itemBuilder: (context, i) {
                      final student = filteredStudents[i];
                      final name = student['name'] ?? '';
                      final years = student['yearsOfExperience'] ?? 0;
                      final rating = student['rating']?.toDouble() ?? 4.5;
                      final ratingCount = student['ratingCount'] ?? 100;
                      final hourlyRate = student['hourlyRate'] ?? '20/hr';
                      final photoUrl = student['photo'] ??
                          'https://randomuser.me/api/portraits/men/1.jpg';
                      final studentId = student['objectId'] ?? '';
                      return FutureBuilder<Uint8List?>(
                        future: _getStudentImage(studentId, photoUrl),
                        builder: (context, snapshot) {
                          return TeacherCard(
                            name: name,
                            role: 'Student Of Assalam',
                            years: years,
                            rating: rating,
                            ratingCount: ratingCount,
                            hourlyRate: hourlyRate,
                            imageBytes: snapshot.data,
                            imageUrl: photoUrl,
                            onAdd: () {},
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

class TeacherCard extends StatelessWidget {
  final String name;
  final String role;
  final int years;
  final double rating;
  final int ratingCount;
  final String? hourlyRate; // Make optional for student cards
  final String imageUrl;
  final Uint8List? imageBytes;
  final VoidCallback? onAdd;
  const TeacherCard({
    super.key,
    required this.name,
    required this.role,
    required this.years,
    required this.rating,
    required this.ratingCount,
    this.hourlyRate, // Optional
    required this.imageUrl,
    this.imageBytes,
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
              child: imageBytes != null
                  ? Image.memory(
                      imageBytes!,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      imageUrl,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[300],
                        child: const Icon(Icons.person,
                            size: 32, color: Colors.grey),
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
                      Flexible(
                        child: Text(role,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1),
                      ),
                    ],
                  ),
                  Text(name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1),
                  Text('$years years of experience',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 16),
                      Text('${rating.toStringAsFixed(1)}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(' ($ratingCount)',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                      if (hourlyRate != null) ...[
                        const SizedBox(width: 8),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(hourlyRate!,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1),
                          ),
                        ),
                      ],
                    ],
                  ),
                  // Additional student info fields (address, phone, etc.)
                  if (imageBytes == null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            imageUrl,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (onAdd != null)
              IconButton(
                icon:
                    const Icon(Icons.add_circle_outline, color: Colors.orange),
                onPressed: onAdd,
              ),
          ],
        ),
      ),
    );
  }
}
