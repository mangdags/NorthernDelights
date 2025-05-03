import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:northern_delights_app/models/update_points.dart';
import 'package:northern_delights_app/screens/direction_screen.dart';
import 'package:northern_delights_app/screens/leave_review_screen.dart';
import 'package:northern_delights_app/widgets/menu_widget.dart';
import 'package:northern_delights_app/widgets/reviews_widget.dart';

import '../models/user_service.dart';

enum Tab { Overview, Menu, Review }

double? screenHeight;
double? screenWidth;

late Timestamp openingTime;
late Timestamp closingTime;
late TimeOfDay openTimeOfDay;
late TimeOfDay closeTimeOfDay;

class SinanglaoEmpanadaInfo extends StatefulWidget {
  const SinanglaoEmpanadaInfo({
    required this.storeID,
    required this.isRegular,
    required this.isAdmin,
    super.key,
  });

  final String storeID;
  final bool isRegular;
  final bool isAdmin;

  @override
  _SinanglaoEmpanadaInfoState createState() => _SinanglaoEmpanadaInfoState();
}

class _SinanglaoEmpanadaInfoState extends State<SinanglaoEmpanadaInfo> {
  final ScrollController _scrollController = ScrollController();
  bool _showCircularButton = false;
  bool _showFullHeight = false;
  Tab selectedTab =Tab.Overview; // default tab

  double? storeLat;
  double? storeLong;
  String? storeName;
  String? storeType;


  @override
  void initState() {
    super.initState();
    initialize();
    _scrollController.addListener(() {
      setState(() {
        _showCircularButton = _scrollController.offset > 60;
      });
    });
    _incrementViewCount();
  }

  void initialize() async {
    await loadStoreType(); // sets storeType
    updateAverageRating(widget.storeID, storeType!);
  }

  Future<void> _incrementViewCount() async {
    try {
      await FirebaseFirestore.instance
          .collection(storeType!)
          .doc(widget.storeID)
          .update({
        'view_count': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error incrementing view count: $e');
    }
  }


  void _updateCoordinates(double lat, double long) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        storeLat = lat;
        storeLong = long;
      });
    });
  }

  Future<void> loadStoreType() async {
    storeType = await getStoreType();
    setState(() {}); // trigger rebuild if UI depends on storeType
  }


  Future<String> getStoreType() async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.storeID)
        .get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data() as Map<String, dynamic>;
      return data['store_type'] ?? '';
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (storeType == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection(storeType!)
                .doc(widget.storeID)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              var data = snapshot.data!.data();
              if (data == null) {
                return Center(child: Text('No data found.'));
              }

              var sinanglaoempanada = snapshot.data!.data() as Map<String, dynamic>;
              String storeOverview = sinanglaoempanada['overview'] ?? '';
              storeName = sinanglaoempanada['name'];

              return SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    FoodPlaceInfoWidget(
                      storeType: storeType!,
                      storeID: widget.storeID,
                      onLocationUpdated: _updateCoordinates // Pass the callback
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
                    if (selectedTab == Tab.Overview) _buildText(storeOverview),
                    if (selectedTab == Tab.Menu) _menuDetails(storeType!),
                    if (selectedTab == Tab.Review) ... [
                      _reviewDetails(storeType!),
                      if(widget.isRegular && !widget.isAdmin) ... [
                        const SizedBox(height: 20,),


                        ElevatedButton(onPressed: () => Navigator.push(
                            context, MaterialPageRoute(builder: (context) =>
                            LeaveReviewScreen(collectionType: storeType!, restaurantGastropubId: widget.storeID)))
                            .then((_) {
                          getUserPoints();
                        }),
                          child: Text('Add Review'),),
                      ],
                    ],

                    const SizedBox(height: 100),
                    //Prevent clipping
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
                    if (storeLat != null && storeLong != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DirectionsMapScreen(
                            destinationLat: storeLat!,
                            destinationLong: storeLong!,
                            destinationName: storeName!,
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

  SizedBox _reviewDetails(String storeType) {
    return SizedBox(
      child: ReviewsDetails(
        foodPlaceID: widget.storeID,
        foodPlaceCategory: storeType, // <-- use the fetched storeType
      ),
    );
  }

  SizedBox _menuDetails(String storeType) {
    return SizedBox(
      height: 600,
      child: MenuDetails(
        foodPlaceID: widget.storeID,
        foodPlaceCategory: storeType,
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
            if (storeLat != null && storeLong != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DirectionsMapScreen(
                    destinationLat: storeLat!,
                    destinationLong: storeLong!,
                    destinationName: storeName!,
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

  Future<void> updateAverageRating(String docId, String storeType) async {
    final firestore = FirebaseFirestore.instance;

    try {
      final reviewsCollection = firestore
          .collection(storeType)
          .doc(docId)
          .collection('reviews');

      final querySnapshot = await reviewsCollection.get();

      if (querySnapshot.docs.isEmpty) {
        await firestore.collection(storeType).doc(docId).update({'rating': 0.00});
        return;
      }

      final starRatings = querySnapshot.docs.map((doc) {
        final food = doc['foodRating'] ?? 0;
        final service = doc['serviceRating'] ?? 0;
        final atmosphere = doc['atmosphereRating'] ?? 0;
        return (food + service + atmosphere) as num;
      }).toList();

      final averageRating = starRatings.reduce((a, b) => a + b) / starRatings.length;
      final formattedRating = double.parse(averageRating.toStringAsFixed(1));

      await firestore
          .collection(storeType)
          .doc(docId)
          .update({'rating': formattedRating});

    } catch (e) {
      print('Error updating rating: $e');
    }
  }


  Widget _buildText(String sinanglaoempanadaOverview) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Text(
        sinanglaoempanadaOverview,
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
    required this.storeID,
    required this.onLocationUpdated, // Accept the callback
    required this.storeType,
    super.key,
  });

  final String storeID;
  final Function(double lat, double long) onLocationUpdated; // Callback definition
  final String storeType;

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
          .collection(storeType)
          .doc(storeID)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.data == null) {
          return Center(child: Text('No data found.'));
        }

        var store = snapshot.data!.data() as Map<String, dynamic>;
        screenWidth = MediaQuery
            .of(context)
            .size
            .width;
        screenHeight = MediaQuery
            .of(context)
            .size
            .height;


        openingTime = store['open_time'];
        closingTime = store['close_time'];

        openTimeOfDay = convertToTimeOfDay(openingTime);
        closeTimeOfDay = convertToTimeOfDay(closingTime);

        GeoPoint geoPoint = store['geopoint'];
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
                      future: FirebaseFirestore.instance.collection('users').doc(storeID).get(),
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
                                errorWidget: (context, error, stackTrace) => Container(
                                  alignment: Alignment.center,
                                  color: Colors.grey[200],
                                  child: Image.asset(
                                      'assets/images/store.png',
                                      fit: BoxFit.contain,
                                      width: 220,
                                      height: 350),
                                ),
                                placeholder: (context, url) => Center(
                                  child: CircularProgressIndicator(),),
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
                        height: 180,
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
                                  store['name'],
                                  style: const TextStyle(
                                    fontSize: 23,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),

                                const SizedBox(height: 5,),

                                FutureBuilder<String>(
                                  future: UserService.getSellerName(storeID),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      return Text(snapshot.data!, style: TextStyle(color: Colors.white),);
                                    } else {
                                      return const Text('Owner: Unknown', style: TextStyle(color: Colors.white),);
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
                                        store['location'],
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
                                      store['rating'].toString(),
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
