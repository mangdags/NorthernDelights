import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:northern_delights_app/models/update_average_rating.dart';
import 'package:image_picker/image_picker.dart';
import 'package:northern_delights_app/models/update_points.dart';

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

  double _foodRating = 1.0; //Default to 1
  double _serviceRating = 1.0;
  double _atmosRating = 1.0;

  bool _isSubmitting = false;

  double _points = 3.0;

  Future<void> _submitReview() async {
    if (_reviewController.text.isEmpty) {
      _reviewController.text = "No comment provided";
    } else {
      if(_reviewController.text.length > 100) {
        _points = _points += 25.5;
      } else if(_reviewController.text.length > 30 && _reviewController.text.length < 100) {
        _points = _points += 10.5;
      } else if (_reviewController.text.length < 30 && _reviewController.text.isNotEmpty) {
        _points = _points += 5.5;
      }
    }

    setState(() {
      _isSubmitting = true;
      getUserPoints();
    });

    String userId = FirebaseAuth.instance.currentUser!.uid;

    DocumentSnapshot userDoc = await firestore.collection('users').doc(userId).get();
    if (!userDoc.exists) {
      throw Exception("User document does not exist.");
    }

    String userName = "${userDoc['first_name']} ${userDoc['last_name']}";

    if(_selectedImage != null) {
      _points = _points += 10.5;
    }

    await _uploadImage();

    Review review = Review(
      userName: userName,
      reviewText: _reviewController.text,
      reviewImage: _imageUrl,
      foodRating: _foodRating,
      svcRating: _serviceRating,
      atmosRating: _atmosRating,
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
        _foodRating = 1.0;
        _serviceRating = 1.0;
        _foodRating = 1.0;
      });

      await updateAverageRating(widget.collectionType, widget.restaurantGastropubId);
      await updateUserPoints(_points);

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
        child: SingleChildScrollView(
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
                children: [
                  Text('Food: ', style: TextStyle(fontSize: 16),),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _foodRating
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                        ),
                        onPressed: () {
                          setState(() {
                            _foodRating = index + 1.0;
                          });
                        },
                      );
                    }),
                  ),
                ],
              ),
          
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Service: ', style: TextStyle(fontSize: 16),),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _serviceRating
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                        ),
                        onPressed: () {
                          setState(() {
                            _serviceRating = index + 1.0;
                          });
                        },
                      );
                    }),
                  ),
                ],
              ),
          
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Atmosphere: ', style: TextStyle(fontSize: 16),),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _atmosRating
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                        ),
                        onPressed: () {
                          setState(() {
                            _atmosRating = index + 1.0;
                          });
                        },
                      );
                    }),
                  ),
                ],
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
      ),
    );
  }
}
