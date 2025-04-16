import 'package:flutter/material.dart';
import 'login_screen.dart'; // User Log In screen
import 'signup_screen.dart'; // Sign Up screen
import 'hospital_login_screen.dart'; // Hospital Log In screen
import 'admin_login_screen.dart'; // Admin Log In screen

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedLoginOption = 'User'; // Default to User

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      appBar: AppBar(
        title: Text(
          'Emergence',
          style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        actions: [
          ElevatedButton(
            onPressed: () {
              // Navigate to Sign Up screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SignUpScreen()),
              );
            },
            child: Text('Sign Up', style: TextStyle(fontSize: 14)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            ),
          ),
          SizedBox(width: 10),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Ensure the logo image is in the correct path and added in pubspec.yaml
            Image.asset(
              'logo.png', // Check the path of the logo image
              width: 150,
              height: 150,
              fit: BoxFit.cover, // Ensures the logo fits well in the box
            ),
            SizedBox(height: 20),
            Text(
              'Welcome to Emergence',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 40),

            // Dropdown for selecting login option
            DropdownButton<String>(
              value: _selectedLoginOption,
              items: <String>['User', 'Hospital', 'Admin']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedLoginOption = newValue!; // Update the selected login option
                });
              },
              style: TextStyle(fontSize: 18, color: Colors.blue),
              dropdownColor: Colors.white,
              iconEnabledColor: Colors.deepOrange, // Change icon color
            ),
            SizedBox(height: 30),

            // Adding a custom styled button
            ElevatedButton(
              onPressed: () {
                // Navigate to Login screen based on selected option
                switch (_selectedLoginOption) {
                  case 'User':
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                    break;
                  case 'Hospital':
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HospitalLoginScreen()),
                    );
                    break;
                  case 'Admin':
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AdminLoginScreen()),
                    );
                    break;
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'Log In',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
