import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HospitalBookingScreen extends StatefulWidget {
  final String hospitalId;

  HospitalBookingScreen({required this.hospitalId});

  @override
  _HospitalBookingScreenState createState() => _HospitalBookingScreenState();
}

class _HospitalBookingScreenState extends State<HospitalBookingScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  String _errorMessage = '';
  String _selectedBedType = 'ICU';  // Default bed type
  List<String> _bedTypes = ['ICU', 'NICU'];  // Available bed types

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _bookSeat() async {
    String name = _nameController.text.trim();
    String phone = _phoneController.text.trim();
    String address = _addressController.text.trim();

    if (name.isEmpty || phone.isEmpty || address.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in all fields.';
      });
      return;
    }

    if (phone.length != 10 || !RegExp(r'^[0-9]+$').hasMatch(phone)) {
      setState(() {
        _errorMessage = 'Please enter a valid 10-digit phone number.';
      });
      return;
    }

    if (address.length < 10) {
      setState(() {
        _errorMessage = 'Address should be at least 10 characters long.';
      });
      return;
    }

    var currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      setState(() {
        _errorMessage = 'You must be logged in to book a seat.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      DocumentReference hospitalRef =
      _firestore.collection('hospitals').doc(widget.hospitalId);
      DocumentSnapshot hospitalSnapshot = await hospitalRef.get();

      if (hospitalSnapshot.exists) {
        var hospitalData = hospitalSnapshot.data() as Map<String, dynamic>;
        int currentBedsAvailable = hospitalData['${_selectedBedType.toLowerCase()}_beds'] as int;

        if (currentBedsAvailable > 0) {
          await hospitalRef.update({
            '${_selectedBedType.toLowerCase()}_beds': currentBedsAvailable - 1,
          });

          await _firestore.collection('bookings').add({
            'hospitalId': widget.hospitalId,
            'userId': currentUser.uid,
            'name': name,
            'phone': phone,
            'address': address,
            'bedType': _selectedBedType,
            'bookingTime': Timestamp.now(),
          });

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Seat booked successfully!'),
            backgroundColor: Colors.green,
          ));

          Navigator.pop(context);
        } else {
          setState(() {
            _errorMessage = 'No ${_selectedBedType} beds available at this hospital.';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Hospital not found.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred while booking. Please try again later.';
      });
      print('Error: $e'); // Debugging purpose
    }

    setState(() {
      _isLoading = false;
    });
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Seat'),
        backgroundColor: Colors.blue,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  'Enter Your Details to Book Seat',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                buildTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  icon: Icons.person,
                  inputType: TextInputType.name,
                ),
                SizedBox(height: 20),
                buildTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  icon: Icons.phone,
                  inputType: TextInputType.phone,
                ),
                SizedBox(height: 20),
                buildTextField(
                  controller: _addressController,
                  label: 'Address',
                  icon: Icons.home,
                  inputType: TextInputType.streetAddress,
                ),
                SizedBox(height: 20),
                DropdownButton<String>(
                  value: _selectedBedType,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedBedType = newValue!;
                    });
                  },
                  items: _bedTypes.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                SizedBox(height: 30),
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: _bookSeat,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding:
                      EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text('Book Seat'),
                  ),
                SizedBox(height: 20),
                if (_errorMessage.isNotEmpty)
                  Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
