import 'package:cached_network_image/cached_network_image.dart';
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
  double _overallRating = 0.0;

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


// Convert to a list and sort using Dart
    final sortedDocs = querySnapshot.docs.toList()
      ..sort((a, b) {
        final aTime = (a['datetime'] as Timestamp).toDate();
        final bTime = (b['datetime'] as Timestamp).toDate();
        return bTime.compareTo(aTime); // Descending (latest first)
      });


    return sortedDocs.map((doc) => doc.data() as Map<String, dynamic>).toList();
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
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  reviews['reviewimage'] != null && reviews['reviewimage'].toString().isNotEmpty
                                  ? CachedNetworkImage(imageUrl: reviews['reviewimage'],
                                    fit: BoxFit.contain,
                                    alignment: Alignment.center,
                                    width: 150,
                                    height: 150,
                                    errorWidget: (context, url, error) => Container(
                                      alignment: Alignment.center,
                                      child: Image.asset(
                                        'assets/images/review.png',
                                        fit: BoxFit.contain,
                                        alignment: Alignment.center,
                                        width: 60,
                                        height: 60,
                                      ),
                                    ),
                                  )

                                  : Image.asset(
                                    'assets/images/review.png',
                                    fit: BoxFit.contain,
                                    alignment: Alignment.center,
                                    width: 60,
                                    height: 60,
                                  ),
                                  const SizedBox(width: 15,),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Overall: ${(((reviews['foodRating'] ?? 0) + (reviews['serviceRating'] ?? 0) + (reviews['atmosphereRating'] ?? 0)) / 3).toStringAsFixed(1)}',

                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 18,
                                              color: Colors.black,
                                            ),
                                          ),
                                          Icon(Icons.star, color: Colors.yellow.shade800, size: 20),
                                          const SizedBox(width: 5),
                                        ],
                                      ),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Food: ${reviews['foodRating'].toString()}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 14,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),

                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Service: ${reviews['serviceRating'].toString()}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 14,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),

                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Atmosphere: ${reviews['atmosphereRating'].toString()}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 14,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 10),

                                      Text('Comment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),),
                                      Container(
                                        constraints: BoxConstraints(
                                          maxWidth: (MediaQuery.of(context).size.width * 0.78) -140,
                                          maxHeight: 150, // set a reasonable max height for scrolling
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 3.0, vertical: 0.0),
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.vertical,
                                            child: Text(
                                              reviews['feedback'] ?? 'No feedback',
                                              softWrap: true,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.normal,
                                                fontSize: 14,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                    ],
                                  ),
                                ],
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
    final date = timestamp.toDate().toLocal();
    //final utc8Date = date.add(Duration(hours: 8));
    return DateFormat('yyyy-MM-dd hh:mm a').format(date);
  }
}