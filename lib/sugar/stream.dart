import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sugapulse/sugar/tile.dart';

class SugarReadingsStream extends StatelessWidget {
  SugarReadingsStream({required this.getAvg, super.key});
  final Function getAvg;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('Health_Data')
          .doc(firebaseService
              .getCurrentUser()!
              .email) // Use email as the doc ID
          .collection('sugar_readings')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
              child: CircularProgressIndicator(
            backgroundColor: Colors.black,
          ));
        }
        final recordedReadings = snapshot.data?.docs;
        List<Tile> tiles = [];

        for (var recordedReading in recordedReadings!) {
          final data = recordedReading.data() as Map<String, dynamic>;

          // Ensure 'sugar_reading' exists and is not null
          if (data.containsKey('sugar_reading') &&
              data['sugar_reading'] != null) {
            final int reading = data['sugar_reading'];

            // Check if 'timestamp' exists and is not null before converting
            DateTime dateTime;
            if (data.containsKey('timestamp') && data['timestamp'] != null) {
              final Timestamp timestamp = data['timestamp'];
              dateTime = timestamp.toDate();
            } else {
              dateTime = DateTime
                  .now(); // Fallback to current time if 'timestamp' is missing
            }
            final String documentId = recordedReading.id;
            tiles.add(Tile(
              getAvg: getAvg,
              id: documentId,
              reading: reading,
              dateTime: dateTime,
            ));
          }
        }

        return ListView(
          reverse: true,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          children: tiles,
        );
      },
    );
  }
}
