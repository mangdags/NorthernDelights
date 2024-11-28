import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:northern_delights_app/models/update_average_rating.dart';
import 'package:northern_delights_app/screens/home_screen.dart';

import '../models/review.dart';
import 'gastropub_info_screen.dart';

class LeaveReviewScreen extends StatefulWidget {
  final String restaurantGastropubId;
  final String collectionType;

  const LeaveReviewScreen({Key? key, required this.restaurantGastropubId, required this.collectionType})
      : super(key: key);

  @override
  _LeaveReviewScreenState createState() => _LeaveReviewScreenState();
}

class _LeaveReviewScreenState extends State<LeaveReviewScreen> {
  final TextEditingController _reviewController = TextEditingController();
  final firestore = FirebaseFirestore.instance;

  double _rating = 1.0; //Default to 1
  bool _isSubmitting = false;

  Future<void> _submitReview() async {
    if (_reviewController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a review')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    String userId = FirebaseAuth.instance.currentUser!.uid;

    DocumentSnapshot userDoc = await firestore.collection('users').doc(userId).get();
    if (!userDoc.exists) {
      throw Exception("User document does not exist.");
    }

    String userName = "${userDoc['first_name']} ${userDoc['last_name']}";

    Review review = Review(
      userName: userName,
      reviewText: _reviewController.text,
      rating: _rating,
      dateTime: DateTime.now(),
    );

    try {
      await FirebaseFirestore.instance
          .collection(widget.collectionType)
          .doc(widget.restaurantGastropubId)
          .collection('reviews')
          .add(review.toMap());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted successfully')),
      );


      _reviewController.clear();
      setState(() {
        _rating = 1.0;
      });

      await updateAverageRating(widget.collectionType, widget.restaurantGastropubId);

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error submitting review')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave a Review'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _reviewController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Your Review',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1.0;
                    });
                  },
                );
              }),
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitReview,
              child: _isSubmitting
                  ? const CircularProgressIndicator()
                  : const Text('Submit Review'),
            ),
          ],
        ),
      ),
    );
  }
}
