import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:northern_delights_app/models/update_average_rating.dart';
import 'package:image_picker/image_picker.dart';

import '../models/review.dart';

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

  File? _selectedImage;
  String? _imageUrl;
  bool isUploading = false;
  final ImagePicker _imagePicker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

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

    await _uploadImage();

    Review review = Review(
      userName: userName,
      reviewText: _reviewController.text,
      reviewImage: _imageUrl,
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
  Future<void> _uploadImage() async {
    if (_selectedImage == null || isUploading) return;

    setState(() {
      isUploading = true;
    });

    String userId = FirebaseAuth.instance.currentUser!.uid;

    final fileName = '$userId-${widget.restaurantGastropubId}-review.png';
    final storageRef = _storage.ref().child('${widget.collectionType}/reviews/${widget.restaurantGastropubId}/$fileName');

    try {
      final uploadTask = await storageRef.putFile(_selectedImage!);
      final imageUrl = await uploadTask.ref.getDownloadURL();

      setState(() {
        _imageUrl = imageUrl;
      });

      // await firestore.collection(widget.collectionType).doc(userId).update({
      //   'image_url': _imageUrl,
      // });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image uploaded!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image upload failed: $e')),
      );
    } finally{
      setState(() {
        isUploading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
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
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 30,
                backgroundImage: _selectedImage != null
                    ? FileImage(_selectedImage!)
                    : (_imageUrl != null ? NetworkImage(_imageUrl!) as ImageProvider : null),
                child: _selectedImage == null && _imageUrl == null
                    ? const Icon(Icons.camera_alt, size: 25)
                    : null,
              ),
            ),

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
