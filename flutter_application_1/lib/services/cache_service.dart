import 'package:hive/hive.dart';

class CacheService {
  static const String classBoxName = 'classBox';
  static const String studentBoxName = 'studentBox';
  static const String teacherBoxName = 'teacherBox';
  static const String attendanceBoxName = 'attendanceBox';
  static const String userBoxName = 'userBox';
  static const String settingsBoxName = 'settingsBox';

  // Call once at app startup
  static Future<void> init() async {
    await Hive.openBox(classBoxName);
    await Hive.openBox(studentBoxName);
    await Hive.openBox(teacherBoxName);
    await Hive.openBox(attendanceBoxName);
    await Hive.openBox(userBoxName);
    await Hive.openBox(settingsBoxName);
  }

  // Class List
  static Future<void> saveClassList(
      List<Map<String, dynamic>> classList) async {
    final box = Hive.box(classBoxName);
    await box.put('classList', classList);
  }

  static List<Map<String, dynamic>>? getClassList() {
    final box = Hive.box(classBoxName);
    final data = box.get('classList');
    if (data != null) {
      return List<Map<String, dynamic>>.from(
          (data as List).map((e) => Map<String, dynamic>.from(e)));
    }
    return null;
  }

  static Future<void> clearClassList() async {
    final box = Hive.box(classBoxName);
    await box.delete('classList');
  }

  // Student List
  static Future<void> saveStudentList(
      List<Map<String, dynamic>> studentList) async {
    final box = Hive.box(studentBoxName);
    await box.put('studentList', studentList);
  }

  static List<Map<String, dynamic>>? getStudentList() {
    final box = Hive.box(studentBoxName);
    final data = box.get('studentList');
    if (data != null) {
      return List<Map<String, dynamic>>.from(
          (data as List).map((e) => Map<String, dynamic>.from(e)));
    }
    return null;
  }

  static Future<void> clearStudentList() async {
    final box = Hive.box(studentBoxName);
    await box.delete('studentList');
  }

  // Teacher List
  static Future<void> saveTeacherList(
      List<Map<String, dynamic>> teacherList) async {
    final box = Hive.box(teacherBoxName);
    await box.put('teacherList', teacherList);
  }

  static List<Map<String, dynamic>>? getTeacherList() {
    final box = Hive.box(teacherBoxName);
    final data = box.get('teacherList');
    if (data != null) {
      return List<Map<String, dynamic>>.from(
          (data as List).map((e) => Map<String, dynamic>.from(e)));
    }
    return null;
  }

  static Future<void> clearTeacherList() async {
    final box = Hive.box(teacherBoxName);
    await box.delete('teacherList');
  }

  // Attendance History
  static Future<void> saveAttendanceHistory(
      List<Map<String, dynamic>> attendanceList) async {
    final box = Hive.box(attendanceBoxName);
    await box.put('attendanceList', attendanceList);
  }

  static List<Map<String, dynamic>>? getAttendanceHistory() {
    final box = Hive.box(attendanceBoxName);
    final data = box.get('attendanceList');
    if (data != null) {
      return List<Map<String, dynamic>>.from(data);
    }
    return null;
  }

  static Future<void> clearAttendanceHistory() async {
    final box = Hive.box(attendanceBoxName);
    await box.delete('attendanceList');
  }

  // User Profile
  static Future<void> saveUserProfile(Map<String, dynamic> userProfile) async {
    final box = Hive.box(userBoxName);
    await box.put('userProfile', userProfile);
  }

  static Map<String, dynamic>? getUserProfile() {
    final box = Hive.box(userBoxName);
    final data = box.get('userProfile');
    if (data != null) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  static Future<void> clearUserProfile() async {
    final box = Hive.box(userBoxName);
    await box.delete('userProfile');
  }

  // App Settings or Role Info
  static Future<void> saveSettings(Map<String, dynamic> settings) async {
    final box = Hive.box(settingsBoxName);
    await box.put('settings', settings);
  }

  static Map<String, dynamic>? getSettings() {
    final box = Hive.box(settingsBoxName);
    final data = box.get('settings');
    if (data != null) {
      return Map<String, dynamic>.from(data);
    }
    return null;
  }

  static Future<void> clearSettings() async {
    final box = Hive.box(settingsBoxName);
    await box.delete('settings');
  }

  // Images (base64 or file path)
  static Future<void> saveImage(
      String boxName, String key, String imageData) async {
    final box = Hive.box(boxName);
    await box.put(key, imageData);
  }

  static String? getImage(String boxName, String key) {
    final box = Hive.box(boxName);
    return box.get(key);
  }

  static Future<void> clearImage(String boxName, String key) async {
    final box = Hive.box(boxName);
    await box.delete(key);
  }

  // Generic list cache methods
  Future<void> saveList(String key, List<Map<String, dynamic>> list) async {
    // Use attendanceBox for attendance history, otherwise default to classBox
    final box = Hive.box(CacheService.attendanceBoxName);
    await box.put(key, list);
  }

  List<Map<String, dynamic>>? getList(String key) {
    final box = Hive.box(CacheService.attendanceBoxName);
    final data = box.get(key);
    if (data != null) {
      return List<Map<String, dynamic>>.from(
        (data as List).map((e) => Map<String, dynamic>.from(e)),
      );
    }
    return null;
  }

  Future<void> clear(String key) async {
    final box = Hive.box(CacheService.attendanceBoxName);
    await box.delete(key);
  }
}
