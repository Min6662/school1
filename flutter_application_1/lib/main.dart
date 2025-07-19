import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'views/login_page.dart';
import 'screens/student_attendance_history_screen.dart';
import 'screens/student_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Parse().initialize(
    'EIbuzFd5v46RVy8iqf3vupM40l4PEcuS773XLUc5',
    'https://parseapi.back4app.com/',
    clientKey: 'o35E0eNihkhwtlOtwBoIASmO2htYsbAeL1BpnUdE',
    autoSendSessionId: true,
    debug: true,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter School App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginPage(),
      routes: {
        '/studentAttendanceHistory': (context) =>
            const StudentAttendanceHistoryScreen(),
        '/studentList': (context) => const StudentDashboard(currentIndex: 2),
      },
    );
  }
}
