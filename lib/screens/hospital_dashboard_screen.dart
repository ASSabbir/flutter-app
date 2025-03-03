import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'view_hospital_data_screen.dart';
import 'home_screen.dart';  // Assuming you have a home screen called 'HomeScreen'

class HospitalDashboardScreen extends StatefulWidget {
  @override
  _HospitalDashboardScreenState createState() =>
      _HospitalDashboardScreenState();
}

class _HospitalDashboardScreenState extends State<HospitalDashboardScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController icuBedsController = TextEditingController();
  final TextEditingController nicuBedsController = TextEditingController();
  final TextEditingController priceIcuController = TextEditingController();
  final TextEditingController priceNicuController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchHospitalData();
  }

  Future<void> _fetchHospitalData() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return;

      DocumentSnapshot doc =
      await _firestore.collection('hospitals').doc(user.uid).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        nameController.text = data['name'] ?? '';
        emailController.text = data['email'] ?? '';
        icuBedsController.text = data['icu_beds']?.toString() ?? '';
        nicuBedsController.text = data['nicu_beds']?.toString() ?? '';
        priceIcuController.text = data['price_icu']?.toString() ?? '';
        priceNicuController.text = data['price_nicu']?.toString() ?? '';
      }
    } catch (e) {
      print("Fetch error: $e");
    }
  }

  Future<void> _saveOrUpdateData() async {
    setState(() => _isLoading = true);

    try {
      if (nameController.text.trim().isEmpty ||
          emailController.text.trim().isEmpty ||
          icuBedsController.text.trim().isEmpty ||
          nicuBedsController.text.trim().isEmpty ||
          priceIcuController.text.trim().isEmpty ||
          priceNicuController.text.trim().isEmpty) {
        _showSnackBar('Please fill out all fields.', Colors.orange);
        setState(() => _isLoading = false);
        return;
      }

      User? user = _auth.currentUser;
      if (user == null) return;

      String hospitalId = user.uid;
      DocumentReference ref = _firestore.collection('hospitals').doc(hospitalId);
      DocumentSnapshot snapshot = await ref.get();

      Map<String, dynamic> data = {
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'icu_beds': int.tryParse(icuBedsController.text.trim()) ?? 0,
        'nicu_beds': int.tryParse(nicuBedsController.text.trim()) ?? 0,
        'price_icu': int.tryParse(priceIcuController.text.trim()) ?? 0,
        'price_nicu': int.tryParse(priceNicuController.text.trim()) ?? 0,
      };

      if (snapshot.exists) {
        await ref.update(data);
        _showSnackBar('Hospital data updated.', Colors.green);
      } else {
        await ref.set(data);
        _showSnackBar('Hospital data saved.', Colors.blue);
      }
    } catch (e) {
      print("Error saving data: $e");
      _showSnackBar('Failed to save data.', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteHospitalData() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection('hospitals').doc(user.uid).delete();
      _showSnackBar('Hospital data deleted.', Colors.redAccent);
      _clearFields();
    } catch (e) {
      print("Error deleting data: $e");
      _showSnackBar('Failed to delete data.', Colors.red);
    }
  }

  void _clearFields() {
    nameController.clear();
    emailController.clear();
    icuBedsController.clear();
    nicuBedsController.clear();
    priceIcuController.clear();
    priceNicuController.clear();
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white),
          filled: true,
          fillColor: Colors.blue[700],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Hospital Dashboard', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: CircleAvatar(child: Text('H')),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text('Manage Hospital Data',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue[800])),
              SizedBox(height: 20),
              _buildTextField(nameController, 'Hospital Name'),
              _buildTextField(emailController, 'Email'),
              _buildTextField(icuBedsController, 'ICU Beds', isNumeric: true),
              _buildTextField(nicuBedsController, 'NICU Beds', isNumeric: true),
              _buildTextField(priceIcuController, 'ICU Bed Price', isNumeric: true),
              _buildTextField(priceNicuController, 'NICU Bed Price', isNumeric: true),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveOrUpdateData,
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.blue)
                    : Text('Save / Update', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue[900],
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: _deleteHospitalData,
                child: Text('Delete Data', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => ViewHospitalDataScreen()));
                },
                child: Text('View All Hospital Data'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue[900],
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
              SizedBox(height: 15),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                },
                child: Text('Home', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue[900],
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    icuBedsController.dispose();
    nicuBedsController.dispose();
    priceIcuController.dispose();
    priceNicuController.dispose();
    super.dispose();
  }
}
