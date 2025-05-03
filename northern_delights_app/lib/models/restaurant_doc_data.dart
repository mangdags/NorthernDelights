import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:northern_delights_app/models/gastropub_doc_data.dart';
import 'package:rxdart/rxdart.dart';


class RestaurantAllUnsorted {
  Stream<List<Map<String, dynamic>>> getRestaurantData({String? keyword}) {
    CollectionReference restaurants = FirebaseFirestore.instance.collection('restaurants');
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

class RestaurantSearch {
  Stream<List<Map<String, dynamic>>> getRestaurantSearchOr({String? keyword}) async* {
    var keywordLower = keyword?.toLowerCase();

    if (keywordLower == null || keywordLower.isEmpty) {
      yield [];
      return;
    }

    // Create both queries
    var keywordsQuery = FirebaseFirestore.instance
        .collection('restaurants')
        .where('search_keywords', arrayContains: keywordLower);

    // var shopNameQuery = FirebaseFirestore.instance
    //     .collection('restaurants')
    //     .where('name', isEqualTo: keyword);

    // keywordsQuery.get().then((querySnapshot) {
    //   for (var doc in querySnapshot.docs) {
    //     print('Found $keywordLower: ${doc.data()}');
    //   }
    // }).catchError((error) {
    //   print('Error: $error');
    // });

    // Fetch both query snapshots asynchronous
    var keyWordsResults = await keywordsQuery.get();
    // var shopNameResults = await shopNameQuery.get();

    // Combine results and map to a list of Maps
    final results = <Map<String, dynamic>>{};

    for (var doc in keyWordsResults.docs) {
      var data = doc.data();
      data['id'] = doc.id;
      results.add(data); // Add to the set to avoid duplicates
    }

    // for (var doc in shopNameResults.docs) {
    //   var data = doc.data();
    //   data['id'] = doc.id;
    //   results.add(data); // Add to the set to avoid duplicates
    // }

    yield results.toList();
  }
}

class RestaurantService {
  Stream<List<Map<String, dynamic>>> getStream(String filter, {String? keyword}) {
    switch (filter.trim()) {
      case 'Most Viewed':
        final restaurantStream = RestaurantMostViewed().getRestaurantMostViewed(keyword: keyword);
        final gastroRestoStream = GastroRestoMostViewed().getGastroRestoMostViewed();

        return CombineLatestStream.list([
          restaurantStream,
          gastroRestoStream,
        ]).map((lists) {
          return [...lists[0], ...lists[1]];
        });
      case 'Latest':
        final restaurantStream = RestaurantLatestAdded().getRestaurantLatestAdded(keyword: keyword);
        final gastroRestoStream = GastroRestoLatestAdded().getGastroRestoLatestAdded();

        return CombineLatestStream.list([
          restaurantStream,
          gastroRestoStream,
        ]).map((lists) {
          return [...lists[0], ...lists[1]];
        });
      // case 'Sinanglao':
      //   final keywordVariants = ['sinanglao', 'sinanglaw', 'sinanglaoan', 'sinanglawan'];
      //   return SinanglaoStore().getSinanglaoStore(keywordVariants);
      // case 'Empanada':
      //   final keywordVariants = ['empanada', 'empanadaan'];
      //   return EmpanadaStore().getEmpanadaStore(keywordVariants);
      default:
        final restaurantStream = RestaurantAllUnsorted().getRestaurantData(keyword: keyword);
        final gastroRestoStream = GastroRestoAllUnsorted().getGastroRestoData();

        return CombineLatestStream.list([
          restaurantStream,
          gastroRestoStream,
        ]).map((lists) {
          return [...lists[0], ...lists[1]];
        });
    }
  }
}

Future<void> updateKeywordsResto(String id, String name, List<String> menuKeywords) async {
  try {
    final docRef = FirebaseFirestore.instance.collection('restaurants').doc(id);

    // Fetch the document
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data() as Map<String, dynamic>;

      final searchKeywords = generateSearchKeywordsResto(name);

      if (data.containsKey('search_keywords')) {
        final existingKeywords = List<String>.from(data['search_keywords']);
        searchKeywords.addAll(existingKeywords);
      }

      searchKeywords.addAll(menuKeywords);

      // Remove duplicates
      final uniqueKeywords = searchKeywords.toSet().toList();

      // Update the document with new keywords
      await docRef.update({
        'search_keywords': uniqueKeywords,
      });
    } else {
      print('Document with id $id does not exist.');
    }
  } catch (e) {
    print('Failed to update keywords for document $id: $e');
  }
}


Future<List<String>> fetchMenuKeywordsResto(String docId) async {
  final menuCollection = FirebaseFirestore.instance
      .collection('restaurants')
      .doc(docId)
      .collection('menu');

  final menuSnapshot = await menuCollection.get();

  List<String> menuKeywords = [];
  for (var menuDoc in menuSnapshot.docs) {
    var menuData = menuDoc.data();

    if (menuData.containsKey('name')) {
      menuKeywords.addAll(generateSearchKeywordsResto(menuData['name']));
    }
    if (menuData.containsKey('description')) {
      menuKeywords.add(menuData['description'].toLowerCase());
    }
  }

  return menuKeywords;
}


List<String> generateSearchKeywordsResto(String name) {
  final keywords = <String>{};

  final lowerCaseName = name.toLowerCase();
  final nameParts = lowerCaseName.split(' ');

  // Add all parts and combinations to the keywords set
  keywords.add(lowerCaseName);
  keywords.addAll(nameParts);

  // Return the unique list of keywords
  return keywords.toList();
}

Future<bool> hasRestoResult(String keywordStr) async {
  RestaurantSearch restaurantSearch = RestaurantSearch();
  var snapshot = await restaurantSearch.getRestaurantSearchOr(keyword: keywordStr).first;
  return snapshot.isEmpty ? false : true;
}


