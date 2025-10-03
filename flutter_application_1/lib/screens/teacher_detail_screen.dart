import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/teacher.dart';

class TeacherDetailScreen extends StatefulWidget {
  final Teacher teacher;

  const TeacherDetailScreen({Key? key, required this.teacher})
      : super(key: key);

  @override
  _TeacherDetailScreenState createState() => _TeacherDetailScreenState();
}

class _TeacherDetailScreenState extends State<TeacherDetailScreen> {
  bool _isLoading = true;
  String? _teacherUsername;
  String? _teacherPassword;
  bool _hasUserAccount = false;

  @override
  void initState() {
    super.initState();
    _loadTeacherCredentials();
  }

  Future<void> _loadTeacherCredentials() async {
    try {
      final query = QueryBuilder<ParseObject>(ParseObject('Teacher'))
        ..whereEqualTo('objectId', widget.teacher.objectId);

      final response = await query.query();

      if (response.success &&
          response.results != null &&
          response.results!.isNotEmpty) {
        final teacherRecord = response.results!.first as ParseObject;

        setState(() {
          _teacherUsername = teacherRecord.get<String>('username');
          _teacherPassword = teacherRecord.get<String>('plainPassword');
          _hasUserAccount = teacherRecord.get<bool>('hasUserAccount') ?? false;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading teacher credentials: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.teacher.fullName} Details'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Basic Information Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Basic Information',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 16),
                          _buildDetailRow('Full Name', widget.teacher.fullName),
                          _buildDetailRow('Gender', widget.teacher.gender),
                          _buildDetailRow(
                              'Subject',
                              widget.teacher.subject.isEmpty
                                  ? 'Not specified'
                                  : widget.teacher.subject),
                          _buildDetailRow('Address',
                              widget.teacher.address ?? 'Not specified'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Login Credentials Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Login Credentials',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 16),
                          if (_hasUserAccount) ...[
                            _buildDetailRow('Username',
                                _teacherUsername ?? 'Not available'),
                            _buildDetailRow('Password',
                                _teacherPassword ?? 'Not available'),
                            _buildDetailRow('Account Status', 'Active'),
                            const SizedBox(height: 16),
                            // Credential Management Buttons for Existing Accounts
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      _showChangePasswordDialog();
                                    },
                                    icon: const Icon(Icons.lock_reset),
                                    label: const Text('Change Password'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      _showChangeUsernameDialog();
                                    },
                                    icon: const Icon(Icons.person_outline),
                                    label: const Text('Change Username'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  _showCopyCredentialsDialog();
                                },
                                icon: const Icon(Icons.copy),
                                label: const Text('Copy Credentials'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Add warning and recreate account option
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.orange[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.orange[200]!),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.warning,
                                          color: Colors.orange[600], size: 20),
                                      const SizedBox(width: 8),
                                      const Expanded(
                                        child: Text(
                                          'Due to Parse Server security, credential changes require account recreation.',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      _showRecreateAccountDialog();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red[400],
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text(
                                        'Recreate Account with New Credentials'),
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            _buildDetailRow(
                                'Username', 'No account created yet'),
                            _buildDetailRow(
                                'Password', 'No account created yet'),
                            _buildDetailRow('Account Status', 'Inactive'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                _showSetCredentialsDialog();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Set Credentials'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  // NEW: Session-Free Teacher Credential Creation using HTTP API
  Future<void> _createTeacherCredentialsViaHTTP(
      String username, String password) async {
    print('DEBUG: Creating teacher credentials via HTTP API (session-free)...');

    try {
      // Use direct HTTP calls to Parse REST API
      const appId = 'EIbuzFd5v46RVy8iqf3vupM40l4PEcuS773XLUc5';
      const clientKey = 'o35E0eNihkhwtlOtwBoIASmO2htYsbAeL1BpnUdE';

      final headers = {
        'X-Parse-Application-Id': appId,
        'X-Parse-Client-Key': clientKey,
        'Content-Type': 'application/json',
      };

      // Step 1: Create user via REST API (doesn't affect current session)
      final userResponse = await http.post(
        Uri.parse('https://parseapi.back4app.com/users'),
        headers: headers,
        body: jsonEncode({
          'username': username,
          'password': password,
          'email': '$username@school.edu',
          'role': 'teacher',
        }),
      );

      if (userResponse.statusCode == 201) {
        final userData = jsonDecode(userResponse.body);
        final userId = userData['objectId'];

        print('DEBUG: ✅ User created via HTTP: $userId');

        // Step 2: Update Teacher record via REST API
        final teacherResponse = await http.put(
          Uri.parse(
              'https://parseapi.back4app.com/classes/Teacher/${widget.teacher.objectId}'),
          headers: headers,
          body: jsonEncode({
            'userId': {
              '__type': 'Pointer',
              'className': '_User',
              'objectId': userId,
            },
            'username': username,
            'plainPassword': password,
            'hasUserAccount': true,
            'accountCreatedAt': {
              '__type': 'Date',
              'iso': DateTime.now().toIso8601String(),
            },
            'isAccountActive': true,
            'lastPasswordReset': {
              '__type': 'Date',
              'iso': DateTime.now().toIso8601String(),
            },
            'lastModified': {
              '__type': 'Date',
              'iso': DateTime.now().toIso8601String(),
            },
          }),
        );

        if (teacherResponse.statusCode == 200) {
          print('DEBUG: ✅ Teacher record updated successfully');
          print('DEBUG: ✅ Credentials set without session conflicts!');

          // Success! Refresh credentials display
          await _loadTeacherCredentials();

          if (mounted) {
            Navigator.pop(context); // Close loading dialog
            _showCredentialsSetSuccessDialog(username, password);
          }
        } else {
          throw Exception(
              'Failed to update teacher record: ${teacherResponse.body}');
        }
      } else {
        final errorData = jsonDecode(userResponse.body);
        String errorMessage = errorData['error'] ?? 'Failed to create user';

        if (errorMessage.contains('already taken') ||
            errorMessage.contains('already exists')) {
          errorMessage =
              'Username "$username" is already taken. Please choose a different username.';
        }

        throw Exception(errorMessage);
      }
    } catch (e) {
      print('DEBUG: ❌ HTTP creation failed: $e');
      rethrow;
    }
  }

  Future<void> _setManualCredentials(String username, String password) async {
    // Show loading dialog
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Setting credentials...'),
            ],
          ),
        ),
      );
    }

    try {
      // Use the new HTTP-based approach (no session conflicts)
      await _createTeacherCredentialsViaHTTP(username, password);
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to set credentials: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _showCredentialsSetSuccessDialog(String username, String password) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green[600]),
            const SizedBox(width: 8),
            const Text('Credentials Set Successfully'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Login credentials for ${widget.teacher.fullName}:'),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person, size: 20, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Text('Username: ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Expanded(child: Text(username)),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 20),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: username));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Username copied to clipboard')),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.lock, size: 20, color: Colors.orange),
                      const SizedBox(width: 8),
                      const Text('Password: ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Expanded(child: Text(password)),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 20),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: password));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Password copied to clipboard')),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Please share these credentials securely with the teacher.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              print(
                  'DEBUG: ✅ Credentials set successfully, admin remains logged in');
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showSetCredentialsDialog() {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.admin_panel_settings, color: Colors.blue[600]),
            const SizedBox(width: 8),
            const Text('Set Login Credentials'),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Create login credentials for ${widget.teacher.fullName}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a username';
                    }
                    if (value.length < 3) {
                      return 'Username must be at least 3 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 4) {
                      return 'Password must be at least 4 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber,
                          color: Colors.orange[600], size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'This will create a new user account for the teacher.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context);
                _setManualCredentials(
                  usernameController.text.trim(),
                  passwordController.text.trim(),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Set Credentials'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.lock_reset, color: Colors.orange[600]),
            const SizedBox(width: 8),
            const Text('Change Password'),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Change password for ${widget.teacher.fullName}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'New Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a new password';
                    }
                    if (value.length < 4) {
                      return 'Password must be at least 4 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (value) {
                    if (value != passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Colors.orange[600], size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'This will update the teacher\'s login password.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context);
                _updatePassword(passwordController.text.trim());
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Change Password'),
          ),
        ],
      ),
    );
  }

  void _showChangeUsernameDialog() {
    final usernameController = TextEditingController(text: _teacherUsername);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.person_outline, color: Colors.blue[600]),
            const SizedBox(width: 8),
            const Text('Change Username'),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Change username for ${widget.teacher.fullName}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'New Username',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a username';
                    }
                    if (value.length < 3) {
                      return 'Username must be at least 3 characters';
                    }
                    if (value == _teacherUsername) {
                      return 'Please enter a different username';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Colors.blue[600], size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'This will update the teacher\'s login username.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context);
                _updateUsername(usernameController.text.trim());
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Change Username'),
          ),
        ],
      ),
    );
  }

  void _showCopyCredentialsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.copy, color: Colors.green[600]),
            const SizedBox(width: 8),
            const Text('Copy Credentials'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Current login credentials for ${widget.teacher.fullName}:'),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person, size: 20, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Text('Username: ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Expanded(child: Text(_teacherUsername ?? 'N/A')),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 20),
                        onPressed: () {
                          Clipboard.setData(
                              ClipboardData(text: _teacherUsername ?? ''));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Username copied to clipboard')),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.lock, size: 20, color: Colors.orange),
                      const SizedBox(width: 8),
                      const Text('Password: ',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Expanded(child: Text(_teacherPassword ?? 'N/A')),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 20),
                        onPressed: () {
                          Clipboard.setData(
                              ClipboardData(text: _teacherPassword ?? ''));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Password copied to clipboard')),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final credentials =
                                'Username: ${_teacherUsername ?? 'N/A'}\nPassword: ${_teacherPassword ?? 'N/A'}';
                            Clipboard.setData(ClipboardData(text: credentials));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Both credentials copied to clipboard')),
                            );
                          },
                          icon: const Icon(Icons.copy_all, size: 18),
                          label: const Text('Copy Both'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _updatePassword(String newPassword) async {
    // Show loading dialog
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Updating password...'),
            ],
          ),
        ),
      );
    }

    try {
      // Get teacher's userId first
      final query = QueryBuilder<ParseObject>(ParseObject('Teacher'))
        ..whereEqualTo('objectId', widget.teacher.objectId);
      final response = await query.query();

      if (response.success && response.results!.isNotEmpty) {
        final teacher = response.results!.first;
        final userId = teacher.get<ParseObject>('userId')?.objectId;

        if (userId == null) {
          throw Exception('Teacher has no associated user account');
        }

        // Update password via HTTP API (session-free)
        const appId = 'EIbuzFd5v46RVy8iqf3vupM40l4PEcuS773XLUc5';
        const clientKey = 'o35E0eNihkhwtlOtwBoIASmO2htYsbAeL1BpnUdE';

        final headers = {
          'X-Parse-Application-Id': appId,
          'X-Parse-Client-Key': clientKey,
          'Content-Type': 'application/json',
        };

        // IMPORTANT: Parse Server ACL prevents direct user updates
        // We'll update the Teacher table and inform about account recreation

        print(
            'DEBUG: 🔄 Updating Teacher table only due to Parse ACL restrictions');

        // Step 2: Update Teacher record with new password
        final teacherResponse = await http.put(
          Uri.parse(
              'https://parseapi.back4app.com/classes/Teacher/${widget.teacher.objectId}'),
          headers: headers,
          body: jsonEncode({
            'plainPassword': newPassword,
            'lastPasswordReset': {
              '__type': 'Date',
              'iso': DateTime.now().toIso8601String(),
            },
            'lastModified': {
              '__type': 'Date',
              'iso': DateTime.now().toIso8601String(),
            },
          }),
        );

        if (teacherResponse.statusCode == 200) {
          print('DEBUG: ✅ Teacher password updated successfully');
          print(
              'DEBUG: ⚠️  Note: User account password not updated due to Parse ACL restrictions');

          // Update local state
          setState(() {
            _teacherPassword = newPassword;
          });

          if (mounted) {
            Navigator.pop(context); // Close loading dialog
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Password updated in Teacher record. Note: User account requires recreation for login.'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 6),
              ),
            );
          }
        } else {
          throw Exception(
              'Failed to update teacher record: ${teacherResponse.body}');
        }
      } else {
        throw Exception('Teacher not found');
      }
    } catch (e) {
      print('DEBUG: ❌ Password update failed: $e');
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update password: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _updateUsername(String newUsername) async {
    // Show loading dialog
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Updating username...'),
            ],
          ),
        ),
      );
    }

    try {
      // Get teacher's userId first
      final query = QueryBuilder<ParseObject>(ParseObject('Teacher'))
        ..whereEqualTo('objectId', widget.teacher.objectId);
      final response = await query.query();

      if (response.success && response.results!.isNotEmpty) {
        final teacher = response.results!.first;
        final userId = teacher.get<ParseObject>('userId')?.objectId;

        if (userId == null) {
          throw Exception('Teacher has no associated user account');
        }

        // Update username via HTTP API (session-free)
        const appId = 'EIbuzFd5v46RVy8iqf3vupM40l4PEcuS773XLUc5';
        const clientKey = 'o35E0eNihkhwtlOtwBoIASmO2htYsbAeL1BpnUdE';

        final headers = {
          'X-Parse-Application-Id': appId,
          'X-Parse-Client-Key': clientKey,
          'Content-Type': 'application/json',
        };

        // IMPORTANT: Parse Server ACL prevents direct user updates
        // We'll update the Teacher table and inform about account recreation

        print(
            'DEBUG: 🔄 Updating Teacher table only due to Parse ACL restrictions');

        // Step 2: Update Teacher record with new username
        final teacherResponse = await http.put(
          Uri.parse(
              'https://parseapi.back4app.com/classes/Teacher/${widget.teacher.objectId}'),
          headers: headers,
          body: jsonEncode({
            'username': newUsername,
            'lastModified': {
              '__type': 'Date',
              'iso': DateTime.now().toIso8601String(),
            },
          }),
        );

        if (teacherResponse.statusCode == 200) {
          print('DEBUG: ✅ Teacher username updated successfully');
          print(
              'DEBUG: ⚠️  Note: User account username not updated due to Parse ACL restrictions');

          // Update local state
          setState(() {
            _teacherUsername = newUsername;
          });

          if (mounted) {
            Navigator.pop(context); // Close loading dialog
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Username updated in Teacher record. Note: User account requires recreation for login.'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 6),
              ),
            );
          }
        } else {
          throw Exception(
              'Failed to update teacher record: ${teacherResponse.body}');
        }
      } else {
        throw Exception('Teacher not found');
      }
    } catch (e) {
      print('DEBUG: ❌ Username update failed: $e');
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update username: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _showRecreateAccountDialog() {
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.refresh, color: Colors.red[600]),
            const SizedBox(width: 8),
            const Text('Recreate Account'),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red[600], size: 20),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'This will DELETE the existing account and create a new one.',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Create new account for ${widget.teacher.fullName}',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'New Username',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a username';
                    }
                    if (value.length < 3) {
                      return 'Username must be at least 3 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'New Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 4) {
                      return 'Password must be at least 4 characters';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context);
                _recreateTeacherAccount(
                  usernameController.text.trim(),
                  passwordController.text.trim(),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Recreate Account'),
          ),
        ],
      ),
    );
  }

  Future<void> _recreateTeacherAccount(
      String newUsername, String newPassword) async {
    // Show loading dialog
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Recreating account...'),
            ],
          ),
        ),
      );
    }

    try {
      // Get current teacher data
      final query = QueryBuilder<ParseObject>(ParseObject('Teacher'))
        ..whereEqualTo('objectId', widget.teacher.objectId);
      final response = await query.query();

      if (response.success && response.results!.isNotEmpty) {
        final teacher = response.results!.first;
        final oldUserId = teacher.get<ParseObject>('userId')?.objectId;

        // Step 1: Delete old user account if exists
        if (oldUserId != null) {
          try {
            const appId = 'EIbuzFd5v46RVy8iqf3vupM40l4PEcuS773XLUc5';
            const clientKey = 'o35E0eNihkhwtlOtwBoIASmO2htYsbAeL1BpnUdE';

            final headers = {
              'X-Parse-Application-Id': appId,
              'X-Parse-Client-Key': clientKey,
              'Content-Type': 'application/json',
            };

            await http.delete(
              Uri.parse('https://parseapi.back4app.com/users/$oldUserId'),
              headers: headers,
            );
            print('DEBUG: 🗑️ Old user account deleted');
          } catch (e) {
            print('DEBUG: ⚠️ Could not delete old user account: $e');
          }
        }

        // Step 2: Create new user account using our session-free approach
        await _createTeacherCredentialsViaHTTP(newUsername, newPassword);

        if (mounted) {
          Navigator.pop(context); // Close loading dialog
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Account recreated successfully! Teacher can now login with new credentials.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 5),
            ),
          );
        }
      } else {
        throw Exception('Teacher not found');
      }
    } catch (e) {
      print('DEBUG: ❌ Account recreation failed: $e');
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to recreate account: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
}
