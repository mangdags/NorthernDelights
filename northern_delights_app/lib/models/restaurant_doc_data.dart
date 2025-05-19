import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantAllUnsorted {
<<<<<<< Updated upstream
  Stream<List<Map<String, dynamic>>> getRestaurantData() {
    return FirebaseFirestore.instance.collection('restaurants').snapshots().map(
          (snapshot) {
        return snapshot.docs.map((doc) {
          var data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
      },
    );
=======
  Stream<List<Map<String, dynamic>>> getRestaurantData({String? keyword}) {
    CollectionReference restaurants = FirebaseFirestore.instance.collection('restaurants');
    Query query = restaurants;

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
>>>>>>> Stashed changes
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
        var data = doc.data();
        data['id'] = doc.id;
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
        var data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

<<<<<<< Updated upstream
=======
class RestaurantSearch {
  Stream<List<Map<String, dynamic>>> getRestaurantSearchOr({String? keyword}) async* {
    var keywordLower = keyword?.toLowerCase();

    if (keywordLower == null || keywordLower.isEmpty) {
      yield [];
      return;
    }

    //create both queries
    var keywordsQuery = FirebaseFirestore.instance
        .collection('restaurants')
        .where('search_keywords', arrayContains: keywordLower);


    //fetch both query snapshots
    var keyWordsResults = await keywordsQuery.get();
    // var shopNameResults = await shopNameQuery.get();

    //combine results and map to a list of Maps
    final results = <Map<String, dynamic>>{};

    for (var doc in keyWordsResults.docs) {
      var data = doc.data();
      data['id'] = doc.id;
      results.add(data);
    }

    yield results.toList();
  }
>>>>>>> Stashed changes
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
