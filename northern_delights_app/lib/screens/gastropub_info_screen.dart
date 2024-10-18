import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:northern_delights_app/models/gastropub_doc_data.dart';

class GastropubInfo extends StatefulWidget {
  const GastropubInfo({
    required this.gastropubID,
    super.key,
  });

  final String gastropubID;

  @override
  _GastropubInfoState createState() => _GastropubInfoState();
}

class _GastropubInfoState extends State<GastropubInfo> {
  ScrollController _scrollController = ScrollController();
  bool _showCircularButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset > 60) {
        setState(() {
          _showCircularButton = true;
        });
      } else {
        setState(() {
          _showCircularButton = false;
        });
      }
    });
    _incrementViewCount();
  }

  // For adding view count
  void _incrementViewCount() async {
    try {
      await FirebaseFirestore.instance
          .collection('gastropubs')
          .doc(widget.gastropubID)
          .update({
        'gastro_view_count': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error incrementing view count: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('gastropubs').doc(widget.gastropubID).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              var gastropub = snapshot.data!.data() as Map<String, dynamic>;
              String gastroOverview = gastropub['gastro_overview'] ?? '';

              return SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    FoodPlaceInfoWidget(gastropubID: widget.gastropubID),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () {},
                          style: ButtonStyle(
                            foregroundColor: MaterialStateProperty.all(Colors.black),
                            textStyle: MaterialStateProperty.all(
                              TextStyle(fontSize: 20),
                            ),
                          ),
                          child: Text('Overview'),
                        ),
                        TextButton(
                          onPressed: () {},
                          style: ButtonStyle(
                            foregroundColor: MaterialStateProperty.all(Colors.black45),
                            textStyle: MaterialStateProperty.all(
                              TextStyle(fontSize: 18),
                            ),
                          ),
                          child: Text('Menu'),
                        ),
                        TextButton(
                          onPressed: () {},
                          style: ButtonStyle(
                            foregroundColor: MaterialStateProperty.all(Colors.black45),
                            textStyle: MaterialStateProperty.all(
                              TextStyle(fontSize: 18),
                            ),
                          ),
                          child: Text('Review'),
                        ),
                        TextButton(
                          onPressed: () {},
                          style: ButtonStyle(
                            foregroundColor: MaterialStateProperty.all(Colors.black45),
                            textStyle: MaterialStateProperty.all(
                              TextStyle(fontSize: 18),
                            ),
                          ),
                          child: Text('Details'),
                        ),
                      ],
                    ),
                    _buildText(gastroOverview), // Use the regular text widget
                    SizedBox(height: 200), // Add space to prevent clipping
                  ],
                ),
              );
            },
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: _showCircularButton
                ? Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: FloatingActionButton(
                  backgroundColor: Colors.black,
                  onPressed: () {},
                  child: Icon(Icons.navigation, color: Colors.white,),
                ),
              ),
            )
                : _buildFullWidthButton(),
          ),
        ],
      ),
    );
  }

  // Full-width ElevatedButton
  Widget _buildFullWidthButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: SizedBox(
        width: (double.infinity) - 100,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black, // Change background color
            padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 24.0), // Change padding
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20), // Change border radius
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Direction',
                style: TextStyle(
                  fontSize: 22, // Change font size
                  fontWeight: FontWeight.bold, // Change font weight
                  fontFamily: 'Roboto', // Change font family (make sure it's included in your pubspec.yaml)
                  color: Colors.white, // Change text color
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.navigation, color: Colors.white,),
            ],
          ),
        ),
      ),
    );
  }

  // Regular Text Widget
  Widget _buildText(String gastroOverview) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Text(
        gastroOverview,
        style: TextStyle(
          color: Colors.black87,
          fontSize: 16,
        ),
      ),
    );
  }
}

class FoodPlaceInfoWidget extends StatelessWidget {
  FoodPlaceInfoWidget({required this.gastropubID});

  final String gastropubID;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('gastropubs').doc(gastropubID).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        var gastropub = snapshot.data!.data() as Map<String, dynamic>;
        double screenWidth = MediaQuery.of(context).size.width;

        return Container(
          margin: EdgeInsets.only(top: 30, left: 20, right: 20),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // Image container
              Container(
                width: screenWidth - 40, // Leave space for margin
                height: 450,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      offset: const Offset(0.0, 4),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    gastropub['gastro_image_url'], // Use the image URL from Firestore
                    fit: BoxFit.cover,
                    width: 220,
                    height: 300,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.error, // Fallback if the image can't load
                          size: 220,
                          color: Colors.red,
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Info box aligned to the bottom center of the image
              Positioned(
                bottom: 15,
                child: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                    child: Container(// Padding inside the box
                    width: 330,
                    height: 110,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.01),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    width: 330,
                    height: 110,
                    margin: const EdgeInsets.only(bottom: 5), // Margin from bottom
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          gastropub['gastro_name'],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 3),
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/icons/location-pin.svg',
                              height: 20,
                              width: 20,
                              colorFilter: ColorFilter.mode(Colors.white60, BlendMode.srcIn),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              gastropub['gastro_location'],
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 3),
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/icons/star.svg',
                              colorFilter: ColorFilter.mode(Colors.white70, BlendMode.srcIn),
                              height: 20,
                              width: 20,
                            ),
                            SizedBox(width: 5),
                            Text(
                              gastropub['gastro_rating'].toString(),
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),)),
              ),
              // Back button
              Positioned(
                top: 20,
                left: 20,
                child: GestureDetector(
                  child: Container(
                    alignment: Alignment.center,
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(81, 154, 154, 154),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: SvgPicture.asset(
                      'assets/icons/back_2.svg',
                      height: 20,
                      width: 20,
                      colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
