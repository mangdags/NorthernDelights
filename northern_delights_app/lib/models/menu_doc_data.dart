import 'package:cloud_firestore/cloud_firestore.dart';

class MenuDocData {
  Stream<List<Map<String, dynamic>>> fetchMenuData(String id, String category) {
    return FirebaseFirestore.instance
        .collection(category)
        .doc(id)
        .collection('menu')
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList());
  }
}