
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'hospital_booking_screen.dart'; // your booking screen

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({Key? key}) : super(key: key);

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  String userName = '';
  int age = 0;
  String history = '';
  bool _loading = true;
  List<Map<String, dynamic>> registeredHospitals = [];

  Future<void> _loadUserProfileAndHospitals() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final userDoc = await _firestore.collection('users').doc(uid).get();
    final userData = userDoc.data();

    final hospitalSnapshot = await _firestore
        .collection('registrations')
        .where('user_id', isEqualTo: uid)
        .get();

    setState(() {
      if (userData != null) {
        userName = userData['name'] ?? '';
        age = userData['age'] ?? 0;
        history = userData['medical_history'] ?? '';
      }

      registeredHospitals = hospitalSnapshot.docs.map((doc) {
        return {
          'hospital_id': doc['hospital_id'],
          'hospital_name': doc['hospital_name'] ?? 'Unnamed Hospital',
          'location': doc['location'] ?? 'Unknown',
        };
      }).toList();

      _loading = false;
    });
  }

  void _logout() async {
    await _auth.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserProfileAndHospitals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Dashboard'),
        backgroundColor: Colors.blue[900],
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Name: $userName', style: const TextStyle(fontSize: 18)),
                  Text('Age: $age', style: const TextStyle(fontSize: 18)),
                  Text('Medical History: $history', style: const TextStyle(fontSize: 18)),
                ],
              ),
            ),
            const SizedBox(height: 30),

            const Text('Registered Hospitals:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...registeredHospitals.map((hospital) => Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(hospital['hospital_name']),
                subtitle: Text('Location: ${hospital['location']}'),
                trailing: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HospitalBookingScreen(hospitalId: hospital['hospital_id']),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange[700],
                  ),
                  child: const Text('Book'),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
