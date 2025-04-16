import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'view_hospital_data_screen.dart'; // Updated import

class HospitalLoginScreen extends StatefulWidget {
  @override
  _HospitalLoginScreenState createState() => _HospitalLoginScreenState();
}

class _HospitalLoginScreenState extends State<HospitalLoginScreen> {
  final _hospitalEmailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _hospitalEmailError;
  String? _passwordError;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  void _validateHospitalEmail() {
    String email = _hospitalEmailController.text;
    if (email.isEmpty) {
      setState(() {
        _hospitalEmailError = 'Email cannot be empty.';
      });
    } else if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(email)) {
      setState(() {
        _hospitalEmailError = 'Enter a valid email address.';
      });
    } else {
      setState(() {
        _hospitalEmailError = null;
      });
    }
  }

  void _validatePassword() {
    String password = _passwordController.text;
    if (password.isEmpty || password.length < 6) {
      setState(() {
        _passwordError = 'Password must be at least 6 characters long.';
      });
    } else {
      setState(() {
        _passwordError = null;
      });
    }
  }

  Future<void> _handleLogin() async {
    _validateHospitalEmail();
    _validatePassword();

    if (_hospitalEmailError == null && _passwordError == null) {
      setState(() {
        _isLoading = true;
      });

      try {
        String email = _hospitalEmailController.text.trim();
        String password = _passwordController.text.trim();

        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        User? user = userCredential.user;
        if (user != null) {
          DocumentSnapshot hospitalDoc = await FirebaseFirestore.instance
              .collection('hospitals')
              .doc(user.uid)
              .get();

          if (!hospitalDoc.exists) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('No hospital data found for this account.'),
              backgroundColor: Colors.red,
            ));
            await _auth.signOut();
            return;
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Hospital Login Successful'),
          backgroundColor: Colors.green,
        ));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ViewHospitalDataScreen()),
        );
      } catch (e) {
        print('Login Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Login Failed. Please check your email and password.'),
          backgroundColor: Colors.red,
        ));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please fill in both fields correctly'),
        backgroundColor: Colors.orange,
      ));
    }
  }

  Future<void> _resetPassword() async {
    String email = _hospitalEmailController.text.trim();
    _validateHospitalEmail();

    if (_hospitalEmailError == null) {
      try {
        await _auth.sendPasswordResetEmail(email: email);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Password reset email sent.'),
          backgroundColor: Colors.green,
        ));
      } catch (e) {
        print('Password Reset Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to send reset email.'),
          backgroundColor: Colors.red,
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Enter a valid email to reset password.'),
        backgroundColor: Colors.orange,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
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
                        'Hospital Login',
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
                    controller: _hospitalEmailController,
                    decoration: InputDecoration(
                      labelText: 'Hospital Email',
                      labelStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: Icon(Icons.local_hospital, color: Colors.white),
                      filled: true,
                      fillColor: Colors.blue[700],
                      errorText: _hospitalEmailError,
                    ),
                    style: TextStyle(color: Colors.white),
                    onChanged: (value) => _validateHospitalEmail(),
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
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue[900],
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator()
                          : Text(
                        'Login',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: TextButton(
                      onPressed: _resetPassword,
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
