import 'dart:convert'; // For JSON decoding
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For loading assets
import 'admin_dashboard_screen.dart'; // Import Admin Dashboard screen

// AdminLoginScreen
class AdminLoginScreen extends StatefulWidget {
  @override
  _AdminLoginScreenState createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _adminIDController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _adminIDError;
  String? _passwordError;

  // Function to validate admin ID
  void _validateAdminID() {
    String adminID = _adminIDController.text;
    if (adminID.isEmpty) {
      setState(() {
        _adminIDError = 'Admin ID cannot be empty.';
      });
    } else {
      setState(() {
        _adminIDError = null; // No error
      });
    }
  }

  // Function to validate password
  void _validatePassword() {
    String password = _passwordController.text;
    if (password.isEmpty || password.length < 6) {
      setState(() {
        _passwordError = 'Password must be at least 6 characters long.';
      });
    } else {
      setState(() {
        _passwordError = null; // No error
      });
    }
  }

  // Function to handle login
  void _handleLogin() async {
    _validateAdminID();
    _validatePassword();

    if (_adminIDError == null && _passwordError == null) {
      String username = _adminIDController.text.trim();
      String password = _passwordController.text;

      try {
        // Load the admin credentials
        final List<Map<String, String>> admins = await _loadAdminCredentials();

        // Check if the username and password match
        bool isValid = admins.any((admin) =>
        admin['username'] == username && admin['password'] == password);

        if (isValid) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Admin Login Successful')),
          );
          // Navigate to Admin Dashboard on success
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminDashboardScreen()),
          );
        } else {
          setState(() {
            _passwordError = 'Invalid username or password.';
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading credentials: ${e.toString()}')),
        );
      }
    }
  }

  // Function to load JSON data
  Future<List<Map<String, String>>> _loadAdminCredentials() async {
    // Load the JSON string from assets
    final String jsonString = await rootBundle.loadString('assets/admin_credentials.json');

    // Decode the JSON data into a Map<String, dynamic>
    final Map<String, dynamic> jsonData = jsonDecode(jsonString);

    // Access the "admins" key and cast it to a List of Maps with the appropriate type
    List<dynamic> adminsList = jsonData['admins'];

    // Return the list of admin credentials
    return adminsList.map<Map<String, String>>((admin) {
      return {
        'username': admin['username'],
        'password': admin['password'],
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100], // Light blue background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Admin Login',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 40),
                  TextField(
                    controller: _adminIDController,
                    decoration: InputDecoration(
                      labelText: 'Admin ID',
                      labelStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: Icon(Icons.account_circle, color: Colors.white),
                      filled: true,
                      fillColor: Colors.blue[700],
                      errorText: _adminIDError,
                    ),
                    style: TextStyle(color: Colors.white),
                    onChanged: (value) => _validateAdminID(),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: Icon(Icons.lock, color: Colors.white),
                      filled: true,
                      fillColor: Colors.blue[700],
                      errorText: _passwordError,
                    ),
                    style: TextStyle(color: Colors.white),
                    onChanged: (value) => _validatePassword(),
                  ),
                  SizedBox(height: 30),
                  Center(
                    child: ElevatedButton(
                      onPressed: _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue[900],
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        'Login',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Forgot Password functionality')),
                        );
                      },
                      child: Text(
                        'This is a private section without admin no one can access here',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0, top: 16.0),
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Navigate back to the previous screen
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    ),
                    child: Text(
                      'Back',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
