import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReviewsDetails extends StatefulWidget {
  const ReviewsDetails({
    required this.foodPlaceID,
    required this.foodPlaceCategory,
    super.key,
  });

  final String foodPlaceID;
  final String foodPlaceCategory;

  @override
  State<ReviewsDetails> createState() => _ReviewsDetailsState();
}

class _ReviewsDetailsState extends State<ReviewsDetails> {
  DocumentSnapshot? lastDocument;
  bool isLoading = false;
  bool hasMore = true; // Flag to check if more data is available
  List<QueryDocumentSnapshot> reviews = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchReviews(); // Initial fetch
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && hasMore) {
        fetchReviews();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void fetchReviews() async {
    if (isLoading || !hasMore) return;

    setState(() => isLoading = true);

    Query query = FirebaseFirestore.instance
        .collection(widget.foodPlaceCategory)
        .doc(widget.foodPlaceID)
        .collection('reviews')
        .limit(50);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument!);
    }

    QuerySnapshot snapshot = await query.get();
    if (snapshot.docs.isNotEmpty) {
      lastDocument = snapshot.docs.last;
      setState(() {
        reviews.addAll(snapshot.docs);
      });
    } else {
      hasMore = false; // No more data to fetch
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: reviews.length + (isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == reviews.length) {
          return Center(child: CircularProgressIndicator());
        }
        var reviewData = reviews[index].data() as Map<String, dynamic>;
        return ListTile(
          title: Text('Star: ${reviewData['star']}'),
          subtitle: Text('Feedback: ${reviewData['feedback']}'),
        );
      },
    );
  }
}


