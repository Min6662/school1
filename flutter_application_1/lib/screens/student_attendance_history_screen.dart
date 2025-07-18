import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import '../services/attendance_service.dart';

class StudentAttendanceHistoryScreen extends StatefulWidget {
  final String? classId;
  const StudentAttendanceHistoryScreen({super.key, this.classId});

  @override
  State<StudentAttendanceHistoryScreen> createState() =>
      _StudentAttendanceHistoryScreenState();
}

class _StudentAttendanceHistoryScreenState
    extends State<StudentAttendanceHistoryScreen> {
  List<ParseObject> _attendanceRecords = [];
  String? _selectedClassId;
  String? _selectedStatus;
  DateTime? _selectedDate;
  bool _loading = false;

  final AttendanceService _attendanceService = AttendanceService();

  @override
  void initState() {
    super.initState();
    _selectedClassId = widget.classId;
    _fetchAttendance();
  }

  Future<void> _fetchAttendance() async {
    setState(() {
      _loading = true;
    });
    final records = await _attendanceService.fetchStudentAttendance(
      classId: _selectedClassId,
      status: _selectedStatus,
      date: _selectedDate,
    );
    print('Fetched attendance records: \\${records.length}'); // Debug print
    setState(() {
      _attendanceRecords = records;
      _loading = false;
    });
  }

  Widget _buildFilters() {
    // Extract unique classnames from attendance records
    final classNames = <String>{};
    for (final record in _attendanceRecords) {
      final name = record.get<String>('classname');
      if (name != null && name.isNotEmpty) {
        classNames.add(name);
      }
    }
    // Ensure selected value is valid
    if (_selectedClassId != null && !classNames.contains(_selectedClassId)) {
      _selectedClassId = null;
    }
    final classDropdownItems = [
      const DropdownMenuItem(value: null, child: Text('All Classes')),
      ...classNames
          .map((name) => DropdownMenuItem(value: name, child: Text(name)))
    ];

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          DropdownButton<String?>(
            hint: const Text('Class'),
            value: _selectedClassId,
            items: classDropdownItems,
            onChanged: (val) {
              setState(() {
                _selectedClassId = val;
              });
              _fetchAttendance();
            },
          ),
          const SizedBox(width: 12),
          // Status filter
          DropdownButton<String>(
            hint: const Text('Status'),
            value: _selectedStatus,
            items: const [
              DropdownMenuItem(value: null, child: Text('All Statuses')),
              DropdownMenuItem(value: 'present', child: Text('Present')),
              DropdownMenuItem(value: 'absent', child: Text('Absent')),
              DropdownMenuItem(value: 'excuse', child: Text('Excused')),
            ],
            onChanged: (val) {
              setState(() {
                _selectedStatus = val;
              });
              _fetchAttendance();
            },
          ),
          const SizedBox(width: 12),
          // Date filter
          ElevatedButton(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                setState(() {
                  _selectedDate = picked;
                });
                _fetchAttendance();
              }
            },
            child: Text(_selectedDate == null
                ? 'Date'
                : _selectedDate!.toIso8601String().substring(0, 10)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Attendance History')),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : (_attendanceRecords.isEmpty
                      ? const Column(
                          children: [
                            SizedBox(height: 80),
                            Icon(Icons.history, size: 64, color: Colors.blue),
                            SizedBox(height: 24),
                            Text(
                              'Attendance history will appear here.',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        )
                      : ListView.builder(
                          itemCount: _attendanceRecords.length,
                          itemBuilder: (context, i) {
                            final record = _attendanceRecords[i];
                            final status = record.get<String>('status') ?? '';
                            final date = record.get<DateTime>('date');
                            final studentName =
                                record.get<String>('studentName') ?? 'Unknown';
                            final className =
                                record.get<String>('classname') ?? 'Unknown';
                            String dateStr = date != null
                                ? date.toLocal().toString().substring(0, 19)
                                : 'Unknown';

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 1,
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 16),
                                leading: Icon(
                                  status == 'present'
                                      ? Icons.check_circle
                                      : status == 'absent'
                                          ? Icons.cancel
                                          : Icons.info,
                                  size: 28,
                                  color: status == 'present'
                                      ? Colors.green
                                      : status == 'absent'
                                          ? Colors.red
                                          : Colors.orange,
                                ),
                                title: Text('Student: $studentName',
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500)),
                                subtitle: Text(
                                    'Class: $className\nDate: $dateStr\nStatus: $status',
                                    style: const TextStyle(fontSize: 14)),
                              ),
                            );
                          },
                        ))),
        ],
      ),
    );
  }
}
