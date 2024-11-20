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
