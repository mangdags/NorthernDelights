import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:northern_delights_app/models/reviews_doc_data.dart';

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
  final ReviewsDocData _reviewsDocData = ReviewsDocData();
  Future<List<Map<String, dynamic>>>? initialReviewData;

  @override
  void initState() {
    super.initState();
    initialReviewData = fetchInitialReviewData();
  }

  Future<List<Map<String, dynamic>>> fetchInitialReviewData() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection(widget.foodPlaceCategory)
        .doc(widget.foodPlaceID)
        .collection('reviews')
        .get();

    return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: initialReviewData,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        var initialReviewList = snapshot.data!;

        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: _reviewsDocData.fetchReviewsData(widget.foodPlaceID, widget.foodPlaceCategory),
          builder: (context, streamSnapshot) {
            var reviewList = streamSnapshot.hasData
                ? streamSnapshot.data!
                : initialReviewList;

            if(!snapshot.hasData) {
              return Text('No Reviews Yet');
            }

            return SingleChildScrollView(
              child: Column(
                children: reviewList.map((reviews) {
                  return IntrinsicHeight(
                    child: Container(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.9,
                          //maxHeight: reviews['feedback'].toString().length.toDouble() > 100
                          //    ? reviews['feedback'].toString().length.toDouble() /2 : 100,
                      ),
                      margin: const EdgeInsets.all(10),
                      padding: const EdgeInsets.only(left: 10, top: 15, right: 10, bottom: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        color: Colors.blue.shade50,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            offset: Offset(0.0, 4),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.star, color: Colors.yellow.shade800, size: 20),
                                  const SizedBox(width: 5),
                                  Text(
                                    reviews['star'].toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Container(
                                constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context).size.width * 0.78,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 3.0, vertical: 2.0),
                                  child: Text(
                                    reviews['feedback'] ?? 'No feedback',
                                    overflow: TextOverflow.visible,
                                    maxLines: reviews['feedback'].toString().length,
                                    softWrap: true,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Text(
                                    reviews['customer'] ?? 'Anonymous',
                                    textAlign: TextAlign.end,
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(width: 5),
                                  const Text('|'),
                                  const SizedBox(width: 5),
                                  Text(
                                    _formatDate(reviews['datetime']),
                                    textAlign: TextAlign.end,
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10,),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    final utc8Date = date.add(Duration(hours: 8));
    return DateFormat('yyyy-MM-dd hh:mm a').format(utc8Date);
  }
}