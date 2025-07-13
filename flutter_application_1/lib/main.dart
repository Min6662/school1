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
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const AdminDashboard(currentIndex: 0)));
      } else if (role == 'teacher') {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => const TeacherDashboard(currentIndex: 1)));
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
                Text('Columbia University',
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
                Text('Columbia University',
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
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: signupUser,
                      child:
                          const Text('Sign Up', style: TextStyle(fontSize: 16)),
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
  const ModernDashboard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.activities,
    required this.users,
    required this.items,
    this.actions,
    this.currentIndex = 0,
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
          builder: (_) => const TeacherDashboard(currentIndex: 1),
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
          padding:
              const EdgeInsets.fromLTRB(16, 16, 16, kBottomNavigationBarHeight + 17),
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
            const Text('The campus star',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: widget.users.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  final user = widget.users[i];
                  return SizedBox(
                    width: 80,
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundImage: NetworkImage(user['avatar'] ?? ''),
                          radius: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(user['name'] ?? '',
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                              minimumSize: const Size(60, 24),
                              padding: EdgeInsets.zero),
                          child: const Text('Follow',
                              style: TextStyle(fontSize: 10)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            const Text('Hot food',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 140,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: widget.items.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  final item = widget.items[i];
                  return Container(
                    width: 120,
                    constraints: const BoxConstraints(maxWidth: 140),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.grey.shade200, blurRadius: 6)
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16)),
                          child: Image.network(item['image'] ?? '',
                              height: 60, width: 120, fit: BoxFit.cover),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(item['title'] ?? '',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(item['desc'] ?? '',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2),
                        ),
                      ],
                    ),
                  );
                },
              ),
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
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
      body: Column(
        children: [
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(
                      'https://randomuser.me/api/portraits/men/1.jpg'),
                ),
                const SizedBox(height: 12),
                const Text('Ekeke Theophilus',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                const Text('@Theographic',
                    style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const EditProfileScreen()));
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
                  BoxShadow(color: Colors.grey.shade200, blurRadius: 12)
                ],
              ),
              child: ListView(
                children: [
                  _settingsTile(Icons.favorite_border, 'Favorites'),
                  _settingsTile(Icons.download_outlined, 'Downloads'),
                  _settingsTile(Icons.language, 'Language'),
                  _settingsTile(Icons.location_on_outlined, 'Location'),
                  _settingsTile(Icons.subscriptions_outlined, 'Subscription'),
                  _settingsTile(Icons.bug_report_outlined, 'Clear Crash'),
                  _settingsTile(Icons.history, 'Clear History'),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text('Logout',
                        style: TextStyle(color: Colors.red)),
                    onTap: () {
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (_) => const LoginPage()));
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

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

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
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Center(
            child: CircleAvatar(
              radius: 40,
              backgroundImage:
                  NetworkImage('https://randomuser.me/api/portraits/men/1.jpg'),
            ),
          ),
          const SizedBox(height: 24),
          _profileField('Name', 'Ekeke Theophilus'),
          _profileField('Email address', 'samsontheophilus32@gmail.com'),
          _profileField('User name', '@theographic'),
          _profileField('Password', '********', isPassword: true),
          _profileField('User name', '+234 9050053441'),
        ],
      ),
    );
  }

  Widget _profileField(String label, String value, {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        TextField(
          enabled: false,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: value,
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
}

class AdminDashboard extends StatelessWidget {
  final int currentIndex;
  const AdminDashboard({super.key, this.currentIndex = 0});
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
      users: const [
        {
          'name': 'Timothy White',
          'avatar': 'https://randomuser.me/api/portraits/men/1.jpg'
        },
        {
          'name': 'Anthony Clark',
          'avatar': 'https://randomuser.me/api/portraits/men/2.jpg'
        },
        {
          'name': 'James',
          'avatar': 'https://randomuser.me/api/portraits/men/3.jpg'
        },
      ],
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
        {
          'title': 'Spaghetti',
          'desc': '32 Reviews',
          'image':
              'https://images.unsplash.com/photo-1519864600265-abb224a0e99c'
        },
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
      currentIndex: currentIndex,
    );
  }
}

class TeacherDashboard extends StatelessWidget {
  final int currentIndex;
  const TeacherDashboard({super.key, this.currentIndex = 1});
  @override
  Widget build(BuildContext context) {
    return ModernDashboard(
      title: 'Assalam School',
      subtitle: 'Teacher circle',
      activities: const [
        {'title': 'My lectures'},
        {'title': 'Assignments'},
        {'title': 'Student feedback'},
        {'title': 'Events'},
      ],
      users: const [
        {
          'name': 'Alice',
          'avatar': 'https://randomuser.me/api/portraits/women/1.jpg'
        },
        {
          'name': 'Bob',
          'avatar': 'https://randomuser.me/api/portraits/men/4.jpg'
        },
        {
          'name': 'Carol',
          'avatar': 'https://randomuser.me/api/portraits/women/2.jpg'
        },
      ],
      items: const [
        {
          'title': 'Math Book',
          'desc': 'New edition',
          'image':
              'https://images.unsplash.com/photo-1512820790803-83ca734da794'
        },
        {
          'title': 'Physics Kit',
          'desc': 'Lab tools',
          'image':
              'https://images.unsplash.com/photo-1465101046530-73398c7f28ca'
        },
        {
          'title': 'Chemistry Set',
          'desc': 'For experiments',
          'image':
              'https://images.unsplash.com/photo-1509228468518-180dd4864904'
        },
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
      currentIndex: currentIndex,
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
              content: Text('Failed to fetch students: ${response.error?.message ?? 'Unknown error'}')),
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
                Text('All Students',
                    style: TextStyle(color: Colors.grey)),
                Row(
                  children: [
                    Text('Sort by time',
                        style: TextStyle(color: Colors.grey)),
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
                            final studentId = student.objectId;
                            if (studentId != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditStudentInformationScreen(
                                      objectId: studentId),
                                ),
                              );
                            }
                          },
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        onTap: () {
                          final studentId = student.objectId;
                          if (studentId != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => StudentInformationScreen(
                                    objectId: studentId),
                              ),
                            );
                          }
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
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => const TeacherDashboard(currentIndex: 1)));
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
  State<AddStudentInformationScreen> createState() => _AddStudentInformationScreenState();
}

class _AddStudentInformationScreenState extends State<AddStudentInformationScreen> {
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
              content: Text('Failed to add student: ${response.error?.message ?? 'Unknown error'}')),
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
                      child: imageFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(
                                imageFile!,
                                fit: BoxFit.cover,
                                width: 260,
                                height: 260,
                              ),
                            )
                          : Icon(Icons.person, size: 120, color: Colors.grey[400]),
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
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text('ID 00000000', style: TextStyle(color: Colors.grey, fontSize: 18)),
              const SizedBox(height: 32),
              _inputField(icon: Icons.person, label: 'Name', controller: nameController),
              _inputField(
                icon: Icons.cake,
                label: 'Date of birth',
                controller: TextEditingController(
                  text: dateOfBirth == null ? '' : dateOfBirth!.toLocal().toString().split(' ')[0],
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
              _inputField(icon: Icons.school, label: 'Grade', controller: gradeController),
              _inputField(icon: Icons.home, label: 'Addrees', controller: addressController),
              _inputField(icon: Icons.phone, label: 'Phone number', controller: phoneController),
              _inputField(icon: Icons.info, label: 'Study Status', controller: studyStatusController),
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
                      gradient: LinearGradient(colors: [Color(0xFF00B4DB), Color(0xFF0083B0)]),
                      borderRadius: BorderRadius.all(Radius.circular(32)),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: loading
                          ? const CircularProgressIndicator()
                          : const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
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

class EditStudentInformationScreen extends StatefulWidget {
  final String objectId;
  const EditStudentInformationScreen({super.key, required this.objectId});
  @override
  State<EditStudentInformationScreen> createState() => _EditStudentInformationScreenState();
}

class _EditStudentInformationScreenState extends State<EditStudentInformationScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController gradeController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController studyStatusController = TextEditingController();
  DateTime? dateOfBirth;
  File? imageFile;
  String? photoUrl;
  bool loading = false;
  bool deleting = false;

  @override
  void initState() {
    super.initState();
    _fetchStudent();
  }

  Future<void> _fetchStudent() async {
    setState(() => loading = true);
    final query = QueryBuilder<ParseObject>(ParseObject('Student'))
      ..whereEqualTo('objectId', widget.objectId);
    final response = await query.query();
    if (response.success &&
        response.results != null &&
        response.results!.isNotEmpty) {
      final student = response.results!.first as ParseObject;
      nameController.text = student.get<String>('name') ?? '';
      gradeController.text = student.get<String>('grade') ?? '';
      addressController.text = student.get<String>('address') ?? '';
      phoneController.text = student.get<String>('phoneNumber') ?? '';
      studyStatusController.text = student.get<String>('studyStatus') ?? '';
      photoUrl = student.get<String>('photo');
      final dobStr = student.get<String>('dateOfBirth');
      if (dobStr != null && dobStr.isNotEmpty) {
        dateOfBirth = DateTime.tryParse(dobStr);
      }
    }
    setState(() => loading = false);
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

  Future<void> _saveStudent() async {
    setState(() => loading = true);
    String? newPhotoUrl = photoUrl;
    if (imageFile != null) {
      newPhotoUrl = await _uploadImage(imageFile!);
    }
    final student = ParseObject('Student')
      ..objectId = widget.objectId
      ..set('name', nameController.text.trim())
      ..set('grade', gradeController.text.trim())
      ..set('address', addressController.text.trim())
      ..set('phoneNumber', phoneController.text.trim())
      ..set('studyStatus', studyStatusController.text.trim())
      ..set('dateOfBirth', dateOfBirth?.toIso8601String())
      ..set('photo', newPhotoUrl ?? '');
    final response = await student.save();
    setState(() => loading = false);
    if (response.success) {
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
              content: Text('Failed to update student: ${response.error?.message ?? 'Unknown error'}')),
        );
      }
    }
  }

  Future<void> _deleteStudent() async {
    setState(() => deleting = true);
    final student = ParseObject('Student')..objectId = widget.objectId;
    final response = await student.delete();
    setState(() => deleting = false);
    if (response.success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student deleted successfully!')),
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to delete student: ${response.error?.message ?? 'Unknown error'}')),
        );
      }
    }
  }

  Future<void> _onEditImage() async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Change Image'),
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Image',
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  setState(() {
                    imageFile = null;
                    photoUrl = null;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
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
        title: const Text('Edit Student', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: deleting ? null : _deleteStudent,
            tooltip: 'Delete',
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: _onEditImage,
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
                                    child: imageFile != null
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(16),
                                            child: Image.file(
                                              imageFile!,
                                              width: 260,
                                              height: 260,
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : Icon(Icons.person, size: 120, color: Colors.grey[400]),
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
                            const SizedBox(height: 24),
                            Text(
                              nameController.text.isEmpty ? 'Name' : nameController.text,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text('ID ${widget.objectId}', style: const TextStyle(color: Colors.grey, fontSize: 16)),
                            const SizedBox(height: 24),
                            _inputField(icon: Icons.person, label: 'Name', controller: nameController),
                            _inputField(
                              icon: Icons.cake,
                              label: 'Date of birth',
                              controller: TextEditingController(
                                text: dateOfBirth == null ? '' : dateOfBirth!.toLocal().toString().split(' ')[0],
                              ),
                              readOnly: true,
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: dateOfBirth ?? DateTime(2005, 1, 1),
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
                            _inputField(icon: Icons.school, label: 'Grade', controller: gradeController),
                            _inputField(icon: Icons.home, label: 'Address', controller: addressController),
                            _inputField(icon: Icons.phone, label: 'Phone number', controller: phoneController),
                            _inputField(icon: Icons.info, label: 'Study Status', controller: studyStatusController),
                            const SizedBox(height: 32),
                            Container(
                              width: double.infinity,
                              height: 54,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [Color(0xFF00B4DB), Color(0xFF0083B0)]),
                                borderRadius: BorderRadius.circular(32),
                                border: Border.all(color: Colors.cyan, width: 2),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(32),
                                  onTap: loading ? null : _saveStudent,
                                  child: Center(
                                    child: loading
                                        ? const CircularProgressIndicator()
                                        : const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
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
                },
              ),
            );
  }
}

class StudentInformationScreen extends StatefulWidget {
  final String objectId;
  const StudentInformationScreen({super.key, required this.objectId});
  @override
  State<StudentInformationScreen> createState() => _StudentInformationScreenState();
}

class _StudentInformationScreenState extends State<StudentInformationScreen> {
  String name = '';
  String grade = '';
  String address = '';
  String phoneNumber = '';
  String studyStatus = '';
  String? photoUrl;
  DateTime? dateOfBirth;
  bool loading = true;
  String gender = 'Female'; // Placeholder, replace with actual data if available
  int absentCount = 5; // Placeholder, replace with actual data if available

  @override
  void initState() {
    super.initState();
    _fetchStudent();
  }

  Future<void> _fetchStudent() async {
    final query = QueryBuilder<ParseObject>(ParseObject('Student'))
      ..whereEqualTo('objectId', widget.objectId);
    final response = await query.query();
    if (response.success &&
        response.results != null &&
        response.results!.isNotEmpty) {
      final student = response.results!.first as ParseObject;
      setState(() {
        name = student.get<String>('name') ?? '';
        grade = student.get<String>('grade') ?? '';
        address = student.get<String>('address') ?? '';
        phoneNumber = student.get<String>('phoneNumber') ?? '';
        studyStatus = student.get<String>('studyStatus') ?? '';
        photoUrl = student.get<String>('photo');
        final dobStr = student.get<String>('dateOfBirth');
        if (dobStr != null && dobStr.isNotEmpty) {
          dateOfBirth = DateTime.tryParse(dobStr);
        }
        loading = false;
      });
    } else {
      setState(() => loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to fetch student: ${response.error?.message ?? 'Unknown error'}')),
        );
      }
    }
  }

  String getAgeText() {
    if (dateOfBirth == null) return '';
    final now = DateTime.now();
    final years = now.year - dateOfBirth!.year;
    return '$years years';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.black),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Student Information',
                          style: TextStyle(
                            color: Color(0xFF8B7EDC),
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.signal_cellular_alt, color: Colors.black54, size: 20),
                        const SizedBox(width: 4),
                        const Icon(Icons.wifi, color: Colors.black54, size: 20),
                        const SizedBox(width: 4),
                        const Icon(Icons.battery_full, color: Colors.black54, size: 20),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Column(
                          children: [
                            // Card with landscape image and carousel
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: 160,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      color: Colors.white,
                                    ),
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(16),
                                          child: Image.network(
                                            'https://img.freepik.com/free-vector/landscape-background-illustration_53876-107151.jpg',
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: 160,
                                          ),
                                        ),
                                        const Positioned(
                                          left: 12,
                                          top: 60,
                                          child: CircleAvatar(
                                            backgroundColor: Colors.white,
                                            child: Icon(Icons.chevron_left, color: Color(0xFF8B7EDC)),
                                          ),
                                        ),
                                        const Positioned(
                                          right: 12,
                                          top: 60,
                                          child: CircleAvatar(
                                            backgroundColor: Colors.white,
                                            child: Icon(Icons.chevron_right, color: Color(0xFF8B7EDC)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF8B7EDC),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: Colors.grey,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: Colors.grey,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  // Student Info Card
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                name.isEmpty ? 'Name' : name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 22,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: 28,
                                              height: 28,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFF8B7EDC),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(Icons.location_on, color: Color(0xFF8B7EDC), size: 18),
                                            const SizedBox(width: 4),
                                            Text(
                                              address.isEmpty ? 'Address' : address,
                                              style: const TextStyle(color: Colors.grey, fontSize: 16),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            _infoBox('Gender', gender, highlight: true),
                                            _infoBox('Age', getAgeText(), highlight: true),
                                            _infoBox('Grade', grade, highlight: true),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        const Text('Study Status',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16)),
                                        Text(
                                          studyStatus.isEmpty ? 'Normal' : studyStatus,
                                          style: const TextStyle(color: Colors.grey, fontSize: 16),
                                        ),
                                        const SizedBox(height: 12),
                                        const Text('Attendance',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16)),
                                        Text(
                                          'Absent $absentCount times',
                                          style: const TextStyle(color: Colors.grey, fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF8B7EDC),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () {},
                                child: const Text(
                                  'Report',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
  }

  Widget _infoBox(String label, String value, {bool highlight = false}) {
    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7FB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.isEmpty ? '-' : value,
            style: TextStyle(
              color: highlight ? const Color(0xFF8B7EDC) : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
