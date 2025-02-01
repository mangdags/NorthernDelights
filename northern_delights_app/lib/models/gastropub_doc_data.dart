import 'package:cloud_firestore/cloud_firestore.dart';

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

class GastropubService {
  Stream<List<Map<String, dynamic>>> getStream(String filter) {
    switch (filter.trim()) {
      case 'Most Viewed':
        return GastropubMostViewed().getGastropubMostViewed();
      case 'Latest':
        return GastropubLatestAdded().getGastropubLatestAdded();
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