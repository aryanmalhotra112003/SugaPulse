import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? getCurrentUser() {
    try {
      final user =
          _auth.currentUser; // Use currentUser instead of onAuthStateChanged
      if (user != null) {
        return user;
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<int> calculateAverageSugarReading(
      String? email, String timeFrame) async {
    if (email == null) return 0; // Handle null email case

    // Reference to Firestore collection
    CollectionReference sugarReadingsRef = FirebaseFirestore.instance
        .collection('Health_Data')
        .doc(email)
        .collection('sugar_readings');

    QuerySnapshot snapshot;

    if (timeFrame == 'weekly') {
      // Get the timestamp for 7 days ago
      DateTime oneWeekAgo = DateTime.now().subtract(Duration(days: 7));

      // Query only readings from the last week
      snapshot = await sugarReadingsRef
          .where('timestamp',
              isGreaterThanOrEqualTo: Timestamp.fromDate(oneWeekAgo))
          .get();
    } else {
      // Query all-time readings
      snapshot = await sugarReadingsRef.get();
    }

    double totalReading = 0.0;
    int count = snapshot.docs.length;

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final sugarReading = data['sugar_reading'];

      // Ensure the reading is a valid number before summing
      if (sugarReading is num) {
        totalReading += sugarReading.toDouble();
      }
    }

    return count == 0 ? 0 : (totalReading / count).toInt();
  }

  Future<void> addSugarReading(int reading, String? email) async {
    if (email == null) return;

    // Reference to the 'Sugar' collection
    CollectionReference sugarCollection =
        FirebaseFirestore.instance.collection('Health_Data');

    // Create a document with the user's email as the document ID
    DocumentReference userDocRef = sugarCollection.doc(email);

    // Reference to the user's sugar_readings subcollection within their document
    CollectionReference readingsRef = userDocRef.collection('sugar_readings');

    await readingsRef.add({
      'sugar_reading': reading,
      'timestamp': FieldValue.serverTimestamp(), // Store the time of reading
    });
    await increaseSugarScoreAndStreak(email);
  }

  Future<void> addBPReading(int sbp, int dbp, int pulse, String? email) async {
    if (email == null) return;

    CollectionReference bpCollection =
        FirebaseFirestore.instance.collection('Health_Data');

    // Create a document with the user's email as the document ID
    DocumentReference userDocRef = bpCollection.doc(email);

    // Reference to the user's sugar_readings subcollection within their document
    CollectionReference readingsRef = userDocRef.collection('bp_readings');

    await readingsRef.add({
      'sbp': sbp,
      'dbp': dbp,
      'pulse': pulse,
      'timestamp': FieldValue.serverTimestamp(), // Store the time of reading
    });
    await increaseBPScoreAndStreak(email);
  }

  Future<void> deleteSugarReading(String readingId, String? email) async {
    if (email == null) return;

    await FirebaseFirestore.instance
        .collection('Health_Data') // Access the 'Sugar' collection
        .doc(email) // Locate the document with user's email as ID
        .collection(
            'sugar_readings') // Access the 'sugar_readings' subcollection
        .doc(readingId) // Locate the specific reading document by its ID
        .delete();
  }

  Future<void> deleteBPReading(String readingId, String? email) async {
    if (email == null) return;

    await FirebaseFirestore.instance
        .collection('Health_Data') // Access the 'Sugar' collection
        .doc(email) // Locate the document with user's email as ID
        .collection('bp_readings') // Access the 'sugar_readings' subcollection
        .doc(readingId) // Locate the specific reading document by its ID
        .delete();
  }

  Future<int> findDangerousSugarHigh(String? email, String timeFrame) async {
    if (email == null) return 0; // Handle null email case

    // Query the 'sugar_readings' subcollection under the user's document
    CollectionReference sugarReadingsRef = FirebaseFirestore.instance
        .collection('Health_Data')
        .doc(email)
        .collection('sugar_readings');

    QuerySnapshot snapshot;

    if (timeFrame == 'weekly') {
      // Get the timestamp for 7 days ago
      DateTime oneWeekAgo = DateTime.now().subtract(Duration(days: 7));

      // Query only readings from the last week
      snapshot = await sugarReadingsRef
          .where('timestamp',
              isGreaterThanOrEqualTo: Timestamp.fromDate(oneWeekAgo))
          .get();
    } else {
      // Query all-time readings
      snapshot = await sugarReadingsRef.get();
    }

    // Initialize total sum of readings
    int countOfHighs = 0;
    int count = snapshot.docs.length;

    // Loop through the documents and sum up the readings
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final sugarReading = data['sugar_reading']; // Extract sugar reading
      if (sugarReading > 300) {
        countOfHighs++;
      }
    }

    // Calculate and return the average
    return count == 0 ? 0 : countOfHighs;
  }

  Future<int> findDangerousSugarLow(String? email, String timeFrame) async {
    if (email == null) return 0; // Handle null email case

    // Query the 'sugar_readings' subcollection under the user's document
    CollectionReference sugarReadingsRef = FirebaseFirestore.instance
        .collection('Health_Data')
        .doc(email)
        .collection('sugar_readings');

    QuerySnapshot snapshot;

    if (timeFrame == 'weekly') {
      // Get the timestamp for 7 days ago
      DateTime oneWeekAgo = DateTime.now().subtract(Duration(days: 7));

      // Query only readings from the last week
      snapshot = await sugarReadingsRef
          .where('timestamp',
              isGreaterThanOrEqualTo: Timestamp.fromDate(oneWeekAgo))
          .get();
    } else {
      // Query all-time readings
      snapshot = await sugarReadingsRef.get();
    }

    // Initialize total sum of readings
    int countOfLows = 0;
    int count = snapshot.docs.length;

    // Loop through the documents and sum up the readings
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final sugarReading = data['sugar_reading']; // Extract sugar reading
      if (sugarReading < 70) {
        countOfLows++;
      }
    }

    // Calculate and return the average
    return count == 0 ? 0 : countOfLows;
  }

  Future<List<FlSpot>> getWeeklySugarReadings(String? email) async {
    if (email == null) return [];

    // Reference to Firestore collection
    CollectionReference sugarReadingsRef = FirebaseFirestore.instance
        .collection('Health_Data')
        .doc(email)
        .collection('sugar_readings');

    DateTime oneWeekAgo = DateTime.now().subtract(Duration(days: 7));

    // Query Firestore for the last 7 days of readings
    QuerySnapshot snapshot = await sugarReadingsRef
        .where('timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(oneWeekAgo))
        .orderBy('timestamp', descending: false)
        .get();

    if (snapshot.docs.isEmpty) return []; // No readings found

    List<FlSpot> spots = [];
    Map<String, List<int>> dailyReadings = {};
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final sugarReading = data['sugar_reading'];
      final timestamp = (data['timestamp'] as Timestamp).toDate();
      String formattedDate = DateFormat.yMd().format(timestamp);
      if (dailyReadings.containsKey(formattedDate)) {
        dailyReadings[formattedDate]!.add(sugarReading);
      } else {
        dailyReadings[formattedDate] = [sugarReading];
      }
    }
    dailyReadings.forEach((date, readings) {
      double avgReading = readings.reduce((a, b) => a + b) /
          readings.length; // Calculate average
      DateTime parsedDate =
          DateFormat.yMd().parse(date); // Convert date string back to DateTime
      double xValue = parsedDate.millisecondsSinceEpoch
          .toDouble(); // Convert to timestamp for X-axis

      spots.add(FlSpot(xValue, avgReading)); // Add the point to the list
    });

    return spots;
  }

  Future<List<FlSpot>> getWeeklySBP(String? email) async {
    if (email == null) return [];

    // Reference to Firestore collection
    CollectionReference sugarReadingsRef = FirebaseFirestore.instance
        .collection('Health_Data')
        .doc(email)
        .collection('bp_readings');

    DateTime oneWeekAgo = DateTime.now().subtract(Duration(days: 7));

    // Query Firestore for the last 7 days of readings
    QuerySnapshot snapshot = await sugarReadingsRef
        .where('timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(oneWeekAgo))
        .orderBy('timestamp', descending: false)
        .get();

    if (snapshot.docs.isEmpty) return []; // No readings found

    List<FlSpot> spots = [];
    Map<String, List<int>> dailyReadings = {};
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final sbp = data['sbp'];
      final timestamp = (data['timestamp'] as Timestamp).toDate();
      String formattedDate = DateFormat.yMd().format(timestamp);
      if (dailyReadings.containsKey(formattedDate)) {
        dailyReadings[formattedDate]!.add(sbp);
      } else {
        dailyReadings[formattedDate] = [sbp];
      }
    }
    dailyReadings.forEach((date, readings) {
      double avgReading = readings.reduce((a, b) => a + b) /
          readings.length; // Calculate average
      DateTime parsedDate =
          DateFormat.yMd().parse(date); // Convert date string back to DateTime
      double xValue = parsedDate.millisecondsSinceEpoch
          .toDouble(); // Convert to timestamp for X-axis

      spots.add(FlSpot(xValue, avgReading)); // Add the point to the list
    });

    return spots;
  }

  Future<List<FlSpot>> getWeeklyDBP(String? email) async {
    if (email == null) return [];

    // Reference to Firestore collection
    CollectionReference sugarReadingsRef = FirebaseFirestore.instance
        .collection('Health_Data')
        .doc(email)
        .collection('bp_readings');

    DateTime oneWeekAgo = DateTime.now().subtract(Duration(days: 7));

    // Query Firestore for the last 7 days of readings
    QuerySnapshot snapshot = await sugarReadingsRef
        .where('timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(oneWeekAgo))
        .orderBy('timestamp', descending: false)
        .get();

    if (snapshot.docs.isEmpty) return []; // No readings found

    List<FlSpot> spots = [];
    Map<String, List<int>> dailyReadings = {};
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final dbp = data['dbp'];
      final timestamp = (data['timestamp'] as Timestamp).toDate();
      String formattedDate = DateFormat.yMd().format(timestamp);
      if (dailyReadings.containsKey(formattedDate)) {
        dailyReadings[formattedDate]!.add(dbp);
      } else {
        dailyReadings[formattedDate] = [dbp];
      }
    }
    dailyReadings.forEach((date, readings) {
      double avgReading = readings.reduce((a, b) => a + b) /
          readings.length; // Calculate average
      DateTime parsedDate =
          DateFormat.yMd().parse(date); // Convert date string back to DateTime
      double xValue = parsedDate.millisecondsSinceEpoch
          .toDouble(); // Convert to timestamp for X-axis

      spots.add(FlSpot(xValue, avgReading)); // Add the point to the list
    });

    return spots;
  }

  Future<List<FlSpot>> getWeeklyPulse(String? email) async {
    if (email == null) return [];

    // Reference to Firestore collection
    CollectionReference sugarReadingsRef = FirebaseFirestore.instance
        .collection('Health_Data')
        .doc(email)
        .collection('bp_readings');

    DateTime oneWeekAgo = DateTime.now().subtract(Duration(days: 7));

    // Query Firestore for the last 7 days of readings
    QuerySnapshot snapshot = await sugarReadingsRef
        .where('timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(oneWeekAgo))
        .orderBy('timestamp', descending: false)
        .get();

    if (snapshot.docs.isEmpty) return []; // No readings found

    List<FlSpot> spots = [];
    Map<String, List<int>> dailyReadings = {};
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final pulse = data['pulse'];
      final timestamp = (data['timestamp'] as Timestamp).toDate();
      String formattedDate = DateFormat.yMd().format(timestamp);
      if (dailyReadings.containsKey(formattedDate)) {
        dailyReadings[formattedDate]!.add(pulse);
      } else {
        dailyReadings[formattedDate] = [pulse];
      }
    }
    dailyReadings.forEach((date, readings) {
      double avgReading = readings.reduce((a, b) => a + b) /
          readings.length; // Calculate average
      DateTime parsedDate =
          DateFormat.yMd().parse(date); // Convert date string back to DateTime
      double xValue = parsedDate.millisecondsSinceEpoch
          .toDouble(); // Convert to timestamp for X-axis

      spots.add(FlSpot(xValue, avgReading)); // Add the point to the list
    });

    return spots;
  }

  Future<Map<String, int>> calculateAverageBPReading(String? email) async {
    if (email == null) {
      return {'sbp': 0, 'dbp': 0, 'pulse': 0}; // Handle null email case
    }

    // Reference to Firestore collection
    CollectionReference bpReadingsRef = FirebaseFirestore.instance
        .collection('Health_Data')
        .doc(email)
        .collection('bp_readings');

    QuerySnapshot snapshot;
    // Get the timestamp for 7 days ago
    DateTime oneWeekAgo = DateTime.now().subtract(Duration(days: 7));

    // Query only readings from the last week
    snapshot = await bpReadingsRef
        .where('timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(oneWeekAgo))
        .get();

    double sbpReading = 0.0;
    double dbpReading = 0.0;
    double pulseReading = 0.0;
    int count = snapshot.docs.length;

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      sbpReading += data['sbp'];
      dbpReading += data['dbp'];
      pulseReading += data['pulse'];
    }
    int sbpAvg = (sbpReading / count).toInt();
    int dbpAvg = (dbpReading / count).toInt();
    int pulseAvg = (pulseReading / count).toInt();

    return count == 0
        ? {'sbp': 0, 'dbp': 0, 'pulse': 0}
        : {'sbp': sbpAvg, 'dbp': dbpAvg, 'pulse': pulseAvg};
  }

  Future<int> findCountOfSugarReadings(String? email) async {
    if (email == null) return 0; // Handle null email case

    // Reference to Firestore collection
    CollectionReference sugarReadingsRef = FirebaseFirestore.instance
        .collection('Health_Data')
        .doc(email)
        .collection('sugar_readings');

    QuerySnapshot snapshot = await sugarReadingsRef.get();

    int count = snapshot.docs.length;

    return count;
  }

  Future<int> findCountOfBPReadings(String? email) async {
    if (email == null) return 0; // Handle null email case

    // Reference to Firestore collection
    CollectionReference BPReadingsRef = FirebaseFirestore.instance
        .collection('Health_Data')
        .doc(email)
        .collection('bp_readings');

    QuerySnapshot snapshot = await BPReadingsRef.get();

    int count = snapshot.docs.length;

    return count;
  }

  Future<void> increaseSugarScoreAndStreak(String? userEmail) async {
    if (userEmail == null) return;

    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final DocumentReference userDocRef =
        firestore.collection('Health_Data').doc(userEmail);

    // Fetch all sugar readings sorted by timestamp ASCENDING (oldest to newest)
    final QuerySnapshot sugarSnapshot = await userDocRef
        .collection('sugar_readings')
        .orderBy('timestamp', descending: false)
        .get();

    int count = await findCountOfSugarReadings(userEmail);

    if (count == 1) {
      // First reading  added
      await userDocRef.set({
        'sugar_streak': 1,
        'sugar_score': 20,
      }, SetOptions(merge: true));
      return;
    }

    // Convert all reading timestamps to date-only format
    List<DateTime> dateList = sugarSnapshot.docs.map((doc) {
      Timestamp timestamp = doc['timestamp'];
      DateTime dt = timestamp.toDate();
      return DateTime(dt.year, dt.month, dt.day);
    }).toList();

    // Remove duplicates in case multiple readings are made on the same date
    dateList = dateList.toSet().toList();
    dateList.sort();

    // Step 1: Start from most recent date and count backwards
    int streak = 1;
    for (int i = dateList.length - 1; i > 0; i--) {
      int diff = dateList[i].difference(dateList[i - 1]).inDays;
      if (diff == 1) {
        streak++;
      } else {
        break;
      }
    }

    // Step 2: Fetch current score
    final DocumentSnapshot userSnapshot = await userDocRef.get();
    final data = userSnapshot.data() as Map<String, dynamic>?;
    final int currentScore = data?['sugar_score'] ?? 0;

    int newScore = currentScore + 20;

    // Step 3: Update Firestore with new score and streak
    await userDocRef.set({
      'sugar_streak': streak,
      'sugar_score': newScore,
    }, SetOptions(merge: true));
  }

  Future<void> decreaseSugarScore(String? userEmail) async {
    if (userEmail == null) return;

    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final DocumentReference userDocRef =
        firestore.collection('Health_Data').doc(userEmail);

    // Fetch all sugar readings
    final QuerySnapshot sugarSnapshot = await userDocRef
        .collection('sugar_readings')
        .orderBy('timestamp', descending: true)
        .get();

    // Normalize all dates to yyyy-mm-dd
    List<DateTime> uniqueDates = sugarSnapshot.docs
        .map((doc) => (doc['timestamp'] as Timestamp).toDate())
        .map((dt) => DateTime(dt.year, dt.month, dt.day))
        .toSet()
        .toList();

    // Sort from latest to oldest
    uniqueDates.sort((a, b) => b.compareTo(a));

    // Calculate new streak starting from the most recent reading
    int newStreak = 1;
    for (int i = 1; i < uniqueDates.length; i++) {
      if (uniqueDates[i - 1].difference(uniqueDates[i]).inDays == 1) {
        newStreak++;
      } else {
        break;
      }
    }

    // Fetch current score
    final DocumentSnapshot userSnapshot = await userDocRef.get();
    final data = userSnapshot.data() as Map<String, dynamic>?;
    final int currentScore = data?['sugar_score'] ?? 0;
    int newScore = currentScore - 20;

    // Update values (prevent negative values)
    await userDocRef.set({
      'sugar_score': newScore < 0 ? 0 : newScore,
      'sugar_streak': newStreak < 0 ? 0 : newStreak,
    }, SetOptions(merge: true));
  }

  Future<void> increaseBPScoreAndStreak(String? userEmail) async {
    if (userEmail == null) return;

    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final DocumentReference userDocRef =
        firestore.collection('Health_Data').doc(userEmail);

    final QuerySnapshot bpSnapshot = await userDocRef
        .collection('bp_readings')
        .orderBy('timestamp', descending: false)
        .get();

    int count = await findCountOfBPReadings(
        userEmail); // You already have this function

    if (count == 1) {
      // First reading added
      await userDocRef.set({
        'bp_streak': 1,
        'bp_score': 35,
      }, SetOptions(merge: true));
      return;
    }
    // Convert all reading timestamps to date-only format
    List<DateTime> dateList = bpSnapshot.docs.map((doc) {
      Timestamp timestamp = doc['timestamp'];
      DateTime dt = timestamp.toDate();
      return DateTime(dt.year, dt.month, dt.day);
    }).toList();

    // Remove duplicates in case multiple readings are made on the same date
    dateList = dateList.toSet().toList();
    dateList.sort();

    // Step 1: Start from most recent date and count backwards
    int streak = 1;
    for (int i = dateList.length - 1; i > 0; i--) {
      int diff = dateList[i].difference(dateList[i - 1]).inDays;
      if (diff == 1) {
        streak++;
      } else {
        break;
      }
    }

    // Fetch current streak and score
    final DocumentSnapshot userSnapshot = await userDocRef.get();
    final data = userSnapshot.data() as Map<String, dynamic>?;

    final int currentScore = data?['bp_score'] ?? 0;
    int newScore = currentScore + 35;

    await userDocRef.set({
      'bp_streak': streak,
      'bp_score': newScore,
    }, SetOptions(merge: true));
  }

  Future<void> decreaseBPScore(String? userEmail) async {
    if (userEmail == null) return;

    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final DocumentReference userDocRef =
        firestore.collection('Health_Data').doc(userEmail);
// Fetch all BP readings
    final QuerySnapshot bpSnapshot = await userDocRef
        .collection('bp_readings')
        .orderBy('timestamp', descending: true)
        .get();

    // Normalize all dates to yyyy-mm-dd
    List<DateTime> uniqueDates = bpSnapshot.docs
        .map((doc) => (doc['timestamp'] as Timestamp).toDate())
        .map((dt) => DateTime(dt.year, dt.month, dt.day))
        .toSet()
        .toList();

    // Sort from latest to oldest
    uniqueDates.sort((a, b) => b.compareTo(a));

    // Calculate new streak starting from the most recent reading
    int newStreak = 1;
    for (int i = 1; i < uniqueDates.length; i++) {
      if (uniqueDates[i - 1].difference(uniqueDates[i]).inDays == 1) {
        newStreak++;
      } else {
        break;
      }
    }

    // Fetch current bp score and streak
    final DocumentSnapshot userSnapshot = await userDocRef.get();
    final data = userSnapshot.data() as Map<String, dynamic>?;

    final int currentScore = data?['bp_score'] ?? 0;

    int newScore = currentScore - 35;
    // Default to no change

    // Update the user's score and streak
    await userDocRef.set(
      {
        'bp_score': newScore < 0 ? 0 : newScore,
        'bp_streak': newStreak < 0 ? 0 : newStreak,
      },
      SetOptions(merge: true),
    );
  }

  Future<int> fetchScore(String? userEmail) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final DocumentReference userDocRef =
        firestore.collection('Health_Data').doc(userEmail);

    // Fetch current streak and score
    final DocumentSnapshot userSnapshot = await userDocRef.get();
    final data = userSnapshot.data() as Map<String, dynamic>?;

    int bpScore = data?['bp_score'] ?? 0;
    int sugarScore = data?['sugar_score'] ?? 0;
    int score = bpScore + sugarScore;
    return score;
  }

  Future<int> fetchSugarStreak(String? userEmail) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final DocumentReference userDocRef =
        firestore.collection('Health_Data').doc(userEmail);
    final QuerySnapshot sugarSnapshot = await userDocRef
        .collection('sugar_readings')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (sugarSnapshot.docs.isEmpty) {
      return 0;
    }

    final Timestamp lastTimestamp = sugarSnapshot.docs.first['timestamp'];
    final DateTime lastDate = lastTimestamp.toDate();
    final DateTime currentDate = DateTime.now();

    final int dayDifference = currentDate
        .difference(
          DateTime(lastDate.year, lastDate.month, lastDate.day),
        )
        .inDays;

    // Fetch current streak and score
    final DocumentSnapshot userSnapshot = await userDocRef.get();
    final data = userSnapshot.data() as Map<String, dynamic>?;

    int currentStreak = data?['sugar_streak'] ?? 0;

    if (dayDifference > 1) {
      currentStreak = 0;
      await userDocRef.set({
        'sugar_streak': currentStreak,
      }, SetOptions(merge: true)); // Streak broken
    }

    return currentStreak;
  }

  Future<int> fetchBPStreak(String? userEmail) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final DocumentReference userDocRef =
        firestore.collection('Health_Data').doc(userEmail);
    final QuerySnapshot bpSnapshot = await userDocRef
        .collection('bp_readings')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (bpSnapshot.docs.isEmpty) {
      return 0;
    }

    final Timestamp lastTimestamp = bpSnapshot.docs.first['timestamp'];
    final DateTime lastDate = lastTimestamp.toDate();
    final DateTime currentDate = DateTime.now();

    final int dayDifference = currentDate
        .difference(
          DateTime(lastDate.year, lastDate.month, lastDate.day),
        )
        .inDays;

    // Fetch current streak and score
    final DocumentSnapshot userSnapshot = await userDocRef.get();
    final data = userSnapshot.data() as Map<String, dynamic>?;

    int currentStreak = data?['bp_streak'] ?? 0;

    if (dayDifference > 1) {
      currentStreak = 0;
      await userDocRef.set({
        'bp_streak': currentStreak,
      }, SetOptions(merge: true)); // Streak broken
    }

    return currentStreak;
  }
}
