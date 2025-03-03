import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _hospitalNameController = TextEditingController();
  final _hospitalEmailController = TextEditingController();
  final _hospitalPasswordController = TextEditingController();

  String? _hospitalNameError;
  String? _hospitalEmailError;
  String? _hospitalPasswordError;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _validateHospitalName() {
    String name = _hospitalNameController.text;
    if (name.isEmpty) {
      setState(() {
        _hospitalNameError = 'Hospital name cannot be empty.';
      });
    } else {
      setState(() {
        _hospitalNameError = null;
      });
    }
  }

  void _validateHospitalEmail() {
    String email = _hospitalEmailController.text;
    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        _hospitalEmailError = 'Enter a valid email.';
      });
    } else {
      setState(() {
        _hospitalEmailError = null;
      });
    }
  }

  void _validateHospitalPassword() {
    String password = _hospitalPasswordController.text;
    if (password.isEmpty || password.length < 6) {
      setState(() {
        _hospitalPasswordError = 'Password must be at least 6 characters.';
      });
    } else {
      setState(() {
        _hospitalPasswordError = null;
      });
    }
  }

  Future<void> _registerHospital() async {
    _validateHospitalName();
    _validateHospitalEmail();
    _validateHospitalPassword();

    if (_hospitalNameError == null &&
        _hospitalEmailError == null &&
        _hospitalPasswordError == null) {
      String name = _hospitalNameController.text.trim();
      String email = _hospitalEmailController.text.trim();
      String password = _hospitalPasswordController.text.trim();

      try {
        // Check if the hospital name already exists
        final existingHospital =
        await _firestore.collection('hospitals').doc(name).get();

        if (existingHospital.exists) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Hospital name already exists. Choose a different one.')),
          );
          return;
        }

        // Create user with Firebase Authentication
        UserCredential userCredential =
        await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Use hospital name as the document ID in Firestore
        await _firestore.collection('hospitals').doc(name).set({
          'name': name,
          'email': email,
          'created_at': Timestamp.now(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hospital Registration Successful!')),
        );

        _hospitalNameController.clear();
        _hospitalEmailController.clear();
        _hospitalPasswordController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to register hospital: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields correctly.')),
      );
    }
  }

  void _logout() {
    _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      appBar: AppBar(
        title: Text(
          'Admin Dashboard',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        actions: [
          TextButton(
            onPressed: _logout,
            child: Text(
              'Log Out',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _hospitalNameController,
              decoration: InputDecoration(
                labelText: 'Hospital Name',
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(Icons.local_hospital, color: Colors.white),
                filled: true,
                fillColor: Colors.blue[700],
                errorText: _hospitalNameError ?? null,
              ),
              style: TextStyle(color: Colors.white),
              onChanged: (value) => _validateHospitalName(),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _hospitalEmailController,
              decoration: InputDecoration(
                labelText: 'Hospital Email',
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(Icons.email, color: Colors.white),
                filled: true,
                fillColor: Colors.blue[700],
                errorText: _hospitalEmailError ?? null,
              ),
              style: TextStyle(color: Colors.white),
              onChanged: (value) => _validateHospitalEmail(),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _hospitalPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Hospital Password',
                labelStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(Icons.lock, color: Colors.white),
                filled: true,
                fillColor: Colors.blue[700],
                errorText: _hospitalPasswordError ?? null,
              ),
              style: TextStyle(color: Colors.white),
              onChanged: (value) => _validateHospitalPassword(),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: _registerHospital,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue[900],
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'Register Hospital',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 30),
            Text(
              'Registered Hospitals',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
            SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('hospitals')
                  .orderBy('created_at', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Text('No hospitals registered yet.',
                      style: TextStyle(fontSize: 16));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var hospital = snapshot.data!.docs[index];
                    return Card(
                      color: Colors.blue[50],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: Icon(Icons.local_hospital, color: Colors.blue[900]),
                        title: Text(hospital['name'],
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(hospital['email']),
                        trailing: Text(
                          (hospital['created_at'] as Timestamp)
                              .toDate()
                              .toString()
                              .split('.')
                              .first,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
