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
//
//   Future<void> fetchUserData() async {
//     String? role = await fetchRole();
//
//     if (role == 'admin'){
//       userData = await getUserByID('users');
//
//       setState(() {
//         firstName = userData?['first_name'] ?? '';
//         lastName = userData?['last_name'] ?? '';
//         shopName = userData?['shop_name'] ?? '';
//         isAdmin = true;
//         isSeller = false;
//       });
//     } else if (role == 'seller'){
//
//       userData = await getSellerByID('gastropubs');
//       if (userData == null) {
//         userData = await getSellerByID('restaurants');
//         storeType = 'restaurants';
//       }else{
//         storeType = 'gastropubs';
//       }
//
//       if (userData != null) {
//         setState(() {
//           firstName = userData?['first_name'] ?? '';
//           lastName = userData?['last_name'] ?? '';
//           shopName = userData?['shop_name'] ?? '';
//           points = userData?['points'] ?? 0;
//         });
//       } else {
//         setState(() {
//           firstName = '';
//           lastName = '';
//           shopName = '';
//           points = 0;
//
//           return;
//         });
//       }
//       isAdmin = false;
//       isSeller = true;
//     } else {
//       userData = await getUserByID('users');
//
//       setState(() {
//         firstName = userData?['first_name'] ?? '';
//         lastName = userData?['last_name'] ?? '';
//         points = userData?['points'] ?? 0;
//         isAdmin = false;
//
//       });
//     }
//   }
//
//   Future<String> fetchRole() async {
//     try {
//       if (userID!.isEmpty) {
//         print('Error: userId is empty.');
//         return 'err: invalid_userID';
//       }
//
//       DocumentSnapshot snapshot = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(userID)
//           .get();
//
//       if (snapshot.exists) {
//         final data = snapshot.data() as Map<String, dynamic>;
//         if (data['isAdmin'] == true) {
//           return 'admin';
//         } else if (data['isSeller'] == true) {
//           return 'seller';
//         } else {
//           return 'regular';
//         }
//       } else {
//         return 'regular';
//       }
//     } catch (e) {
//       print('Error fetching user role: $e');
//       return 'err: no_role';
//     }
//   }
//
//   Future<Map<String, dynamic>?> getUserByID(String collect) async {
//     try {
//       DocumentSnapshot snapshot = await FirebaseFirestore.instance
//           .collection(collect)
//           .doc(userID)
//           .get();
//
//       return snapshot.exists ? snapshot.data() as Map<String, dynamic> : null;
//
//     } catch (e) {
//       print("Error fetching user data: $e");
//       return null;
//     }
//   }
// }
