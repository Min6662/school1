import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import '../services/auth_service.dart';

class TeacherQRScanScreen extends StatefulWidget {
  const TeacherQRScanScreen({super.key});

  @override
  State<TeacherQRScanScreen> createState() => _TeacherQRScanScreenState();
}

class _TeacherQRScanScreenState extends State<TeacherQRScanScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? scanResult;
  bool isProcessing = false;
  String? teacherObjectId;

  @override
  void initState() {
    super.initState();
    _fetchTeacherId();
  }

  Future<void> _fetchTeacherId() async {
    final user = await AuthService().getCurrentUser();
    setState(() {
      teacherObjectId = user?.objectId;
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController ctrl) {
    controller = ctrl;
    ctrl.scannedDataStream.listen((scanData) async {
      if (!isProcessing) {
        setState(() => isProcessing = true);
        scanResult = scanData.code;
        // Save attendance to Parse
        if (scanResult != null && teacherObjectId != null) {
          final attendance = ParseObject('TeacherAttendance')
            ..set(
                'teacherID', ParseObject('Teacher')..objectId = teacherObjectId)
            ..set('classId', ParseObject('Class')..objectId = scanResult)
            ..set('timestamp', DateTime.now().toUtc());
          final response = await attendance.save();
          if (response.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Attendance recorded!')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      'Failed to record attendance: ${response.error?.message ?? 'Unknown error'}')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Missing teacher or class info.')),
          );
        }
        await Future.delayed(const Duration(seconds: 2));
        setState(() => isProcessing = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Classroom QR'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.blue,
                borderRadius: 12,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 250,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: scanResult == null
                  ? const Text('Scan a classroom QR code')
                  : Text('Last scan: $scanResult'),
            ),
          ),
        ],
      ),
    );
  }
}
