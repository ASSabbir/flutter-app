import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'hospital_booking_screen.dart';

class SeatAvailabilityScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seat Availability'),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('hospitals').snapshots(),
        builder: (context, snapshot) {
          // If data isn't available yet, show loading indicator
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          // Get all the documents from the snapshot
          final hospitals = snapshot.data!.docs;

          return ListView.builder(
            itemCount: hospitals.length,
            itemBuilder: (context, index) {
              var hospital = hospitals[index];

              // Safely access the fields from the Firestore document
              Map<String, dynamic> hospitalData = hospital.data() as Map<String, dynamic>;

              // Ensure fields are safely accessed
              String hospitalName = hospitalData['name'] ?? 'No name available';
              int icuBeds = hospitalData['icu_beds'] ?? 0;
              int nicuBeds = hospitalData['nicu_beds'] ?? 0;
              String priceIcu = hospitalData['price_icu']?.toString() ?? 'N/A';
              String priceNicu = hospitalData['price_nicu']?.toString() ?? 'N/A';

              // Calculate total available beds
              int totalBeds = icuBeds + nicuBeds;

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(hospitalName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ICU Beds: $icuBeds'),
                      Text('NICU Beds: $nicuBeds'),
                      Text('Price (ICU): $priceIcu'),
                      Text('Price (NICU): $priceNicu'),
                    ],
                  ),
                  trailing: totalBeds > 0
                      ? ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HospitalBookingScreen(hospitalId: hospital.id),
                        ),
                      );
                    },
                    child: Text('Book Seat'),
                  )
                      : Text('Full', style: TextStyle(color: Colors.red)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
