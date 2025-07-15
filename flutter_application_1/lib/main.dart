import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';

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
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginPage(), // Start with login page
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String errorMessage = '';

  Future<void> loginUser() async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    final user = ParseUser(email, password, email);
    final response = await user.login();
    if (response.success && response.result != null) {
      final role = response.result.get<String>('role');
      if (role == 'admin') {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => const AdminDashboard(currentIndex: 0)));
      } else if (role == 'teacher') {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const TeacherDashboard()));
      } else {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => const StudentDashboard(currentIndex: 2)));
      }
    } else {
      setState(() {
        errorMessage = response.error?.message ?? 'Login failed';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.school, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 12),
                Text('Assalam School',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900])),
              ],
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.grey.shade200, blurRadius: 12)
                ],
              ),
              child: Column(
                children: [
                  Text('Login',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900])),
                  const SizedBox(height: 24),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16)),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16)),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: loginUser,
                      child:
                          const Text('Login', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SignupPage()));
                    },
                    child: const Text('Don\'t have an account? Sign Up'),
                  ),
                  if (errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(errorMessage,
                          style: const TextStyle(color: Colors.red)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  String selectedRole = 'student';
  String errorMessage = '';

  Future<void> signupUser() async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    final username = usernameController.text.trim();
    final user = ParseUser.createUser(username, password, email);
    user.set('role', selectedRole);
    final response = await user.signUp();
    if (response.success) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Signup successful! Please login.')),
        );
        Navigator.pop(context); // Go back to login
      }
    } else {
      setState(() {
        errorMessage = response.error?.message ?? 'Signup failed';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.school, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 12),
                Text('Assalam School',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900])),
              ],
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.grey.shade200, blurRadius: 12)
                ],
              ),
              child: Column(
                children: [
                  Text('Sign Up',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900])),
                  const SizedBox(height: 24),
                  TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16)),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16)),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16)),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: InputDecoration(
                      labelText: 'Role',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16)),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    items: const [
                      DropdownMenuItem(value: 'admin', child: Text('Admin')),
                      DropdownMenuItem(
                          value: 'teacher', child: Text('Teacher')),
                      DropdownMenuItem(
                          value: 'student', child: Text('Student')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedRole = value ?? 'student';
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: signupUser,
                      child:
                          const Text('Sign Up', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Go Back to Login'),
                    ),
                  ),
                  if (errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(errorMessage,
                          style: const TextStyle(color: Colors.red)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: const Center(
        child: Text('User Profile Screen'),
      ),
    );
  }
}

class ModernDashboard extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<Map<String, String>> activities;
  final List<Map<String, String>> users;
  final List<Map<String, String>> items;
  final List<Widget>? actions;
  final int currentIndex;
  final Widget? customTeacherList;
  const ModernDashboard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.activities,
    required this.users,
    required this.items,
    this.actions,
    this.currentIndex = 0,
    this.customTeacherList,
  });

  @override
  State<ModernDashboard> createState() => _ModernDashboardState();
}

class _ModernDashboardState extends State<ModernDashboard> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const AdminDashboard(currentIndex: 0),
        ),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const TeacherDashboard(),
        ),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const StudentDashboard(currentIndex: 2),
        ),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.blue,
              child: Icon(Icons.school, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Text(widget.title, style: const TextStyle(color: Colors.black)),
          ],
        ),
        actions: widget.actions,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
              16, 16, 16, kBottomNavigationBarHeight + 17),
          children: [
            Text(widget.subtitle,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: widget.activities.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  final act = widget.activities[i];
                  return Container(
                    width: 160,
                    constraints: const BoxConstraints(maxWidth: 180),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Colors.blueAccent, Colors.pinkAccent]),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        act['title'] ?? '',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            const Text('Teachers list',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            widget.customTeacherList ?? SizedBox.shrink(),
            const SizedBox(height: 24),
            // School Data Section
            const SizedBox(height: 32),
            Text('School Data',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.3,
              children: [
                _schoolDataCard(
                  icon: Icons.class_,
                  title: 'Class',
                  description: 'View all classes',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ClassListScreen()),
                    );
                  },
                ),
                _schoolDataCard(
                  icon: Icons.person,
                  title: 'Student',
                  description: 'View all students',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Student card clicked')),
                    );
                  },
                ),
                _schoolDataCard(
                  icon: Icons.grade,
                  title: 'Exam Result',
                  description: 'View exam results',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Exam Result card clicked')),
                    );
                  },
                ),
                _schoolDataCard(
                  icon: Icons.assignment_ind,
                  title: 'Enrolments',
                  description: 'Assign students to classes',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AssignStudentToClassScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Teachers'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Students'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  Widget _schoolDataCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 6)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.blue),
            const SizedBox(height: 12),
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text(description,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? name;
  String? username;
  String? photoUrl;
  bool loading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    setState(() {
      loading = true;
      error = '';
    });
    final user = await ParseUser.currentUser();
    if (user != null) {
      setState(() {
        name = user.get<String>('name') ?? user.username ?? '';
        username = user.username ?? '';
        photoUrl = user.get<String>('photo');
        loading = false;
      });
    } else {
      setState(() {
        error = 'Failed to fetch user info.';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => const AdminDashboard(currentIndex: 0)),
              );
            }
          },
        ),
        title: const Text('My Profile',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
              ? Center(
                  child: Text(error, style: const TextStyle(color: Colors.red)))
              : Column(
                  children: [
                    const SizedBox(height: 16),
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundImage: (photoUrl != null &&
                                    photoUrl!.isNotEmpty)
                                ? NetworkImage(photoUrl!)
                                : const NetworkImage(
                                    'https://randomuser.me/api/portraits/men/1.jpg'),
                          ),
                          const SizedBox(height: 12),
                          Text(name ?? '',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20)),
                          Text('@${username ?? ''}',
                              style: const TextStyle(color: Colors.grey)),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 8),
                            ),
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const EditProfileScreen()));
                            },
                            child: const Text('Edit Profile'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.shade200, blurRadius: 12)
                          ],
                        ),
                        child: ListView(
                          children: [
                            _settingsTile(Icons.favorite_border, 'Favorites'),
                            _settingsTile(Icons.download_outlined, 'Downloads'),
                            _settingsTile(Icons.language, 'Language'),
                            _settingsTile(
                                Icons.location_on_outlined, 'Location'),
                            _settingsTile(
                                Icons.subscriptions_outlined, 'Subscription'),
                            _settingsTile(
                                Icons.bug_report_outlined, 'Clear Crash'),
                            _settingsTile(Icons.history, 'Clear History'),
                            const Divider(),
                            ListTile(
                              leading:
                                  const Icon(Icons.logout, color: Colors.red),
                              title: const Text('Logout',
                                  style: TextStyle(color: Colors.red)),
                              onTap: () {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const LoginPage()));
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _settingsTile(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {},
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  File? imageFile;
  String? photoUrl;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() => loading = true);
    final user = await ParseUser.currentUser();
    if (user != null) {
      setState(() {
        nameController.text = user.get<String>('name') ?? '';
        emailController.text = user.emailAddress ?? '';
        usernameController.text = user.username ?? '';
        passwordController.text = '';
        phoneController.text = user.get<String>('phoneNumber') ?? '';
        photoUrl = user.get<String>('photo');
        loading = false;
      });
    } else {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch user info.')),
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File file) async {
    final parseFile = ParseFile(file);
    final response = await parseFile.save();
    if (response.success && response.result != null) {
      return parseFile.url;
    }
    return null;
  }

  Future<void> _saveProfile() async {
    setState(() => loading = true);
    final user = await ParseUser.currentUser();
    if (user != null) {
      String? uploadedPhotoUrl = photoUrl;
      if (imageFile != null) {
        uploadedPhotoUrl = await _uploadImage(imageFile!);
      }
      user.set('name', nameController.text.trim());
      user.emailAddress = emailController.text.trim();
      user.username = usernameController.text.trim();
      if (passwordController.text.isNotEmpty) {
        user.password = passwordController.text;
      }
      user.set('phoneNumber', phoneController.text.trim());
      user.set('photo', uploadedPhotoUrl ?? '');
      final response = await user.save();
      setState(() => loading = false);
      if (response.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!')),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Failed to update profile: \\${response.error?.message ?? 'Unknown error'}')),
          );
        }
      }
    } else {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user found.')),
      );
    }
  }

  Widget _profileField(String label, TextEditingController controller,
      {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: label,
            suffixIcon: isPassword ? const Icon(Icons.visibility_off) : null,
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Edit Profile',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.black),
            onPressed: loading ? null : _saveProfile,
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: imageFile != null
                          ? FileImage(imageFile!)
                          : (photoUrl != null && photoUrl!.isNotEmpty)
                              ? NetworkImage(photoUrl!)
                              : const NetworkImage(
                                      'https://randomuser.me/api/portraits/men/1.jpg')
                                  as ImageProvider,
                      child: imageFile == null &&
                              (photoUrl == null || photoUrl!.isEmpty)
                          ? const Icon(Icons.person,
                              size: 40, color: Colors.grey)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _profileField('Name', nameController),
                _profileField('Email address', emailController),
                _profileField('User name', usernameController),
                _profileField('Password', passwordController, isPassword: true),
                _profileField('Phone number', phoneController),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: loading ? null : _saveProfile,
                    child: loading
                        ? const CircularProgressIndicator()
                        : const Text('Save',
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
    );
  }
}

class AdminDashboard extends StatefulWidget {
  final int currentIndex;
  const AdminDashboard({super.key, this.currentIndex = 0});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List<ParseObject> teachers = [];
  bool loading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    _fetchTeachers();
  }

  Future<void> _fetchTeachers() async {
    setState(() {
      loading = true;
      error = '';
    });
    final query = QueryBuilder<ParseObject>(ParseObject('Teacher'));
    final response = await query.query();
    if (response.success && response.results != null) {
      setState(() {
        teachers = response.results!.cast<ParseObject>();
        loading = false;
      });
    } else {
      setState(() {
        error = 'Failed to fetch teachers.';
        loading = false;
      });
    }
  }

  Widget _teacherListWidget() {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error.isNotEmpty) {
      return Center(
          child: Text(error, style: const TextStyle(color: Colors.red)));
    }
    if (teachers.isEmpty) {
      return const Center(child: Text('No teachers found.'));
    }
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: teachers.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final teacher = teachers[index];
          final name = teacher.get<String>('fullName') ?? '';
          final photoUrl = teacher.get<String>('photo');
          final subject = teacher.get<String>('subject') ?? '';
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      TeacherInformationScreen(objectId: teacher.objectId!),
                ),
              );
            },
            child: Card(
              child: IntrinsicWidth(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: (photoUrl != null &&
                                photoUrl.isNotEmpty)
                            ? NetworkImage(photoUrl)
                            : const NetworkImage(
                                'https://randomuser.me/api/portraits/men/1.jpg'),
                        radius: 28,
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2),
                            Text('Subject: $subject',
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ModernDashboard(
      title: 'Assalam School',
      subtitle: 'Campus circle',
      activities: const [
        {'title': 'Teacher lecture'},
        {'title': 'The school play'},
        {'title': 'Club activities'},
        {'title': 'The lost and found'},
      ],
      users: const [],
      items: const [
        {
          'title': 'Barbecue',
          'desc': 'Highly recommended',
          'image':
              'https://images.unsplash.com/photo-1504674900247-0877df9cc836'
        },
        {
          'title': 'Beer Crayfish',
          'desc': '87 Reviews',
          'image':
              'https://images.unsplash.com/photo-1464306076886-debede6b2b47'
        },
        {'title': 'Spaghetti', 'desc': '32 Reviews', 'image': ''},
      ],
      actions: [
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.black),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()));
          },
        ),
      ],
      currentIndex: widget.currentIndex,
      customTeacherList: _teacherListWidget(),
    );
  }
}

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  bool loading = true;
  String error = '';
  List<ParseObject> teachers = [];

  @override
  void initState() {
    super.initState();
    _fetchTeachers();
  }

  Future<void> _fetchTeachers() async {
    setState(() {
      loading = true;
      error = '';
    });
    final query = QueryBuilder<ParseObject>(ParseObject('Teacher'));
    final response = await query.query();
    if (response.success && response.results != null) {
      setState(() {
        teachers = response.results!.cast<ParseObject>();
        loading = false;
      });
    } else {
      setState(() {
        error = 'Failed to fetch teachers.';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const AdminDashboard(currentIndex: 0),
              ),
            );
          },
        ),
        title: const Text('Teachers', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
              ? Center(
                  child: Text(error, style: const TextStyle(color: Colors.red)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: teachers.length,
                  itemBuilder: (context, index) {
                    final teacher = teachers[index];
                    final name = teacher.get<String>('fullName') ?? '';
                    final photoUrl = teacher.get<String>('photo');
                    final subject = teacher.get<String>('subject') ?? '';
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: (photoUrl != null &&
                                  photoUrl.isNotEmpty)
                              ? NetworkImage(photoUrl)
                              : const NetworkImage(
                                  'https://randomuser.me/api/portraits/men/1.jpg'),
                        ),
                        title: Text(name,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Subject: $subject'),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TeacherInformationScreen(
                                  objectId: teacher.objectId!),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddTeacherInformationScreen(),
            ),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Add Teacher',
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Teachers'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Students'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => const AdminDashboard(currentIndex: 0)));
          } else if (index == 1) {
            // Already on Teachers
          } else if (index == 2) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => const StudentDashboard(currentIndex: 2)));
          } else if (index == 3) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()));
          }
        },
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class StudentDashboard extends StatefulWidget {
  final int currentIndex;
  const StudentDashboard({super.key, this.currentIndex = 2});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  List<ParseObject> students = [];
  bool loading = false;
  String searchQuery = '';
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _fetchStudents();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _fetchStudents();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchStudents() async {
    setState(() => loading = true);
    final query = QueryBuilder<ParseObject>(ParseObject('Student'));
    if (searchQuery.isNotEmpty) {
      query.whereContains('name', searchQuery);
    }
    final response = await query.query();
    if (response.success && response.results != null) {
      setState(() {
        students = List<ParseObject>.from(response.results!);
        loading = false;
      });
    } else {
      setState(() => loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to fetch students: ${response.error?.message ?? 'Unknown error'}')),
        );
      }
    }
  }

  void _onSearchChanged(String value) {
    setState(() {
      searchQuery = value.trim();
    });
    _fetchStudents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => const AdminDashboard(currentIndex: 0)),
              );
            }
          },
        ),
        title: const Text('search and find students',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.blue),
            onPressed: _fetchStudents,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('All Students', style: TextStyle(color: Colors.grey)),
                Row(
                  children: [
                    Text('Sort by time', style: TextStyle(color: Colors.grey)),
                    Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    itemCount: students.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final student = students[i];
                      final name =
                          student.get<String>('name') ?? "Student's Name";
                      final grade = student.get<String>('grade') ?? 'Grade';
                      final photo = student.get<String>('photo');
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: photo != null && photo.isNotEmpty
                              ? NetworkImage(photo)
                              : const NetworkImage(
                                  'https://img.icons8.com/clouds/100/000000/user.png'),
                        ),
                        title: Text(name,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Grade $grade'),
                        trailing: IconButton(
                          icon:
                              const Icon(Icons.more_horiz, color: Colors.blue),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Edit screen is currently unavailable.')),
                            );
                          },
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StudentInformationScreen(
                                  objectId: student.objectId!),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddStudentInformationScreen(),
            ),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Add Student',
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Teachers'),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Students'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
        currentIndex: widget.currentIndex,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => const AdminDashboard(currentIndex: 0)));
          } else if (index == 1) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const TeacherDashboard()));
          } else if (index == 2) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => const StudentDashboard(currentIndex: 2)));
          } else if (index == 3) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()));
          }
        },
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class AddStudentInformationScreen extends StatefulWidget {
  const AddStudentInformationScreen({super.key});

  @override
  State<AddStudentInformationScreen> createState() =>
      _AddStudentInformationScreenState();
}

class _AddStudentInformationScreenState
    extends State<AddStudentInformationScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController gradeController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController studyStatusController = TextEditingController();
  DateTime? dateOfBirth;
  File? imageFile;
  bool loading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File file) async {
    final parseFile = ParseFile(file);
    final response = await parseFile.save();
    if (response.success && response.result != null) {
      return parseFile.url;
    }
    return null;
  }

  Future<void> _saveStudent() async {
    setState(() => loading = true);
    String? photoUrl;
    if (imageFile != null) {
      photoUrl = await _uploadImage(imageFile!);
    }
    final student = ParseObject('Student')
      ..set('name', nameController.text.trim())
      ..set('grade', gradeController.text.trim())
      ..set('address', addressController.text.trim())
      ..set('phoneNumber', phoneController.text.trim())
      ..set('studyStatus', studyStatusController.text.trim())
      ..set('dateOfBirth', dateOfBirth?.toIso8601String())
      ..set('photo', photoUrl ?? '');
    final response = await student.save();
    setState(() => loading = false);
    if (response.success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student added successfully!')),
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to add student: ${response.error?.message ?? 'Unknown error'}')),
        );
      }
    }
  }

  Widget _inputField(
      {required IconData icon,
      required String label,
      required TextEditingController controller,
      bool readOnly = false,
      VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black),
          filled: true,
          fillColor: const Color(0xFFEDEDED),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Add Student', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Image Card
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black, width: 4),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: imageFile != null
                            ? Image.file(
                                imageFile!,
                                fit: BoxFit.cover,
                                width: 260,
                                height: 260,
                              )
                            : Icon(Icons.person,
                                size: 120, color: Colors.grey[400]),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(Icons.edit, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                nameController.text.isEmpty ? 'Name' : nameController.text,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text('ID 00000000',
                  style: TextStyle(color: Colors.grey, fontSize: 18)),
              const SizedBox(height: 32),
              _inputField(
                  icon: Icons.person,
                  label: 'Name',
                  controller: nameController),
              _inputField(
                icon: Icons.cake,
                label: 'Date of birth',
                controller: TextEditingController(
                  text: dateOfBirth == null
                      ? ''
                      : dateOfBirth!.toLocal().toString().split(' ')[0],
                ),
                readOnly: true,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime(2005, 1, 1),
                    firstDate: DateTime(1990),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      dateOfBirth = picked;
                    });
                  }
                },
              ),
              _inputField(
                  icon: Icons.school,
                  label: 'Grade',
                  controller: gradeController),
              _inputField(
                  icon: Icons.home,
                  label: 'Addrees',
                  controller: addressController),
              _inputField(
                  icon: Icons.phone,
                  label: 'Phone number',
                  controller: phoneController),
              _inputField(
                  icon: Icons.info,
                  label: 'Study Status',
                  controller: studyStatusController),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                      side: const BorderSide(color: Colors.cyan, width: 2),
                    ),
                    elevation: 0,
                  ),
                  onPressed: loading ? null : _saveStudent,
                  child: Ink(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Color(0xFF00B4DB), Color(0xFF0083B0)]),
                      borderRadius: BorderRadius.all(Radius.circular(32)),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: loading
                          ? const CircularProgressIndicator()
                          : const Text('Save',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// --- StudentInformationScreen ---
class StudentInformationScreen extends StatefulWidget {
  final String objectId;
  const StudentInformationScreen({super.key, required this.objectId});

  @override
  State<StudentInformationScreen> createState() =>
      _StudentInformationScreenState();
}

class _StudentInformationScreenState extends State<StudentInformationScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController gradeController = TextEditingController();
  TextEditingController studyStatusController = TextEditingController();
  TextEditingController attendanController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  String gender = 'Male';
  String? photoUrl;
  DateTime? dateOfBirth;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _fetchStudentData();
  }

  Future<void> _fetchStudentData() async {
    setState(() => loading = true);
    final query = QueryBuilder<ParseObject>(ParseObject('Student'))
      ..whereEqualTo('objectId', widget.objectId);
    final response = await query.query();
    if (response.success &&
        response.results != null &&
        response.results!.isNotEmpty) {
      final student = response.results!.first;
      setState(() {
        nameController.text = student.get<String>('name') ?? '';
        addressController.text = student.get<String>('address') ?? '';
        gradeController.text = student.get<String>('grade') ?? '';
        studyStatusController.text = student.get<String>('studyStatus') ?? '';
        attendanController.text = student.get<String>('attendan') ?? '';
        gender = student.get<String>('gender') ?? 'Male';
        photoUrl = student.get<String>('photo');
        final dobStr = student.get<String>('dateOfBirth');
        if (dobStr != null && dobStr.isNotEmpty) {
          dateOfBirth = DateTime.tryParse(dobStr);
          dobController.text = dobStr.split('T').first;
        }
        loading = false;
      });
    } else {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Failed to fetch student: ${response.error?.message ?? 'Unknown error'}')),
      );
    }
  }

  int _calculateAge(DateTime? dob) {
    if (dob == null) return 0;
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dateOfBirth ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        dateOfBirth = picked;
        dobController.text = picked.toIso8601String().split('T').first;
      });
    }
  }

  Future<void> _saveStudentEdits() async {
    setState(() => loading = true);
    final student = ParseObject('Student')..objectId = widget.objectId;
    student
      ..set('name', nameController.text.trim())
      ..set('address', addressController.text.trim())
      ..set('grade', gradeController.text.trim())
      ..set('studyStatus', studyStatusController.text.trim())
      ..set('attendan', attendanController.text.trim())
      ..set('gender', gender)
      ..set('dateOfBirth', dateOfBirth?.toIso8601String());
    final response = await student.save();
    if (response.success) {
      // Update all Enrolment records for this student with the new name
      final enrolQuery = QueryBuilder<ParseObject>(ParseObject('Enrolment'))
        ..whereEqualTo(
            'student', ParseObject('Student')..objectId = widget.objectId);
      final enrolResponse = await enrolQuery.query();
      if (enrolResponse.success && enrolResponse.results != null) {
        for (final enrol in enrolResponse.results!) {
          enrol.set('studentName', nameController.text.trim());
          await enrol.save();
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student updated successfully!')),
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to update student: ' +
                  (response.error?.message ?? 'Unknown error'))),
        );
      }
    }
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF8B7EDC)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Student Information',
          style: TextStyle(
            color: Color(0xFF8B7EDC),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black12, width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: photoUrl != null && photoUrl!.isNotEmpty
                            ? Image.network(photoUrl!, fit: BoxFit.cover)
                            : Icon(Icons.person,
                                size: 80, color: Colors.grey[400]),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _editField('Name', nameController),
                  _editField('Address', addressController),
                  _genderDropdown(),
                  _editField('Date of Birth', dobController, isDate: true),
                  _infoCard(
                      'Age',
                      dateOfBirth != null
                          ? _calculateAge(dateOfBirth).toString()
                          : ''),
                  _editField('Grade', gradeController),
                  _editField('Study Status', studyStatusController),
                  _editField('Attendan', attendanController),
                  const SizedBox(height: 24),
                  _saveButton(),
                ],
              ),
            ),
    );
  }

  Widget _editField(String label, TextEditingController controller,
      {bool isDate = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        readOnly: isDate,
        onTap: isDate ? _selectDate : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black),
          filled: true,
          fillColor: const Color(0xFFEDEDED),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _genderDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: gender,
        items: const [
          DropdownMenuItem(value: 'Male', child: Text('Male')),
          DropdownMenuItem(value: 'Female', child: Text('Female')),
          DropdownMenuItem(value: 'Other', child: Text('Other')),
        ],
        onChanged: (val) {
          setState(() {
            gender = val ?? 'Male';
          });
        },
        decoration: InputDecoration(
          labelText: 'Gender',
          filled: true,
          fillColor: const Color(0xFFEDEDED),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _infoCard(String label, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7FB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(width: 12),
          Text(value,
              style: const TextStyle(
                  color: Color(0xFF8B7EDC),
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
        ],
      ),
    );
  }

  Widget _saveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: loading ? null : _saveStudentEdits,
        child: loading
            ? const CircularProgressIndicator()
            : const Text('Save', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}

// --- TeacherInformationScreen ---
class TeacherInformationScreen extends StatefulWidget {
  final String objectId;
  const TeacherInformationScreen({super.key, required this.objectId});

  @override
  State<TeacherInformationScreen> createState() =>
      _TeacherInformationScreenState();
}

class _TeacherInformationScreenState extends State<TeacherInformationScreen> {
  bool loading = true;
  String error = '';
  String? name;
  String? photoUrl;
  String? email;
  String? username;

  @override
  void initState() {
    super.initState();
    _fetchTeacherInfo();
  }

  Future<void> _fetchTeacherInfo() async {
    setState(() {
      loading = true;
      error = '';
    });
    final query = QueryBuilder<ParseObject>(ParseObject('Teacher'))
      ..whereEqualTo('objectId', widget.objectId);
    final response = await query.query();
    if (response.success &&
        response.results != null &&
        response.results!.isNotEmpty) {
      final teacher = response.results!.first as ParseObject;
      setState(() {
        name = teacher.get<String>('name') ?? '';
        photoUrl = teacher.get<String>('photo');
        email = teacher.get<String>('email') ?? '';
        username = teacher.get<String>('username') ?? '';
        loading = false;
      });
    } else {
      setState(() {
        error = 'Failed to fetch teacher info.';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Teacher Information',
            style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
              ? Center(
                  child: Text(error, style: const TextStyle(color: Colors.red)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundImage: (photoUrl != null &&
                                photoUrl!.isNotEmpty)
                            ? NetworkImage(photoUrl!)
                            : const NetworkImage(
                                'https://randomuser.me/api/portraits/men/1.jpg'),
                      ),
                      const SizedBox(height: 16),
                      Text(name ?? '',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 22)),
                      const SizedBox(height: 8),
                      Text('@${username ?? ''}',
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 16)),
                      const SizedBox(height: 8),
                      Text(email ?? '',
                          style: const TextStyle(
                              color: Colors.black, fontSize: 16)),
                    ],
                  ),
                ),
    );
  }
}

Future<void> createSampleTeachers() async {
  // Function cleared as requested.
}

class AddTeacherInformationScreen extends StatefulWidget {
  const AddTeacherInformationScreen({super.key});

  @override
  State<AddTeacherInformationScreen> createState() =>
      _AddTeacherInformationScreenState();
}

class _AddTeacherInformationScreenState
    extends State<AddTeacherInformationScreen> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();
  String gender = 'Male';
  File? imageFile;
  bool loading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imageFile = File(pickedFile.path);
      });
    }
  }

  Future<String?> _uploadImage(File file) async {
    final parseFile = ParseFile(file);
    final response = await parseFile.save();
    if (response.success && response.result != null) {
      return parseFile.url;
    }
    return null;
  }

  Future<void> _saveTeacher() async {
    setState(() => loading = true);
    String? photoUrl;
    if (imageFile != null) {
      photoUrl = await _uploadImage(imageFile!);
    }
    final teacher = ParseObject('Teacher')
      ..set('fullName', fullNameController.text.trim())
      ..set('gender', gender)
      ..set('subject', subjectController.text.trim())
      ..set('photo', photoUrl ?? '');
    final response = await teacher.save();
    setState(() => loading = false);
    if (response.success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Teacher added successfully!')),
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to add teacher: \\${response.error?.message ?? 'Unknown error'}')),
        );
      }
    }
  }

  Widget _inputField(
      {required IconData icon,
      required String label,
      required TextEditingController controller}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black),
          filled: true,
          fillColor: const Color(0xFFEDEDED),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Add Teacher', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black, width: 3),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: imageFile != null
                            ? Image.file(imageFile!, fit: BoxFit.cover)
                            : const Icon(Icons.person,
                                size: 80, color: Colors.grey),
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 2),
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(Icons.edit, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _inputField(
                  icon: Icons.person,
                  label: 'Full Name',
                  controller: fullNameController),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: DropdownButtonFormField<String>(
                  value: gender,
                  items: const [
                    DropdownMenuItem(value: 'Male', child: Text('Male')),
                    DropdownMenuItem(value: 'Female', child: Text('Female')),
                    DropdownMenuItem(value: 'Other', child: Text('Other')),
                  ],
                  onChanged: (val) {
                    setState(() {
                      gender = val ?? 'Male';
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Gender',
                    filled: true,
                    fillColor: const Color(0xFFEDEDED),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              _inputField(
                  icon: Icons.book,
                  label: 'Subject',
                  controller: subjectController),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: loading ? null : _saveTeacher,
                  child: loading
                      ? const CircularProgressIndicator()
                      : const Text('Save',
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class ClassListScreen extends StatefulWidget {
  const ClassListScreen({super.key});

  @override
  State<ClassListScreen> createState() => _ClassListScreenState();
}

class _ClassListScreenState extends State<ClassListScreen> {
  bool loading = true;
  String error = '';
  List<ParseObject> classes = [];

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
    } else {
      setState(() {
        error = 'Failed to fetch classes.';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Class List'),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
              ? Center(
                  child: Text(error, style: const TextStyle(color: Colors.red)))
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.3,
                  ),
                  itemCount: classes.length,
                  itemBuilder: (context, index) {
                    final classObj = classes[index];
                    final className =
                        classObj.get<String>('classname') ?? 'Class';
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ClassEnrolmentScreen(classObj: classObj),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              className,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final TextEditingController controller = TextEditingController();
          final result = await showDialog<String>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Create New Class'),
              content: TextField(
                controller: controller,
                decoration: const InputDecoration(hintText: 'Enter class name'),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () =>
                      Navigator.pop(context, controller.text.trim()),
                  child: const Text('Create'),
                ),
              ],
            ),
          );
          if (result != null && result.isNotEmpty) {
            setState(() => loading = true);
            final newClass = ParseObject('Class')..set('classname', result);
            final response = await newClass.save();
            if (response.success) {
              await _fetchClasses();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Class created successfully!')),
                );
              }
            } else {
              setState(() => loading = false);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Failed to create class: ' +
                          (response.error?.message ?? 'Unknown error'))),
                );
              }
            }
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.blue,
        tooltip: 'Create Class',
      ),
    );
  }
}

class AssignStudentToClassScreen extends StatefulWidget {
  const AssignStudentToClassScreen({super.key});

  @override
  State<AssignStudentToClassScreen> createState() =>
      _AssignStudentToClassScreenState();
}

class _AssignStudentToClassScreenState
    extends State<AssignStudentToClassScreen> {
  List<ParseObject> classes = [];
  List<ParseObject> students = [];
  List<String> selectedStudentIds = [];
  String? selectedClassId;
  bool loadingClasses = true;
  bool loadingStudents = false;
  String error = '';

  @override
  void initState() {
    super.initState();
    _fetchClasses();
  }

  Future<void> _fetchClasses() async {
    setState(() {
      loadingClasses = true;
      error = '';
    });
    final query = QueryBuilder<ParseObject>(ParseObject('Class'));
    final response = await query.query();
    if (response.success && response.results != null) {
      setState(() {
        classes = response.results!.cast<ParseObject>();
        loadingClasses = false;
      });
    } else {
      setState(() {
        error = 'Failed to fetch classes.';
        loadingClasses = false;
      });
    }
  }

  Future<void> _fetchStudents() async {
    setState(() {
      loadingStudents = true;
      error = '';
    });
    final query = QueryBuilder<ParseObject>(ParseObject('Student'));
    final response = await query.query();
    if (response.success && response.results != null) {
      setState(() {
        students = response.results!.cast<ParseObject>();
        loadingStudents = false;
      });
    } else {
      setState(() {
        error = 'Failed to fetch students.';
        loadingStudents = false;
      });
    }
  }

  Future<void> _assignStudentsToClass() async {
    if (selectedClassId == null || selectedStudentIds.isEmpty) return;
    setState(() {
      loadingStudents = true;
    });
    for (final studentId in selectedStudentIds) {
      // Fetch student name
      final studentQuery = QueryBuilder<ParseObject>(ParseObject('Student'))
        ..whereEqualTo('objectId', studentId);
      final studentResponse = await studentQuery.query();
      String studentName = '';
      if (studentResponse.success &&
          studentResponse.results != null &&
          studentResponse.results!.isNotEmpty) {
        studentName = studentResponse.results!.first.get<String>('name') ?? '';
      }
      final enrolment = ParseObject('Enrolment')
        ..set('class', ParseObject('Class')..objectId = selectedClassId)
        ..set('student', ParseObject('Student')..objectId = studentId)
        ..set('studentName', studentName);
      await enrolment.save();
    }
    setState(() {
      loadingStudents = false;
      selectedStudentIds.clear();
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Students assigned successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Student to Class'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: loadingClasses
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
              ? Center(
                  child: Text(error, style: const TextStyle(color: Colors.red)))
              : selectedClassId == null
                  ? _buildClassSelection()
                  : _buildStudentSelection(),
    );
  }

  Widget _buildClassSelection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select a Class',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.3,
              children: classes.map((cls) {
                final className = cls.get<String>('classname') ?? '';
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedClassId = cls.objectId;
                    });
                    _fetchStudents();
                  },
                  child: Card(
                    color: Colors.blue[50],
                    child: Center(
                      child: Text(className,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentSelection() {
    return loadingStudents
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        setState(() {
                          selectedClassId = null;
                          selectedStudentIds.clear();
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    const Text('Select Students',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (context, i) {
                      final student = students[i];
                      final name = student.get<String>('name') ?? '';
                      final id = student.objectId!;
                      return CheckboxListTile(
                        title: Text(name),
                        value: selectedStudentIds.contains(id),
                        onChanged: (checked) {
                          setState(() {
                            if (checked == true) {
                              selectedStudentIds.add(id);
                            } else {
                              selectedStudentIds.remove(id);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: selectedStudentIds.isEmpty
                        ? null
                        : _assignStudentsToClass,
                    child: const Text('Assign to Class',
                        style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          );
  }
}

class ClassEnrolmentScreen extends StatefulWidget {
  final ParseObject classObj;
  const ClassEnrolmentScreen({super.key, required this.classObj});

  @override
  State<ClassEnrolmentScreen> createState() => _ClassEnrolmentScreenState();
}

class _ClassEnrolmentScreenState extends State<ClassEnrolmentScreen> {
  bool loading = true;
  String error = '';
  List<_EnrolledStudent> enrolledStudents = [];

  @override
  void initState() {
    super.initState();
    _fetchEnrolments();
  }

  Future<void> _fetchEnrolments() async {
    setState(() {
      loading = true;
      error = '';
    });
    final enrolQuery = QueryBuilder<ParseObject>(ParseObject('Enrolment'))
      ..whereEqualTo(
          'class', ParseObject('Class')..objectId = widget.classObj.objectId);
    final enrolResponse = await enrolQuery.query();
    if (enrolResponse.success && enrolResponse.results != null) {
      // Collect all studentIds from enrolments
      List<_EnrolledStudent> students = [];
      List<String> studentIds = [];
      Map<String, String> enrolmentIdByStudentId = {};
      for (final enrol in enrolResponse.results!) {
        final studentPointer = enrol.get<ParseObject>('student');
        String? studentId = studentPointer?.objectId;
        String? enrolmentId = enrol.objectId;
        if (studentId != null && enrolmentId != null) {
          studentIds.add(studentId);
          enrolmentIdByStudentId[studentId] = enrolmentId;
        }
      }
      // Batch fetch all students
      if (studentIds.isNotEmpty) {
        final studentQuery = QueryBuilder<ParseObject>(ParseObject('Student'))
          ..whereContainedIn('objectId', studentIds);
        final studentResponse = await studentQuery.query();
        if (studentResponse.success && studentResponse.results != null) {
          for (final studentObj in studentResponse.results!) {
            final name = studentObj.get<String>('name') ?? '';
            final studentId = studentObj.objectId;
            final enrolmentId = enrolmentIdByStudentId[studentId];
            if (name.isNotEmpty && studentId != null && enrolmentId != null) {
              students.add(_EnrolledStudent(
                name: name,
                studentId: studentId,
                enrolmentId: enrolmentId,
              ));
            }
          }
        }
      }
      setState(() {
        enrolledStudents = students;
        loading = false;
      });
    } else {
      setState(() {
        error = 'Failed to fetch enrolments.';
        loading = false;
      });
    }
  }

  Future<void> _removeStudent(String enrolmentId) async {
    setState(() {
      loading = true;
    });
    final enrolment = ParseObject('Enrolment')..objectId = enrolmentId;
    final response = await enrolment.delete();
    if (response.success) {
      await _fetchEnrolments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student removed from class.')),
        );
      }
    } else {
      setState(() {
        loading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to remove student: ' +
                  (response.error?.message ?? 'Unknown error'))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final className = widget.classObj.get<String>('classname') ?? 'Class';
    return Scaffold(
      appBar: AppBar(
        title: Text(className),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error.isNotEmpty
              ? Center(
                  child: Text(error, style: const TextStyle(color: Colors.red)))
              : enrolledStudents.isEmpty
                  ? const Center(child: Text('No students enrolled.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: enrolledStudents.length,
                      itemBuilder: (context, i) {
                        final student = enrolledStudents[i];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading:
                                const Icon(Icons.person, color: Colors.blue),
                            title: Text(student.name),
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_circle,
                                  color: Colors.red),
                              tooltip: 'Remove from class',
                              onPressed: loading
                                  ? null
                                  : () => _removeStudent(student.enrolmentId),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}

class _EnrolledStudent {
  final String name;
  final String studentId;
  final String enrolmentId;
  _EnrolledStudent(
      {required this.name, required this.studentId, required this.enrolmentId});
}
