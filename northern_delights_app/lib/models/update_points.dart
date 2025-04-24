

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> updateUserPoints(double addPoints) async {
  final firestore = FirebaseFirestore.instance;
  final userId = FirebaseAuth.instance.currentUser?.uid;

  if (userId == null) {
    print('User not logged in');
    return;
  }

  try {
    final userDoc = await firestore.collection('users').doc(userId).get();

    if (!userDoc.exists) {
      print('User document does not exist');
      return;
    }

    double currentPoints = userDoc.data()?['points'] ?? 0;
    double newPoints = currentPoints + addPoints;

    await firestore.collection('users').doc(userId).update({'points': newPoints});
    print('User points updated successfully');
  } catch (e) {
    print('Error updating user points: $e');
  }
}

Future<double> getUserPoints() async {
  try {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return 0;

    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    return (snapshot.data() as Map<String, dynamic>)['points']?.toDouble() ?? 0;
  } catch (e) {
    print("Error getting points: $e");
    return 0;
  }
}

