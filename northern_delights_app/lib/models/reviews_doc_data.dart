import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewsDocData {
  Stream<List<Map<String, dynamic>>> fetchReviewsData(String id, String category) {
    return FirebaseFirestore.instance
        .collection(category)
        .doc(id)
        .collection('reviews')
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList());
  }
}