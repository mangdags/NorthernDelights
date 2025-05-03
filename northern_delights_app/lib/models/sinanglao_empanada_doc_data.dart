import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

class SinanglaoEmpanadaService {
  Stream<List<Map<String, dynamic>>> getStream(String filter) {
    switch (filter.trim()) {
      case 'Sinanglao':
        final keywordVariants = ['sinanglao', 'sinanglaw', 'sinanglaoan', 'sinanglawan'];
        return SinanglaoStore().getSinanglaoStore(keywordVariants);
      case 'Empanada':
        final keywordVariants = ['empanada', 'empanadaan'];
        return EmpanadaStore().getEmpanadaStore(keywordVariants);
      default:
        final keywordVariants = [''];
        return SinanglaoStore().getSinanglaoStore(keywordVariants);
    }
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