import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'seat_availability_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final String email;

  UserProfileScreen({required this.email});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  @override
  void initState() {
    super.initState();
    _user = _auth.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        title: Text('User Profile'),
        backgroundColor: Colors.blue,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Welcome!',
                    style: TextStyle(color: Colors.blue, fontSize: 36, fontWeight: FontWeight.bold)),
                SizedBox(height: 40),
                Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.5), blurRadius: 5)],
                  ),
                  child: Text(
                    'Email: ${_user?.email ?? widget.email}',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                SizedBox(height: 20),
                if (_user?.displayName != null)
                  Text('Name: ${_user?.displayName}', style: TextStyle(fontSize: 18)),
                if (_user?.photoURL != null)
                  CircleAvatar(radius: 50, backgroundImage: NetworkImage(_user!.photoURL!)),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => SeatAvailabilityScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                  child: Text('Check Seat Availability'),
                ),
                SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    _auth.signOut();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                  child: Text('Log Out'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
