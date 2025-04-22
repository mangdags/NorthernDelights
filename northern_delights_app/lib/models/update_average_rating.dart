
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> updateAllRatings(String collectionType) async {
  final firestore = FirebaseFirestore.instance;

  try {
    final collectionSnapshot = await firestore.collection(collectionType).get();

    if (collectionSnapshot.docs.isEmpty) {
      return;
    }

    for (final doc in collectionSnapshot.docs) {
      final docId = doc.id;

      await updateAverageRating(collectionType, docId);
    }
  } catch (e) {
    print('Error updating all ratings: $e');
  }
}

Future<void> updateAverageRating(String collectionType, String docId) async {
  final firestore = FirebaseFirestore.instance;

  try {
    final reviewsCollection = firestore
        .collection(collectionType)
        .doc(docId)
        .collection('reviews');

    final querySnapshot = await reviewsCollection.get();

    if (querySnapshot.docs.isEmpty) {
      await firestore.collection(collectionType).doc(docId).update({'rating': 0.00});
      return;
    }

    final starRatings = querySnapshot.docs.map((doc) {
      final food = doc['foodRating'] ?? 0;
      final service = doc['serviceRating'] ?? 0;
      final atmosphere = doc['atmosphereRating'] ?? 0;
      final perReviewAverage = (food + service + atmosphere) / 3;
      return perReviewAverage;
    }).toList();

    final averageRating = starRatings.reduce((a, b) => a + b) / starRatings.length;
    final formattedRating = double.parse(averageRating.toStringAsFixed(1));

    await firestore
        .collection(collectionType)
        .doc(docId)
        .update({'rating': formattedRating});

  } catch (e) {
    print('Error updating rating: $e');
  }
}