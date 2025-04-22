import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

class GastropubAllUnsorted {
  Stream<List<Map<String, dynamic>>> getGastropubData() {
    return FirebaseFirestore.instance.collection('gastropubs').snapshots().map(
          (snapshot) {
        return snapshot.docs.map((doc) {
          var data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
      },
    );
  }
}

class GastropubMostViewed {
  Stream<List<Map<String, dynamic>>> getGastropubMostViewed() {
    return FirebaseFirestore.instance
        .collection('gastropubs')
        .orderBy('view_count', descending: true)
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

class GastropubLatestAdded {
  Stream<List<Map<String, dynamic>>> getGastropubLatestAdded() {
    return FirebaseFirestore.instance
        .collection('gastropubs')
        .orderBy('date_added', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        var data = doc.data();
        data['id'] = doc.id; // Attach the document ID to the data
        return data;
      }).toList();
    });
  }
}

class SinanglaoStore {
  Stream<List<Map<String, dynamic>>> getSinanglaoStore(List<String> keywords) {
    final restaurantsStream = FirebaseFirestore.instance
        .collection('gastropubs')
        .where('search_keywords', arrayContainsAny: keywords)
        .orderBy('date_added', descending: true)
        .snapshots();

    final gastropubsStream = FirebaseFirestore.instance
        .collection('restaurants')
        .where('search_keywords', arrayContainsAny: keywords)
        .orderBy('date_added', descending: true)
        .snapshots();

    return Rx.combineLatest2(
      restaurantsStream,
      gastropubsStream,
          (QuerySnapshot restaurantSnap, QuerySnapshot gastropubSnap) {
        final allDocs = [...restaurantSnap.docs, ...gastropubSnap.docs];
        final result = allDocs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return data;
        }).toList();

        // Optional: sort all results by 'date_added' descending
        result.sort((a, b) => (b['date_added'] as Timestamp)
            .compareTo(a['date_added'] as Timestamp));

        return result;
      },
    );
  }
}


class EmpanadaStore {
  Stream<List<Map<String, dynamic>>> getEmpanadaStore(List<String> keywords) {
    final restaurantsStream = FirebaseFirestore.instance
        .collection('restaurants')
        .where('search_keywords', arrayContainsAny: keywords)
        .orderBy('date_added', descending: true)
        .snapshots();

    final gastropubsStream = FirebaseFirestore.instance
        .collection('gastropubs')
        .where('search_keywords', arrayContainsAny: keywords)
        .orderBy('date_added', descending: true)
        .snapshots();

    return Rx.combineLatest2(
      restaurantsStream,
      gastropubsStream,
          (QuerySnapshot restaurantSnap, QuerySnapshot gastropubSnap) {
        final allDocs = [...restaurantSnap.docs, ...gastropubSnap.docs];
        final result = allDocs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return data;
        }).toList();

        // Optional: sort all results by 'date_added' descending
        result.sort((a, b) => (b['date_added'] as Timestamp)
            .compareTo(a['date_added'] as Timestamp));

        return result;
      },
    );
  }
}


class GastropubService {
  Stream<List<Map<String, dynamic>>> getStream(String filter) {
    switch (filter.trim()) {
      case 'Most Viewed':
        return GastropubMostViewed().getGastropubMostViewed();
      case 'Latest':
        return GastropubLatestAdded().getGastropubLatestAdded();
      case 'Sinanglao':
        final keywordVariants = ['sinanglao', 'sinanglaw', 'sinanglaoan', 'sinanglawan'];
        return SinanglaoStore().getSinanglaoStore(keywordVariants);
      case 'Empanada':
        final keywordVariants = ['empanada', 'empanadaan'];
        return EmpanadaStore().getEmpanadaStore(keywordVariants);
      default:
        return GastropubAllUnsorted().getGastropubData();
    }
  }
}

class GastropubSearch {
  Stream<List<Map<String, dynamic>>> getGastroSearchOr({String? keyword}) async* {
    var keywordLower = keyword?.toLowerCase();

    if (keywordLower == null || keywordLower.isEmpty) {
      yield [];
      return;
    }

    var keywordsQuery = FirebaseFirestore.instance
        .collection('gastropubs')
        .where('search_keywords', arrayContains: keywordLower);

    keywordsQuery.get().then((querySnapshot) {
      for (var doc in querySnapshot.docs) {
        print('Found $keywordLower: ${doc.data()}');
      }
    }).catchError((error) {
      print('Error: $error');
    });

    var keyWordsResults = await keywordsQuery.get();

    final results = <Map<String, dynamic>>{};

    for (var doc in keyWordsResults.docs) {
      var data = doc.data();
      data['id'] = doc.id;
      results.add(data);
    }

    yield results.toList();
  }
}

Future<void> updateKeywordsGastro(String id, String name, List<String> menuKeywords) async {
  try {
    final docRef = FirebaseFirestore.instance.collection('gastropubs').doc(id);

    // Fetch the document
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data() as Map<String, dynamic>;

      final searchKeywords = generateSearchKeywordsGastro(name);

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


Future<List<String>> fetchMenuKeywordsGastro(String docId) async {
  final menuCollection = FirebaseFirestore.instance
      .collection('gastropubs')
      .doc(docId)
      .collection('menu');

  final menuSnapshot = await menuCollection.get();

  List<String> menuKeywords = [];
  for (var menuDoc in menuSnapshot.docs) {
    var menuData = menuDoc.data();

    if (menuData.containsKey('name')) {
      menuKeywords.addAll(generateSearchKeywordsGastro(menuData['name']));
    }
    if (menuData.containsKey('description')) {
      menuKeywords.add(menuData['description'].toLowerCase());
    }
  }

  return menuKeywords;
}


List<String> generateSearchKeywordsGastro(String name) {
  final keywords = <String>{};

  final lowerCaseName = name.toLowerCase();
  final nameParts = lowerCaseName.split(' ');

  // Add all parts and combinations to the keywords set
  keywords.add(lowerCaseName);
  keywords.addAll(nameParts);

  // Return the unique list of keywords
  return keywords.toList();
}

Future<bool> hasGastroResult(String keywordStr) async {
  GastropubSearch gastropubSearch = GastropubSearch();
  var snapshot = await gastropubSearch.getGastroSearchOr(keyword: keywordStr).first;
  return snapshot.isEmpty ? false : true;
}



//DUAL STORES
class GastroRestoAllUnsorted {
  Stream<List<Map<String, dynamic>>> getGastroRestoData() {
    return FirebaseFirestore.instance.collection('gastropubs').where('isDualStore', isEqualTo: true).snapshots().map(
          (snapshot) {
        return snapshot.docs.map((doc) {
          var data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
      },
    );
  }
}

class GastroRestoMostViewed {
  Stream<List<Map<String, dynamic>>> getGastroRestoMostViewed() {
    return FirebaseFirestore.instance
        .collection('gastropubs').where('isDualStore', isEqualTo: true)
        .orderBy('view_count', descending: true)
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

class GastroRestoLatestAdded {
  Stream<List<Map<String, dynamic>>> getGastroRestoLatestAdded() {
    return FirebaseFirestore.instance
        .collection('gastropubs')
        .where('isDualStore', isEqualTo: true)
        .orderBy('date_added', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        var data = doc.data();
        data['id'] = doc.id; // Attach the document ID to the data
        return data;
      }).toList();
    });
  }
}