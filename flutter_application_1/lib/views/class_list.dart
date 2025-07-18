import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class ClassList extends StatefulWidget {
  const ClassList({super.key});

  @override
  State<ClassList> createState() => _ClassListState();
}

class _ClassListState extends State<ClassList> {
  List<ParseObject> classes = [];
  Map<String, List<String>> enrolledStudents = {};
  bool loading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    _fetchClasses();
  }

  Future<void> _fetchClasses() async {
    setState(() {
      loading = true;
      error = '';
    });
    final query = QueryBuilder<ParseObject>(ParseObject('Class'));
    final response = await query.query();
    if (response.success && response.results != null) {
      setState(() {
        classes = response.results!.cast<ParseObject>();
        loading = false;
      });
      // Fetch enrolled students for each class
      for (var classObj in classes) {
        final classId = classObj.objectId;
        if (classId != null) {
          _fetchEnrolledStudents(classId);
        }
      }
    } else {
      setState(() {
        error = 'Failed to fetch classes.';
        loading = false;
      });
    }
  }

  Future<void> _fetchEnrolledStudents(String classId) async {
    final classPointer = ParseObject('Class')..objectId = classId;
    final enrolQuery = QueryBuilder<ParseObject>(ParseObject('Enrolment'))
      ..whereEqualTo('class', classPointer);
    final enrolResponse = await enrolQuery.query();
    if (enrolResponse.success && enrolResponse.results != null) {
      final students = enrolResponse.results!
          .map((e) => e.get<String>('studentName') ?? '')
          .where((name) => name.isNotEmpty)
          .toList()
          .cast<String>();
      setState(() {
        enrolledStudents[classId] = students;
      });
    } else {
      setState(() {
        enrolledStudents[classId] = [];
      });
    }
  }

  void _showAddClassDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Class'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Class Name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  final newClass = ParseObject('Class')..set('classname', name);
                  final response = await newClass.save();
                  if (response.success) {
                    Navigator.of(context).pop();
                    _fetchClasses();
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Class List'),
        backgroundColor: Colors.blue[900],
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Classes',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : error.isNotEmpty
                      ? Center(
                          child: Text(error,
                              style: const TextStyle(color: Colors.red)))
                      : classes.isEmpty
                          ? const Center(child: Text('No classes found.'))
                          : ListView.builder(
                              itemCount: classes.length,
                              itemBuilder: (context, index) {
                                final classObj = classes[index];
                                final className =
                                    classObj.get<String>('classname') ??
                                        'Class';
                                final classId = classObj.objectId ?? '';
                                final students =
                                    enrolledStudents[classId] ?? [];
                                return Card(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                  elevation: 2,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: ListTile(
                                    onTap: () {
                                      _showEditClassDialog(classObj);
                                    },
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.orange[100],
                                      child: Icon(Icons.class_,
                                          color: Colors.orange[700]),
                                    ),
                                    title: Text(className),
                                    trailing: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange[400],
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text(
                                                  'Enrolled Students for "$className"'),
                                              content: students.isEmpty
                                                  ? const Text(
                                                      'No students enrolled.')
                                                  : SizedBox(
                                                      width: double.maxFinite,
                                                      child: ListView.builder(
                                                        shrinkWrap: true,
                                                        itemCount:
                                                            students.length,
                                                        itemBuilder:
                                                            (context, idx) {
                                                          final studentName =
                                                              students[idx];
                                                          return ListTile(
                                                            leading: const Icon(
                                                                Icons.person),
                                                            title: Text(
                                                                studentName),
                                                            trailing:
                                                                PopupMenuButton<
                                                                    String>(
                                                              icon: const Icon(
                                                                  Icons
                                                                      .more_vert),
                                                              onSelected:
                                                                  (value) async {
                                                                if (value ==
                                                                    'delete') {
                                                                  final classPointer =
                                                                      ParseObject(
                                                                          'Class')
                                                                        ..objectId =
                                                                            classId;
                                                                  final enrolQuery = QueryBuilder<
                                                                      ParseObject>(
                                                                    ParseObject(
                                                                        'Enrolment'),
                                                                  )
                                                                    ..whereEqualTo(
                                                                        'class',
                                                                        classPointer)
                                                                    ..whereEqualTo(
                                                                        'studentName',
                                                                        studentName);
                                                                  final enrolResponse =
                                                                      await enrolQuery
                                                                          .query();
                                                                  if (enrolResponse
                                                                          .success &&
                                                                      enrolResponse
                                                                              .results !=
                                                                          null &&
                                                                      enrolResponse
                                                                          .results!
                                                                          .isNotEmpty) {
                                                                    final enrolObj = enrolResponse
                                                                            .results!
                                                                            .first
                                                                        as ParseObject;
                                                                    await enrolObj
                                                                        .delete();
                                                                    await _fetchEnrolledStudents(
                                                                        classId);
                                                                    setState(
                                                                        () {});
                                                                  }
                                                                }
                                                              },
                                                              itemBuilder:
                                                                  (context) => [
                                                                const PopupMenuItem(
                                                                  value:
                                                                      'delete',
                                                                  child: Row(
                                                                    children: [
                                                                      Icon(
                                                                          Icons
                                                                              .delete,
                                                                          color:
                                                                              Colors.red),
                                                                      SizedBox(
                                                                          width:
                                                                              8),
                                                                      Text(
                                                                          'Delete'),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(),
                                                  child: const Text('Close'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      child: const Text('View'),
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddClassDialog,
        backgroundColor: Colors.blue,
        tooltip: 'Add Class',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showEditClassDialog(ParseObject classObj) {
    final controller =
        TextEditingController(text: classObj.get<String>('classname') ?? '');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Class'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: 'Class Name'),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // Delete class
                await classObj.delete();
                Navigator.of(context).pop();
                _fetchClasses();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = controller.text.trim();
                if (newName.isNotEmpty) {
                  classObj.set('classname', newName);
                  await classObj.save();
                  Navigator.of(context).pop();
                  _fetchClasses();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
