import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  static Future<String> getSellerName(String uid) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (snapshot.exists) {
        return 'Owner: ${snapshot['first_name']} ${snapshot['last_name']}';
      } else {
        return 'Unknown Seller';
      }
    } catch (e) {
      return 'Unknown Seller';
    }
  }
}
