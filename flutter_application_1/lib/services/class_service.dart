import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class ClassService {
  Future<List<ParseObject>> fetchClasses() async {
    final query = QueryBuilder<ParseObject>(ParseObject('Class'));
    final response = await query.query();
    if (response.success && response.results != null) {
      return response.results!.cast<ParseObject>();
    }
    return [];
  }

  Future<ParseResponse> createClass(String className) async {
    final newClass = ParseObject('Class')..set('classname', className);
    return await newClass.save();
  }

  Future<ParseObject?> getClassById(String objectId) async {
    final query = QueryBuilder<ParseObject>(ParseObject('Class'))
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
