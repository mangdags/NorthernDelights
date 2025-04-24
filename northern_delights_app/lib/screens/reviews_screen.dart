import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReviewsScreen extends StatelessWidget {
  final String userId;
  final String storeType;

  const ReviewsScreen({
    required this.userId,
    required this.storeType,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final reviewsCollection = FirebaseFirestore.instance
        .collection(storeType)
        .doc(userId)
        .collection('reviews')
        .orderBy('datetime', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Customer Reviews"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: reviewsCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error loading reviews."));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No reviews available."));
          }

          // final reviews = snapshot.data!.docs.toList()
          //   ..sort((a, b) {
          //     final aTime = (a['datetime'] as Timestamp).toDate();
          //     final bTime = (b['datetime'] as Timestamp).toDate();
          //     return bTime.compareTo(aTime); // Sort by full datetime
          //   });

          final reviews = snapshot.data!.docs;

          return ListView.builder(
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index].data() as Map<String, dynamic>;
              final reviewerName = review['customer'] ?? 'Anonymous';
              final foodRating = review['foodRating'] ?? 0.0;
              final serviceRating = review['serviceRating'] ?? 0.0;
              final atmosphereRating = review['atmosphereRating'] ?? 0.0;
              final comment = review['feedback'] ?? 'No comment provided';
              final timestamp = review['datetime'] as Timestamp?;


              final formattedDate = _formatDate(timestamp!);


              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reviewerName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            foodRating.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            serviceRating.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            atmosphereRating.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(comment),
                      const SizedBox(height: 8),
                      if (timestamp != null)
                        Text(
                          "Reviewed on: $formattedDate",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate().toLocal(); // Respect device timezone
    return DateFormat('yyyy-MM-dd hh:mm a').format(date);
  }
}
