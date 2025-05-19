import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:northern_delights_app/screens/direction_screen.dart';

String? restoName;

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

  double? restoLat;
  double? restoLong;

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

  void _incrementViewCount() async {
    try {
      await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(widget.restaurantID)
          .update({
        'resto_view_count': FieldValue.increment(1),
      });
    } catch (e) {
<<<<<<< Updated upstream
      print('Error incrementing view count: $e'); // For debugging only
=======
      print('Error incrementing view count: $e'); //for debugging
>>>>>>> Stashed changes
    }
  }

  void _updateCoordinates(double lat, double long) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        restoLat = lat;
        restoLong = long;
      });
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
<<<<<<< Updated upstream
                      onLocationUpdated: _updateCoordinates, // Pass callback
=======
                      onLocationUpdated: _updateCoordinates,
>>>>>>> Stashed changes
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () {},
                          style: ButtonStyle(
                            foregroundColor:
                            WidgetStateProperty.all(Colors.black),
                            textStyle: WidgetStateProperty.all(
                              TextStyle(fontSize: 20),
                            ),
                          ),
                          child: Text('Overview'),
                        ),
                        TextButton(
                          onPressed: () {},
                          style: ButtonStyle(
                            foregroundColor:
                            WidgetStateProperty.all(Colors.black45),
                            textStyle: WidgetStateProperty.all(
                              TextStyle(fontSize: 18),
                            ),
                          ),
                          child: Text('Menu'),
                        ),
                        TextButton(
                          onPressed: () {},
                          style: ButtonStyle(
                            foregroundColor:
                            WidgetStateProperty.all(Colors.black45),
                            textStyle: WidgetStateProperty.all(
                              TextStyle(fontSize: 18),
                            ),
                          ),
                          child: Text('Review'),
                        ),
                        TextButton(
                          onPressed: () {},
                          style: ButtonStyle(
                            foregroundColor:
                            WidgetStateProperty.all(Colors.black45),
                            textStyle: WidgetStateProperty.all(
                              TextStyle(fontSize: 18),
                            ),
                          ),
                          child: Text('Details'),
                        ),
                      ],
                    ),
<<<<<<< Updated upstream
                    _buildText(restoOverview),
                    SizedBox(height: 200),
=======
                    if (selectedTab == Tab.Overview) _buildText(restoOverview),
                    if (selectedTab == Tab.Menu) _menuDetails(),
                    if (selectedTab == Tab.Review) ... [
                      _reviewDetails(),
                      if(widget.isRegular) ... [
                        const SizedBox(height: 20,),

                        ElevatedButton(onPressed: () => Navigator.push(
                            context, MaterialPageRoute(builder: (context) =>
                            LeaveReviewScreen(collectionType: 'restaurants',restaurantGastropubId: widget.restaurantID)))
                                .then((_) {getUserPoints();
                            }),
                          child: Text('Add Review'),),
                      ],
                    ],
                    const SizedBox(height: 100),
>>>>>>> Stashed changes
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

  Widget _buildFullWidthButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: SizedBox(
        width: (double.infinity) - 100,
        child: ElevatedButton(
          onPressed: () {
            if (restoLat != null && restoLong != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DirectionsMapScreen(
                    destinationLat: restoLat!,
                    destinationLong: restoLong!,
                    destinationName: restoName!,
                  ),
                ),
              );
            } else {
              // Handle case where coordinates are not available
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black, // Change background color
            padding: EdgeInsets.symmetric(
                vertical: 15.0, horizontal: 24.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Direction',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                  color: Colors.white,
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
    required this.onLocationUpdated,
    super.key,
  });

  final String restoID;
  final Function(double lat, double long) onLocationUpdated;

<<<<<<< Updated upstream
=======
  String convertToDateString(TimeOfDay? timeOfDay) {

    if (timeOfDay == null) {
      return '00:00';
    }
    final hours = timeOfDay.hourOfPeriod;
    final minutes = timeOfDay.minute;
    final period = timeOfDay.period == DayPeriod.am ? 'AM' : 'PM';

    return '$hours:${minutes.toString().padLeft(2, '0')} $period';
  }

  TimeOfDay convertToTimeOfDay(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
  }

>>>>>>> Stashed changes
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('restaurants')
          .doc(restoID)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        var resto = snapshot.data!.data() as Map<String, dynamic>;
        double screenWidth = MediaQuery.of(context).size.width;

        GeoPoint geoPoint = resto['resto_geopoint'];
        double lat = geoPoint.latitude;
        double long = geoPoint.longitude;

        onLocationUpdated(lat, long);

<<<<<<< Updated upstream
        return Container(
          margin: EdgeInsets.only(top: 30, left: 20, right: 20),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // Image container
              Container(
                width: screenWidth - 40,
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
=======
        return SafeArea(
          child: Container(
            margin: EdgeInsets.only(top: 30, left: 20, right: 20),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  width: screenWidth! - 40,
                  height: 500,
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
                    child: FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('users').doc(restoID).get(),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }

                        final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                        final imageUrls = userData['image_urls'] as List<dynamic>?;

                        if (imageUrls != null && imageUrls.isNotEmpty) {
                          return CarouselSlider(
                            options: CarouselOptions(
                              height: 500,
                              enlargeCenterPage: true,
                              enableInfiniteScroll: true,
                              viewportFraction: 1.0,
                              autoPlay: true,
                            ),
                            items: imageUrls.map((url) {
                              return CachedNetworkImage(
                                  imageUrl: url,
                                  fit: BoxFit.cover,
                                  width: MediaQuery.of(context).size.width,
                                  errorWidget: (context, url, error) => Container(
                                    alignment: Alignment.center,
                                    color: Colors.grey[200],
                                    child: Image.asset(
                                        'assets/images/store.png',
                                        fit: BoxFit.contain,
                                        width: 220,
                                        height: 350),
                                  ),
                                  placeholder: (context, url) => Center(
                                  child: CircularProgressIndicator())
                              );
                            }).toList(),
                          );
                        } else {
                          return Image.asset(
                            'assets/images/store.png',
                            fit: BoxFit.contain,
                            width: 220,
                            height: 350,
                          );
                        }
                      },
>>>>>>> Stashed changes
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    resto['resto_image_url'],
                    fit: BoxFit.cover,
                    width: 220,
                    height: 300,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.error,
                          size: 220,
                          color: Colors.red,
                        ),
                      );
                    },
                  ),
                ),
              ),
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
                              resto['resto_name'],
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              resto['resto_location'],
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
