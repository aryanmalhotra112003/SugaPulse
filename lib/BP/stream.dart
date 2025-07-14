import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sugapulse/BP/tile.dart';

class BPReadingsStream extends StatelessWidget {
  BPReadingsStream({super.key});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('Health_Data')
          .doc(firebaseService
              .getCurrentUser()!
              .email) // Use email as the doc ID
          .collection('bp_readings')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.black,
            ),
          );
        }
        final recordedReadings = snapshot.data?.docs;
        List<Tile> tiles = [];
        for (var recordedReading in recordedReadings!) {
          final data = recordedReading.data() as Map<String, dynamic>;
          if (data.containsKey('sbp') && data['sbp'] != null) {
            final int sbp = data['sbp'];
            if (data.containsKey('dbp') && data['dbp'] != null) {
              final int dbp = data['dbp'];
              if (data.containsKey('pulse') && data['pulse'] != null) {
                final int pulse = data['pulse'];
                // Check if 'timestamp' exists and is not null before converting
                DateTime dateTime;
                if (data.containsKey('timestamp') &&
                    data['timestamp'] != null) {
                  final Timestamp timestamp = data['timestamp'];
                  dateTime = timestamp.toDate();
                } else {
                  dateTime = DateTime
                      .now(); // Fallback to current time if 'timestamp' is missing
                }
                final String documentId = recordedReading.id;

                tiles.add(Tile(
                  id: documentId,
                  SBP: sbp,
                  DBP: dbp,
                  pulse: pulse,
                  dateTime: dateTime,
                ));
              }
            }
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
