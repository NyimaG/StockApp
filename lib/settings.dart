import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsUser extends StatelessWidget {
  const SettingsUser({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Settings',
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: Colors.blue[400]!,
          secondary: Colors.blue[300]!,
          surface: const Color(0xFF252525),
          surfaceContainerHighest: const Color(0xFF252525),
        ),
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
        useMaterial3: true,
      ),
      home: const SettingsPage(),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final firestore = FirebaseFirestore.instance;
  final TextEditingController _usernameController = TextEditingController();
  bool _isEditing = false;

  Future<DocumentSnapshot> getUserData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      return FirebaseFirestore.instance
          .collection('Userinfo')
          .doc(currentUser.uid)
          .get();
    } else {
      throw Exception("No user is logged in");
    }
  }

  Future<void> updateUserData(String field, String value) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await FirebaseFirestore.instance
            .collection('Userinfo')
            .doc(currentUser.uid)
            .update({field: value});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Username updated successfully')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating username: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              setState(() {
                if (_isEditing) {
                  if (_usernameController.text.isNotEmpty) {
                    updateUserData('Username', _usernameController.text);
                  }
                }
                _isEditing = !_isEditing;
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.hasData && snapshot.data != null) {
            final userData = snapshot.data!.data() as Map<String, dynamic>;

            _usernameController.text = userData['Username'] ?? '';

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profile Settings',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[400],
                        ),
                      ),
                      SizedBox(height: 20),
                      _buildSettingField(
                        'Username',
                        userData['Username'] ?? 'No Username',
                        _usernameController,
                        Icons.person,
                      ),
                      _buildSettingField(
                        'Email',
                        userData['Email'] ?? 'No Email',
                        _usernameController,
                        Icons.email,
                      ),
                      _buildSettingField(
                        'Password',
                        userData['Password'] ?? 'No Password',
                        _usernameController,
                        Icons.lock,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return Center(child: Text('No data available'));
        },
      ),
    );
  }

  Widget _buildSettingField(
    String label,
    String value,
    TextEditingController controller,
    IconData icon,
  ) {
    if (label == 'Password') {
      return ListTile(
        leading: Icon(Icons.lock, color: Colors.grey),
        title: Text(
          'Password',
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          '*****',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }

    if (label == 'Email') {
      return ListTile(
        leading: Icon(icon, color: Colors.grey),
        title: Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          value,
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }

    return ListTile(
      leading: Icon(icon, color: Colors.grey),
      title: Text(
        label,
        style: TextStyle(
          color: Colors.grey[400],
          fontSize: 16,
        ),
      ),
      subtitle: _isEditing
          ? TextField(
              controller: controller,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter new username',
                hintStyle: TextStyle(color: Colors.grey[600]),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[600]!),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue[400]!),
                ),
              ),
            )
          : Text(
              value,
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
      trailing: TextButton(
        onPressed: () {
          setState(() {
            if (_isEditing) {
              if (controller.text.isNotEmpty) {
                updateUserData('Username', controller.text);
              }
              _isEditing = false;
            } else {
              _isEditing = true;
            }
          });
        },
        child: Text(_isEditing ? 'Save' : 'Change'),
      ),
    );
  }
}
