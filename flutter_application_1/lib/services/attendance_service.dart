import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class AttendanceService {
  Future<List<ParseObject>> fetchStudentAttendance({
    String? classId,
    String? session,
    DateTime? date,
  }) async {
    final query = QueryBuilder<ParseObject>(ParseObject('Attendance'));
    if (classId != null) {
      query.whereEqualTo('class', ParseObject('Class')..objectId = classId);
    }
    if (session != null && session.isNotEmpty) {
      query.whereEqualTo('session', session);
    }
    if (date != null) {
      final normalizedDate = DateTime(date.year, date.month, date.day);
      query.whereEqualTo(
          'date',
          DateTime.utc(
            normalizedDate.year,
            normalizedDate.month,
            normalizedDate.day,
          ));
    }
    final response = await query.query();
    if (response.success && response.results != null) {
      return response.results as List<ParseObject>;
    }
    return [];
  }
}
