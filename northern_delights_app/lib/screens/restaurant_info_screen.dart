import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:northern_delights_app/models/gastropub_doc_data.dart';
import 'package:northern_delights_app/screens/direction_screen.dart';
import 'package:northern_delights_app/screens/map_screen.dart';

class RestaurantInfo extends StatefulWidget {
  const RestaurantInfo({
    required this.restaurantID,
    super.key,
  });

  final String restaurantID;

  @override
  _RestaurantInfoState createState() => _RestaurantInfoState();
}

class _RestaurantInfoState extends State<RestaurantInfo> {
  final ScrollController _scrollController = ScrollController();
  bool _showCircularButton = false;

  GeoPoint geoPoint = resto['resto_geopoint'];
  double lat = geoPoint.latitude;
  double long = geoPoint.longitude;

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
          .collection('restaurants')
          .doc(widget.restaurantID)
          .update({
        'resto_view_count': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error incrementing view count: $e');
    }
  }

  // Function to update restaurant coordinates
  void _updateCoordinates(double lat, double long) {
    setState(() {
      restoLat = lat;
      restoLong = long;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('restaurants')
                .doc(widget.restaurantID)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              var resto = snapshot.data!.data() as Map<String, dynamic>;
              String restoOverview = resto['resto_overview'] ?? '';

              return SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    FoodPlaceInfoWidget(
                      restoID: widget.restaurantID,
                      onLocationUpdated: _updateCoordinates, // Pass the callback
                    ),
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
                    _buildText(restoOverview), // Use the regular text widget
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
                  child: Icon(
                    Icons.navigation,
                    color: Colors.white,
                  ),
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
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DirectionsMapScreen(
                  destinationLat: restoLat,
                  destinationLong: restoLong,
                ),
              ),
            );
          },
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
              Icon(Icons.navigation, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  // Regular Text Widget
  Widget _buildText(String restoOverview) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Text(
        restoOverview,
        style: TextStyle(
          color: Colors.black87,
          fontSize: 16,
        ),
      ),
    );
  }
}

class FoodPlaceInfoWidget extends StatelessWidget {
  const FoodPlaceInfoWidget({
    required this.restoID,
    required this.onLocationUpdated, // Accept the callback
    super.key,
  });

  final String restoID;
  final Function(double lat, double long) onLocationUpdated; // Callback definition

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('restaurants').doc(restoID).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        var resto = snapshot.data!.data() as Map<String, dynamic>;
        double screenWidth = MediaQuery.of(context).size.width;

        String coordinates = resto['resto_geopoint'].toString();
        List<String> latLng = coordinates.split(", ");
        double lat = double.parse(latLng[0]);
        double long = double.parse(latLng[1]);

        // Call the callback to update the parent widget's state
        onLocationUpdated(lat, long);

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
                    resto['resto_image_url'], // Use the image URL from Firestore
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
                    child: Container(
                      width: 330,
                      height: 110,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.01),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              resto['resto_name'], // Display the restaurant name
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              resto['resto_address'], // Display the restaurant address
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
