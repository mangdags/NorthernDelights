import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantAllUnsorted {
  Stream<List<Map<String, dynamic>>> getRestaurantData() {
    return FirebaseFirestore.instance.collection('restaurants').snapshots().map(
          (snapshot) {
        return snapshot.docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id; // Attach the document ID to the data
          return data;
        }).toList();
      },
    );
  }
}

class RestaurantMostViewed {
  Stream<List<Map<String, dynamic>>> getRestaurantMostViewed() {
    return FirebaseFirestore.instance
        .collection('restaurants')
        .orderBy('resto_view_count', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Attach the document ID to the data
        return data;
      }).toList();
    });
  }

}

class RestaurantLatestAdded {
  Stream<List<Map<String, dynamic>>> getRestaurantLatestAdded() {
    return FirebaseFirestore.instance
        .collection('restaurants')
        .orderBy('resto_date_added', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Attach the document ID to the data
        return data;
      }).toList();
    });
  }

}

class RestaurantService {
  Stream<List<Map<String, dynamic>>> getStream(String filter) {
    switch (filter.trim()) {
      case 'Most Viewed':
        return RestaurantMostViewed().getRestaurantMostViewed();
      case 'Latest':
        return RestaurantLatestAdded().getRestaurantLatestAdded();
      default:
        return RestaurantAllUnsorted().getRestaurantData();
    }
  }
}
