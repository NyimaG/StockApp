import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart';
import 'package:shared_preferences/shared_preferences.dart';

/*void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Here',
      home: Register(
        title: 'Login',
      ),
    );
  }
}
*/
class Register extends StatefulWidget {
  //Register({Key? key, required this.title}) : super(key: key);
  //final String title;
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  //final _firestore = FirebaseFirestore.instance;
  void _signOut() async {
    await _auth.signOut();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Signed out successfully'),
    ));
  }

  Future<void> saveUsername(String username) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('username', username);
  }

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  bool isLoading = false;

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        // Register user in Firebase Authentication
        await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        String user = _usernameController.text;
        saveUsername(user);
        //_usernameController.text;

        FirebaseFirestore.instance.collection('Userinfo').add({
          'Username': _usernameController.text,
          'Email': _emailController.text,
          'Password': _passwordController.text,
        });
        /*final newUserRef = _firestore
            .collection('Userinfo')
            .doc(); // Auto-generate a new document ID
        newUserRef.add({
          'Username': _usernameController.text,
          'Email': _emailController.text,
          'Password': _passwordController.text,
        });*/
        // Navigate to home screen or show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration successful!')),
        );
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));

        //Navigator.pushReplacementNamed(context, '/home');
      } catch (e) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 117, 255, 244),
                  Color.fromARGB(255, 228, 92, 255)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Form Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Register for StockSavvy",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 25,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 35,
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent),
                            borderRadius: BorderRadius.circular(5.5)),
                        prefixIcon: Icon(Icons.person, color: Colors.black),
                        hintText: "Enter a valid email",
                        hintStyle: TextStyle(color: Colors.black),
                        filled: true,
                        fillColor: Colors.white,
                        labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          !value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent),
                            borderRadius: BorderRadius.circular(5.5)),
                        prefixIcon: Icon(Icons.person_2, color: Colors.black),
                        hintText: "Create Username",
                        hintStyle: TextStyle(color: Colors.black),
                        filled: true,
                        fillColor: Colors.white,
                        labelText: 'Username'),
                    keyboardType: TextInputType.name,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a username';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent),
                            borderRadius: BorderRadius.circular(5.5)),
                        prefixIcon: Icon(Icons.lock, color: Colors.black),
                        hintText: "Enter a valid password",
                        hintStyle: TextStyle(color: Colors.black),
                        filled: true,
                        fillColor: Colors.white,
                        labelText: 'Password'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty || value.length < 6) {
                        return 'Password must be at least 6 characters long';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  isLoading
                      ? Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _registerUser,
                          child: Text('Register',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                  fontStyle: FontStyle.normal)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: ContinuousRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            shadowColor: Colors.white,
                          ),
                        ),
                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LoginPage())),
                    child: Text('Cancel'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
