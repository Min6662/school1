import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class ClassEnrolmentScreen extends StatefulWidget {
  final ParseObject classObj;
  const ClassEnrolmentScreen({super.key, required this.classObj});

  @override
  State<ClassEnrolmentScreen> createState() => _ClassEnrolmentScreenState();
}

class _ClassEnrolmentScreenState extends State<ClassEnrolmentScreen> {
  bool loading = true;
  String error = '';
  List<_EnrolledStudent> enrolledStudents = [];

  @override
  void initState() {
    super.initState();
    _fetchEnrolments();
  }

  Future<void> _fetchEnrolments() async {
    setState(() {
      loading = true;
      error = '';
    });
    final enrolQuery = QueryBuilder<ParseObject>(ParseObject('Enrolment'))
      ..whereEqualTo(
          'class', ParseObject('Class')..objectId = widget.classObj.objectId);
    final enrolResponse = await enrolQuery.query();
    if (enrolResponse.success && enrolResponse.results != null) {
      List<_EnrolledStudent> students = [];
      List<String> studentIds = [];
      Map<String, String> enrolmentIdByStudentId = {};
      for (final enrol in enrolResponse.results!) {
        final studentPointer = enrol.get<ParseObject>('student');
        String? studentId = studentPointer?.objectId;
        String? enrolmentId = enrol.objectId;
        if (studentId != null && enrolmentId != null) {
          studentIds.add(studentId);
          enrolmentIdByStudentId[studentId] = enrolmentId;
        }
      }
      if (studentIds.isNotEmpty) {
        final studentQuery = QueryBuilder<ParseObject>(ParseObject('Student'))
          ..whereContainedIn('objectId', studentIds);
        final studentResponse = await studentQuery.query();
        if (studentResponse.success && studentResponse.results != null) {
          for (final studentObj in studentResponse.results!) {
            final name = studentObj.get<String>('name') ?? '';
            final studentId = studentObj.objectId;
            final enrolmentId = enrolmentIdByStudentId[studentId];
            if (name.isNotEmpty && studentId != null && enrolmentId != null) {
              students.add(_EnrolledStudent(
                name: name,
                studentId: studentId,
                enrolmentId: enrolmentId,
              ));
            }
          }
        }
      }
      setState(() {
        enrolledStudents = students;
        loading = false;
      });
    } else {
      setState(() {
        error = 'Failed to fetch enrolments.';
        loading = false;
      });
    }
  }

  Future<void> _removeStudent(String enrolmentId) async {
    setState(() {
      loading = true;
    });
    final enrolment = ParseObject('Enrolment')..objectId = enrolmentId;
    final response = await enrolment.delete();
    if (response.success) {
      await _fetchEnrolments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student removed from class.')),
        );
      }
    } else {
      setState(() {
        loading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to remove student: ' +
                  (response.error?.message ?? 'Unknown error'))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final className = widget.classObj.get<String>('classname') ?? 'Class';
    return Scaffold(
      appBar: AppBar(
        title: Text(className),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
              ? Center(
                  child: Text(error, style: const TextStyle(color: Colors.red)))
              : enrolledStudents.isEmpty
                  ? const Center(child: Text('No students enrolled.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: enrolledStudents.length,
                      itemBuilder: (context, i) {
                        final student = enrolledStudents[i];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading:
                                const Icon(Icons.person, color: Colors.blue),
                            title: Text(student.name),
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_circle,
                                  color: Colors.red),
                              tooltip: 'Remove from class',
                              onPressed: loading
                                  ? null
                                  : () => _removeStudent(student.enrolmentId),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}

class _EnrolledStudent {
  final String name;
  final String studentId;
  final String enrolmentId;
  _EnrolledStudent(
      {required this.name, required this.studentId, required this.enrolmentId});
}
