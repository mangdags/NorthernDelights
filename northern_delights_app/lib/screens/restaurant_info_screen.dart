import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:northern_delights_app/models/user_service.dart';
import 'package:northern_delights_app/screens/direction_screen.dart';
import 'package:northern_delights_app/widgets/menu_widget.dart';
import 'package:northern_delights_app/widgets/reviews_widget.dart';

import '../models/update_points.dart';
import 'leave_review_screen.dart';

enum Tab { Overview, Menu, Review }

double? screenHeight;
double? screenWidth;

late Timestamp openingTime;
late Timestamp closingTime;
late TimeOfDay openTimeOfDay;
late TimeOfDay closeTimeOfDay;

class RestaurantInfo extends StatefulWidget {
  const RestaurantInfo({
    required this.restaurantID,
    required this.isRegular,
    required this.isAdmin,
    super.key,
  });

  final String restaurantID;
  final bool isRegular;
  final bool isAdmin;

  @override
  _RestaurantInfoState createState() => _RestaurantInfoState();
}

class _RestaurantInfoState extends State<RestaurantInfo> {
  final ScrollController _scrollController = ScrollController();
  bool _showCircularButton = false;
  bool _showFullHeight = false;
  Tab selectedTab =Tab.Overview; // default tab

  double? restoLat;
  double? restoLong;
  String? restoName;
  late String _sellerID;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _showCircularButton = _scrollController.offset > 60;
      });
    });
    _incrementViewCount();
  }

  void _incrementViewCount() async {
    try {
      await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(widget.restaurantID)
          .update({
        'view_count': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error incrementing view count: $e'); //for debugging only
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
              String restoOverview = resto['overview'] ?? '';
              restoName = resto['name'];

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
                          onPressed: () => setState(() => selectedTab = Tab.Overview),
                          style: ButtonStyle(
                            foregroundColor: WidgetStateProperty.all(
                                selectedTab == Tab.Overview ? Colors.black : Colors.black45),
                            textStyle: WidgetStateProperty.all(
                              TextStyle(fontSize: selectedTab == Tab.Overview ? 20 : 18),
                            ),
                          ),
                          child: Text('Overview'),
                        ),
                        TextButton(
                          onPressed: () => setState(() => selectedTab = Tab.Menu),
                          style: ButtonStyle(
                            foregroundColor: WidgetStateProperty.all(
                                selectedTab == Tab.Menu ? Colors.black : Colors.black45),
                            textStyle: WidgetStateProperty.all(
                              TextStyle(fontSize: selectedTab == Tab.Menu ? 20 : 18),
                            ),
                          ),
                          child: Text('Menu'),
                        ),
                        TextButton(
                          onPressed: () => setState(() => selectedTab = Tab.Review),
                          style: ButtonStyle(
                            foregroundColor: WidgetStateProperty.all(
                                selectedTab == Tab.Review ? Colors.black : Colors.black45),
                            textStyle: WidgetStateProperty.all(
                              TextStyle(fontSize: selectedTab == Tab.Review ? 20 : 18),
                            ),
                          ),
                          child: Text('Review'),
                        ),
                      ],
                    ),
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
                    const SizedBox(height: 100), //Prevent clipping
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
                    }
                  },
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

  SizedBox _reviewDetails() {
    return SizedBox(
      child: ReviewsDetails(
          foodPlaceID: widget.restaurantID,
          foodPlaceCategory: 'restaurants'
      ),
    );
  }


  SizedBox _menuDetails() {
    return SizedBox(
      height: 600,
      child: MenuDetails(
          foodPlaceID: widget.restaurantID,
          foodPlaceCategory: 'restaurants'
      ),
    );
  }

  Widget _buildFullWidthButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: SizedBox(
        width: double.infinity,
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
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 24.0),
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

  Future<void> updateAverageRating(String docId) async {
    final firestore = FirebaseFirestore.instance;

    try {
      final reviewsCollection = firestore
          .collection('restaurants')
          .doc(docId)
          .collection('reviews');

      final querySnapshot = await reviewsCollection.get();

      if (querySnapshot.docs.isEmpty) {
        await firestore.collection('restaurants').doc(docId).update({'rating': 0.00});
        return;
      }

      final starRatings = querySnapshot.docs.map((doc) {
        final food = doc['foodRating'] ?? 0;
        final service = doc['serviceRating'] ?? 0;
        final atmosphere = doc['atmosphereRating'] ?? 0;
        final perReviewAverage = (food + service + atmosphere) / 3;
        return perReviewAverage;
      }).toList();

      final averageRating = starRatings.reduce((a, b) => a + b) / starRatings.length;
      final formattedRating = double.parse(averageRating.toStringAsFixed(1));

      await firestore
          .collection('restaurants')
          .doc(docId)
          .update({'rating': formattedRating});
    } catch (e) {
      print('Error updating rating: $e');
    }
  }



  Widget _buildText(String restoOverview) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Text(
        restoOverview,
        overflow: TextOverflow.fade,
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

  String convertToDateString(TimeOfDay? timeOfDay) {

    if (timeOfDay == null) {
      return '00:00';
    }
    final hours = timeOfDay.hourOfPeriod; // Gets the hour in 12-hour format
    final minutes = timeOfDay.minute;
    final period = timeOfDay.period == DayPeriod.am ? 'AM' : 'PM';

    return '$hours:${minutes.toString().padLeft(2, '0')} $period';
  }

  TimeOfDay convertToTimeOfDay(Timestamp timestamp) {
    final dateTime = timestamp.toDate();
    return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
  }

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
        screenWidth = MediaQuery
            .of(context)
            .size
            .width;
        screenHeight = MediaQuery
            .of(context)
            .size
            .height;


        openingTime = resto['open_time'];
        closingTime = resto['close_time'];

        openTimeOfDay = convertToTimeOfDay(openingTime);
        closeTimeOfDay = convertToTimeOfDay(closingTime);


        GeoPoint geoPoint = resto['geopoint'];
        double lat = geoPoint.latitude;
        double long = geoPoint.longitude;

        // Call the callback to update the parent widget's state
        onLocationUpdated(lat, long);

        return SafeArea(
          child: Container(
            margin: EdgeInsets.only(top: 30, left: 20, right: 20),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // Image container
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
                    ),
                  ),

                ),

                Positioned(
                  bottom: 15,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                      child: Container(
                        width: 330,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  resto['name'],
                                  style: const TextStyle(
                                    fontSize: 23,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 5,),
                                FutureBuilder<String>(
                                  future: UserService.getSellerName(restoID),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      return Text(snapshot.data!, style: TextStyle(color: Colors.white),);
                                    } else {
                                      return const Text('Unknown', style: TextStyle(color: Colors.white),);
                                    }
                                  },
                                ),
                            
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/icons/location-pin.svg',
                                      height: 20,
                                      width: 20,
                                      colorFilter: ColorFilter.mode(
                                          Colors.white70, BlendMode.srcIn),
                                    ),
                                    SizedBox(width: 5),
                                    Expanded(
                                      child: Text(
                                        overflow: TextOverflow.fade,
                                        maxLines: 2,
                                        resto['location'],
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    const SizedBox(width: 2),
                                    SvgPicture.asset(
                                      'assets/icons/star.svg',
                                      height: 15,
                                      width: 15,
                                      colorFilter: ColorFilter.mode(
                                          Colors.white70, BlendMode.srcIn),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      resto['rating'].toString(),
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    Icon(Icons.access_time_outlined, color: Colors.white70,size: 16),
                            
                                    SizedBox(width: 8),
                                    Text(
                                      convertToDateString(openTimeOfDay),
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '-',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      convertToDateString(closeTimeOfDay),
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
