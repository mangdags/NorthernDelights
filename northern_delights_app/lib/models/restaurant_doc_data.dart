import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantAllUnsorted {
  Stream<List<Map<String, dynamic>>> getRestaurantData({String? keyword}) {
    CollectionReference restaurants =
    FirebaseFirestore.instance.collection('restaurants');
    Query query = restaurants;

    // Add keyword search filter if provided
    if (keyword != null && keyword.isNotEmpty) {
      query = query
          .where('location', isEqualTo: keyword)
          .where('menu_title', isEqualTo: keyword);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }
}

class RestaurantMostViewed {
  Stream<List<Map<String, dynamic>>> getRestaurantMostViewed({String? keyword}) {
    CollectionReference restaurants =
    FirebaseFirestore.instance.collection('restaurants');
    Query query = restaurants.orderBy('view_count', descending: true);

    if (keyword != null && keyword.isNotEmpty) {
      query = query
          .where('location', isEqualTo: keyword)
          .where('menu_title', isEqualTo: keyword);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }
}

class RestaurantLatestAdded {
  Stream<List<Map<String, dynamic>>> getRestaurantLatestAdded({String? keyword}) {
    CollectionReference restaurants =
    FirebaseFirestore.instance.collection('restaurants');
    Query query = restaurants.orderBy('date_added', descending: true);

    if (keyword != null && keyword.isNotEmpty) {
      query = query
          .where('location', isEqualTo: keyword)
          .where('menu_title', isEqualTo: keyword);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }
}

class RestaurantService {
  Stream<List<Map<String, dynamic>>> getStream(String filter, {String? keyword}) {
    switch (filter.trim()) {
      case 'Most Viewed':
        return RestaurantMostViewed().getRestaurantMostViewed(keyword: keyword);
      case 'Latest':
        return RestaurantLatestAdded().getRestaurantLatestAdded(keyword: keyword);
      default:
        return RestaurantAllUnsorted().getRestaurantData(keyword: keyword);
    }
  }
}
