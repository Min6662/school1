import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class AttendanceService {
  Future<List<ParseObject>> fetchStudentAttendance(
      {String? classId, String? status, DateTime? date}) async {
    final query = QueryBuilder<ParseObject>(ParseObject('Attendance'));
    if (classId != null) {
      query.whereEqualTo('classname', classId);
    }
    if (status != null) {
      query.whereEqualTo('status', status);
    }
    if (date != null) {
      query.whereEqualTo('date', date.toIso8601String().substring(0, 10));
    }
    final response = await query.query();
    if (response.success && response.results != null) {
      return response.results as List<ParseObject>;
    }
    return [];
  }
}
