import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class StudentService {
  Future<List<ParseObject>> fetchStudents({String? searchQuery}) async {
    final query = QueryBuilder<ParseObject>(ParseObject('Student'));
    if (searchQuery != null && searchQuery.isNotEmpty) {
      query.whereContains('name', searchQuery);
    }
    final response = await query.query();
    if (response.success && response.results != null) {
      return response.results!.cast<ParseObject>();
    }
    return [];
  }

  Future<ParseResponse> createStudent({
    required String name,
    required String grade,
    required String address,
    required String phoneNumber,
    required String studyStatus,
    DateTime? dateOfBirth,
    String? photoUrl,
    String gender = 'Male',
  }) async {
    final student = ParseObject('Student')
      ..set('name', name)
      ..set('grade', grade)
      ..set('address', address)
      ..set('phoneNumber', phoneNumber)
      ..set('studyStatus', studyStatus)
      ..set('dateOfBirth', dateOfBirth?.toIso8601String())
      ..set('photo', photoUrl ?? '')
      ..set('gender', gender);
    return await student.save();
  }

  Future<ParseObject?> getStudentById(String objectId) async {
    final query = QueryBuilder<ParseObject>(ParseObject('Student'))
      ..whereEqualTo('objectId', objectId);
    final response = await query.query();
    if (response.success &&
        response.results != null &&
        response.results!.isNotEmpty) {
      return response.results!.first as ParseObject;
    }
    return null;
  }
}
